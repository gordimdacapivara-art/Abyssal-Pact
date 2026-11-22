class_name WorldManager
extends ManagerBase
## WorldManager — Sistema de Conexão, Carregamento e Gestão de Mundo de ABYSSAL PACT.
##
## Integra os quatro continentes (Veyrath, Sylvaran, Khar-Duum, Nhal'Kora), suas 40 regiões
## e a dimensão independente Hell Forge em uma estrutura geográfica navegável.
##
## Responsabilidade:
##   1. Gerenciador de continentes (ContinentManager): 4 continentes, capitais, terminais;
##   2. Gerenciador de regiões (RegionManager): 40 regiões 3D em produção completa;
##   3. Sistema de conexões (WorldConnectionGraph): 41 nós, topologia, rotas terrestres, marítimas e dimensionais;
##   4. Sistema de transições (WorldTransitionSystem): validação de nível, fronteiras e coordenação multiplayer;
##   5. Carregamento de cenas (WorldSceneLoader): suporte síncrono e assíncrono (threaded);
##   6. Descarregamento de regiões: liberação estrita da região anterior (evita manter múltiplos 3D em memória);
##   7. Pontos de entrada: resolução determinística de spawns (gates, portais, default);
##   8. Pontos de saída: gatilhos de fronteira (RegionGate) e transições entre vizinhos;
##   9. Portais: conduítes intercontinentais e travessia da Hell Forge;
##   10. Salvamento da última região: persistência de last_visited_region e last_spawn_marker;
##   11. Controle de região atual: current_region_id, current_region_data e active_region_node;
##   12. Registro de regiões descobertas: tracking persistente em WorldSessionData e CharacterManager.

const KEY: StringName = SystemNames.WORLD

func system_key() -> StringName:
	return KEY

const CONTINENTS_DIR := "res://data/content/continents"
const REGIONS_DIR := "res://data/content/regions"
const HELL_FORGE_RES := "res://data/content/dimension/hell_forge.tres"
const EXPECTED_CONTINENT_COUNT := 4
const EXPECTED_REGION_COUNT := 40
const REGIONS_PER_CONTINENT := 10

## Invariante: hub de ressurgimento obrigatório (HELL_FORGE.md).
const HUB_ID: StringName = Invariants.HUB_REGION_ID

var _continents: Dictionary = {} # String(id) -> ContinentData
var _regions: Dictionary = {} # String(id) -> RegionData
var _hell_forge_data: RegionData = null

const MapNavigationSystemScript = preload("res://core/map_navigation_system.gd")

var _continent_manager: ContinentManager = null
var _region_manager: RegionManager = null
var _connection_graph: WorldConnectionGraph = null
var _scene_loader: WorldSceneLoader = null
var _transition_system: WorldTransitionSystem = null
var _map_system: RefCounted = null

var _session: WorldSessionData = null
var _world_counter := 0

func initialize() -> void:
	super()
	load_catalogs()
	_map_system = MapNavigationSystemScript.new(self)
	_connect_events()

func map_system() -> RefCounted:
	return _map_system

# ------------------------------------------------------------------ CATÁLOGOS --

func load_catalogs() -> bool:
	_continents.clear()
	_regions.clear()
	var issues := PackedStringArray()
	_load_dir(CONTINENTS_DIR, _continents, "continente", issues)
	_load_dir(REGIONS_DIR, _regions, "região", issues)

	# Carrega ou instancia os dados da dimensão Hell Forge
	if ResourceLoader.exists(HELL_FORGE_RES):
		_hell_forge_data = load(HELL_FORGE_RES) as RegionData
	if _hell_forge_data == null:
		_hell_forge_data = _create_fallback_hell_forge_data()

	# Inicializa subsistemas especializados
	_continent_manager = ContinentManager.new(_continents, self)
	_region_manager = RegionManager.new(_regions, self)
	_connection_graph = WorldConnectionGraph.new(true)
	_scene_loader = WorldSceneLoader.new()
	_transition_system = WorldTransitionSystem.new(_connection_graph, _scene_loader, self)

	for region in _values(_regions):
		var reg: RegionData = region as RegionData
		if String(reg.continent_id) != "" and not _continents.has(String(reg.continent_id)):
			issues.append("região '%s' referencia continente ausente '%s'" % [reg.id, reg.continent_id])
		for conn in reg.connections:
			if not _regions.has(String(conn)) and conn != HUB_ID and conn != &"DIM-HELL-FORGE":
				issues.append("região '%s' tem conexão com região inexistente '%s'" % [reg.id, conn])

	if _continents.size() != EXPECTED_CONTINENT_COUNT:
		issues.append("catálogo deve conter exatamente %d continentes (tem %d)" % [EXPECTED_CONTINENT_COUNT, _continents.size()])
	if _regions.size() != EXPECTED_REGION_COUNT:
		issues.append("catálogo deve conter exatamente %d regiões (tem %d)" % [EXPECTED_REGION_COUNT, _regions.size()])

	for c_id in _continents.keys():
		var count := regions_of_continent(StringName(c_id)).size()
		if count != REGIONS_PER_CONTINENT:
			issues.append("continente '%s' deve ter %d regiões (tem %d)" % [c_id, REGIONS_PER_CONTINENT, count])

	if issues.is_empty():
		log_info("Catálogos de mundo carregados: %d continentes, %d regiões + Hell Forge." % [_continents.size(), _regions.size()])
		EventBus.catalog_loaded.emit(&"continents", _continents.size())
		EventBus.catalog_loaded.emit(&"regions", _regions.size())
		return true

	EventBus.catalog_invalid.emit(&"world", issues)
	return false

# ---------------------------------------------------- GERENCIADOR DE CONTINENTES --

func continent_manager() -> ContinentManager:
	return _continent_manager

func has_continent(continent_id: StringName) -> bool:
	return _continent_manager.has_continent(continent_id) if _continent_manager != null else _continents.has(String(continent_id))

func get_continent(continent_id: StringName) -> ContinentData:
	return _continent_manager.get_continent(continent_id) if _continent_manager != null else _continents.get(String(continent_id)) as ContinentData

func continents() -> Array[ContinentData]:
	return _continent_manager.all_continents() if _continent_manager != null else []

func regions_of_continent(continent_id: StringName) -> Array[RegionData]:
	var result: Array[RegionData] = []
	for region in regions():
		if region.continent_id == continent_id:
			result.append(region)
	return result

func capital_of_continent(continent_id: StringName) -> StringName:
	return _continent_manager.capital_of_continent(continent_id) if _continent_manager != null else &""

func terminal_region_of_continent(continent_id: StringName) -> StringName:
	return _continent_manager.terminal_region_of_continent(continent_id) if _continent_manager != null else &""

func is_intercontinental(from_region: StringName, to_region: StringName) -> bool:
	return _continent_manager.is_intercontinental(from_region, to_region) if _continent_manager != null else false

# ------------------------------------------------------ GERENCIADOR DE REGIÕES --

func region_manager() -> RegionManager:
	return _region_manager

func has_region(region_id: StringName) -> bool:
	if region_id == HUB_ID or region_id == &"DIM-HELL-FORGE":
		return true
	return _region_manager.has_region(region_id) if _region_manager != null else _regions.has(String(region_id))

func get_region(region_id: StringName) -> RegionData:
	if region_id == HUB_ID or region_id == &"DIM-HELL-FORGE":
		return _hell_forge_data
	return _region_manager.get_region(region_id) if _region_manager != null else _regions.get(String(region_id)) as RegionData

func regions() -> Array[RegionData]:
	return _region_manager.all_regions() if _region_manager != null else []

func regions_by_biome(biome: String) -> Array[RegionData]:
	return _region_manager.regions_by_biome(biome) if _region_manager != null else []

func regions_by_level_range(min_lvl: int, max_lvl: int) -> Array[RegionData]:
	return _region_manager.regions_by_level_range(min_lvl, max_lvl) if _region_manager != null else []

func get_entry_points(region_id: StringName) -> Array[String]:
	return _region_manager.get_entry_points(region_id) if _region_manager != null else ["default"]

func get_exit_points(region_id: StringName) -> Array[Dictionary]:
	return _region_manager.get_exit_points(region_id) if _region_manager != null else []

func get_portals(region_id: StringName) -> Array[Dictionary]:
	return _region_manager.get_portals(region_id) if _region_manager != null else []

# -------------------------------------------------------- SISTEMA DE CONEXÕES --

func connection_graph() -> WorldConnectionGraph:
	return _connection_graph

func are_connected(from_region: StringName, to_region: StringName) -> bool:
	return _connection_graph.are_connected(from_region, to_region) if _connection_graph != null else false

func can_travel(from_region: StringName, to_region: StringName, player_level: int = 1) -> Dictionary:
	return _connection_graph.can_travel(from_region, to_region, player_level) if _connection_graph != null else {"allowed": true}

func find_shortest_route(from_region: StringName, to_region: StringName) -> Array[StringName]:
	return _connection_graph.find_shortest_path(from_region, to_region) if _connection_graph != null else []

func validate_network_integrity() -> Dictionary:
	return _connection_graph.validate_network_integrity() if _connection_graph != null else {"is_valid": true}

func is_hell_forge_connected(region_id: StringName) -> bool:
	return _connection_graph.is_hell_forge_connected(region_id) if _connection_graph != null else false

# ------------------------------------------------------- SUBSISTEMA DE CENAS --

func scene_loader() -> WorldSceneLoader:
	return _scene_loader

func active_region_node() -> Node3D:
	return _scene_loader.active_region_node() if _scene_loader != null else null

func unload_active_region() -> void:
	if _scene_loader != null:
		_scene_loader.unload_active_region()

# ---------------------------------------------------- SISTEMA DE TRANSIÇÕES --

func transition_system() -> WorldTransitionSystem:
	return _transition_system

## Transição controlada entre regiões ou portais.
func transition_to_region(target_region: StringName, target_spawn: StringName) -> Error:
	if not has_region(target_region):
		return ERR_DOES_NOT_EXIST

	var from_region := current_region_id()
	EventBus.region_transition_requested.emit(from_region, target_region, target_spawn)

	# Se houver sessão multiplayer ativa e o nó local for host, sincroniza RPC
	var net_mgr: MultiplayerManager = get_system(SystemNames.NET) as MultiplayerManager
	if net_mgr == null and has_node("/root/Net"):
		net_mgr = get_node("/root/Net") as MultiplayerManager
	if net_mgr != null and net_mgr.is_session_active() and net_mgr.is_host():
		net_mgr.rpc_sync_region_transition(target_region, target_spawn)

	EventBus.region_transition_started.emit(from_region, target_region)
	var load_err := load_region(target_region, String(target_spawn))
	if load_err != OK:
		EventBus.region_transition_failed.emit(from_region, target_region, load_err)
		return load_err

	EventBus.region_transition_completed.emit(from_region, target_region)
	return OK

# ------------------------------------------------------------ SESSÃO PRIVADA --

func create_private_world(world_name: String, host_participant: int = Invariants.HOST_PEER_ID) -> StringName:
	if _session != null:
		log_warn("Mundo já ativo ('%s'); feche antes de criar outro." % _session.world_id)
		return &""
	if world_name.strip_edges().is_empty():
		return &""
	_world_counter += 1
	_session = WorldSessionData.new()
	_session.world_id = StringName("WORLD-%03d" % _world_counter)
	_session.world_name = world_name.strip_edges()
	_session.host_participant = host_participant
	add_participant(host_participant)
	log_info("Mundo privado criado: %s ('%s')." % [_session.world_id, world_name])
	EventBus.world_created.emit(_session.world_id, host_participant)
	return _session.world_id

func close_private_world() -> Error:
	if _session == null:
		return ERR_UNAVAILABLE
	var world_id := _session.world_id
	unload_active_region()
	_session = null
	log_info("Mundo privado encerrado: %s." % world_id)
	EventBus.world_closed.emit(world_id)
	return OK

func active_world() -> WorldSessionData:
	return _session

func max_participants() -> int:
	return Invariants.MAX_PARTICIPANTS

func add_participant(participant: int) -> Error:
	if _session == null:
		return ERR_UNAVAILABLE
	if _session.has_participant(participant):
		return ERR_ALREADY_IN_USE
	if not _session.can_accept_participant():
		log_warn("Participante %d recusado: limite de %d já ocupado." % [participant, max_participants()])
		EventBus.participant_limit_rejected.emit(_session.world_id, participant)
		return FAILED
	_session.participants.append(participant)
	log_info("Participante %d entrou (%d/%d)." % [participant, _session.participant_count(), max_participants()])
	EventBus.participant_added.emit(_session.world_id, participant)
	return OK

func remove_participant(participant: int) -> Error:
	if _session == null or not _session.has_participant(participant):
		return ERR_DOES_NOT_EXIST
	_session.participants.remove_at(_session.participants.find(participant))
	log_info("Participante %d saiu (%d/%d)." % [participant, _session.participant_count(), max_participants()])
	EventBus.participant_removed.emit(_session.world_id, participant)
	return OK

func enter_region(region_id: StringName) -> Error:
	if _session == null:
		return ERR_UNAVAILABLE
	if not has_region(region_id):
		return ERR_DOES_NOT_EXIST
	_session.region_id = region_id
	_session.last_spawn_marker = "default"
	discover_region(region_id)
	log_info("Região atual: %s." % region_id)
	EventBus.region_entered.emit(region_id)
	return OK

func current_region_id() -> StringName:
	return _session.region_id if _session != null else &""

func current_region_data() -> RegionData:
	return get_region(current_region_id())

func last_visited_region() -> StringName:
	return _session.region_id if _session != null else &""

func last_spawn_marker() -> String:
	return _session.last_spawn_marker if _session != null else "default"

# ------------------------------------------------ CARREGAMENTO E DESCARREGAMENTO --

## Carrega mapa de região sob demanda, descarregando a anterior e posicionando o jogador.
func load_region(region_id: StringName, spawn_marker: String = "default") -> Error:
	if not has_region(region_id):
		return ERR_DOES_NOT_EXIST
	var reg := get_region(region_id)
	if reg == null:
		return ERR_INVALID_DATA

	EventBus.region_load_started.emit(region_id)

	# Atualiza o estado da sessão de mundo
	if _session != null:
		_session.region_id = region_id
		_session.last_spawn_marker = spawn_marker
		_session.discover_region(region_id)

	# Descarrega ambiente 3D anterior (evita múltiplos 3D simultâneos em memória)
	unload_active_region()
	if _scene_loader != null:
		_scene_loader.set_active_region(region_id)

	var scenes := get_system(SystemNames.SCENES)
	if scenes != null and scenes.has_method("change_scene"):
		var cur_scene: String = scenes.call("current_scene_path") if scenes.has_method("current_scene_path") else ""
		if not cur_scene.ends_with("run_tests.tscn"):
			scenes.call("change_scene", reg.scene_path, {
				"region_id": region_id,
				"region_data": reg,
				"spawn_marker": spawn_marker
			})

	if _session != null:
		EventBus.region_entered.emit(region_id)
	_record_character_discovery(&"region", region_id)
	EventBus.region_load_completed.emit(region_id)
	log_info("Região carregada: %s (spawn: %s)." % [region_id, spawn_marker])
	return OK

## Carregamento assíncrono (threaded) com progresso via sinal.
func load_region_async(region_id: StringName, spawn_marker: String = "default", on_progress: Callable = Callable()) -> Error:
	if not has_region(region_id):
		return ERR_DOES_NOT_EXIST
	var reg := get_region(region_id)
	if reg == null:
		return ERR_INVALID_DATA

	EventBus.region_load_started.emit(region_id)

	if _session != null:
		_session.region_id = region_id
		_session.last_spawn_marker = spawn_marker
		_session.discover_region(region_id)

	# Carrega recurso com progresso
	var packed: PackedScene = null
	if _scene_loader != null:
		packed = await _scene_loader.load_scene(reg.scene_path, true, get_tree())
	if packed == null:
		packed = load(reg.scene_path) as PackedScene

	unload_active_region()
	if _scene_loader != null:
		_scene_loader.set_active_region(region_id)

	var scenes := get_system(SystemNames.SCENES)
	if scenes != null and scenes.has_method("change_scene"):
		var cur_scene: String = scenes.call("current_scene_path") if scenes.has_method("current_scene_path") else ""
		if not cur_scene.ends_with("run_tests.tscn"):
			scenes.call("change_scene", reg.scene_path, {
				"region_id": region_id,
				"region_data": reg,
				"spawn_marker": spawn_marker
			})

	if _session != null:
		EventBus.region_entered.emit(region_id)
	_record_character_discovery(&"region", region_id)
	EventBus.region_load_completed.emit(region_id)
	log_info("Região assíncrona carregada: %s (spawn: %s)." % [region_id, spawn_marker])
	return OK

# ----------------------------------------------------- EXPLORAÇÃO E POIS --

func discover_region(region_id: StringName) -> bool:
	if _session == null or not has_region(region_id):
		return false
	var is_new := _session.discover_region(region_id)
	if is_new:
		if _map_system != null:
			_map_system.discover_region(region_id)
		_record_character_discovery(&"region", region_id)
		EventBus.region_discovered.emit(region_id)
		var reg := get_region(region_id)
		var label := reg.display_name if reg != null else String(region_id)
		EventBus.notification_requested.emit("Nova Região Descoberta: %s" % label)
		log_info("Região descoberta: %s." % region_id)
	return is_new

func is_region_discovered(region_id: StringName) -> bool:
	if _session != null and _session.is_region_discovered(region_id):
		return true
	return _map_system.is_region_discovered(region_id) if _map_system != null else false

func get_discovered_regions() -> PackedStringArray:
	return _session.discovered_regions if _session != null else PackedStringArray()

func discover_poi(region_id: StringName, poi_id: StringName) -> bool:
	if _session == null:
		return false
	var reg := get_region(region_id)
	var poi_data := reg.poi_by_id(poi_id) if reg != null else {}
	var is_new := _session.discover_poi(poi_id)
	if is_new:
		if _map_system != null:
			_map_system.discover_poi(region_id, poi_id)
		_record_character_discovery(&"poi", poi_id)
		var poi_name := String(poi_data.get("name", poi_id))
		var poi_type := String(poi_data.get("type", "exploration"))
		var xp := int(poi_data.get("discovery_xp", 50))
		_award_character_xp(xp)
		EventBus.poi_discovered.emit(region_id, poi_id, StringName(poi_type))
		EventBus.notification_requested.emit("Ponto de Interesse Descoberto: %s (+%d XP)" % [poi_name, xp])
		log_info("POI descoberto: %s (%s) em %s." % [poi_id, poi_name, region_id])
	return is_new

func is_poi_discovered(poi_id: StringName) -> bool:
	if _session != null and _session.is_poi_discovered(poi_id):
		return true
	return _map_system.is_poi_discovered(poi_id) if _map_system != null else false

func get_discovered_pois() -> PackedStringArray:
	return _session.discovered_pois if _session != null else PackedStringArray()

func activate_portal(portal_id: StringName) -> bool:
	if _session == null:
		return false
	var is_new := _session.activate_portal(portal_id)
	if is_new:
		EventBus.portal_activated.emit(portal_id)
		EventBus.notification_requested.emit("Portal Ativado para Viagem Rápida!")
		log_info("Portal ativado: %s." % portal_id)
	return is_new

func is_portal_activated(portal_id: StringName) -> bool:
	return _session.is_portal_activated(portal_id) if _session != null else false

## Retorna todos os marcadores estruturados da região (POIs, Gates, Portais).
func get_region_markers(region_id: StringName) -> Array[Dictionary]:
	var markers: Array[Dictionary] = []
	var reg := get_region(region_id)
	if reg == null:
		return markers

	for poi: Dictionary in reg.points_of_interest:
		var p_id := StringName(String(poi.get("id", "")))
		markers.append({
			"id": String(p_id),
			"title": String(poi.get("name", "")),
			"type": String(poi.get("type", "exploration")),
			"position": poi.get("position", Vector3.ZERO),
			"discovered": is_poi_discovered(p_id),
			"description": String(poi.get("description", ""))
		})

	for gate: Dictionary in reg.gates:
		markers.append({
			"id": String(gate.get("gate_id", "")),
			"title": "Fronteira → %s" % String(gate.get("target_region", "")),
			"type": "gate",
			"position": gate.get("position", Vector3.ZERO),
			"discovered": true,
			"target_region": String(gate.get("target_region", ""))
		})

	for port: Dictionary in reg.portals:
		var port_id := StringName(String(port.get("portal_id", "")))
		markers.append({
			"id": String(port_id),
			"title": "Portal → %s" % String(port.get("target_region", "")),
			"type": "portal",
			"position": port.get("position", Vector3.ZERO),
			"discovered": is_portal_activated(port_id),
			"target_region": String(port.get("target_region", ""))
		})

	return markers

# ----------------------------------------------------------- RESSURGIMENTO --

func request_respawn(participant: int) -> Error:
	if _session == null or not _session.has_participant(participant):
		return ERR_DOES_NOT_EXIST
	EventBus.respawn_requested.emit(participant)
	return OK

func resolve_respawn(participant: int) -> StringName:
	if _session != null:
		_session.pending_respawns[str(participant)] = String(HUB_ID)
	log_info("Ressurgimento de %d → %s (invariante)." % [participant, HUB_ID])
	EventBus.respawn_resolved.emit(participant, HUB_ID)
	var net_mgr: MultiplayerManager = get_system(SystemNames.NET) as MultiplayerManager
	if net_mgr == null and has_node("/root/Net"):
		net_mgr = get_node("/root/Net") as MultiplayerManager
	if net_mgr != null and net_mgr.is_host():
		net_mgr.rpc_sync_player_respawn(participant, Vector3.ZERO)
	return HUB_ID

# ------------------------------------------------------------------ INTERNO --

func _connect_events() -> void:
	EventBus.session_hosted.connect(_on_session_hosted)
	EventBus.session_joined.connect(_on_session_joined)
	EventBus.session_left.connect(_on_session_left)
	EventBus.peer_registered.connect(_on_peer_registered)
	EventBus.peer_unregistered.connect(_on_peer_unregistered)
	EventBus.respawn_requested.connect(_on_respawn_requested)

func _on_session_hosted(world_name: String, _port: int) -> void:
	if _session != null:
		return
	create_private_world(world_name)

func _on_session_joined(_address: String, _port: int) -> void:
	if _session == null:
		_world_counter += 1
		_session = WorldSessionData.new()
		_session.world_id = StringName("WORLD-%03d" % _world_counter)
		_session.world_name = "sessao_remota"
		log_info("Mundo local espelhado para sessão remota.")

func _on_session_left(_reason: String) -> void:
	if _session != null:
		close_private_world()

func _on_peer_registered(peer_id: int, _display_name: String) -> void:
	if _session != null:
		add_participant(peer_id)

func _on_peer_unregistered(peer_id: int) -> void:
	if _session != null:
		remove_participant(peer_id)

func _on_respawn_requested(participant: int) -> void:
	resolve_respawn(participant)

func _record_character_discovery(category: StringName, ref_id: StringName) -> void:
	var char_mgr := get_system(SystemNames.CHARACTER)
	if char_mgr != null and char_mgr.has_method("selected_character_id") and char_mgr.has_method("record_discovery"):
		var char_id: StringName = char_mgr.call("selected_character_id")
		if not char_id.is_empty():
			char_mgr.call("record_discovery", char_id, category, ref_id)

func _award_character_xp(amount: int) -> void:
	if amount <= 0:
		return
	var char_mgr := get_system(SystemNames.CHARACTER)
	if char_mgr != null and char_mgr.has_method("selected_character_id") and char_mgr.has_method("add_experience"):
		var char_id: StringName = char_mgr.call("selected_character_id")
		if not char_id.is_empty():
			char_mgr.call("add_experience", char_id, amount)

func _load_dir(dir_path: String, target: Dictionary, label: String, issues: PackedStringArray) -> void:
	if not DirAccess.dir_exists_absolute(dir_path):
		issues.append("diretório ausente: %s" % dir_path)
		return
	for file_name in DirAccess.get_files_at(dir_path):
		if not file_name.ends_with(".tres"):
			continue
		var resource := load(dir_path + "/" + file_name) as Resource
		if resource == null:
			issues.append("falha ao carregar %s" % file_name)
			continue
		var data_id := String(resource.get("id"))
		if data_id.is_empty():
			issues.append("id vazio em %s" % file_name)
			continue
		if target.has(data_id):
			issues.append("%s duplicado: %s" % [label, data_id])
			continue
		target[data_id] = resource

func _create_fallback_hell_forge_data() -> RegionData:
	var hf := RegionData.new()
	hf.id = HUB_ID
	hf.display_name = "Hell Forge"
	hf.continent_id = &"NEXUS"
	hf.scene_path = "res://scenes/world/dimension/hell_forge.tscn"
	hf.status = "full_production"
	hf.biome = "abyssal_forge"
	hf.boundaries = {"radius": 150.0, "center": Vector3.ZERO}
	hf.lighting_profile = {"ambient_color": "#2a1215", "fog_color": "#38181a", "fog_density": 0.01, "sun_color": "#ff7744", "sun_energy": 1.45}
	return hf

func _values(dictionary: Dictionary) -> Array:
	return dictionary.values()

# ---------------------------------------------------------------------- SAVE --

func collect_save_data() -> Dictionary:
	var net_mgr: MultiplayerManager = get_system(SystemNames.NET) as MultiplayerManager
	if net_mgr == null and has_node("/root/Net"):
		net_mgr = get_node("/root/Net") as MultiplayerManager
	# Em sessões multiplayer, apenas o anfitrião tem autoridade para gravar o estado do mundo
	if net_mgr != null and net_mgr.is_session_active() and not net_mgr.is_host():
		return {}
	var dict: Dictionary = {"active_world": _session.to_dict() if _session != null else {}}
	if _map_system != null:
		dict["map_navigation"] = _map_system.collect_save_data()
	return dict

func apply_save_data(data: Dictionary) -> bool:
	_session = null
	var world_data: Dictionary = data.get("active_world", {})
	if _map_system != null and data.has("map_navigation"):
		_map_system.apply_save_data(data.get("map_navigation", {}))
	if world_data.is_empty():
		return true
	_session = WorldSessionData.new()
	if not _session.from_dict(world_data):
		_session = null
		return false
	return true

func verify() -> PackedStringArray:
	var issues := super()
	if _continents.size() != EXPECTED_CONTINENT_COUNT:
		issues.append("catálogo deve conter exatamente %d continentes confirmados" % EXPECTED_CONTINENT_COUNT)
	if _regions.size() != EXPECTED_REGION_COUNT:
		issues.append("catálogo deve conter exatamente %d regiões" % EXPECTED_REGION_COUNT)
	for c_id in _continents.keys():
		var count := regions_of_continent(StringName(c_id)).size()
		if count != REGIONS_PER_CONTINENT:
			issues.append("continente '%s' deve ter %d regiões (tem %d)" % [c_id, REGIONS_PER_CONTINENT, count])
	if String(HUB_ID) != String(Invariants.HUB_REGION_ID):
		issues.append("hub diverge do invariante de produto (Hell Forge)")
	if max_participants() != Invariants.MAX_PARTICIPANTS:
		issues.append("limite de participantes diverge de 8 (anfitrião incluído)")
	if _session != null and _session.participant_count() > max_participants():
		issues.append("mundo ativo excede o limite de participantes")
	return issues
