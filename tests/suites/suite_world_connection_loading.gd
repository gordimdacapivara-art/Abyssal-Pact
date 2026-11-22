extends TestCase
## Suite WORLD_CONNECTION_LOADING — Sistema de Conexão e Carregamento do Mundo.
## Valida os 12 subsistemas de geografia navegável:
##   1. Gerenciador de continentes (4 continentes, capitais, terminais)
##   2. Gerenciador de regiões (40 regiões 3D em produção completa)
##   3. Sistema de conexões (REGION_GRAPH.json, 41 nós, rotas e integridade)
##   4. Sistema de transições (validação de nível, fronteiras e ciclo de eventos)
##   5. Carregamento de cenas (síncrono e assíncrono threaded)
##   6. Descarregamento de regiões (liberação de memória, evitando acúmulo de 3D)
##   7. Pontos de entrada (spawns determinísticos e fallbacks)
##   8. Pontos de saída (gatilhos de fronteira RegionGate)
##   9. Portais (conduítes intercontinentais e travessias)
##   10. Salvamento da última região (persistência de sessão e save)
##   11. Controle de região atual (current_region_id e active_region_node)
##   12. Registro de regiões descobertas (WorldSessionData e CharacterManager)
##   13. Dimensão Hell Forge (instância lógica e destino obrigatório de ressurgimento)
##   14. Persistência integral do jogador através de transições (pawn, itens, stats)

const TEST_WORLD_NAME := "Mundo de Navegação e Conexão"

func system_label() -> String:
	return "world_connection_loading"

func execute() -> void:
	await _test_continent_manager()
	await _test_region_manager()
	await _test_world_connection_graph()
	await _test_network_integrity_and_zero_orphans()
	await _test_route_pathfinding()
	await _test_transition_validation_and_events()
	await _test_scene_loading_and_unloading_memory()
	await _test_entry_and_exit_points()
	await _test_hell_forge_dimension_and_mandatory_respawn()
	await _test_player_persistence_across_transitions()
	await _test_last_region_save_and_world_state()
	await _test_multiplayer_host_authority_on_transitions()

# ------------------------------------------------ 1. GERENCIADOR DE CONTINENTES --

func _test_continent_manager() -> void:
	section("1. Gerenciador de Continentes: 4 continentes, capitais, terminais e trânsito intercontinental")
	var world := system(SystemNames.WORLD) as WorldManager
	var cm := world.continent_manager()
	check_not_null(cm, "ContinentManager disponível")

	check_eq(cm.all_continents().size(), 4, "exatamente 4 continentes catalogados")
	check_true(cm.has_continent(&"CONT-01"), "continente Veyrath presente")
	check_true(cm.has_continent(&"CONT-02"), "continente Sylvaran presente")
	check_true(cm.has_continent(&"CONT-03"), "continente Khar-Duum presente")
	check_true(cm.has_continent(&"CONT-04"), "continente Nhal'Kora presente")

	# Capitais continentais
	check_eq(String(cm.capital_of_continent(&"CONT-01")), "REG-001", "Capital de Veyrath: REG-001 (Cinzália)")
	check_eq(String(cm.capital_of_continent(&"CONT-02")), "REG-011", "Capital de Sylvaran: REG-011 (Raiz Antiga)")
	check_eq(String(cm.capital_of_continent(&"CONT-03")), "REG-021", "Capital de Khar-Duum: REG-021 (Caldeira Rubra)")
	check_eq(String(cm.capital_of_continent(&"CONT-04")), "REG-031", "Capital de Nhal'Kora: REG-031 (Geleira dos Ecos)")

	# Regiões terminais de alta periculosidade
	check_eq(String(cm.terminal_region_of_continent(&"CONT-01")), "REG-010", "Terminal de Veyrath: REG-010 (Torre de Aster)")
	check_eq(String(cm.terminal_region_of_continent(&"CONT-02")), "REG-020", "Terminal de Sylvaran: REG-020 (Fonte do Primeiro Broto)")
	check_eq(String(cm.terminal_region_of_continent(&"CONT-03")), "REG-030", "Terminal de Khar-Duum: REG-030 (Cratera do Coração)")
	check_eq(String(cm.terminal_region_of_continent(&"CONT-04")), "REG-040", "Terminal de Nhal'Kora: REG-040 (Trono da Aurora Morta)")

	# Trânsito intercontinental
	check_true(cm.is_intercontinental(&"REG-001", &"REG-011"), "REG-001 -> REG-011 é intercontinental")
	check_false(cm.is_intercontinental(&"REG-001", &"REG-002"), "REG-001 -> REG-002 é intracontinental (mesmo continente)")

	# Cálculo de exploração
	var progress := cm.calculate_continent_exploration(&"CONT-01", PackedStringArray(["REG-001", "REG-002"]))
	check_eq(progress, 0.2, "2 de 10 regiões descobertas = 20%% de progresso")

# ---------------------------------------------------- 2. GERENCIADOR DE REGIÕES --

func _test_region_manager() -> void:
	section("2. Gerenciador de Regiões: Catálogo de 40 regiões 3D, biomas, faixas e filtros")
	var world := system(SystemNames.WORLD) as WorldManager
	var rm := world.region_manager()
	check_not_null(rm, "RegionManager disponível")

	check_eq(rm.all_regions().size(), 40, "exatamente 40 regiões continentais catalogadas")
	check_true(rm.has_region(&"REG-001"), "REG-001 presente")
	check_true(rm.has_region(&"REG-040"), "REG-040 presente")
	check_true(world.has_region(&"hell_forge"), "Dimensão Hell Forge reconhecida pelo WorldManager")

	var reg1 := rm.get_region(&"REG-001")
	check_not_null(reg1, "dados de REG-001 obtidos")
	check_eq(reg1.status, "full_production", "REG-001 em full_production")
	check_true(reg1.scene_path.ends_with(".tscn"), "caminho de cena 3D válido")

	# Filtros
	var ash_regions := rm.regions_by_biome("ash_plains")
	check_true(ash_regions.size() >= 1, "busca por bioma ash_plains funcional")

	var low_level_regions := rm.regions_by_level_range(1, 10)
	check_true(low_level_regions.size() >= 1, "busca por faixa de nível inicial funcional")

# ----------------------------------------------------- 3. SISTEMA DE CONEXÕES --

func _test_world_connection_graph() -> void:
	section("3. Sistema de Conexões: Grafo geográfico (REGION_GRAPH.json) com 41 nós")
	var world := system(SystemNames.WORLD) as WorldManager
	var graph := world.connection_graph()
	check_not_null(graph, "WorldConnectionGraph disponível")
	check_true(graph.is_loaded(), "Grafo carregado com sucesso do disco")
	check_eq(graph.total_nodes(), 41, "exatamente 41 nós carregados (40 regiões + Hell Forge)")
	check_true(graph.total_edges() >= 40, "arestas viárias mapeadas (total: %d)" % graph.total_edges())

	# Vizinhos de REG-001
	var neighbors := graph.get_neighbors(&"REG-001")
	check_true(neighbors.size() >= 2, "REG-001 possui múltiplas conexões de trânsito (tem %d)" % neighbors.size())
	check_true(neighbors.has(&"REG-002"), "REG-001 conectado a REG-002")

	# Conexão direta
	check_true(graph.are_connected(&"REG-001", &"REG-002"), "REG-001 e REG-002 conectados diretamente")
	var conn := graph.get_connection_between(&"REG-001", &"REG-002")
	check_false(conn.is_empty(), "dados da conexão obtidos")
	check_true(conn.has("route_name"), "nome da rota presente: %s" % conn.get("route_name", ""))

# ---------------------------------------- 4. INTEGRIDADE E ZERO NÓS ÓRFÃOS --

func _test_network_integrity_and_zero_orphans() -> void:
	section("4. Validação de Integridade: Garantia de ZERO nós órfãos e conectividade 100%")
	var world := system(SystemNames.WORLD) as WorldManager
	var graph := world.connection_graph()

	var report := graph.validate_network_integrity()
	check_true(bool(report["is_valid"]), "Integridade do grafo 100%% aprovada")
	check_eq(report["orphan_nodes"].size(), 0, "ZERO nós órfãos detectados no mundo inteiro")
	check_eq(report["unreachable_count"], 0, "ZERO regiões inalcançáveis")
	check_true(bool(report["all_reachable"]), "Todas as 40 regiões e a Hell Forge são mutuamente alcançáveis")

	# Verifica grau mínimo de cada uma das 40 regiões
	for num in range(1, 41):
		var r_id := StringName("REG-%03d" % num)
		check_true(graph.get_degree(r_id) >= 2, "%s possui grau viário >= 2 (tem %d)" % [r_id, graph.get_degree(r_id)])

# ------------------------------------------------ 5. CÁLCULO DE ROTAS (BFS) --

func _test_route_pathfinding() -> void:
	section("5. Cálculo de Rotas: Pathfinding topológico entre regiões e continentes")
	var world := system(SystemNames.WORLD) as WorldManager
	var graph := world.connection_graph()

	# Rota intracontinental Veyrath (REG-001 -> REG-004)
	var route_veyrath := graph.find_shortest_path(&"REG-001", &"REG-004")
	check_true(route_veyrath.size() >= 2, "rota intracontinental calculada: %s" % str(route_veyrath))
	check_eq(String(route_veyrath[0]), "REG-001", "início da rota é REG-001")
	check_eq(String(route_veyrath[-1]), "REG-004", "fim da rota é REG-004")

	# Rota intercontinental distante (REG-001 Veyrath -> REG-040 Nhal'Kora)
	var route_world := graph.find_shortest_path(&"REG-001", &"REG-040")
	check_true(route_world.size() >= 3, "rota transcontinental calculada: %s" % str(route_world))
	check_eq(String(route_world[0]), "REG-001", "início é REG-001")
	check_eq(String(route_world[-1]), "REG-040", "destino final é REG-040")

# --------------------------------------- 6. TRANSIÇÕES E CICLO DE EVENTOS --

func _test_transition_validation_and_events() -> void:
	section("6. Sistema de Transições: Validação de nível, fronteiras e ciclo de eventos")
	var world := system(SystemNames.WORLD) as WorldManager
	world.create_private_world("Mundo de Transição", Invariants.HOST_PEER_ID)

	var graph := world.connection_graph()
	var trans_sys := world.transition_system()
	check_not_null(trans_sys, "WorldTransitionSystem disponível")

	# Validação de trânsito permitido
	var travel_ok := graph.can_travel(&"REG-001", &"REG-002", 5)
	check_true(bool(travel_ok["allowed"]), "Trânsito de REG-001 para REG-002 autorizado para nível 5")

	# Validação de trânsito bloqueado por nível
	var travel_low_lvl := graph.can_travel(&"REG-001", &"REG-002", 0)
	check_false(bool(travel_low_lvl["allowed"]), "Trânsito bloqueado para nível insuficiente")

	# Validação de região desconectada
	var travel_invalid := graph.can_travel(&"REG-001", &"REG-038", 1)
	check_false(bool(travel_invalid["allowed"]), "Trânsito direto recusado entre regiões sem rota direta")

	# Captura de sinais do ciclo de vida da transição
	var req_cap := capture(EventBus.region_transition_requested)
	var start_cap := capture(EventBus.region_transition_started)
	var comp_cap := capture(EventBus.region_transition_completed)

	var err := world.transition_to_region(&"REG-002", &"gate_south")
	check_err(err, OK, "transição para REG-002 aceita")
	check_eq(req_cap.count(), 1, "sinal region_transition_requested emitido")
	check_eq(start_cap.count(), 1, "sinal region_transition_started emitido")
	check_eq(comp_cap.count(), 1, "sinal region_transition_completed emitido")
	check_eq(String(world.current_region_id()), "REG-002", "região atual atualizada para REG-002")

	world.close_private_world()

# --------------------------------- 7. CARREGAMENTO E DESCARREGAMENTO DE 3D --

func _test_scene_loading_and_unloading_memory() -> void:
	section("7. Carregamento e Descarregamento de Cenas: Gestão estrita de memória (evita múltiplos 3D)")
	var world := system(SystemNames.WORLD) as WorldManager
	world.create_private_world("Mundo de Carregamento", Invariants.HOST_PEER_ID)

	var loader := world.scene_loader()
	check_not_null(loader, "WorldSceneLoader disponível")

	# Carga inicial da Região 1 (Cinzália)
	var unload_cap := capture(EventBus.region_unloaded)
	check_err(world.load_region(&"REG-001", "default"), OK, "REG-001 carregada com sucesso")
	check_eq(String(world.current_region_id()), "REG-001", "região corrente é REG-001")

	# Transição para a Região 2 (Coroa Partida)
	check_err(world.load_region(&"REG-002", "gate_south"), OK, "REG-002 carregada com sucesso")
	check_eq(String(world.current_region_id()), "REG-002", "região corrente atualizada para REG-002")
	check_true(unload_cap.count() >= 1, "sinal region_unloaded emitido ao descarregar a região anterior")

	# Carregamento assíncrono (threaded)
	var async_start_cap := capture(EventBus.region_load_started)
	var async_comp_cap := capture(EventBus.region_load_completed)
	check_err(await world.load_region_async(&"REG-003", "default"), OK, "load_region_async aceito")
	check_eq(async_start_cap.count(), 1, "region_load_started emitido na carga assíncrona")
	check_eq(async_comp_cap.count(), 1, "region_load_completed emitido na carga assíncrona")
	check_eq(String(world.current_region_id()), "REG-003", "região corrente atualizada para REG-003")

	world.close_private_world()

# -------------------------------------------- 8. PONTOS DE ENTRADA E SAÍDA --

func _test_entry_and_exit_points() -> void:
	section("8. Pontos de Entrada e Saída: Gates de fronteira, spawns e fallbacks graciosos")
	var world := system(SystemNames.WORLD) as WorldManager

	# Inspeção de entradas e saídas de REG-001
	var entries := world.get_entry_points(&"REG-001")
	check_true(entries.size() >= 2, "REG-001 possui pontos de entrada (tem %d)" % entries.size())
	check_true(entries.has("default"), "possui spawn default")

	var exits := world.get_exit_points(&"REG-001")
	check_true(exits.size() >= 1, "REG-001 possui pontos de saída/fronteira (tem %d)" % exits.size())

	# Teste de resolução de spawn em cena instanciada
	var packed := load("res://scenes/world/regions/cinzalia.tscn") as PackedScene
	check_not_null(packed, "cena de teste carrega")
	if packed != null:
		var inst := packed.instantiate() as Node3D
		host.add_child(inst)

		var loader := world.scene_loader()
		var tf_def := loader.resolve_spawn_transform(inst, "default")
		check_true(tf_def != Transform3D.IDENTITY or tf_def.origin != Vector3.ZERO, "spawn default resolvido com sucesso")

		var tf_gate := loader.resolve_spawn_transform(inst, "gate_north")
		check_true(tf_gate.origin.z < 0, "spawn gate_north posicionado ao norte (z < 0)")

		# Fallback para spawn inexistente (não deve crashar nem retornar erro)
		var tf_fallback := loader.resolve_spawn_transform(inst, "spawn_inexistente_999")
		check_not_null(tf_fallback, "fallback gracioso executado sem erro")

		inst.queue_free()
		await wait_frames(1)

# --------------------------------- 9. DIMENSÃO HELL FORGE E RESSURGIMENTO --

func _test_hell_forge_dimension_and_mandatory_respawn() -> void:
	section("9. Dimensão Hell Forge: Instância lógica independente e destino OBRIGATÓRIO de ressurgimento")
	var world := system(SystemNames.WORLD) as WorldManager
	world.create_private_world("Mundo Hell Forge", Invariants.HOST_PEER_ID)

	# 1. Validação de regras e Invariante
	check_eq(String(Invariants.HUB_REGION_ID), "hell_forge", "Invariante HUB_REGION_ID é 'hell_forge'")
	check_eq(String(world.HUB_ID), "hell_forge", "WorldManager.HUB_ID aponta para 'hell_forge'")

	# 2. Resolução de ressurgimento
	var respawn_target := world.resolve_respawn(Invariants.HOST_PEER_ID)
	check_eq(String(respawn_target), "hell_forge", "Ressurgimento OBRIGATÓRIO na Hell Forge")

	# 3. Carregamento da cena 3D da Hell Forge
	check_true(ResourceLoader.exists("res://scenes/world/dimension/hell_forge.tscn"), "Cena 3D da Hell Forge existe no disco")
	var packed_hf := load("res://scenes/world/dimension/hell_forge.tscn") as PackedScene
	check_not_null(packed_hf, "Cena 3D da Hell Forge carrega com sucesso")
	if packed_hf != null:
		var hf_node := packed_hf.instantiate() as Node3D
		check_not_null(hf_node, "Instanciação da Hell Forge concluída")
		host.add_child(hf_node)

		check_eq(String(hf_node.call("region_id")), "hell_forge", "ID da dimensão coincide")
		check_not_null(hf_node.call("safe_zone"), "Santuário SafeZone presente na Hell Forge")
		check_not_null(hf_node.call("spawn_point", "default"), "Spawn default presente")
		check_not_null(hf_node.call("spawn_point", "respawn"), "Spawn de ressurgimento presente")

		# Portais arcanos para as capitais dos 4 continentes
		check_not_null(hf_node.get_node_or_null("Travel/PortalVeyrathCapital"), "Portal para Capital de Veyrath (REG-001) presente")
		check_not_null(hf_node.get_node_or_null("Travel/PortalSylvaranCapital"), "Portal para Capital de Sylvaran (REG-011) presente")
		check_not_null(hf_node.get_node_or_null("Travel/PortalKharduumCapital"), "Portal para Capital de Khar-Duum (REG-021) presente")
		check_not_null(hf_node.get_node_or_null("Travel/PortalNhalkoraCapital"), "Portal para Capital de Nhal'Kora (REG-031) presente")

		# Portais terminais
		check_not_null(hf_node.get_node_or_null("Travel/PortalVeyrathTerminal"), "Portal terminal REG-010 presente")
		check_not_null(hf_node.get_node_or_null("Travel/PortalSylvaranTerminal"), "Portal terminal REG-020 presente")
		check_not_null(hf_node.get_node_or_null("Travel/PortalKharduumTerminal"), "Portal terminal REG-030 presente")
		check_not_null(hf_node.get_node_or_null("Travel/PortalNhalkoraTerminal"), "Portal terminal REG-040 presente")

		hf_node.queue_free()
		await wait_frames(1)

	world.close_private_world()

# ----------------------------- 10. PERSISTÊNCIA INTEGRAL DO JOGADOR --

func _test_player_persistence_across_transitions() -> void:
	section("10. Persistência do Jogador: Preservação de personagem, inventário, equipamentos e progresso")
	var world := system(SystemNames.WORLD) as WorldManager
	var chars := system(SystemNames.CHARACTER) as CharacterManager
	var inv := system(SystemNames.INVENTORY) as InventoryManager

	world.create_private_world("Mundo de Persistência", Invariants.HOST_PEER_ID)

	# Cria e seleciona personagem de teste
	var char_data: CharacterData = chars.create_character("Viajante dos Portais", &"RACE-001", &"SUBRACE-001", &"CLASS-001")
	check_not_null(char_data, "Personagem de teste criado")
	var char_id: StringName = char_data.id if char_data != null else &""
	check_false(char_id.is_empty(), "ID do personagem válido")
	chars.select_character(char_id)

	# Adiciona itens ao inventário e equipa arma
	inv.add_item(char_id, &"IT-001", 3)
	inv.add_item(char_id, &"EQ-001", 1)
	inv.equip_item(char_id, &"weapon", &"EQ-001")
	chars.add_progression(char_id, &"experience", 250)

	var c_record: CharacterData = chars.get_character(char_id)
	var xp_before: int = c_record.progression.experience if c_record != null else 0
	var items_before: int = inv.count_item(char_id, &"IT-001")
	var eq_before: StringName = inv.loadout_of(char_id).item_in_slot(&"weapon") if inv.loadout_of(char_id) != null else &""

	# Realiza transição entre regiões (REG-001 -> REG-002)
	check_err(world.load_region(&"REG-001", "default"), OK, "Carga de REG-001")
	check_err(world.transition_to_region(&"REG-002", &"gate_south"), OK, "Transição para REG-002")

	# Valida preservação estrita do personagem e inventário
	var active_char := chars.selected_character()
	check_not_null(active_char, "Personagem continua selecionado e ativo")
	check_eq(String(active_char.id), String(char_id), "ID do personagem preservado")
	check_eq(active_char.progression.experience, xp_before, "Experiência e nível preservados")
	check_eq(inv.count_item(char_id, &"IT-001"), items_before, "Itens do inventário preservados")
	check_eq(String(inv.loadout_of(char_id).item_in_slot(&"weapon")), String(eq_before), "Equipamentos preservados")

	# Limpeza
	chars.delete_character(char_id)
	world.close_private_world()

# ----------------------------- 11. SALVAMENTO E ESTADO DO MUNDO --

func _test_last_region_save_and_world_state() -> void:
	section("11. Persistência de Estado: Salvamento de last_visited_region, spawn marker e descobertas")
	var world := system(SystemNames.WORLD) as WorldManager
	world.create_private_world("Mundo de Save", Invariants.HOST_PEER_ID)

	# Entra na região e descobre POI
	world.enter_region(&"REG-011")
	world.discover_region(&"REG-011")
	world.discover_poi(&"REG-011", &"poi_reg011_city")
	world.activate_portal(&"portal_reg011_hellforge")

	check_eq(String(world.last_visited_region()), "REG-011", "last_visited_region registrado como REG-011")

	# Coleta e serializa save data
	var save_data := world.collect_save_data()
	check_false(save_data.is_empty(), "dados de save coletados com sucesso")
	var world_dict: Dictionary = save_data.get("active_world", {})
	check_eq(String(world_dict.get("region_id", "")), "REG-011", "region_id serializado no save")
	check_true(world_dict.get("discovered_regions", []).has("REG-011"), "REG-011 nas regiões descobertas")
	check_true(world_dict.get("activated_portals", []).has("portal_reg011_hellforge"), "portal ativado serializado")

	# Restaura em nova sessão
	world.close_private_world()
	check_null(world.active_world(), "mundo fechado limpo")

	check_true(world.apply_save_data(save_data), "save aplicado com sucesso")
	check_not_null(world.active_world(), "mundo restaurado do save")
	check_eq(String(world.current_region_id()), "REG-011", "região atual restaurada como REG-011")
	check_true(world.is_region_discovered(&"REG-011"), "descoberta de REG-011 persistida")
	check_true(world.is_portal_activated(&"portal_reg011_hellforge"), "portal ativado persistido")

	world.close_private_world()

# ----------------------------- 12. AUTORIDADE DO ANFITRIÃO MULTIPLAYER --

func _test_multiplayer_host_authority_on_transitions() -> void:
	section("12. Multiplayer Privado: Autoridade do Anfitrião na coordenação e sincronização de regiões")
	var world := system(SystemNames.WORLD) as WorldManager
	var net := system(SystemNames.NET) as MultiplayerManager

	check_not_null(net, "MultiplayerManager disponível")
	check_eq(int(world.max_participants()), 8, "limite máximo de 8 jogadores confirmado")

	# Anfitrião hospeda mundo privado
	world.create_private_world("Sessão Multiplayer de Viagem", Invariants.HOST_PEER_ID)
	var err_host := net.host_private_world("Sessão Multiplayer de Viagem", 26315)
	check_err(err_host, OK, "Sessão hospedada pelo anfitrião")
	check_true(net.is_host(), "Instância local é a Autoridade do Mundo (Host)")

	var net_trans_cap := capture(EventBus.network_region_transition_replicated)

	# Anfitrião comanda transição para REG-021
	check_err(world.transition_to_region(&"REG-021", &"portal_main"), OK, "Anfitrião executa transição autoritária")
	check_eq(net_trans_cap.count(), 1, "Evento network_region_transition_replicated emitido para o grupo")
	check_eq(String(world.current_region_id()), "REG-021", "Mundo privado sincronizado em REG-021")

	net.leave_session("fim_teste_conexao")
	world.close_private_world()
