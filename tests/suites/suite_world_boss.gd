class_name SuiteWorldBoss
extends TestCase
## SuiteWorldBoss — Testes de validação do Sistema Global de World Boss: Azaroth (PROMPT 01).
##
## Valida:
##   1. Azaroth como o único World Boss do jogo (WB-AZAROTH).
##   2. Ciclo persistente de 5 horas (18.000s) por mundo privado.
##   3. Sincronização do temporizador entre participantes de sessão.
##   4. Processamento contínuo independente de menus, mapas e interfaces abertas.
##   5. Salvamento e restauração fidedignos de progresso do ciclo.
##   6. Imunidade a reinício em trocas de telas, mapas ou regiões.
##   7. Combate de 4 fases, dano, derrota e fuga por tempo esgotado.

const WorldBossSystemScript := preload("res://core/world_boss_system.gd")

func suite_name() -> String:
	return "world_boss"

func execute() -> void:
	await _test_azaroth_single_world_boss_identity()
	await _test_five_hour_persistent_cycle()
	await _test_cycle_states_and_transitions()
	await _test_combat_phases_and_damage()
	await _test_defeat_and_retreat_outcomes()
	await _test_ui_and_menu_independence()
	await _test_save_load_persistence()
	await _test_multiplayer_host_synchronization()

# -------------------------------- 1. IDENTIDADE ÚNICA DE AZAROTH --

func _test_azaroth_single_world_boss_identity() -> void:
	section("1. Azaroth: Identidade Única como World Boss Global")
	var bosses := system(SystemNames.BOSSES) as Node
	check_not_null(bosses, "BossManager disponível no SystemRegistry")

	var wb_sys: Node = bosses.call("world_boss_system")
	check_not_null(wb_sys, "WorldBossSystem instanciado no BossManager")

	var data: Resource = wb_sys.call("boss_data")
	check_not_null(data, "WorldBossData carregado com sucesso")
	check_eq(data.get("id"), Invariants.WORLD_BOSS_ID, "id canônico de Azaroth é WB-AZAROTH")
	check_eq(String(data.get("display_name")), Invariants.WORLD_BOSS_NAME, "nome canônico correto")
	check_eq(float(data.get("max_health")), Invariants.WORLD_BOSS_MAX_HEALTH, "vida colossal de 1.000.000 HP")
	check_eq((data.get("phases") as Array).size(), 4, "possui exatamente 4 fases de combate")

	# Catálogo regional de chefes mantém integridade isolada (30 chefes de masmorra)
	var regional_bosses: Array = bosses.call("bosses")
	check_eq(regional_bosses.size(), 30, "catálogo regional de chefes permanece com 30 entradas isoladas")
	check_false(bool(bosses.call("has_boss", Invariants.WORLD_BOSS_ID)), "Azaroth não se confunde com chefe regional comum")

# -------------------------------- 2. CICLO PERSISTENTE DE 5 HORAS --

func _test_five_hour_persistent_cycle() -> void:
	section("2. Ciclo de 5 Horas (18.000 segundos) por Mundo Privado")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb_sys: Node = bosses.call("world_boss_system")

	check_eq(WorldBossSystemScript.CYCLE_DURATION_SECONDS, 18000.0, "duração total do ciclo é de 18.000s (5 horas)")
	check_eq(WorldBossSystemScript.DORMANT_DURATION, 15300.0, "calmaria/dormência de 15.300s (4h 15m)")
	check_eq(WorldBossSystemScript.WARNING_DURATION, 900.0, "aviso prévio de 900s (15 minutos)")
	check_eq(WorldBossSystemScript.COMBAT_DURATION, 1800.0, "janela de combate de 1.800s (30 minutos)")

	wb_sys.call("reset_cycle")
	check_eq(float(wb_sys.call("cycle_elapsed_time")), 0.0, "ciclo inicia em 0.0s")
	check_eq(float(wb_sys.call("time_remaining_in_cycle")), 18000.0, "tempo restante inicial é 18.000s")
	check_eq(String(wb_sys.call("formatted_time_remaining")), "05:00:00", "tempo formatado inicial é 05:00:00")
	check_true(bool(wb_sys.call("is_dormant")), "estado inicial é DORMANT")

# -------------------------------- 3. TRANSIÇÕES DE ESTADO DO CICLO --

func _test_cycle_states_and_transitions() -> void:
	section("3. Transições de Estado: Dormant -> Warning -> Active -> Rollover")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb_sys: Node = bosses.call("world_boss_system")

	var state_capture := capture(EventBus.world_boss_state_changed)
	var warn_capture := capture(EventBus.world_boss_warning_issued)
	var spawn_capture := capture(EventBus.world_boss_spawned)

	# Avança até a véspera do Warning (15.290s)
	wb_sys.call("reset_cycle")
	wb_sys.call("set_cycle_time", 15290.0)
	wb_sys.call("advance_timer", 5.0) # 15.295s
	check_true(bool(wb_sys.call("is_dormant")), "permanece DORMANT antes dos 15.300s")

	# Cruza o limiar de WARNING (15.300s / 15 minutos restantes)
	wb_sys.call("advance_timer", 10.0) # 15.305s
	check_true(bool(wb_sys.call("is_warning")), "transiciona para WARNING aos 15.300s")
	check_eq(state_capture.count(), 1, "evento world_boss_state_changed emitido")
	check_eq(warn_capture.count(), 1, "evento world_boss_warning_issued emitido")
	check_true(float(wb_sys.call("time_until_spawn")) <= 900.0, "tempo até spawn é menor ou igual a 15 minutos")

	# Cruza o limiar de ACTIVE (16.200s / Azaroth desperta)
	wb_sys.call("set_cycle_time", 16195.0)
	wb_sys.call("advance_timer", 10.0) # 16.205s
	check_true(bool(wb_sys.call("is_active")), "transiciona para ACTIVE aos 16.200s")
	check_eq(spawn_capture.count(), 1, "evento world_boss_spawned emitido")
	check_true(float(wb_sys.call("time_remaining_in_combat")) <= 1800.0, "janela de combate de 30 minutos ativa")

	# Rollover do ciclo de 5 horas para o Ciclo 2
	wb_sys.call("set_cycle_time", 17995.0)
	var initial_cycle: int = int(wb_sys.call("cycle_count"))
	wb_sys.call("advance_timer", 10.0) # ultrapassa 18.000s
	check_eq(int(wb_sys.call("cycle_count")), initial_cycle + 1, "contador de ciclos incrementado para ciclo seguinte")
	check_true(bool(wb_sys.call("is_dormant")), "ciclo reinicia em DORMANT")
	check_true(float(wb_sys.call("cycle_elapsed_time")) < 10.0, "tempo do ciclo resetado com overflow correto")

# -------------------------------- 4. FASES DE COMBATE E DANO --

func _test_combat_phases_and_damage() -> void:
	section("4. Fases de Combate (4 Fases) e Aplicação de Dano")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb_sys: Node = bosses.call("world_boss_system")

	wb_sys.call("trigger_spawn")
	check_true(bool(wb_sys.call("is_active")), "Azaroth ativo para combate")
	check_eq(int(wb_sys.call("current_phase")), 1, "inicia na Fase 1")
	check_eq(float(wb_sys.call("current_hp")), 1000000.0, "HP máximo de 1.000.000")

	var phase_capture := capture(EventBus.world_boss_phase_transitioned)
	var hp_capture := capture(EventBus.world_boss_health_changed)

	# Causa dano até 74% (transiciona para Fase 2 aos 75%)
	wb_sys.call("apply_damage", 260000.0, Invariants.HOST_PEER_ID)
	check_eq(int(wb_sys.call("current_phase")), 2, "transiciona para Fase 2 aos 74% HP")
	check_eq(phase_capture.count(), 1, "evento world_boss_phase_transitioned emitido para Fase 2")

	# Causa dano até 49% (transiciona para Fase 3 aos 50%)
	wb_sys.call("apply_damage", 250000.0, Invariants.HOST_PEER_ID)
	check_eq(int(wb_sys.call("current_phase")), 3, "transiciona para Fase 3 aos 49% HP")

	# Causa dano até 24% (transiciona para Fase 4 / Enrage aos 25%)
	wb_sys.call("apply_damage", 250000.0, Invariants.HOST_PEER_ID)
	check_eq(int(wb_sys.call("current_phase")), 4, "transiciona para Fase 4 (Enrage) aos 24% HP")
	check_true(float(wb_sys.call("current_hp")) > 0.0, "permanece vivo até 0 HP")

# -------------------------------- 5. DESFECHOS: DERROTA E FUGA --

func _test_defeat_and_retreat_outcomes() -> void:
	section("5. Desfechos de Encontro: Vitória dos Jogadores vs Fuga Abissal")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb_sys: Node = bosses.call("world_boss_system")

	# Caso A: Vitória por derrota total
	wb_sys.call("trigger_spawn")
	var defeat_capture := capture(EventBus.world_boss_defeated)
	var cur_hp: float = float(wb_sys.call("current_hp"))
	wb_sys.call("apply_damage", cur_hp, Invariants.HOST_PEER_ID)

	check_true(bool(wb_sys.call("is_defeated")), "estado torna-se DEFEATED após HP zerar")
	check_eq(defeat_capture.count(), 1, "evento world_boss_defeated emitido")
	check_true(int(wb_sys.call("total_defeats")) >= 1, "total de derrotas registrado")

	# Caso B: Fuga por esgotamento do tempo de combate (30m)
	wb_sys.call("trigger_spawn")
	var retreat_capture := capture(EventBus.world_boss_retreated)
	# Avança 30 minutos no combate até o esgotamento do tempo
	wb_sys.call("advance_timer", 1800.0)

	check_true(bool(wb_sys.call("is_retreated")), "estado torna-se RETREATED após expirar os 30m de combate")
	check_eq(retreat_capture.count(), 1, "evento world_boss_retreated emitido")
	check_true(int(wb_sys.call("total_retreats")) >= 1, "total de fugas registrado")

# -------------------------------- 6. INDEPENDÊNCIA DE INTERFACES E TELAS --

func _test_ui_and_menu_independence() -> void:
	section("6. Independência de Interface: Processamento Contínuo sem Resets")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb_sys: Node = bosses.call("world_boss_system")
	var ui := system(SystemNames.UI) as UIManager

	check_eq(int(wb_sys.get("process_mode")), int(Node.PROCESS_MODE_ALWAYS), "process_mode é PROCESS_MODE_ALWAYS")

	wb_sys.call("set_cycle_time", 3600.0)
	var time_before: float = float(wb_sys.call("cycle_elapsed_time"))

	# Simula abertura e fechamento de Mapa-Múndi
	if ui != null:
		var w_screen = ui.open_screen(&"world_map")
		check_not_null(w_screen, "WorldMapScreen aberta com sucesso")
		# Avança simulação
		wb_sys.call("_process", 1.5)
		check_true(float(wb_sys.call("cycle_elapsed_time")) > time_before, "temporizador continuou avançando com mapa aberto")

		# Fecha a tela
		ui.close_screen(&"world_map")
		wb_sys.call("_process", 1.0)
		check_true(float(wb_sys.call("cycle_elapsed_time")) >= time_before + 2.5, "temporizador continuou avançando após fechar mapa")

	# Widget HUD
	if ui != null and ui.has_method("get_world_boss_widget"):
		var widget: Control = ui.call("get_world_boss_widget")
		check_not_null(widget, "WorldBossWidget instanciado pelo UIManager")
		check_eq(int(widget.get("process_mode")), int(Node.PROCESS_MODE_ALWAYS), "widget possui PROCESS_MODE_ALWAYS")

# -------------------------------- 7. PERSISTÊNCIA E SALVAMENTO --

func _test_save_load_persistence() -> void:
	section("7. Persistência de Save/Load: Retomada Exata do Segundo do Ciclo")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb_sys: Node = bosses.call("world_boss_system")

	# Configura estado específico no meio de uma invasão
	wb_sys.call("trigger_spawn")
	wb_sys.call("apply_damage", 350000.0, Invariants.HOST_PEER_ID) # Fase 2
	var target_time: float = 16543.25
	wb_sys.call("set_cycle_time", target_time)

	# Coleta save data
	var save_data: Dictionary = bosses.call("collect_save_data")
	check_false(save_data.is_empty(), "BossManager coleta dados de save")
	check_true(save_data.has("world_boss"), "chave world_boss presente no payload de save")

	var wb_data: Dictionary = save_data.get("world_boss", {})
	check_eq(String(wb_data.get("boss_id", "")), String(Invariants.WORLD_BOSS_ID), "id de Azaroth salvo")
	check_eq(float(wb_data.get("cycle_time", 0.0)), target_time, "tempo exato salvo")
	check_eq(int(wb_data.get("state", -1)), int(WorldBossSystemScript.State.ACTIVE), "estado ACTIVE salvo")

	# Modifica e reseta para testar restauração
	wb_sys.call("reset_cycle")
	check_eq(float(wb_sys.call("cycle_elapsed_time")), 0.0, "sistema resetado para teste")

	# Aplica save data
	bosses.call("apply_save_data", save_data)
	check_eq(float(wb_sys.call("cycle_elapsed_time")), target_time, "tempo exato restaurado com sucesso")
	check_true(bool(wb_sys.call("is_active")), "estado ACTIVE restaurado")
	check_eq(float(wb_sys.call("current_hp")), 650000.0, "vida do chefe restaurada")
	check_eq(int(wb_sys.call("current_phase")), 2, "fase de combate restaurada")

# -------------------------------- 8. SINCRONIZAÇÃO EM REDE MULTIPLAYER --

func _test_multiplayer_host_synchronization() -> void:
	section("8. Sincronização em Rede: Servidor Privado e Clientes Compartilhados")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb_sys: Node = bosses.call("world_boss_system")

	# Simula recebimento de pacote de sincronização de anfitrião
	var sync_time: float = 15500.0 # Warning
	wb_sys.call("apply_network_sync",
		int(WorldBossSystemScript.State.WARNING),
		sync_time,
		WorldBossSystemScript.CYCLE_DURATION_SECONDS,
		1000000.0,
		1000000.0,
		1,
		&"REG-001",
		Vector3(0, 0, -50)
	)

	check_true(bool(wb_sys.call("is_warning")), "cliente adotou estado WARNING do anfitrião")
	check_eq(float(wb_sys.call("cycle_elapsed_time")), sync_time, "tempo sincronizado com precisão")
	check_eq(wb_sys.call("invasion_region"), &"REG-001", "região de invasão sincronizada")

	# Simula sincronização de dano em combate
	wb_sys.call("sync_health_from_network", 500000.0, 1000000.0, 3)
	check_eq(float(wb_sys.call("current_hp")), 500000.0, "vida sincronizada em rede")
	check_eq(int(wb_sys.call("current_phase")), 3, "fase sincronizada em rede")
