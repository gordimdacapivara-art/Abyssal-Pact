class_name MapNavigationSystem
extends RefCounted
## MapNavigationSystem — Sistema central de navegação cartográfica e exploração de ABYSSAL PACT.
##
## Responsabilidade:
##   - Carregamento e integração das coordenadas de WORLD_MAP_DATA.json;
##   - Projeção e conversão bidirecional entre coordenadas do mundo 3D e espaço cartográfico normalizado;
##   - Sistema de exploração gradual (Fog of War) em setores por região;
##   - Descoberta e rastreamento de pontos de interesse (POIs), masmorras, chefes e portais;
##   - Gerenciamento de marcadores pessoais e waypoints de usuário;
##   - Rastreamento multiplayer dos integrantes do grupo e compartilhamento de pings;
##   - Integração com objetivos de missões e persistência de dados.

const WORLD_MAP_DATA_PATH := "res://WORLD_MAP_DATA.json"
const SECTOR_GRID_SIZE := 16 # Grade 16x16 de setores por região
const DEFAULT_EXPLORATION_RADIUS := 35.0 # Metros de raio de revelação do jogador
const DEFAULT_REGION_RADIUS := 150.0 # Raio territorial padrão de uma região 3D
const MAX_PERSONAL_MARKERS := 100

var _world_ref: WeakRef = null
var _world_map_data: Dictionary = {}
var _continents: Dictionary = {} # continent_id -> Dictionary
var _regions: Dictionary = {} # region_id -> Dictionary
var _oceans: Dictionary = {} # ocean_id -> Dictionary
var _dimensions: Dictionary = {} # dimension_id -> Dictionary

# Estado de exploração e marcadores
var _explored_sectors: Dictionary = {} # region_id (StringName) -> Dictionary { "x_y": true }
var _discovered_pois: Dictionary = {} # poi_id (StringName) -> bool
var _discovered_regions: Dictionary = {} # region_id (StringName) -> bool
var _personal_markers: Dictionary = {} # marker_id (StringName) -> Dictionary
var _marker_counter: int = 0

# Multiplayer
var _party_member_positions: Dictionary = {} # peer_id (int) -> Dictionary
var _party_pings: Array[Dictionary] = [] # Array de pings ativos

func _init(world_manager: Object = null) -> void:
	if world_manager != null:
		_world_ref = weakref(world_manager)
	_load_world_map_data()
	EventBus.region_discovered.connect(func(r_id: StringName) -> void: _discovered_regions[r_id] = true)
	EventBus.poi_discovered.connect(func(_r_id: StringName, p_id: StringName, _p_type: StringName) -> void: _discovered_pois[p_id] = true)

# -------------------------------------------------------- CARGA DE DADOS GEO --

func _load_world_map_data() -> void:
	if not FileAccess.file_exists(WORLD_MAP_DATA_PATH):
		push_error("MapNavigationSystem: WORLD_MAP_DATA.json não encontrado em %s" % WORLD_MAP_DATA_PATH)
		return

	var file := FileAccess.open(WORLD_MAP_DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("MapNavigationSystem: falha ao abrir WORLD_MAP_DATA.json")
		return

	var json_str := file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(json_str)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("MapNavigationSystem: JSON inválido em WORLD_MAP_DATA.json")
		return

	_world_map_data = parsed as Dictionary
	_continents = _world_map_data.get("continents", {})
	_regions = _world_map_data.get("regions", {})
	_oceans = _world_map_data.get("oceans", {})
	_dimensions = _world_map_data.get("dimensions", {})

func world_map_metadata() -> Dictionary:
	return _world_map_data.get("metadata", {})

func continents_data() -> Dictionary:
	return _continents

func regions_data() -> Dictionary:
	return _regions

func get_region_geo(region_id: StringName) -> Dictionary:
	var key := String(region_id)
	return _regions.get(key, {})

func get_continent_geo(continent_id: StringName) -> Dictionary:
	var key := String(continent_id)
	return _continents.get(key, {})

func get_hell_forge_geo() -> Dictionary:
	var hf: Dictionary = _dimensions.get("hell_forge", _dimensions.get("DIM-HELL-FORGE", {}))
	if hf.is_empty():
		for d in _dimensions.values():
			if d is Dictionary and (d.get("id") == "DIM-HELL-FORGE" or d.get("name") == "Hell Forge"):
				hf = d
				break
	if not hf.is_empty():
		var copy: Dictionary = hf.duplicate(true)
		copy["type"] = "independent_dimension"
		copy["role"] = "respawn_hub_and_nexus"
		return copy
	return {}

func get_central_ocean_geo() -> Dictionary:
	var ocn: Dictionary = _oceans.get("central", _oceans.get("OCEAN-01", {}))
	if ocn.is_empty():
		for o in _oceans.values():
			if o is Dictionary and o.get("name") == "Mar da Cicatriz":
				ocn = o
				break
	return ocn

# ------------------------------------------------ PROJEÇÃO E COORDENADAS 3D --

## Converte coordenadas locais 3D de uma região para coordenadas cartográficas normalizadas [0.0, 1.0] do Mapa-Múndi.
func world_to_world_map_normalized(region_id: StringName, world_pos: Vector3, territory_radius: float = DEFAULT_REGION_RADIUS) -> Vector2:
	var reg_geo := get_region_geo(region_id)
	if reg_geo.is_empty():
		return Vector2(0.5, 0.5)

	var carto: Dictionary = reg_geo.get("cartographic_position", {})
	var center_arr: Array = carto.get("normalized_center", [0.5, 0.5])
	var bbox_arr: Array = carto.get("normalized_bbox", [0.4, 0.4, 0.6, 0.6])

	var cx: float = float(center_arr[0])
	var cy: float = float(center_arr[1])
	var half_w: float = (float(bbox_arr[2]) - float(bbox_arr[0])) * 0.5
	var half_h: float = (float(bbox_arr[3]) - float(bbox_arr[1])) * 0.5

	var rad := maxf(territory_radius, 1.0)
	var norm_x: float = clampf(cx + (world_pos.x / rad) * half_w, 0.0, 1.0)
	var norm_y: float = clampf(cy + (world_pos.z / rad) * half_h, 0.0, 1.0)

	return Vector2(norm_x, norm_y)

## Converte coordenada normalizada [0.0, 1.0] do Mapa-Múndi de volta para posição 3D local na região.
func world_map_normalized_to_world(region_id: StringName, norm_pos: Vector2, territory_radius: float = DEFAULT_REGION_RADIUS) -> Vector3:
	var reg_geo := get_region_geo(region_id)
	if reg_geo.is_empty():
		return Vector3.ZERO

	var carto: Dictionary = reg_geo.get("cartographic_position", {})
	var center_arr: Array = carto.get("normalized_center", [0.5, 0.5])
	var bbox_arr: Array = carto.get("normalized_bbox", [0.4, 0.4, 0.6, 0.6])

	var cx: float = float(center_arr[0])
	var cy: float = float(center_arr[1])
	var half_w: float = maxf((float(bbox_arr[2]) - float(bbox_arr[0])) * 0.5, 0.001)
	var half_h: float = maxf((float(bbox_arr[3]) - float(bbox_arr[1])) * 0.5, 0.001)

	var rad := territory_radius
	var x: float = ((norm_pos.x - cx) / half_w) * rad
	var z: float = ((norm_pos.y - cy) / half_h) * rad

	return Vector3(x, 0.0, z)

## Converte coordenada 3D local para coordenada regional normalizada [-1.0, 1.0] (centro = (0,0)).
func world_to_regional_radar_normalized(world_pos: Vector3, territory_radius: float = DEFAULT_REGION_RADIUS) -> Vector2:
	var rad := maxf(territory_radius, 1.0)
	return Vector2(
		clampf(world_pos.x / rad, -1.0, 1.0),
		clampf(world_pos.z / rad, -1.0, 1.0)
	)

# ---------------------------------------- SISTEMA DE EXPLORAÇÃO & FOG OF WAR --

## Atualiza a exploração baseada na posição 3D atual do jogador na região.
func explore_position(region_id: StringName, world_pos: Vector3, radius: float = DEFAULT_EXPLORATION_RADIUS, territory_radius: float = DEFAULT_REGION_RADIUS) -> Dictionary:
	var newly_explored := 0
	var new_pois: Array[StringName] = []
	var is_first_region_visit := false

	# 1. Marca região como descoberta
	if not is_region_discovered(region_id):
		discover_region(region_id)
		is_first_region_visit = true

	# 2. Atualiza Fog of War (Setores na grade 16x16)
	var reg_sectors: Dictionary = _explored_sectors.get(region_id, {})
	var cell_size: float = (territory_radius * 2.0) / float(SECTOR_GRID_SIZE)

	var min_gx: int = clampi(int(floor((world_pos.x - radius + territory_radius) / cell_size)), 0, SECTOR_GRID_SIZE - 1)
	var max_gx: int = clampi(int(floor((world_pos.x + radius + territory_radius) / cell_size)), 0, SECTOR_GRID_SIZE - 1)
	var min_gz: int = clampi(int(floor((world_pos.z - radius + territory_radius) / cell_size)), 0, SECTOR_GRID_SIZE - 1)
	var max_gz: int = clampi(int(floor((world_pos.z + radius + territory_radius) / cell_size)), 0, SECTOR_GRID_SIZE - 1)

	for gx in range(min_gx, max_gx + 1):
		for gz in range(min_gz, max_gz + 1):
			var sector_key := "%d_%d" % [gx, gz]
			if not reg_sectors.has(sector_key):
				reg_sectors[sector_key] = true
				newly_explored += 1
				EventBus.map_sector_explored.emit(region_id, Vector2i(gx, gz), reg_sectors.size())

	_explored_sectors[region_id] = reg_sectors

	# 3. Descobre POIs e estruturas próximas
	var reg_geo := get_region_geo(region_id)
	var structures: Array = reg_geo.get("structures", [])
	for st in structures:
		var s_name := String(st.get("name", ""))
		var s_id := StringName(s_name.to_lower().replace(" ", "_"))
		if not is_poi_discovered(s_id):
			# Se o jogador estiver na área da estrutura
			var s_rad: float = float(st.get("safe_radius_meters", st.get("arena_radius_meters", 30.0)))
			if world_pos.length() <= radius + s_rad:
				discover_poi(region_id, s_id)
				new_pois.append(s_id)

	return {
		"new_sectors": newly_explored,
		"new_pois": new_pois,
		"is_first_visit": is_first_region_visit,
		"total_explored_sectors": reg_sectors.size(),
		"exploration_ratio": get_region_exploration_percentage(region_id)
	}

func is_sector_explored(region_id: StringName, gx: int, gz: int) -> bool:
	var reg_sectors: Dictionary = _explored_sectors.get(region_id, {})
	return reg_sectors.has("%d_%d" % [gx, gz])

func get_explored_sectors(region_id: StringName) -> Array[Vector2i]:
	var list: Array[Vector2i] = []
	var reg_sectors: Dictionary = _explored_sectors.get(region_id, {})
	for k in reg_sectors.keys():
		var parts := String(k).split("_")
		if parts.size() == 2:
			list.append(Vector2i(parts[0].to_int(), parts[1].to_int()))
	return list

func get_region_exploration_percentage(region_id: StringName) -> float:
	var reg_sectors: Dictionary = _explored_sectors.get(region_id, {})
	var total_sectors: float = float(SECTOR_GRID_SIZE * SECTOR_GRID_SIZE)
	return clampf(float(reg_sectors.size()) / total_sectors, 0.0, 1.0)

func get_continent_exploration_percentage(continent_id: StringName) -> float:
	var cont_geo := get_continent_geo(continent_id)
	var region_ids: Array = cont_geo.get("region_ids", [])
	if region_ids.is_empty():
		return 0.0

	var sum_pct := 0.0
	for rid in region_ids:
		sum_pct += get_region_exploration_percentage(StringName(rid))
	return sum_pct / float(region_ids.size())

func get_world_exploration_percentage() -> float:
	if _regions.is_empty():
		return 0.0
	var sum_pct := 0.0
	for rid in _regions.keys():
		sum_pct += get_region_exploration_percentage(StringName(rid))
	return sum_pct / float(_regions.size())

func discover_region(region_id: StringName) -> bool:
	if _discovered_regions.has(region_id):
		return false
	_discovered_regions[region_id] = true
	return true

func is_region_discovered(region_id: StringName) -> bool:
	return _discovered_regions.has(region_id)

func discover_poi(_region_id: StringName, poi_id: StringName) -> bool:
	if _discovered_pois.has(poi_id):
		return false
	_discovered_pois[poi_id] = true
	return true

func is_poi_discovered(poi_id: StringName) -> bool:
	return _discovered_pois.has(poi_id)

# ------------------------------------------------------- MARCADORES PESSOAIS --

## Adiciona marcador pessoal customizado do jogador.
func add_personal_marker(region_id: StringName, label: String, position_3d: Vector3, icon_type: StringName = &"pin", color: Color = Color.GOLD) -> StringName:
	if _personal_markers.size() >= MAX_PERSONAL_MARKERS:
		push_warning("MapNavigationSystem: limite máximo de %d marcadores atingido." % MAX_PERSONAL_MARKERS)
		return &""

	_marker_counter += 1
	var marker_id := StringName("marker_%s_%d" % [region_id, _marker_counter])
	var marker_data := {
		"id": marker_id,
		"region_id": region_id,
		"label": label.strip_edges() if not label.is_empty() else "Ponto Marcado",
		"position": position_3d,
		"type": icon_type,
		"color": color,
		"created_at": Time.get_unix_time_from_system()
	}

	_personal_markers[marker_id] = marker_data
	EventBus.map_marker_placed.emit(region_id, marker_id, icon_type, position_3d, marker_data["label"])
	return marker_id

func remove_personal_marker(marker_id: StringName) -> bool:
	if not _personal_markers.has(marker_id):
		return false
	_personal_markers.erase(marker_id)
	EventBus.map_marker_removed.emit(marker_id)
	return true

func get_personal_markers(region_id: StringName = &"") -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for m: Dictionary in _personal_markers.values():
		if region_id.is_empty() or m.get("region_id") == region_id:
			list.append(m)
	return list

func clear_personal_markers(region_id: StringName = &"") -> void:
	if region_id.is_empty():
		_personal_markers.clear()
	else:
		var to_erase: Array[StringName] = []
		for mid: StringName in _personal_markers.keys():
			if _personal_markers[mid].get("region_id") == region_id:
				to_erase.append(mid)
		for mid in to_erase:
			_personal_markers.erase(mid)

# ------------------------------------------------- MULTIPLAYER & PARTY PINGS --

## Atualiza a posição de um membro do grupo no mapa.
func update_party_member_position(peer_id: int, region_id: StringName, pos: Vector3, yaw: float) -> void:
	_party_member_positions[peer_id] = {
		"peer_id": peer_id,
		"region_id": region_id,
		"position": pos,
		"yaw": yaw,
		"updated_at": Time.get_ticks_msec()
	}

func remove_party_member(peer_id: int) -> void:
	_party_member_positions.erase(peer_id)

func get_party_member_positions(region_id: StringName = &"") -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for p: Dictionary in _party_member_positions.values():
		if region_id.is_empty() or p.get("region_id") == region_id:
			list.append(p)
	return list

## Registra e distribui um ping de combate/exploração no mapa.
func record_party_ping(sender_peer: int, region_id: StringName, pos: Vector3, ping_type: StringName = &"alert", label: String = "") -> void:
	var ping := {
		"sender_peer": sender_peer,
		"region_id": region_id,
		"position": pos,
		"type": ping_type,
		"label": label if not label.is_empty() else "Atenção Aqui!",
		"timestamp": Time.get_ticks_msec(),
		"duration_ms": 12000 # 12 segundos visível
	}
	_party_pings.append(ping)

func get_active_party_pings(region_id: StringName = &"") -> Array[Dictionary]:
	var now := Time.get_ticks_msec()
	var valid_pings: Array[Dictionary] = []
	for ping in _party_pings:
		if now - int(ping.get("timestamp", 0)) < int(ping.get("duration_ms", 12000)):
			if region_id.is_empty() or ping.get("region_id") == region_id:
				valid_pings.append(ping)
	_party_pings = valid_pings
	return _party_pings

func clear_party_pings() -> void:
	_party_pings.clear()

# ---------------------------------------------------- OBJETIVOS DE MISSÕES --

## Retorna os marcadores de objetivos de missões ativas na região informada.
func get_quest_objective_markers(region_id: StringName, character_id: StringName = &"") -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	var c_id := character_id
	if c_id.is_empty():
		var char_mgr := Game.get_system(SystemNames.CHARACTER) as CharacterManager if Engine.has_singleton("Game") or (_world_ref != null and (_world_ref.get_ref() as Node).has_node("/root/Game")) else null
		if char_mgr != null and char_mgr.selected_character() != null:
			c_id = char_mgr.selected_character().id

	var quest_mgr := Game.get_system(SystemNames.QUESTS) as QuestManager if Engine.has_singleton("Game") or (_world_ref != null and (_world_ref.get_ref() as Node).has_node("/root/Game")) else null
	if quest_mgr == null or c_id.is_empty():
		return list

	var active_quests := quest_mgr.active_quests(c_id)
	for q in active_quests:
		if q.target_region == region_id:
			list.append({
				"id": String(q.id),
				"title": q.title,
				"type": "quest_objective",
				"position": q.target_position,
				"description": q.description
			})
	return list

# --------------------------------------------------------------- SERIALIZAÇÃO --

func collect_save_data() -> Dictionary:
	var sectors_serializable: Dictionary = {}
	for rid in _explored_sectors.keys():
		sectors_serializable[String(rid)] = _explored_sectors[rid].keys()

	var pois_serializable: Array[String] = []
	for pid in _discovered_pois.keys():
		pois_serializable.append(String(pid))

	var regions_serializable: Array[String] = []
	for rid in _discovered_regions.keys():
		regions_serializable.append(String(rid))

	var markers_serializable: Array[Dictionary] = []
	for m in _personal_markers.values():
		var pos: Vector3 = m.get("position", Vector3.ZERO)
		var col: Color = m.get("color", Color.GOLD)
		markers_serializable.append({
			"id": String(m.get("id", "")),
			"region_id": String(m.get("region_id", "")),
			"label": String(m.get("label", "")),
			"position": [pos.x, pos.y, pos.z],
			"type": String(m.get("type", "pin")),
			"color": [col.r, col.g, col.b, col.a]
		})

	return {
		"explored_sectors": sectors_serializable,
		"discovered_pois": pois_serializable,
		"discovered_regions": regions_serializable,
		"personal_markers": markers_serializable,
		"marker_counter": _marker_counter
	}

func apply_save_data(data: Dictionary) -> bool:
	_explored_sectors.clear()
	_discovered_pois.clear()
	_discovered_regions.clear()
	_personal_markers.clear()

	var sectors_dict: Dictionary = data.get("explored_sectors", {})
	for rid_str in sectors_dict.keys():
		var rid := StringName(rid_str)
		var s_dict: Dictionary = {}
		for skey in sectors_dict[rid_str]:
			s_dict[String(skey)] = true
		_explored_sectors[rid] = s_dict

	for pid in data.get("discovered_pois", []):
		_discovered_pois[StringName(String(pid))] = true

	for rid in data.get("discovered_regions", []):
		_discovered_regions[StringName(String(rid))] = true

	for m in data.get("personal_markers", []):
		var mid := StringName(String(m.get("id", "")))
		var pos_arr: Array = m.get("position", [0.0, 0.0, 0.0])
		var col_arr: Array = m.get("color", [1.0, 0.84, 0.0, 1.0])
		_personal_markers[mid] = {
			"id": mid,
			"region_id": StringName(String(m.get("region_id", ""))),
			"label": String(m.get("label", "")),
			"position": Vector3(float(pos_arr[0]), float(pos_arr[1]), float(pos_arr[2])),
			"type": StringName(String(m.get("type", "pin"))),
			"color": Color(float(col_arr[0]), float(col_arr[1]), float(col_arr[2]), float(col_arr[3]))
		}

	_marker_counter = int(data.get("marker_counter", 0))
	return true
