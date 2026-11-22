extends TestCase
## Suíte de Testes dos Sistemas de Interface e Complementares de ABYSSAL PACT.
##
## Valida:
## 1. Registro e ciclo de vida dos 16 menus/telas + criação de personagem no UIManager.
## 2. Inventário nas 5 categorias (Equipamentos, Consumíveis, Materiais, Relíquias, Itens de Missão) e uso de consumíveis.
## 3. Equipamentos, boneco 3D, slots de equipamento e comparação de atributos em tempo real (StatComparisonCard).
## 4. Habilidades e árvore de classes.
## 5. Sistema de Pactos Abissais: seleção, vínculo ao personagem, evolução até Grau 5 e bônus escalonados.
## 6. Códice com todas as 9 categorias: Demônios, Chefes, Raças, Sub-raças, Classes, Continentes, Regiões, História, Facções.
## 7. Bestiário com filtragem continental (4 x 50) e 30 chefes especiais com arenas/fases.
## 8. Missões nas 5 categorias (Principais, Secundárias, Regionais, De Classe, De Raça).
## 9. Mapa Mundial e Mapa Regional com marcadores (Portais, Cidades, Masmorras, Chefes, Exploração).
## 10. Grupo e configurações multiplayer (convites, participantes, estados).
## 11. Menu de pausa e retorno emergencial à Hell Forge.

func system_label() -> String:
	return "ui_systems"

func execute() -> void:
	await _test_ui_screens_registration_and_lifecycle()
	await _test_inventory_five_categories_and_usage()
	await _test_equipment_system_and_stat_comparison()
	await _test_abilities_and_class_tree()
	await _test_pacts_system_and_evolution()
	await _test_codex_system_all_nine_categories()
	await _test_bestiary_filtering()
	await _test_quests_system_all_five_categories()
	await _test_world_and_regional_map_markers()
	await _test_party_and_settings()
	await _test_pause_menu_and_hub_respawn()

func _test_ui_screens_registration_and_lifecycle() -> void:
	section("UIManager: Registro e Instanciação dos 16 Menus Canônicos")
	var ui := system(SystemNames.UI) as UIManager
	check_not_null(ui, "UIManager acessível via registro de sistemas")

	var registered := ui.registered_screen_ids()
	var expected_screens: Array[StringName] = [
		&"main_menu",
		&"character_creation",
		&"create_world",
		&"join_world",
		&"inventory",
		&"equipment",
		&"abilities",
		&"class_tree",
		&"pacts",
		&"world_map",
		&"regional_map",
		&"codex",
		&"bestiary",
		&"quests",
		&"party",
		&"settings",
		&"pause_menu"
	]

	for expected_id in expected_screens:
		check_true(registered.has(expected_id), "Tela '%s' registrada no router" % String(expected_id))

	# Abre e fecha sequencialmente cada uma das telas
	ui.close_all_screens()
	for screen_id in expected_screens:
		ui.close_all_screens()
		var err := ui.open_screen(screen_id)
		check_err(err, OK, "Abertura da tela '%s' retorna OK" % String(screen_id))
		check_true(ui.is_screen_open(screen_id), "Tela '%s' reportada como aberta" % String(screen_id))
		check_eq(StringName(ui.current_screen_id()), screen_id, "ID corrente corresponde a '%s'" % String(screen_id))
		var screen_node: Node = ui.get_node("Screens").get_child(0)
		check_not_null(screen_node, "Instância da tela '%s' anexada à camada Screens" % String(screen_id))
		check_true(screen_node is ScreenBase, "Tela '%s' herda de ScreenBase" % String(screen_id))

	# Restaura tela inicial
	ui.open_screen(&"main_menu")

func _test_inventory_five_categories_and_usage() -> void:
	section("Inventário: 5 Categorias Canônicas e Consumo de Itens")
	var inv := system(SystemNames.INVENTORY) as InventoryManager
	var chars := system(SystemNames.CHARACTER) as CharacterManager
	check_not_null(inv, "InventoryManager acessível")
	check_not_null(chars, "CharacterManager acessível")

	# Valida presença das 5 categorias no catálogo
	var cat_eq := inv.items_of_category(&"equipment")
	var cat_con := inv.items_of_category(&"consumable")
	var cat_mat := inv.items_of_category(&"material")
	var cat_rel := inv.items_of_category(&"relic")
	var cat_que := inv.items_of_category(&"quest")

	check_true(cat_eq.size() >= 10, "Pelo menos 10 itens de equipamento (encontrados: %d)" % cat_eq.size())
	check_true(cat_con.size() >= 2, "Pelo menos 2 itens consumíveis (encontrados: %d)" % cat_con.size())
	check_true(cat_mat.size() >= 2, "Pelo menos 2 materiais de forja (encontrados: %d)" % cat_mat.size())
	check_true(cat_rel.size() >= 2, "Pelo menos 2 relíquias de pacto (encontrados: %d)" % cat_rel.size())
	check_true(cat_que.size() >= 2, "Pelo menos 2 itens de missão (encontrados: %d)" % cat_que.size())

	# Cria personagem de teste
	var test_char := chars.create_character("Portador dos Pactos", &"RACE-001", &"SUBRACE-001", &"CLASS-001")
	check_not_null(test_char, "Personagem de teste de UI criado com sucesso")
	var cid: StringName = test_char.id
	chars.select_character(cid)

	# Concede itens de cada uma das 5 categorias
	check_err(inv.add_item(cid, &"EQ-001", 1), OK, "Adiciona equipamento (Espada de Basalto)")
	check_err(inv.add_item(cid, &"EQ-012", 3), OK, "Adiciona consumível (Poção de Sangue)")
	check_err(inv.add_item(cid, &"EQ-014", 10), OK, "Adiciona material (Minério de Basalto)")
	check_err(inv.add_item(cid, &"EQ-016", 2), OK, "Adiciona relíquia (Cinza Vulcânica Ancestral)")
	check_err(inv.add_item(cid, &"EQ-018", 1), OK, "Adiciona item de missão (Fragmento do Pacto)")

	# Testa contagem por categoria no inventário do personagem
	check_eq(inv.count_item(cid, &"EQ-012"), 3, "Quantidade de poções inicial = 3")

	# Consumo de item
	check_err(inv.use_item(cid, &"EQ-012"), OK, "Uso de poção consumível retorna OK")
	check_eq(inv.count_item(cid, &"EQ-012"), 2, "Quantidade de poções reduzida para 2 após uso")

	# Descarte
	check_err(inv.remove_item(cid, &"EQ-012", 2), OK, "Descarte das poções restantes")
	check_eq(inv.count_item(cid, &"EQ-012"), 0, "Item removido com sucesso")

func _test_equipment_system_and_stat_comparison() -> void:
	section("Equipamentos: Slots, Doll e Comparador de Atributos (StatComparisonCard)")
	var inv := system(SystemNames.INVENTORY) as InventoryManager
	var chars := system(SystemNames.CHARACTER) as CharacterManager
	var test_char := chars.selected_character()
	var cid: StringName = test_char.id

	# Equipar arma e armadura
	check_err(inv.equip_item(cid, &"weapon", &"EQ-001"), OK, "Equipa arma EQ-001")
	check_eq(inv.loadout_of(cid).item_in_slot(&"weapon"), &"EQ-001", "Slot 'weapon' ocupado por EQ-001")

	# Concede segunda arma para teste de comparação
	check_err(inv.add_item(cid, &"EQ-002", 1), OK, "Adiciona arma alternativa EQ-002")

	var item_curr := inv.get_item(&"EQ-001")
	var item_cand := inv.get_item(&"EQ-002")
	check_not_null(item_curr, "Item atual EQ-001 válido")
	check_not_null(item_cand, "Item candidato EQ-002 válido")

	# Testa componente StatComparisonCard
	var card := StatComparisonCard.new()
	card.compare(item_curr, item_cand)
	check_not_null(card, "Instância do StatComparisonCard gerada com sucesso")

	# Testa ItemSlotUI
	var slot_ui := ItemSlotUI.new(item_cand, 1)
	check_not_null(slot_ui, "Instância de ItemSlotUI gerada com sucesso")
	slot_ui.set_selected(true)
	check_eq(slot_ui.item_data.id, &"EQ-002", "Slot UI retém referência de EQ-002")
	card.queue_free()
	slot_ui.queue_free()

func _test_abilities_and_class_tree() -> void:
	section("Habilidades e Árvore de Classes: Catálogo, Loadout e Progressão")
	var classes := system(SystemNames.CLASS) as ClassManager
	check_not_null(classes, "ClassManager acessível")

	var c_data := classes.get_class_data(&"CLASS-001")
	check_not_null(c_data, "Classe CLASS-001 carregada com sucesso")
	check_true(c_data.active_ability_ids.size() > 0, "Classe possui habilidades ativas cadastradas")

	var first_aid: StringName = c_data.active_ability_ids[0]
	var ab_data := classes.get_ability(first_aid)
	check_not_null(ab_data, "Habilidade '%s' encontrada no catálogo" % String(first_aid))
	check_true(not ab_data.display_name.is_empty(), "Habilidade possui nome de exibição")

	# Testa requisitos da árvore de habilidades
	var unlocked_lv1 := classes.unlocked_abilities(&"CLASS-001", 1)
	var unlocked_lv20 := classes.unlocked_abilities(&"CLASS-001", 20)
	check_true(unlocked_lv20.size() >= unlocked_lv1.size(), "Nível 20 desbloqueia pelo menos tantas habilidades quanto nível 1")

func _test_pacts_system_and_evolution() -> void:
	section("Pactos Abissais: Seleção, Ativação e Evolução até Grau 5")
	var chars := system(SystemNames.CHARACTER) as CharacterManager
	var test_char := chars.selected_character()
	var cid: StringName = test_char.id

	# Catálogo de pactos
	var all_pacts := PactCatalog.pacts()
	check_eq(all_pacts.size(), 5, "Exatamente 5 pactos abissais canônicos carregados")

	var pact_1 := PactCatalog.get_pact(&"PACT-001")
	check_not_null(pact_1, "Pacto PACT-001 (Cinzas Primordiais) carregado")
	check_eq(pact_1.max_tier, 5, "Grau máximo do pacto é 5")

	# Ativação do pacto no personagem
	check_err(chars.set_character_pact(cid, &"PACT-001"), OK, "Vincula PACT-001 ao personagem")
	check_eq(chars.get_character_pact(cid), &"PACT-001", "Pacto ativo é PACT-001")
	check_eq(chars.get_character_pact_tier(cid, &"PACT-001"), 1, "Grau inicial do pacto é 1")

	# Evolução através dos Graus 2, 3, 4 e 5
	for expected_tier in range(2, 6):
		var new_tier := chars.evolve_character_pact(cid, &"PACT-001")
		check_eq(new_tier, expected_tier, "Evolução do pacto para Grau %d retorna novo grau" % expected_tier)
		check_eq(chars.get_character_pact_tier(cid, &"PACT-001"), expected_tier, "Grau verificado como %d" % expected_tier)

	# Bônus escalonado no Grau 5
	var base_fire := float(pact_1.stat_modifiers.get("fire_power", 12.0))
	pact_1.tier = 5
	var scaled_fire: float = pact_1.get_stat_modifier("fire_power")
	check_true(scaled_fire > base_fire, "Poder de fogo no Grau 5 (%.1f) supera o base (%.1f)" % [scaled_fire, base_fire])

	# Tentativa de evolução além do Grau 5 permanece no Grau 5
	var tier_over := chars.evolve_character_pact(cid, &"PACT-001")
	check_eq(tier_over, 5, "Evolução além do Grau 5 permanece travada no Grau 5")

func _test_codex_system_all_nine_categories() -> void:
	section("Códice do Conhecimento: Validação das 9 Categorias Canônicas")
	var demons := system(SystemNames.DEMONS) as DemonManager
	var bosses := system(SystemNames.BOSSES) as BossManager
	var races := system(SystemNames.RACE) as RaceManager
	var classes := system(SystemNames.CLASS) as ClassManager
	var world := system(SystemNames.WORLD) as WorldManager

	# 1. Demônios (200)
	check_eq(demons.demons().size(), 200, "Códice: 200 demônios regionais")

	# 2. Chefes (30)
	check_eq(bosses.bosses().size(), 30, "Códice: 30 chefes especiais")

	# 3. Raças (40)
	check_eq(races.races().size(), 40, "Códice: 40 raças catalogadas")

	# 4. Sub-raças (80)
	check_eq(races.subraces().size(), 80, "Códice: 80 sub-raças catalogadas")

	# 5. Classes (80)
	check_eq(classes.classes().size(), 80, "Códice: 80 classes catalogadas")

	# 6. Continentes (4)
	check_eq(world.continents().size(), 4, "Códice: 4 continentes mundiais")

	# 7. Regiões (40)
	check_eq(world.regions().size(), 40, "Códice: 40 regiões exploráveis")

	# 8. História Canônica
	var history := CodexLore.get_history_entries()
	check_true(history.size() >= 4, "Códice: Pelo menos 4 registros históricos canônicos (%d)" % history.size())

	# 9. Facções do Mundo
	var factions := CodexLore.get_faction_entries()
	check_true(factions.size() >= 4, "Códice: Pelo menos 4 facções registradas (%d)" % factions.size())

func _test_bestiary_filtering() -> void:
	section("Bestiário: Filtragem Continental (4 Continentes x 50) e Chefes")
	var demons := system(SystemNames.DEMONS) as DemonManager
	var bosses := system(SystemNames.BOSSES) as BossManager

	var continents := [&"CONT-01", &"CONT-02", &"CONT-03", &"CONT-04"]
	for cont in continents:
		var count := 0
		for d in demons.demons():
			if d.continent_id == cont:
				count += 1
		check_eq(count, 50, "Bestiário: Continente %s possui exatamente 50 criaturas" % String(cont))

	# Valida chefes especiais com arena e fases
	var boss_count := bosses.bosses().size()
	check_eq(boss_count, 30, "Bestiário: Exatamente 30 chefes cadastrados")
	var boss_sample := bosses.get_boss(&"BOSS-001")
	check_not_null(boss_sample, "Chefe BOSS-001 presente")
	check_true(boss_sample.phases.size() >= 2, "Chefe BOSS-001 possui múltiplas fases (%d)" % boss_sample.phases.size())
	check_true(not boss_sample.arena.is_empty(), "Chefe BOSS-001 possui arena definida")

func _test_quests_system_all_five_categories() -> void:
	section("Missões: 5 Categorias Canônicas e Acompanhamento de Objetivos")
	var quests := system(SystemNames.QUESTS) as QuestManager
	var chars := system(SystemNames.CHARACTER) as CharacterManager
	var test_char := chars.selected_character()
	var cid: StringName = test_char.id

	var q_main := quests.quests_of_category(&"main")
	var q_side := quests.quests_of_category(&"side")
	var q_reg := quests.quests_of_category(&"regional")
	var q_class := quests.quests_of_category(&"class")
	var q_race := quests.quests_of_category(&"race")

	check_true(q_main.size() >= 2, "Missões principais presentes (%d)" % q_main.size())
	check_true(q_side.size() >= 2, "Missões secundárias presentes (%d)" % q_side.size())
	check_true(q_reg.size() >= 2, "Missões regionais presentes (%d)" % q_reg.size())
	check_true(q_class.size() >= 2, "Missões de classe presentes (%d)" % q_class.size())
	check_true(q_race.size() >= 2, "Missões de raça presentes (%d)" % q_race.size())

	# Aceitar missão secundária
	var side_q: QuestData = q_side[0]
	check_err(quests.accept_quest(cid, side_q.id), OK, "Aceita missão secundária '%s'" % String(side_q.id))
	check_eq(quests.quest_state(cid, side_q.id), "active", "Missão está ativa no diário")

	# Progredir objetivo da missão secundária
	var oid: StringName = side_q.get_objective_ids()[0]
	var req_cnt: int = side_q.get_objective_required(oid)
	check_err(quests.progress_objective(cid, side_q.id, oid, req_cnt), OK, "Conclui objetivo da missão secundária")
	check_eq(quests.quest_state(cid, side_q.id), "completed", "Missão secundária completada no diário")

func _test_world_and_regional_map_markers() -> void:
	section("Mapas Mundial e Regional: Marcadores Geográficos e Exploração")
	var world := system(SystemNames.WORLD) as WorldManager
	check_not_null(world, "WorldManager acessível")

	var markers := world.get_region_markers(&"REG-001")
	check_true(markers.size() >= 4, "Região REG-001 possui pelo menos 4 marcadores mapeados (%d)" % markers.size())

	var found_portal := false
	var found_city := false
	var found_dungeon := false
	var found_boss := false

	for m in markers:
		var mtype := String(m.get("type", ""))
		match mtype:
			"portal":
				found_portal = true
			"city":
				found_city = true
			"dungeon":
				found_dungeon = true
			"boss", "boss_arena":
				found_boss = true

	check_true(found_portal, "Marcador de Portal encontrado em REG-001")
	check_true(found_city, "Marcador de Cidade/Baluarte encontrado em REG-001")
	check_true(found_dungeon, "Marcador de Masmorra encontrado em REG-001")
	check_true(found_boss, "Marcador de Chefe encontrado em REG-001")

func _test_party_and_settings() -> void:
	section("Grupo e Configurações: Participantes, Convites e Painel de Ajustes")
	var net := system(SystemNames.NET) as MultiplayerManager
	check_not_null(net, "MultiplayerManager acessível")

	var session_started := false
	if not net.is_session_active():
		net.host_private_world("Sessão Teste UI")
		session_started = true

	var parts := net.participants()
	check_true(parts.size() >= 1, "Grupo contém pelo menos o jogador anfitrião")

	var host_details := net.get_participant_details(Invariants.HOST_PEER_ID)
	check_not_null(host_details, "Detalhes do participante anfitrião disponíveis")

	var invite_code := net.invite_code()
	check_true(not invite_code.is_empty(), "Código de convite para mundo privado gerado com sucesso (%s)" % invite_code)

	if session_started:
		net.leave_session()

func _test_pause_menu_and_hub_respawn() -> void:
	section("Menu de Pausa: Acesso Global e Retorno à Hell Forge")
	var ui := system(SystemNames.UI) as UIManager
	var chars := system(SystemNames.CHARACTER) as CharacterManager
	var world := system(SystemNames.WORLD) as WorldManager

	var world_session_created := false
	if world.active_world() == null:
		world.create_private_world("Mundo da Pausa")
		world_session_created = true

	check_err(ui.open_screen(&"pause_menu"), OK, "Menu de pausa aberto com sucesso")
	check_true(ui.is_screen_open(&"pause_menu"), "Menu de pausa confirmado como tela ativa")

	# Testa transição de retorno à Hell Forge (invariante do HUB via resolve_respawn)
	var respawned_hub := world.resolve_respawn(Invariants.HOST_PEER_ID)
	check_eq(respawned_hub, Invariants.HUB_REGION_ID, "Ressurgimento aponta obrigatoriamente para Hell Forge (invariante)")

	# Testa transição entre regiões do mundo aberto
	check_err(world.transition_to_region(&"REG-001", &"default"), OK, "Transição para REG-001 executada com sucesso")
	check_eq(world.current_region_id(), &"REG-001", "Região atual é REG-001")

	# Fecha menu de pausa e faz limpeza do personagem de teste
	ui.close_screen(&"pause_menu")
	if world_session_created:
		world.close_private_world()

	var test_char := chars.selected_character()
	if test_char != null:
		chars.delete_character(test_char.id)
