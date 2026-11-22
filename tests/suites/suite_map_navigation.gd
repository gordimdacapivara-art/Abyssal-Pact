class_name SuiteMapNavigation
extends TestCase
## Suite MAP_NAVIGATION — Sistema Completo de Mapas e Navegação de ABYSSAL PACT.

const WorldMapScreenScript = preload("res://scenes/ui/screens/world_map_screen.gd")
const RegionalMapScreenScript = preload("res://scenes/ui/screens/regional_map_screen.gd")
const MinimapHUDScript = preload("res://scenes/ui/hud/minimap_hud.gd")

func system_label() -> String:
	return "map_navigation"

func execute() -> void:
	await _test_world_map_data_and_structure()
	await _test_level_1_world_map_projection_and_routes()
	await _test_level_2_regional_map_all_40_regions()
	await _test_level_3_minimap_hud_radar()
	await _test_gradual_exploration_and_fog_of_war()
	await _test_personal_markers_system()
	await _test_interactive_ui_controls_and_filters()
	await _test_multiplayer_allies_and_shared_pings()
	await _test_map_persistence_and_serialization()

# -------------------------------- 1. DADOS E ESTRUTURA GEOGRÁFICA --

func _test_world_map_data_and_structure() -> void:
	section("1. Estrutura Geográfica: 4 Continentes, Mar da Cicatriz, Hell Forge e 40 Regiões")
	var world := system(SystemNames.WORLD) as WorldManager
	check_not_null(world, "WorldManager disponível")

	var map_sys: RefCounted = world.call("map_system")
	check_not_null(map_sys, "MapNavigationSystem inicializado no WorldManager")

	# Metadados
	var meta: Dictionary = map_sys.world_map_metadata()
	check_eq(int(meta.get("total_continents", 0)), 4, "total de 4 continentes registrado")
	check_eq(int(meta.get("total_regions", 0)), 40, "total de 40 regiões registrado")
	check_eq(String(meta.get("central_ocean", "")), "Mar da Cicatriz", "Oceano Central é 'Mar da Cicatriz'")

	# Continentes
	var conts: Dictionary = map_sys.continents_data()
	check_eq(conts.size(), 4, "exatamente 4 continentes carregados")
	check_true(conts.has("CONT-01"), "continente Veyrath presente (CONT-01)")
	check_true(conts.has("CONT-02"), "continente Sylvaran presente (CONT-02)")
	check_true(conts.has("CONT-03"), "continente Khar-Duum presente (CONT-03)")
	check_true(conts.has("CONT-04"), "continente Nhal'Kora presente (CONT-04)")

	# Hell Forge como dimensão independente
	var hf_geo: Dictionary = map_sys.get_hell_forge_geo()
	check_false(hf_geo.is_empty(), "Hell Forge cadastrada como dimensão")
	check_eq(String(hf_geo.get("type", "")), "independent_dimension", "Hell Forge é dimensão independente")
	check_eq(String(hf_geo.get("role", "")), "respawn_hub_and_nexus", "Hell Forge é Hub de Ressurgimento e Nexus")

	# Oceano Central
	var ocean_geo: Dictionary = map_sys.get_central_ocean_geo()
	check_false(ocean_geo.is_empty(), "Mar da Cicatriz cadastrado")
	check_eq(String(ocean_geo.get("name", "")), "Mar da Cicatriz", "Nome canônico do oceano correto")

# -------------------------------- 2. NÍVEL 1 — MAPA-MÚNDI --

func _test_level_1_world_map_projection_and_routes() -> void:
	section("2. Nível 1 (Mapa-Múndi): Coordenadas normalizadas, limites, rotas e portais")
	var world := system(SystemNames.WORLD) as WorldManager
	var map_sys: RefCounted = world.call("map_system")

	# Tela de Mapa-Múndi
	var screen: Control = WorldMapScreenScript.new()
	host.add_child(screen)
	screen.open()
	check_eq(String(screen.screen_id), "world_map", "WorldMapScreen abre como world_map")

	# Validação de projeção 3D para Mapa-Múndi [0.0, 1.0]
	var norm_center: Vector2 = map_sys.world_to_world_map_normalized(&"REG-001", Vector3.ZERO)
	check_true(norm_center.x >= 0.0 and norm_center.x <= 1.0, "X normalizado no intervalo [0, 1]")
	check_true(norm_center.y >= 0.0 and norm_center.y <= 1.0, "Y normalizado no intervalo [0, 1]")

	# Ponto extremo leste na região desloca X positivamente no mapa
	var norm_east: Vector2 = map_sys.world_to_world_map_normalized(&"REG-001", Vector3(100.0, 0, 0))
	check_true(norm_east.x > norm_center.x, "Deslocamento leste no 3D reflete aumento de X no Mapa-Múndi")

	# Projeção inversa (Mapa -> 3D)
	var recon_3d: Vector3 = map_sys.world_map_normalized_to_world(&"REG-001", norm_east)
	check_true(recon_3d.x > 50.0, "Projeção inversa recupera coordenada 3D coerente")

	# Verificação de Conduítes para Hell Forge nas Capitais
	var reg001: Dictionary = map_sys.get_region_geo(&"REG-001")
	var conns: Dictionary = reg001.get("connections", {})
	var portals: Array = conns.get("dimensional_portals", [])
	check_true(portals.size() >= 1, "REG-001 possui conduíte permanente para Hell Forge")

	# Rotas marítimas pelo Mar da Cicatriz
	var m_routes: Array = conns.get("maritime_routes", [])
	check_true(m_routes.size() >= 1, "REG-001 possui conexões navais pelo Mar da Cicatriz")

	screen.queue_free()
	await wait_frames(1)

# -------------------------------- 3. NÍVEL 2 — MAPA REGIONAL --

func _test_level_2_regional_map_all_40_regions() -> void:
	section("3. Nível 2 (Mapa Regional): Terreno, relevo, limites naturais, masmorras, chefes e POIs")
	var world := system(SystemNames.WORLD) as WorldManager
	var map_sys: RefCounted = world.call("map_system")
	var regions: Dictionary = map_sys.regions_data()

	check_eq(regions.size(), 40, "todas as 40 regiões presentes no mapa regional")

	# Amostragem das 4 regiões inaugurais de cada continente
	var test_rids := [&"REG-001", &"REG-011", &"REG-021", &"REG-031"]
	for rid in test_rids:
		var r_geo: Dictionary = map_sys.get_region_geo(rid)
		check_false(r_geo.is_empty(), "região %s possui dados geográficos" % String(rid))

		# Limites naturais
		var terrain: Dictionary = r_geo.get("terrain", {})
		var nat_bounds: Dictionary = terrain.get("natural_boundaries", {})
		check_true(nat_bounds.has("north"), "%s possui limite norte" % String(rid))
		check_true(nat_bounds.has("south"), "%s possui limite sul" % String(rid))
		check_true(nat_bounds.has("east"), "%s possui limite leste" % String(rid))
		check_true(nat_bounds.has("west"), "%s possui limite oeste" % String(rid))

		# Perfil de elevação
		var elev: Dictionary = r_geo.get("elevation_profile_meters", {})
		check_true(int(elev.get("max", 0)) >= int(elev.get("min", 0)), "%s elevação coerente" % String(rid))

		# Estruturas e Masmorras
		var structs: Array = r_geo.get("structures", [])
		check_true(structs.size() >= 2, "%s possui estruturas e POIs catalogados (tem %d)" % [String(rid), structs.size()])

	# Tela de Mapa Regional
	var screen: Control = RegionalMapScreenScript.new()
	host.add_child(screen)
	screen.open({"region_id": &"REG-001"})
	check_eq(String(screen.screen_id), "regional_map", "RegionalMapScreen abre como regional_map")

	var all_markers: Array[Dictionary] = screen.get_all_regional_markers()
	check_true(all_markers.size() >= 3, "Marcadores consolidados da região >= 3 (tem %d)" % all_markers.size())

	screen.queue_free()
	await wait_frames(1)

# -------------------------------- 4. NÍVEL 3 — MINIMAPA HUD --

func _test_level_3_minimap_hud_radar() -> void:
	section("4. Nível 3 (Minimapa HUD): Tracking do jogador, orientação (yaw), estruturas e radar")
	var minimap: Control = MinimapHUDScript.new()
	host.add_child(minimap)
	await wait_frames(1)

	check_not_null(minimap, "MinimapHUD instanciado com sucesso")
	check_eq(minimap.radar_range_meters, 120.0, "alcance inicial do radar é 120m")

	# Simula tracking do jogador
	minimap.set_mock_player_tracking(Vector3(45.0, 0, -30.0), 1.57, &"REG-001")
	check_eq(minimap._player_pos, Vector3(45.0, 0, -30.0), "posição do jogador sincronizada")
	check_eq(minimap._player_yaw, 1.57, "orientação angular (yaw) registrada")

	# Ajuste de Zoom do Minimapa
	var cap_zoom := capture(EventBus.minimap_zoom_changed)
	minimap._on_zoom_in_pressed()
	check_true(minimap.radar_range_meters < 120.0, "zoom in reduz alcance em metros (aumenta detalhe)")
	check_eq(cap_zoom.count(), 1, "sinal minimap_zoom_changed emitido")

	minimap._on_zoom_out_pressed()
	minimap._on_zoom_out_pressed()
	check_true(minimap.radar_range_meters > 100.0, "zoom out amplia alcance do radar")

	# Clamping de limites do radar
	minimap.set_radar_range(10.0)
	check_eq(minimap.radar_range_meters, minimap.min_range, "radar respeita min_range (60m)")

	minimap.set_radar_range(1000.0)
	check_eq(minimap.radar_range_meters, minimap.max_range, "radar respeita max_range (250m)")

	minimap.queue_free()
	await wait_frames(1)

# -------------------------------- 5. SISTEMA DE EXPLORAÇÃO & FOG OF WAR --

func _test_gradual_exploration_and_fog_of_war() -> void:
	section("5. Sistema de Exploração: Névoa (Fog of War) em setores 16x16 e descoberta progressiva")
	var world := system(SystemNames.WORLD) as WorldManager
	var map_sys: RefCounted = world.call("map_system")

	# Estado inicial sem exploração
	map_sys.apply_save_data({})
	var ratio_init: float = map_sys.get_region_exploration_percentage(&"REG-001")
	check_eq(ratio_init, 0.0, "região inicia com 0% explorado")

	# Explora centro da região
	var cap_sector := capture(EventBus.map_sector_explored)
	var exp_res: Dictionary = map_sys.explore_position(&"REG-001", Vector3.ZERO, 35.0)
	check_true(int(exp_res.get("new_sectors", 0)) > 0, "novos setores revelados na posição inicial")
	check_true(cap_sector.count() > 0, "sinal map_sector_explored emitido para cada setor")
	check_true(map_sys.is_region_discovered(&"REG-001"), "REG-001 marcada como descoberta")

	var ratio_mid: float = map_sys.get_region_exploration_percentage(&"REG-001")
	check_true(ratio_mid > 0.0, "percentual de exploração regional aumentou (> 0%)")

	# Explora extremidade leste
	map_sys.explore_position(&"REG-001", Vector3(120.0, 0, 80.0), 40.0)
	var ratio_final: float = map_sys.get_region_exploration_percentage(&"REG-001")
	check_true(ratio_final > ratio_mid, "exploração em novo setor amplia o percentual descoberto")

	# Percentual continental e global
	var cont_ratio: float = map_sys.get_continent_exploration_percentage(&"CONT-01")
	check_true(cont_ratio > 0.0, "percentual do continente Veyrath reflete a exploração de REG-001")

	var world_ratio: float = map_sys.get_world_exploration_percentage()
	check_true(world_ratio > 0.0, "percentual global reflete a exploração das regiões")

# -------------------------------- 6. MARCADORES PESSOAIS --

func _test_personal_markers_system() -> void:
	section("6. Marcadores Pessoais: Adição, filtragem, remoção e limite de marcadores")
	var world := system(SystemNames.WORLD) as WorldManager
	var map_sys: RefCounted = world.call("map_system")
	map_sys.clear_personal_markers()

	var cap_placed := capture(EventBus.map_marker_placed)
	var cap_removed := capture(EventBus.map_marker_removed)

	# Adiciona marcador pessoal
	var mid1: StringName = map_sys.add_personal_marker(&"REG-001", "Acampamento Secreto", Vector3(25.0, 0, -40.0), &"camp", Color.GREEN)
	check_false(mid1.is_empty(), "marcador 1 criado com ID válido")
	check_eq(cap_placed.count(), 1, "sinal map_marker_placed emitido")

	var mid2: StringName = map_sys.add_personal_marker(&"REG-001", "Emboscada de Demônios", Vector3(-80.0, 0, 50.0), &"danger", Color.RED)
	check_false(mid2.is_empty(), "marcador 2 criado")

	var mid3: StringName = map_sys.add_personal_marker(&"REG-002", "Minério Raro", Vector3(10.0, 0, 10.0), &"treasure", Color.GOLD)
	check_false(mid3.is_empty(), "marcador 3 criado em REG-002")

	# Filtro por região
	var reg001_markers: Array[Dictionary] = map_sys.get_personal_markers(&"REG-001")
	check_eq(reg001_markers.size(), 2, "exatamente 2 marcadores em REG-001")

	var all_personal: Array[Dictionary] = map_sys.get_personal_markers()
	check_eq(all_personal.size(), 3, "total de 3 marcadores globais")

	# Remoção de marcador
	check_true(map_sys.remove_personal_marker(mid1), "marcador mid1 removido com sucesso")
	check_eq(cap_removed.count(), 1, "sinal map_marker_removed emitido")
	check_eq(map_sys.get_personal_markers(&"REG-001").size(), 1, "resta 1 marcador em REG-001")

	# Limpeza por região
	map_sys.clear_personal_markers(&"REG-001")
	check_eq(map_sys.get_personal_markers(&"REG-001").size(), 0, "marcadores de REG-001 limpos")
	check_eq(map_sys.get_personal_markers().size(), 1, "marcador de REG-002 preservado")

	map_sys.clear_personal_markers()
	check_eq(map_sys.get_personal_markers().size(), 0, "todos os marcadores limpos")

# -------------------------------- 7. CONTROLES DE INTERFACE E FILTROS --

func _test_interactive_ui_controls_and_filters() -> void:
	section("7. Interface e Controles: Zoom, pan, filtros visuais, seleção de continentes e legendas")
	var screen: Control = WorldMapScreenScript.new()
	host.add_child(screen)
	screen.open()

	var canvas = screen._map_canvas
	check_not_null(canvas, "WorldMapCanvas instanciado na tela")

	# Teste de Zoom no Canvas
	screen._adjust_zoom(1.5)
	check_eq(canvas.zoom, 1.5, "zoom ajustado para 1.5x")

	screen._adjust_zoom(0.5)
	check_true(canvas.zoom < 1.0, "zoom ajustado para menos de 1.0x")

	screen._reset_camera_view()
	check_eq(canvas.zoom, 1.0, "câmera resetada para zoom 1.0x")
	check_eq(canvas.pan_offset, Vector2.ZERO, "pan offset resetado para Vector2.ZERO")

	# Foco em Continente
	screen._focus_geographic_area(&"CONT-02")
	check_eq(String(screen._selected_continent_id), "CONT-02", "continente Sylvaran selecionado")
	check_true(canvas.zoom > 1.0, "câmera aproximada no continente focado")
	check_ne(canvas.pan_offset, Vector2.ZERO, "pan deslocado para o quadrante NE")

	# Filtros de Camadas
	check_true(canvas.filters.get("portals", false), "filtro de portais ativo por padrão")
	canvas.filters["portals"] = false
	check_false(canvas.filters["portals"], "filtro de portais pode ser desativado")

	screen.queue_free()
	await wait_frames(1)

# -------------------------------- 8. MULTIPLAYER E PINGS COMPARTILHADOS --

func _test_multiplayer_allies_and_shared_pings() -> void:
	section("8. Multiplayer Privado: Posição de aliados no grupo (até 8) e pings compartilhados")
	var world := system(SystemNames.WORLD) as WorldManager
	var map_sys: RefCounted = world.call("map_system")

	# Atualiza posições de aliados do grupo
	map_sys.update_party_member_position(2, &"REG-001", Vector3(20.0, 0, 15.0), 0.0)
	map_sys.update_party_member_position(3, &"REG-001", Vector3(-45.0, 0, 30.0), 3.14)
	map_sys.update_party_member_position(4, &"REG-002", Vector3(10.0, 0, 50.0), 1.2)

	var reg001_allies: Array[Dictionary] = map_sys.get_party_member_positions(&"REG-001")
	check_eq(reg001_allies.size(), 2, "2 aliados presentes em REG-001")

	var all_allies: Array[Dictionary] = map_sys.get_party_member_positions()
	check_eq(all_allies.size(), 3, "total de 3 aliados no mundo")

	# Pings compartilhados de combate / exploração
	var cap_ping := capture(EventBus.map_ping_shared)
	map_sys.record_party_ping(2, &"REG-001", Vector3(25.0, 0, 15.0), &"danger", "Inimigo Elite Aqui!")
	check_eq(map_sys.get_active_party_pings(&"REG-001").size(), 1, "ping registrado em REG-001")

	# Remoção de participante desconectado
	map_sys.remove_party_member(3)
	check_eq(map_sys.get_party_member_positions(&"REG-001").size(), 1, "aliado desconectado removido do radar")

	map_sys.clear_party_pings()
	check_eq(map_sys.get_active_party_pings().size(), 0, "pings limpos com sucesso")

# -------------------------------- 9. PERSISTÊNCIA DE EXPLORAÇÃO --

func _test_map_persistence_and_serialization() -> void:
	section("9. Persistência: Serialização e restauração de setores explorados e marcadores no Save")
	var world := system(SystemNames.WORLD) as WorldManager
	var map_sys: RefCounted = world.call("map_system")

	# Configura estado para salvar
	map_sys.explore_position(&"REG-011", Vector3(10.0, 0, 20.0), 30.0)
	map_sys.discover_poi(&"REG-011", &"poi_sylvaran_sanctuary")
	map_sys.add_personal_marker(&"REG-011", "Fonte Sagrada", Vector3(50.0, 0, 50.0), &"poi", Color.CYAN)

	var save_data: Dictionary = map_sys.collect_save_data()
	check_false(save_data.is_empty(), "dados de navegação coletados para save")
	check_true(save_data.get("discovered_regions", []).has("REG-011"), "REG-011 serializada nas descobertas")
	check_true(save_data.get("discovered_pois", []).has("poi_sylvaran_sanctuary"), "POI serializado")

	# Reseta e restaura
	map_sys.apply_save_data({})
	check_false(map_sys.is_region_discovered(&"REG-011"), "estado limpo após reset")

	check_true(map_sys.apply_save_data(save_data), "save de navegação restaurado com sucesso")
	check_true(map_sys.is_region_discovered(&"REG-011"), "REG-011 restaurada como descoberta")
	check_true(map_sys.is_poi_discovered(&"poi_sylvaran_sanctuary"), "POI restaurado como descoberto")
	check_eq(map_sys.get_personal_markers(&"REG-011").size(), 1, "marcador pessoal restaurado do save")
