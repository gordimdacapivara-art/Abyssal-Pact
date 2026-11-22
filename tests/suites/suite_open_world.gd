extends TestCase
## Suite OPEN_WORLD — Sistema de mundo aberto: 4 continentes, 40 regiões (10 por continente),
## região completa de Veyrath (REG-001), carregador modular de regiões, transições,
## limites geográficos, portais, POIs, cidades, masmorras, chefes, exploração e save.

const REGION_001_SCENE := "res://scenes/world/regions/region_001.tscn"
const MODULAR_REGION_SCENE := "res://scenes/world/modular_region.tscn"
const Region001Script := preload("res://scenes/world/regions/region_001.gd")
const ModularRegionScript := preload("res://scenes/world/modular_region.gd")
const CONTINENT_IDS: Array[String] = ["CONT-01", "CONT-02", "CONT-03", "CONT-04"]
const CONTINENT_NAMES := {
	"CONT-01": "Veyrath",
	"CONT-02": "Sylvaran",
	"CONT-03": "Khar-Duum",
	"CONT-04": "Nhal'Kora"
}
const SAVE_SLOT_TEST := 89

func system_label() -> String:
	return "open_world"

func execute() -> void:
	await _test_continents_catalog()
	await _test_regions_catalog_and_identities()
	await _test_complete_region_001_runtime()
	await _test_modular_region_runtime()
	await _test_navigation_and_transitions()
	await _test_exploration_and_discovery_system()
	await _test_exploration_save_persistence()

# ----------------------------------------------------------------- CONTINENTES --

func _test_continents_catalog() -> void:
	section("Catálogo de Continentes: 4 continentes confirmados, exatamente 10 regiões cada")
	var world := system(SystemNames.WORLD) as WorldManager
	check_not_null(world, "WorldManager disponível")
	check_eq(world.continents().size(), 4, "catálogo deve conter exatamente 4 continentes")

	for c_id in CONTINENT_IDS:
		check_true(world.has_continent(StringName(c_id)), "continente deve existir: %s" % c_id)
		var cont := world.get_continent(StringName(c_id))
		check_not_null(cont, "dados do continente %s carregados" % c_id)
		check_eq(cont.display_name, CONTINENT_NAMES[c_id], "nome canônico de %s" % c_id)
		check_false(cont.description.strip_edges().is_empty(), "descrição de %s presente" % c_id)
		check_false(cont.theme.strip_edges().is_empty(), "tema de %s presente" % c_id)
		check_false(cont.climate.strip_edges().is_empty(), "clima de %s presente" % c_id)
		check_false(String(cont.capital_region_id).is_empty(), "capital de %s definida" % c_id)
		check_eq(cont.region_count(), 10, "continente %s deve ter exatamente 10 regiões" % c_id)
		var regions_in_c := world.regions_of_continent(StringName(c_id))
		check_eq(regions_in_c.size(), 10, "regions_of_continent(%s) retorna 10" % c_id)
		check_true(cont.pending_assets.size() > 0, "%s registra assets 3D pendentes" % c_id)

# ------------------------------------------------------------------- REGIÕES --

func _test_regions_catalog_and_identities() -> void:
	section("Catálogo de Regiões: 40 regiões, 10 por continente, biomas e POIs")
	var world := system(SystemNames.WORLD) as WorldManager
	var demons := system(SystemNames.DEMONS) as DemonManager
	var bosses := system(SystemNames.BOSSES) as BossManager
	check_eq(world.regions().size(), 40, "catálogo deve conter exatamente 40 regiões")

	var full_production_count := 0
	var modular_staging_count := 0
	var boss_regions_count := 0
	var total_pois := 0

	for number in range(1, 41):
		var reg_id := StringName("REG-%03d" % number)
		check_true(world.has_region(reg_id), "região %s deve existir" % reg_id)
		var reg := world.get_region(reg_id)
		check_not_null(reg, "dados da região %s carregados" % reg_id)
		check_false(reg.display_name.strip_edges().is_empty(), "%s: nome presente" % reg_id)
		check_false(reg.biome.strip_edges().is_empty(), "%s: bioma definido (%s)" % [reg_id, reg.biome])
		check_true(reg.level_range.x >= 1 and reg.level_range.y >= reg.level_range.x, "%s: faixa de nível válida" % reg_id)

		# Limites e iluminação
		check_true(float(reg.boundaries.get("radius", 0.0)) > 50.0, "%s: raio de limites válido" % reg_id)
		check_true(reg.lighting_profile.has("sun_color"), "%s: iluminação com sun_color" % reg_id)
		check_true(reg.lighting_profile.has("fog_density"), "%s: iluminação com fog_density" % reg_id)

		# Conexões válidas
		check_false(reg.connections.is_empty(), "%s: deve ter conexões geográficas" % reg_id)
		for target_id in reg.connections:
			check_true(world.has_region(StringName(String(target_id))), "%s: conexão %s deve existir" % [reg_id, target_id])

		# POIs estruturados
		check_true(reg.points_of_interest.size() >= 3, "%s: deve ter pelo menos 3 POIs (tem %d)" % [reg_id, reg.points_of_interest.size()])
		check_true(reg.pois_of_type("city").size() >= 1, "%s: deve conter POI de cidade/acampamento" % reg_id)
		check_true(reg.pois_of_type("dungeon").size() >= 1, "%s: deve conter POI de masmorra" % reg_id)
		total_pois += reg.points_of_interest.size()

		# Portais e portões
		check_false(reg.gates.is_empty(), "%s: deve ter portões de fronteira" % reg_id)
		check_false(reg.portals.is_empty(), "%s: deve ter portal arcano" % reg_id)

		# Inimigos vinculados aos dados do DemonManager
		check_eq(reg.enemy_spawns.size(), 5, "%s: deve ter 5 zonas de inimigos (1 para cada demônio)" % reg_id)
		for spawn in reg.enemy_spawns:
			var d_id := StringName(String(spawn.get("demon_id", "")))
			check_true(demons.has_demon(d_id), "%s: demônio de spawn %s existe no catálogo" % [reg_id, d_id])

		# Chefes
		if not reg.boss_encounter_id.is_empty():
			boss_regions_count += 1
			check_true(bosses.has_boss(reg.boss_encounter_id), "%s: chefe %s existe no BossManager" % [reg_id, reg.boss_encounter_id])
			check_false(reg.boss_arena.is_empty(), "%s: chefe deve ter arena de dados" % reg_id)

		# Estado de produção
		if reg.status == "full_production":
			full_production_count += 1
			check_true(String(reg.id).begins_with("REG-0"), "%s em full_production" % reg_id)
			check_true(ResourceLoader.exists(reg.scene_path), "cena dedicada de %s deve existir no disco" % reg_id)
			check_eq(reg.pending_assets.size(), 0, "região full_production não tem pendências imediatas")
		else:
			modular_staging_count += 1
			check_eq(reg.status, "modular_staging", "%s deve estar em modular_staging" % reg_id)
			check_true(reg.pending_assets.size() > 0, "%s deve registrar assets pendentes" % reg_id)

	check_eq(full_production_count, 40, "todas as 40 regiões dos 4 continentes em produção completa 3D (REG-001..REG-040)")
	check_eq(modular_staging_count, 0, "todas as 40 regiões migradas para produção completa")
	check_eq(boss_regions_count, 30, "exatamente 30 regiões abrigam chefes demoníacos")
	check_true(total_pois >= 150, "mais de 150 POIs catalogados no mundo aberto (total: %d)" % total_pois)

# ------------------------------------------------------------- REG-001 VEYRATH --

func _test_complete_region_001_runtime() -> void:
	section("Região completa de Veyrath (REG-001): cena 3D, terreno, cidade, masmorra, chefe")
	var packed := load(REGION_001_SCENE) as PackedScene
	check_not_null(packed, "cena dedicada da região 001 carrega")
	if packed == null:
		return

	var region_node := packed.instantiate() as Node3D
	check_not_null(region_node, "instanciação de REG-001 concluída")
	host.add_child(region_node)

	check_eq(region_node.get_script(), Region001Script, "script canônico region_001.gd")
	var r001: Node = region_node
	check_eq(String(r001.region_id()), "REG-001", "id da cena coincide")
	check_not_null(r001.safe_zone(), "cidade Baluarte das Cinzas possui SafeZone funcional")
	check_true(r001.safe_zone().radius > 15.0, "raio da safe zone adequado")
	check_not_null(r001.boss_arena(), "arena de chefe BOSS-001 instanciada")
	check_eq(String(r001.boss_arena().boss_id), "BOSS-001", "arena associada a BOSS-001")

	# Spawns
	check_not_null(r001.spawn_point("default"), "spawn default presente")
	check_not_null(r001.spawn_point("gate_north"), "spawn gate_north presente")
	check_not_null(r001.spawn_point("gate_south"), "spawn gate_south presente")
	check_not_null(r001.spawn_point("portal_main"), "spawn portal_main presente")

	# Elementos de cenário
	check_not_null(region_node.get_node_or_null("Terrain/MainGround"), "terreno principal presente")
	check_not_null(region_node.get_node_or_null("Terrain/LavaFissure"), "fenda de lava presente")
	check_not_null(region_node.get_node_or_null("WorldBoundary"), "barreira de limites presente")
	check_not_null(region_node.get_node_or_null("Structures/DungeonBasalt"), "Catacumbas de Basalto presente")
	check_not_null(region_node.get_node_or_null("Exploration/MonolithPact"), "Monólito do Primeiro Pacto presente")
	check_not_null(region_node.get_node_or_null("Travel/GateNorth"), "portão norte presente")
	check_not_null(region_node.get_node_or_null("Travel/PortalHellForge"), "portal para Hell Forge presente")

	region_node.queue_free()
	await wait_frames(2)

# ------------------------------------------------------------- MODULAR RUNTIME --

func _test_modular_region_runtime() -> void:
	section("Carregador modular de regiões: construção dinâmica a partir de RegionData de staging")
	var world := system(SystemNames.WORLD) as WorldManager
	var reg31 := world.get_region(&"REG-031")
	check_not_null(reg31, "dados de REG-031 disponíveis como template")

	var packed := load(MODULAR_REGION_SCENE) as PackedScene
	check_not_null(packed, "cena modular de regiões carrega")
	if packed == null:
		return

	var staging_data := RegionData.new()
	staging_data.id = &"REG-STAGING-TEST"
	staging_data.display_name = "Zona de Teste Modular Glacial"
	staging_data.continent_id = &"CONT-04"
	staging_data.biome = "spectral_cliffs"
	staging_data.status = "modular_staging"
	staging_data.pending_assets = PackedStringArray(["model_mesh_staging_a.glb", "model_mesh_staging_b.glb", "model_mesh_staging_c.glb"])
	staging_data.boundaries = reg31.boundaries
	staging_data.lighting_profile = reg31.lighting_profile
	staging_data.points_of_interest = reg31.points_of_interest
	staging_data.gates = reg31.gates
	staging_data.portals = reg31.portals
	staging_data.boss_encounter_id = &"BOSS-024"
	staging_data.boss_arena = {"name": "Arena Modular de Teste", "radius": 20.0}
	staging_data.enemy_spawns = reg31.enemy_spawns

	var modular_node: Node = packed.instantiate()
	check_not_null(modular_node, "instanciação da cena modular concluída")
	check_eq(modular_node.get_script(), ModularRegionScript, "script canônico modular_region.gd")
	host.add_child(modular_node)

	modular_node.setup({"region_data": staging_data})
	check_eq(String(modular_node.region_id()), "REG-STAGING-TEST", "id da região modular configurado")
	check_eq(modular_node.region_data().biome, "spectral_cliffs", "bioma spectral_cliffs aplicado")
	check_true(modular_node.get_pois().size() >= 3, "POIs gerados dinamicamente (total: %d)" % modular_node.get_pois().size())
	check_true(modular_node.get_gates().size() >= 2, "portões de fronteira gerados (total: %d)" % modular_node.get_gates().size())
	check_true(modular_node.get_portals().size() >= 1, "portal gerado dinamicamente")
	check_not_null(modular_node.boss_arena(), "arena de chefe BOSS-024 gerada dinamicamente")
	check_not_null(modular_node.spawn_point("default"), "spawn default criado")
	check_true(staging_data.pending_assets.size() >= 3, "assets pendentes da região registrados explicitamente")

	modular_node.queue_free()
	await wait_frames(2)

# ------------------------------------------------------- NAVEGAÇÃO E TRANSIÇÃO --

func _test_navigation_and_transitions() -> void:
	section("Navegação e Transições de Mundo Aberto: carregamento de mapa e gates")
	var world := system(SystemNames.WORLD) as WorldManager
	world.create_private_world("Mundo de Viagem", Invariants.HOST_PEER_ID)

	var req_capture := capture(EventBus.region_transition_requested)
	var load_started_capture := capture(EventBus.region_load_started)
	var load_comp_capture := capture(EventBus.region_load_completed)
	var entered_capture := capture(EventBus.region_entered)

	# Carga da região 001
	check_err(world.load_region(&"REG-001", "default"), OK, "load_region REG-001 aceito")
	check_eq(String(world.current_region_id()), "REG-001", "região atual é REG-001")
	check_eq(load_started_capture.count(), 1, "evento region_load_started emitido")
	check_eq(load_comp_capture.count(), 1, "evento region_load_completed emitido")
	check_eq(entered_capture.count(), 1, "evento region_entered emitido")

	# Transição para REG-002 via portão
	check_err(world.transition_to_region(&"REG-002", &"gate_south"), OK, "transition_to_region REG-002 aceita")
	check_eq(req_capture.count(), 1, "evento region_transition_requested emitido")
	var req_args: Array = req_capture.first()
	check_eq(String(req_args[0]), "REG-001", "transição partiu de REG-001")
	check_eq(String(req_args[1]), "REG-002", "transição vai para REG-002")
	check_eq(String(req_args[2]), "gate_south", "marcador de chegada é gate_south")
	check_eq(String(world.current_region_id()), "REG-002", "região atual atualizada para REG-002")

	# Recusa de região inválida
	check_err(world.transition_to_region(&"REG-999", &"gate_default"), ERR_DOES_NOT_EXIST, "região inexistente recusa")

	world.close_private_world()

# ---------------------------------------------------- DESCOBERTAS E MARCADORES --

func _test_exploration_and_discovery_system() -> void:
	section("Sistema de Descobertas e Marcadores: POIs, regiões e portais")
	var world := system(SystemNames.WORLD) as WorldManager
	var chars := system(SystemNames.CHARACTER) as CharacterManager
	var char_inst: Resource = chars.create_character("Explorador do Vazio", &"RACE-001", &"SUBRACE-001", &"CLASS-001")
	var char_id: StringName = char_inst.id
	chars.select_character(char_id)

	world.create_private_world("Mundo da Exploração", Invariants.HOST_PEER_ID)
	var reg_disc_capture := capture(EventBus.region_discovered)
	var poi_disc_capture := capture(EventBus.poi_discovered)
	var portal_act_capture := capture(EventBus.portal_activated)

	# Descoberta de região
	check_true(world.discover_region(&"REG-001"), "primeira descoberta de REG-001 retorna true")
	check_false(world.discover_region(&"REG-001"), "descoberta repetida é idempotente (retorna false)")
	check_true(world.is_region_discovered(&"REG-001"), "is_region_discovered retorna true")
	check_eq(reg_disc_capture.count(), 1, "evento region_discovered emitido")

	# Descoberta de POI
	check_true(world.discover_poi(&"REG-001", &"poi_reg-001_city"), "descobrir cidade do Baluarte das Cinzas retorna true")
	check_false(world.discover_poi(&"REG-001", &"poi_reg-001_city"), "descoberta de POI repetida retorna false")
	check_true(world.is_poi_discovered(&"poi_reg-001_city"), "is_poi_discovered retorna true")
	check_eq(poi_disc_capture.count(), 1, "evento poi_discovered emitido")
	var poi_args: Array = poi_disc_capture.first()
	check_eq(String(poi_args[0]), "REG-001", "evento carrega região")
	check_eq(String(poi_args[1]), "poi_reg-001_city", "evento carrega id do POI")
	check_eq(String(poi_args[2]), "city", "evento carrega tipo de POI")

	# Ativação de Portal
	check_true(world.activate_portal(&"portal_reg-001_hub"), "ativar portal retorna true")
	check_false(world.activate_portal(&"portal_reg-001_hub"), "ativar portal repetido retorna false")
	check_true(world.is_portal_activated(&"portal_reg-001_hub"), "is_portal_activated retorna true")
	check_eq(portal_act_capture.count(), 1, "evento portal_activated emitido")

	# Marcadores de mapa
	var markers := world.get_region_markers(&"REG-001")
	check_true(markers.size() >= 5, "região 001 expõe marcadores estruturados (total: %d)" % markers.size())
	var found_city_marker := false
	for m in markers:
		if String(m.get("id", "")) == "poi_reg-001_city":
			found_city_marker = true
			check_true(bool(m.get("discovered", false)), "marcador de cidade reflete status de descoberta")
	check_true(found_city_marker, "marcador da cidade encontrado na lista de marcadores")

	world.close_private_world()
	chars.delete_character(char_id)

# ---------------------------------------------------------- PERSISTÊNCIA SAVE --

func _test_exploration_save_persistence() -> void:
	section("Salvamento de Exploração: persistência de regiões descobertas, POIs e portais")
	var world := system(SystemNames.WORLD) as WorldManager
	var saves := system(SystemNames.SAVE)

	world.create_private_world("Mundo Salvo", Invariants.HOST_PEER_ID)
	world.load_region(&"REG-001", "gate_north")
	world.discover_region(&"REG-001")
	world.discover_region(&"REG-002")
	world.discover_poi(&"REG-001", &"poi_reg-001_city")
	world.discover_poi(&"REG-001", &"poi_reg-001_dung")
	world.activate_portal(&"portal_reg-001_hub")

	# Salva o slot
	check_err(saves.call("save_slot", SAVE_SLOT_TEST), OK, "salvamento do slot de exploração")

	# Fecha o mundo e limpa estado
	world.close_private_world()
	check_null(world.active_world(), "mundo fechado")

	# Carrega o slot
	check_err(saves.call("load_slot", SAVE_SLOT_TEST), OK, "carregamento do slot de exploração")
	var restored := world.active_world()
	check_not_null(restored, "sessão de mundo restaurada")
	check_eq(String(restored.region_id), "REG-001", "região ativa restaurada como REG-001")
	check_eq(restored.last_spawn_marker, "gate_north", "marcador de spawn restaurado")
	check_true(restored.is_region_discovered(&"REG-001"), "REG-001 marcada como descoberta após load")
	check_true(restored.is_region_discovered(&"REG-002"), "REG-002 marcada como descoberta após load")
	check_true(restored.is_poi_discovered(&"poi_reg-001_city"), "POI cidade preservado")
	check_true(restored.is_poi_discovered(&"poi_reg-001_dung"), "POI masmorra preservado")
	check_true(restored.is_portal_activated(&"portal_reg-001_hub"), "portal ativado preservado")

	# Limpeza
	saves.call("delete_slot", SAVE_SLOT_TEST)
	world.close_private_world()
