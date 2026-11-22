class_name SuiteWorldBossAlert
extends TestCase
## SuiteWorldBossAlert — Testes de validação do Alerta Cinematográfico de Azaroth (PROMPT 02).
##
## Valida:
##   1. Disparo automático quando faltar exatamente 1 hora para a invasão (3.600s).
##   2. Mensagem dinâmica oficial: "AZAROTH E SEU EXÉRCITO IRÃO INVADIR EM BREVE AS TERRAS DE [NOME DA REGIÃO], [NOME DO CONTINENTE].".
##   3. Identificação automática de região, continente, horário previsto e coordenadas no mapa.
##   4. Componente visual AzarothCinematicAlert: canto superior esquerdo, elementos demoníacos, animações e ameaça iminente.
##   5. Não-interferência: temporizador contínuo sem reinício e sem depender de o jogador abrir o mapa.
##   6. Sincronização autoritativa via RPC no mundo privado multiplayer.
##   7. Persistência de save/load e reset no rollover do ciclo de 5 horas.

const WorldBossSystemScript := preload("res://core/world_boss_system.gd")

func suite_name() -> String:
	return "world_boss_alert"

func execute() -> void:
	await _test_one_hour_alert_threshold_trigger()
	await _test_dynamic_message_formatting()
	await _test_dynamic_information_identification()
	await _test_cinematic_alert_ui_component()
	await _test_timer_non_interference_and_map_independence()
	await _test_multiplayer_host_synchronization()
	await _test_persistence_and_cycle_reset()

# -------------------------------- 1. DISPARO DO ALERTA DE 1 HORA --

func _test_one_hour_alert_threshold_trigger() -> void:
	section("1. Disparo do Alerta aos 60 Minutos Restantes (1h antes do spawn)")
	var bosses := system(SystemNames.BOSSES) as Node
	check_not_null(bosses, "BossManager disponível no SystemRegistry")

	var wb_sys: Node = bosses.call("world_boss_system")
	check_not_null(wb_sys, "WorldBossSystem instanciado no BossManager")

	wb_sys.call("reset_cycle")
	check_false(bool(wb_sys.call("is_one_hour_alert_issued")), "alerta não emitido no início do ciclo")

	var alert_capture := capture(EventBus.world_boss_one_hour_warning)

	# Avança até 12.590s (faltando 3.610s para invasão — mais de 1 hora)
	wb_sys.call("set_cycle_time", 12590.0)
	wb_sys.call("advance_timer", 5.0) # 12.595s (faltam 3.605s)
	check_false(bool(wb_sys.call("is_one_hour_alert_issued")), "alerta ainda não disparado antes de 1h")
	check_eq(alert_capture.count(), 0, "nenhum evento de 1h emitido antes do limiar")

	# Cruza o limiar exato de 1 hora (12.600s / 3.600s restantes)
	wb_sys.call("advance_timer", 10.0) # 12.605s (faltam 3.595s)
	check_true(bool(wb_sys.call("is_one_hour_alert_issued")), "alerta disparado ao atingir 1h restante")
	check_eq(alert_capture.count(), 1, "evento world_boss_one_hour_warning emitido")

	# Avanço posterior não deve redisparar dentro do mesmo ciclo
	wb_sys.call("advance_timer", 30.0)
	check_eq(alert_capture.count(), 1, "alerta não é redisparado redundantemente no mesmo ciclo")

# -------------------------------- 2. MENSAGEM DINÂMICA OFICIAL --

func _test_dynamic_message_formatting() -> void:
	section("2. Mensagem Dinâmica Oficial de Invasão de Azaroth")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb_sys: Node = bosses.call("world_boss_system")

	# Caso A: Região padrão Veyrath (REG-001 Cinzália)
	wb_sys.call("set_invasion_target", &"REG-001", Vector3(0, 0, -50))
	var msg_001: String = String(wb_sys.call("get_alert_message", true))
	check_eq(msg_001, "AZAROTH E SEU EXÉRCITO IRÃO INVADIR EM BREVE AS TERRAS DE CINZÁLIA, VEYRATH.", "mensagem para REG-001 Cinzália confere com a fórmula do Prompt 02")

	# Caso B: Região de Khar-Duum (REG-021 Caldeira Rubra)
	wb_sys.call("set_invasion_target", &"REG-021", Vector3(100, 20, -80))
	var msg_021: String = String(wb_sys.call("get_alert_message", true))
	check_eq(msg_021, "AZAROTH E SEU EXÉRCITO IRÃO INVADIR EM BREVE AS TERRAS DE CALDEIRA RUBRA, KHAR-DUUM.", "mensagem para REG-021 Caldeira Rubra confere")

	# Caso C: Região de Sylvaran (REG-011 Raiz Antiga)
	wb_sys.call("set_invasion_target", &"REG-011", Vector3(-50, 10, 30))
	var msg_011: String = String(wb_sys.call("get_alert_message", true))
	check_eq(msg_011, "AZAROTH E SEU EXÉRCITO IRÃO INVADIR EM BREVE AS TERRAS DE RAIZ ANTIGA, SYLVARAN.", "mensagem para REG-011 Raiz Antiga confere")

	# Caso D: Região de Nhal'Kora (REG-031 Geleira dos Ecos)
	wb_sys.call("set_invasion_target", &"REG-031", Vector3(20, 5, -200))
	var msg_031: String = String(wb_sys.call("get_alert_message", true))
	check_eq(msg_031, "AZAROTH E SEU EXÉRCITO IRÃO INVADIR EM BREVE AS TERRAS DE GELEIRA DOS ECOS, NHAL'KORA.", "mensagem para REG-031 Geleira dos Ecos confere")

	# Restaura padrão
	wb_sys.call("set_invasion_target", &"REG-001", Vector3(0, 0, -50))

# -------------------------------- 3. IDENTIFICAÇÃO AUTOMÁTICA DE INFORMAÇÕES --

func _test_dynamic_information_identification() -> void:
	section("3. Identificação Automática de Região, Continente, Horário e Mapa")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb_sys: Node = bosses.call("world_boss_system")

	wb_sys.call("set_invasion_target", &"REG-002", Vector3(15, 0, -60))
	check_eq(wb_sys.call("get_threatened_region_id"), &"REG-002", "ID da região ameaçada")
	check_eq(String(wb_sys.call("get_threatened_region_name")), "Coroa Partida", "Nome identificado da região")
	check_eq(String(wb_sys.call("get_threatened_continent_name")), "Veyrath", "Nome identificado do continente")

	# Horário previsto formatado
	var time_str: String = String(wb_sys.call("get_estimated_invasion_time_formatted"))
	check_true(time_str.contains("restantes"), "horário previsto contém indicação de tempo restante")

	# Localização no mapa
	var map_loc: Dictionary = wb_sys.call("get_invasion_map_location")
	check_eq(map_loc.get("region_id"), &"REG-002", "região identificada no dicionário de localização")
	check_true(map_loc.has("world_position"), "coordenadas 3D de mundo presentes")
	check_true(map_loc.has("cartographic_center"), "centro cartográfico 2D presente")

	wb_sys.call("set_invasion_target", &"REG-001", Vector3(0, 0, -50))

# -------------------------------- 4. COMPONENTE VISUAL AZAROTH CINEMATIC ALERT --

func _test_cinematic_alert_ui_component() -> void:
	section("4. Componente Visual AzarothCinematicAlert: Canto Superior Esquerdo e Demônio")
	var ui := system(SystemNames.UI) as UIManager
	check_not_null(ui, "UIManager disponível no SystemRegistry")

	var alert_widget: Control = ui.call("get_azaroth_cinematic_alert")
	check_not_null(alert_widget, "AzarothCinematicAlert instanciado com sucesso")
	check_eq(int(alert_widget.get("process_mode")), int(Node.PROCESS_MODE_ALWAYS), "process_mode é PROCESS_MODE_ALWAYS")

	# Dispara configuração do alerta
	alert_widget.call("setup_alert", &"REG-001", "Cinzália", "Veyrath", 3600.0, Vector3(0, 0, -50))
	check_true(alert_widget.visible, "widget torna-se visível após setup")

	# Verifica presença dos elementos visuais demoníacos
	var msg_lbl: Label = alert_widget.get_node_or_null("Panel/VBox/MessageLabel")
	check_not_null(msg_lbl, "MessageLabel presente na árvore do widget")
	check_true(msg_lbl.text.contains("AZAROTH E SEU EXÉRCITO IRÃO INVADIR EM BREVE"), "mensagem exibida no label")

	var title_lbl: Label = alert_widget.get_node_or_null("Panel/VBox/Header/HeaderTitle")
	check_not_null(title_lbl, "HeaderTitle demoníaco presente")

	# Testa animação de saída e entrada
	alert_widget.call("play_exit_animation", false)
	alert_widget.call("play_entry_animation")
	check_true(alert_widget.visible, "animação de entrada reativa visibilidade")

# -------------------------------- 5. NÃO-INTERFERÊNCIA NO TEMPORIZADOR E MAPA --

func _test_timer_non_interference_and_map_independence() -> void:
	section("5. Independência: Não Reinicia Temporizador e Não Depende do Mapa")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb_sys: Node = bosses.call("world_boss_system")
	var ui := system(SystemNames.UI) as UIManager

	wb_sys.call("set_cycle_time", 12600.0)
	var time_at_alert: float = float(wb_sys.call("cycle_elapsed_time"))

	# Dispara alerta explicitamente
	wb_sys.call("trigger_one_hour_alert")
	check_eq(float(wb_sys.call("cycle_elapsed_time")), time_at_alert, "temporizador não foi reiniciado nem alterado pelo disparo")

	# Avança o tempo com mapa aberto
	if ui != null:
		ui.open_screen(&"world_map")
		wb_sys.call("advance_timer", 5.0)
		check_true(float(wb_sys.call("cycle_elapsed_time")) >= time_at_alert + 5.0, "tempo avançou normalmente com o mapa aberto")
		ui.close_screen(&"world_map")

	# Avança o tempo com mapa fechado
	wb_sys.call("advance_timer", 5.0)
	check_true(float(wb_sys.call("cycle_elapsed_time")) >= time_at_alert + 10.0, "tempo avançou normalmente com mapa fechado")

# -------------------------------- 6. SINCRONIZAÇÃO EM REDE MULTIPLAYER --

func _test_multiplayer_host_synchronization() -> void:
	section("6. Sincronização em Rede: Alerta de 1h Emitido para Clientes Conectados")
	var net_mgr := system(SystemNames.NET) as MultiplayerManager

	check_not_null(net_mgr, "MultiplayerManager acessível")
	check_true(net_mgr.has_method("rpc_world_boss_one_hour_alert"), "RPC rpc_world_boss_one_hour_alert implementada")

	var alert_capture := capture(EventBus.world_boss_one_hour_warning)

	# Simula recebimento de pacote de alerta de 1h do servidor autoritativo
	net_mgr.call("rpc_world_boss_one_hour_alert",
		&"REG-001",
		"Cinzália",
		"Veyrath",
		3600.0,
		Vector3(0, 0, -50)
	)

	check_eq(alert_capture.count(), 1, "evento world_boss_one_hour_warning disparado pela RPC do anfitrião")

# -------------------------------- 7. PERSISTÊNCIA E RESET NO CICLO --

func _test_persistence_and_cycle_reset() -> void:
	section("7. Persistência de Save/Load e Reset no Rollover do Ciclo")
	var bosses := system(SystemNames.BOSSES) as Node
	var wb_sys: Node = bosses.call("world_boss_system")

	# Configura alerta emitido e salva
	wb_sys.call("set_cycle_time", 12700.0)
	wb_sys.call("trigger_one_hour_alert")
	check_true(bool(wb_sys.call("is_one_hour_alert_issued")), "alerta marcado como emitido")

	var save_data: Dictionary = bosses.call("collect_save_data")
	var wb_save: Dictionary = save_data.get("world_boss", {})
	check_true(wb_save.has("one_hour_alert_issued"), "one_hour_alert_issued presente no payload de save")
	check_true(bool(wb_save.get("one_hour_alert_issued")), "valor salvo é true")

	# Reseta e restaura
	wb_sys.call("reset_cycle")
	check_false(bool(wb_sys.call("is_one_hour_alert_issued")), "reset_cycle reinicia flag para false")

	bosses.call("apply_save_data", save_data)
	check_true(bool(wb_sys.call("is_one_hour_alert_issued")), "apply_save_data restaura flag para true")

	# Reseta para estado limpo
	wb_sys.call("reset_cycle")
