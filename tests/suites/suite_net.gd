extends TestCase
## Suite NET — sessões privadas: invariantes, roster com gancho de teste e
## host real (loopback ENet provisório).

const HOST_PORT_BASE := 24565

func system_label() -> String:
	return "net"

func execute() -> void:
	section("Invariantes de produto expostos pela API")
	var net := system(SystemNames.NET)
	check_eq(int(net.call("max_participants")), 8, "limite total de 8 (anfitrião incluído)")
	check_false(net.call("is_session_active"), "sem sessão ativa no início")
	check_err(net.call("join_private_world", "", 24565), ERR_INVALID_PARAMETER,
		"endereço vazio é recusado fora de sessão")

	section("Roster via gancho de teste: limite e sinais")
	var net_waiter_registered := capture(EventBus.peer_registered)
	check_err(net.call("debug_register_participant", 2, "Convidado 2"), OK, "peer 2 registrado")
	var registered_args: Array = net_waiter_registered.first()
	check_eq(int(registered_args[0]), 2, "evento carrega o peer")
	for peer_id in range(3, 9):
		check_err(net.call("debug_register_participant", peer_id), OK, "peer %d registrado" % peer_id)
	check_err(net.call("debug_register_participant", 9), OK, "peer 9 completa o roster (8/8)")
	var waiter_limit := capture(EventBus.peer_limit_rejected)
	check_err(net.call("debug_register_participant", 10), FAILED, "9º peer é recusado (8 já ocupados)")
	check_eq(int(waiter_limit.first()[0]), 10, "evento de recusa carrega o peer")
	check_eq(int(net.call("participant_count")), 8, "roster fecha em 8")
	net.call("debug_clear_roster")

	section("Hospedagem real (loopback): sessão privada + mundo espelhado")
	var world := system(SystemNames.WORLD)
	var port: int = HOST_PORT_BASE + (randi() % 500)
	var waiter_hosted := capture(EventBus.session_hosted)
	var host_result: int = net.call("host_private_world", "Sessão de Teste", port)
	check_err(host_result, OK, "hospedar sessão privada em localhost:%d" % port)
	var hosted_args: Array = waiter_hosted.first()
	check_eq(int(hosted_args[1]), port, "evento carrega a porta")
	check_true(net.call("is_session_active"), "sessão ativa após hospedar")
	check_true(net.call("is_host"), "hospedador é reconhecido como anfitrião")
	check_eq(int(net.call("participant_count")), 1, "roster inicia apenas com o anfitrião")
	check_ne(String(net.call("invite_code")), "", "código de convite gerado (validação pendente)")

	section("Mundo espelhado: hospedagem cria o mundo automaticamente")
	check_not_null(world.call("active_world"),
		"WorldManager escuta session_hosted e cria o mundo espelhado (sem create manual)")

	section("Conexão enquanto ativo é recusada (uma sessão por instância)")
	check_err(net.call("join_private_world", "127.0.0.1", port), ERR_ALREADY_IN_USE,
		"conectar com sessão ativa recusa")
	check_err(net.call("host_private_world", "Outra", port + 1), ERR_ALREADY_IN_USE,
		"hospedar com sessão ativa recusa")

	section("Saída da sessão encerra o mundo espelhado")
	var waiter_session_left := capture(EventBus.session_left)
	var waiter_world_closed := capture(EventBus.world_closed)
	check_err(net.call("leave_session", "teste"), OK, "sair da sessão")
	check_eq(waiter_session_left.count(), 1, "session_left emitido ao sair")
	check_eq(waiter_world_closed.count(), 1, "world_closed emitido com a sessão encerrada")
	check_false(net.call("is_session_active"), "sessão encerrada")
	check_null(world.call("active_world"), "mundo local encerrado com a sessão")
	check_eq(int(net.call("participant_count")), 0, "roster limpo")

	section("Verificação de integridade pós-teste")
	check_eq((Game.verify_all() as Dictionary).size(), 0, "nenhum sistema reporta issues após o fluxo de rede")
