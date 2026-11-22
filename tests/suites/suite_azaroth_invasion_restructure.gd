class_name SuiteAzarothInvasionRestructure
extends TestCase
## SuiteAzarothInvasionRestructure — Suíte Completa de Testes da Reestruturação do Sistema de Invasão de Azaroth.
##
## Validações dos 10 Pilares:
##   1. Identidade Única do World Boss (Azaroth é o único comandante supremo; demônios superiores são tropas militares).
##   2. Ciclo Persistente de 5 Horas (Independência de UI, temporizador contínuo e persistência Save/Load).
##   3. Seleção de Região com Autoridade do Servidor (3 continentes, exclusão absoluta do Verdadeiro Inferno).
##   4. Alerta Cinematográfico de 1 Hora (Mensagem oficial dinâmica, identificação automática e animação).
##   5. Integração Cartográfica em 3 Níveis (Mapa-Múndi, Mapa Regional e Minimapa/Radar Tático).
##   6. Geração Natural da Invasão (~1 km dos jogadores, 3 estágios sísmicos sem teletransporte artificial).
##   7. Progressão em Duas Fases (Fase 1: Corrupção & Emboscadas; Fase 2: Expansão, Primordiais & Cerco em Pinça).
##   8. Batalha Exclusiva de Azaroth (4 fases, dificuldade progressiva, telegrafia, cinemáticas invulneráveis).
##   9. Sincronização Multiplayer (RPCs de ciclo, alvos, fases, telegrafias e vitória).
##   10. Conclusão de Vitória, Expurgamento Territorial (fendas seladas, corrupção zerada) e Recompensas.

const WorldBossSystemScript := preload("res://core/world_boss_system.gd")
const DemonicInvasionSystemScript := preload("res://core/demonic_invasion_system.gd")
const AzarothCombatControllerScript := preload("res://scenes/world/components/azaroth_combat_controller.gd")
const AzarothSpawnSequenceScript := preload("res://scenes/world/components/azaroth_spawn_sequence.gd")
const WorldBossDataScript := preload("res://data/models/world_boss_data.gd")

func suite_name() -> String:
	return "azaroth_invasion_restructure"

func execute() -> void:
	await _test_world_boss_unique_identity()
	await _test_persistent_five_hour_cycle()
	await _test_server_region_selection_and_true_hell_exclusion()
	await _test_one_hour_cinematic_alert()
	await _test_three_level_map_and_navigation_integration()
	await _test_natural_spawn_and_emergence_sequence()
	await _test_two_phase_invasion_progression()
	await _test_exclusive_azaroth_battle_mechanics()
	await _test_authoritative_multiplayer_synchronization()
	await _test_victory_territory_cleansing_and_rewards()

# -------------------------------- 1. IDENTIDADE DO WORLD BOSS --

func _test_world_boss_unique_identity() -> void:
	section("1. Identidade do World Boss: Azaroth é o Único World Boss do Jogo")
	var bosses := system(SystemNames.BOSSES) as Node
	check_not_null(bosses, "BossManager disponível")

	var wb_sys: Node = bosses.call("world_boss_system")
	check_not_null(wb_sys, "WorldBossSystem instanciado e gerenciado")

	var boss_data: Resource = wb_sys.call("boss_data")
	check_not_null(boss_data, "WorldBossData carregado")
	check_eq(String(boss_data.get("id")), String(Invariants.WORLD_BOSS_ID), "ID oficial é 'azaroth'")
	check_true(float(boss_data.get("max_health")) >= 1000000.0, "HP titânico de World Boss (>= 1.000.000)")

	# Confirma que demônios superiores integram a hierarquia do exército e NÃO o catálogo de chefes individuais BOSS-XXX
	var inv_sys: Node = DemonicInvasionSystemScript.new()
	host.add_child(inv_sys)
	var sup_unit: Resource = inv_sys.call("spawn_army_unit", DemonicInvasionSystemScript.MilitaryRank.SUPERIOR, Vector3.ZERO)
	check_not_null(sup_unit, "demônio superior gerado com sucesso")
	check_eq(int(sup_unit.get("military_rank")), int(DemonicInvasionSystemScript.MilitaryRank.SUPERIOR), "patente SUPERIOR")
	check_false(String(sup_unit.get("unit_id")).begins_with("BOSS-"), "demônio superior não colide com chefes individuais")
	check_eq(sup_unit.get("army_faction"), Invariants.AZAROTH_ARMY_FACTION, "pertence à facção ARMY_AZAROTH")

	inv_sys.call("cleanse_invasion")
	inv_sys.queue_free()

# -------------------------------- 2. CICLO DO EVENTO (5 HORAS) --

func _test_persistent_five_hour_cycle() -> void:
	section("2. Ciclo do Evento: 5 Horas Persistentes e Independência de Interface")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb_sys: Node = bosses.call("world_boss_system")
	wb_sys.call("reset_cycle")

	# Validação dos tempos canônicos
	check_eq(WorldBossSystemScript.CYCLE_DURATION_SECONDS, 18000.0, "ciclo total de 5 horas (18.000 segundos)")
	check_eq(WorldBossSystemScript.DORMANT_DURATION, 15300.0, "fase DORMANT dura 4h 15m (15.300 segundos)")
	check_eq(WorldBossSystemScript.WARNING_DURATION, 900.0, "fase WARNING dura 15m (900 segundos)")
	check_eq(WorldBossSystemScript.COMBAT_DURATION, 1800.0, "fase ACTIVE dura 30m (1.800 segundos)")

	# Independência de interface (PROCESS_MODE_ALWAYS)
	check_eq(int(wb_sys.get("process_mode")), int(Node.PROCESS_MODE_ALWAYS), "WorldBossSystem roda com PROCESS_MODE_ALWAYS")

	# Avanço de tempo
	wb_sys.call("set_cycle_time", 7200.0) # 2 horas de ciclo
	check_eq(float(wb_sys.call("cycle_elapsed_time")), 7200.0, "tempo do ciclo atualizado com precisão")

	# Teste de persistência de save/load
	var save_payload: Dictionary = wb_sys.call("collect_save_data")
	check_false(save_payload.is_empty(), "dados de save coletados")
	check_eq(float(save_payload.get("cycle_time")), 7200.0, "tempo salvo no payload")

	wb_sys.call("reset_cycle")
	check_eq(float(wb_sys.call("cycle_elapsed_time")), 0.0, "reset do ciclo efetuado")

	wb_sys.call("apply_save_data", save_payload)
	check_eq(float(wb_sys.call("cycle_elapsed_time")), 7200.0, "tempo restaurado com exatidão")

	wb_sys.call("reset_cycle")

# -------------------------------- 3. SELEÇÃO DA REGIÃO & PROIBIÇÃO DO VERDADEIRO INFERNO --

func _test_server_region_selection_and_true_hell_exclusion() -> void:
	section("3. Seleção da Região: 3 Continentes e Exclusão Estrita do Verdadeiro Inferno")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb_sys: Node = bosses.call("world_boss_system")

	var valid_regions: Array = wb_sys.call("get_valid_invasion_regions")
	check_eq(valid_regions.size(), 30, "exatamente 30 regiões nos 3 continentes mortais")

	var valid_conts: Array = wb_sys.call("get_valid_invasion_continents")
	check_eq(valid_conts.size(), 3, "exatamente 3 continentes válidos (CONT-01, CONT-02, CONT-03)")

	# Garante que o Verdadeiro Inferno / Hell Forge NUNCA está na lista
	check_false(wb_sys.call("is_valid_invasion_region", Invariants.HUB_REGION_ID), "Hell Forge é estritamente proibida")
	check_false(wb_sys.call("is_valid_invasion_region", &"verdadeiro_inferno"), "Verdadeiro Inferno é estritamente proibido")

	# Teste probabilístico de 100 seleções aleatórias consecutivas
	var selected_regions := {}
	for i in range(100):
		var loc: Dictionary = wb_sys.call("select_random_invasion_location")
		var reg_id: StringName = loc.get("region_id", &"")
		check_true(wb_sys.call("is_valid_invasion_region", reg_id), "região selecionada %s é estritamente válida" % reg_id)
		check_false(reg_id == Invariants.HUB_REGION_ID or reg_id == &"verdadeiro_inferno", "Verdadeiro Inferno nunca selecionado")
		selected_regions[reg_id] = true

	check_true(selected_regions.size() >= 5, "seleção verdadeiramente randômica distribuída entre múltiplas regiões")

# -------------------------------- 4. ALERTA DE UMA HORA --

func _test_one_hour_cinematic_alert() -> void:
	section("4. Alerta de Uma Hora: Notificação Cinematográfica e Mensagem Dinâmica")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb_sys: Node = bosses.call("world_boss_system")
	wb_sys.call("reset_cycle")

	# Configura alvo
	wb_sys.call("set_invasion_target", &"REG-001", Vector3(100, 0, 100))

	# Mensagem dinâmica canônica oficial (PROMPT 02)
	var expected_msg := "AZAROTH E SEU EXÉRCITO IRÃO INVADIR EM BREVE AS TERRAS DE CINZÁLIA, VEYRATH."
	var generated_msg: String = wb_sys.call("get_alert_message", true)
	check_eq(generated_msg, expected_msg, "mensagem dinâmica corresponde perfeitamente ao formato oficial")

	var alert_cap := capture(EventBus.world_boss_one_hour_warning)

	# Faltando 1 hora (14.400s do ciclo -> 3.600s para o spawn)
	wb_sys.call("set_cycle_time", 14400.0)
	wb_sys.call("advance_timer", 1.0)

	check_true(bool(wb_sys.call("is_one_hour_alert_issued")), "alerta de 1 hora emitido pelo sistema")
	check_true(alert_cap.count() >= 1, "sinal world_boss_one_hour_warning capturado")

	wb_sys.call("reset_cycle")

# -------------------------------- 5. MAPA E LOCALIZAÇÃO EM 3 NÍVEIS --

func _test_three_level_map_and_navigation_integration() -> void:
	section("5. Mapa e Localização: Nível 1 (Múndi), Nível 2 (Regional) e Nível 3 (Minimapa)")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb_sys: Node = bosses.call("world_boss_system")
	wb_sys.call("reset_cycle")
	wb_sys.call("set_invasion_target", &"REG-022", Vector3(200, 0, 200))

	var map_loc: Dictionary = wb_sys.call("get_invasion_map_location")
	check_eq(map_loc.get("region_id"), &"REG-022", "região mapeada é REG-022 (Fornalha dos Reis)")
	check_eq(map_loc.get("continent_name"), "Khar-Duum", "continente é Khar-Duum")
	check_eq(map_loc.get("world_position"), Vector3(200, 0, 200), "posição no mundo preservada")

	var summary: Dictionary = wb_sys.call("get_invasion_status_summary")
	check_eq(summary.get("region_name"), "Fornalha dos Reis", "nome da região identificado")
	check_eq(summary.get("continent_name"), "Khar-Duum", "nome do continente identificado")

	wb_sys.call("reset_cycle")

# -------------------------------- 6. GERAÇÃO DA INVASÃO (~1 KM E SEM TELEPORTE) --

func _test_natural_spawn_and_emergence_sequence() -> void:
	section("6. Geração da Invasão: Spawn a ~1 km e Sequência em 3 Estágios sem Teletransporte")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb_sys: Node = bosses.call("world_boss_system")

	# Posição de jogadores de teste
	var player_positions := [Vector3(50, 0, 50)]
	var calculated_pos: Vector3 = wb_sys.call("compute_spawn_position_for_players", player_positions)

	check_true(wb_sys.call("is_spawn_distance_valid", calculated_pos, player_positions[0], 150.0), "Azaroth posicionado a aproximadamente 1 km dos jogadores")

	# Sequência demoníaca de chegada (3 estágios)
	var seq: Node = wb_sys.call("get_spawn_sequence")
	check_not_null(seq, "AzarothSpawnSequence disponível")

	seq.call("start_sequence", calculated_pos)
	check_eq(int(seq.call("get_current_stage")), int(AzarothSpawnSequenceScript.Stage.TECTONIC_TREMOR), "Estágio 1: Abalo Tectônico")

	seq.call("advance_sequence", Invariants.WORLD_BOSS_ARRIVAL_TREMOR_DURATION + 0.1)
	check_eq(int(seq.call("get_current_stage")), int(AzarothSpawnSequenceScript.Stage.EMERGENCE), "Estágio 2: Ascensão do Subsolo")

	seq.call("advance_sequence", Invariants.WORLD_BOSS_ARRIVAL_EMERGENCE_DURATION + 0.1)
	check_eq(int(seq.call("get_current_stage")), int(AzarothSpawnSequenceScript.Stage.SHOCKWAVE_ROAR), "Estágio 3: Rugido da Onda de Choque")

	seq.call("advance_sequence", Invariants.WORLD_BOSS_ARRIVAL_SHOCKWAVE_DURATION + 0.1)
	check_eq(int(seq.call("get_current_stage")), int(AzarothSpawnSequenceScript.Stage.COMPLETED), "Sequência de chegada concluída com sucesso")

	wb_sys.call("reset_cycle")

# -------------------------------- 7. PROGRESSÃO EM DUAS FASES DA INVASÃO --

func _test_two_phase_invasion_progression() -> void:
	section("7. Progressão da Invasão: Fase 1 (Corrupção & Emboscadas) e Fase 2 (Expansão & Pinça)")
	var inv_sys: Node = DemonicInvasionSystemScript.new()
	host.add_child(inv_sys)

	# Inicia Fase 1
	inv_sys.call("start_invasion", &"REG-003", DemonicInvasionSystemScript.Phase.CORRUPTION)
	check_eq(int(inv_sys.call("get_current_phase")), int(DemonicInvasionSystemScript.Phase.CORRUPTION), "Fase 1: A Corrupção")
	check_true(is_equal_approx(float(inv_sys.call("get_corruption_level")), 0.3), "corrupção inicial de 30%")
	check_true(int(inv_sys.call("get_fissures_count")) >= 3, "fendas abertas no terreno")

	# Emboscada
	var ambush_units: Array = inv_sys.call("trigger_ambush", Vector3.ZERO, 4)
	check_eq(ambush_units.size(), 4, "emboscada gerou esquadrão de 4 unidades")

	# Transiciona para Fase 2
	inv_sys.call("set_phase", DemonicInvasionSystemScript.Phase.EXPANSION)
	check_eq(int(inv_sys.call("get_current_phase")), int(DemonicInvasionSystemScript.Phase.EXPANSION), "Fase 2: Expansão da Invasão")
	check_true(is_equal_approx(float(inv_sys.call("get_corruption_level")), 0.75), "corrupção expandida para 75%")
	check_true(int(inv_sys.call("get_fissures_count")) >= 6, "reforço de fendas abertas no território")
	check_true(inv_sys.call("get_primordial_units").size() >= 2, "criaturas primordiais emergiram para liderar a expansão")

	# Investida em pinça
	var pincer_units: Array = inv_sys.call("trigger_pincer_assault", Vector3.ZERO, 3, 2)
	check_eq(pincer_units.size(), 6, "investida em pinça com cerco simultâneo de 6 tropas")

	inv_sys.call("cleanse_invasion")
	inv_sys.queue_free()

# -------------------------------- 8. BATALHA EXCLUSIVA DE AZAROTH --

func _test_exclusive_azaroth_battle_mechanics() -> void:
	section("8. Batalha de Azaroth: 4 Fases Canônicas, Escalonamento e Transições Cinematográficas")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb_sys: Node = bosses.call("world_boss_system")
	wb_sys.call("reset_cycle")
	wb_sys.call("trigger_spawn")

	var controller: Node = wb_sys.call("get_combat_controller")
	check_not_null(controller, "AzarothCombatController ativo")

	# Fase 1
	check_eq(int(wb_sys.call("current_phase")), 1, "inicia na Fase 1")
	check_true(is_equal_approx(float(controller.call("get_damage_multiplier")), 1.0), "multiplicador de dano 1.0x")

	# Dano até Fase 2 (74% HP)
	wb_sys.call("apply_damage", Invariants.WORLD_BOSS_MAX_HEALTH * 0.26)
	check_eq(int(wb_sys.call("current_phase")), 2, "transição para Fase 2 aos 74% HP")
	check_true(bool(controller.call("is_invulnerable")), "invulnerável durante cinemática de transição")

	# Avança tempo da cinemática (4.5s)
	wb_sys.call("advance_timer", Invariants.WORLD_BOSS_PHASE_TRANSITION_DURATION + 0.5)
	check_false(bool(controller.call("is_invulnerable")), "invulnerabilidade removida pós-cinemática")
	check_true(float(controller.call("get_damage_multiplier")) >= 1.2, "dano escalonado para Fase 2 (1.2x)")

	# Dano até Fase 3 (49% HP)
	wb_sys.call("apply_damage", Invariants.WORLD_BOSS_MAX_HEALTH * 0.26)
	check_eq(int(wb_sys.call("current_phase")), 3, "transição para Fase 3 aos 49% HP")
	wb_sys.call("advance_timer", Invariants.WORLD_BOSS_PHASE_TRANSITION_DURATION + 0.5)
	check_true(float(controller.call("get_damage_multiplier")) >= 1.35, "dano escalonado para Fase 3 (1.35x)")

	# Dano até Fase 4 (24% HP)
	wb_sys.call("apply_damage", Invariants.WORLD_BOSS_MAX_HEALTH * 0.26)
	check_eq(int(wb_sys.call("current_phase")), 4, "transição para Fase 4 (Enrage) aos 24% HP")
	wb_sys.call("advance_timer", Invariants.WORLD_BOSS_PHASE_TRANSITION_DURATION + 0.5)
	check_true(float(controller.call("get_damage_multiplier")) >= 1.6, "dano máximo no Enrage (1.6x)")

	wb_sys.call("reset_cycle")

# -------------------------------- 9. SINCRONIZAÇÃO MULTIPLAYER --

func _test_authoritative_multiplayer_synchronization() -> void:
	section("9. Sincronização Multiplayer: RPCs do Servidor e Compartilhamento de Evento")
	var net_mgr := system(SystemNames.NET) as MultiplayerManager
	check_not_null(net_mgr, "MultiplayerManager disponível")

	check_true(net_mgr.has_method("rpc_sync_world_boss_cycle"), "rpc_sync_world_boss_cycle presente")
	check_true(net_mgr.has_method("rpc_sync_world_boss_invasion_target"), "rpc_sync_world_boss_invasion_target presente")
	check_true(net_mgr.has_method("rpc_sync_demonic_invasion_phase"), "rpc_sync_demonic_invasion_phase presente")
	check_true(net_mgr.has_method("rpc_azaroth_ability_telegraphed"), "rpc_azaroth_ability_telegraphed presente")
	check_true(net_mgr.has_method("rpc_azaroth_phase_cinematic"), "rpc_azaroth_phase_cinematic presente")
	check_true(net_mgr.has_method("rpc_azaroth_victory_sequence"), "rpc_azaroth_victory_sequence presente")

# -------------------------------- 10. VITÓRIA, EXPURGAMENTO E RECOMPENSAS --

func _test_victory_territory_cleansing_and_rewards() -> void:
	section("10. Vitória e Expurgamento: Selamento de Fendas e Recompensas Lendárias")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb_sys: Node = bosses.call("world_boss_system")
	wb_sys.call("reset_cycle")
	wb_sys.call("trigger_spawn")

	var inv_sys: Node = wb_sys.call("get_invasion_system")
	inv_sys.call("start_invasion", &"REG-001", DemonicInvasionSystemScript.Phase.EXPANSION)

	var defeat_cap := capture(EventBus.world_boss_defeated)

	# Slays Azaroth
	wb_sys.call("apply_damage", Invariants.WORLD_BOSS_MAX_HEALTH * 2.0)
	check_true(bool(wb_sys.call("is_defeated")), "Azaroth derrotado")
	check_true(defeat_cap.count() >= 1, "sinal world_boss_defeated emitido")

	# Território é expurgado imediatamente
	check_true(is_equal_approx(float(inv_sys.call("get_corruption_level")), 0.0), "nível de corrupção zerado")
	check_eq(int(inv_sys.call("get_fissures_count")), 0, "todas as fendas demoníacas foram seladas")
	check_eq(int(inv_sys.call("get_current_phase")), int(DemonicInvasionSystemScript.Phase.CLEANSED), "status territorial é CLEANSED")

	# Recompensas registradas
	var rewards: Dictionary = wb_sys.call("boss_data").get("rewards")
	check_true(int(rewards.get("xp", 0)) >= 10000, "recompensa de XP concedida (>= 10.000)")
	check_true(int(rewards.get("gold", 0)) >= 5000, "recompensa de Ouro concedida (>= 5.000)")
	check_true(rewards.has("title"), "título de prestígio Flagelo de Azaroth presente")
	check_true(rewards.has("mythic_essence"), "essência mítica do Devorador presente")
	check_true(rewards.has("achievement_id"), "conquista de derrota de Azaroth presente")

	wb_sys.call("reset_cycle")
