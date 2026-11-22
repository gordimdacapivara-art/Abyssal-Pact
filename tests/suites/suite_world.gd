extends TestCase
## Suite WORLD — sessão privada, limite de 8 (anfitrião incluído), regiões e
## ressurgimento obrigatório na Hell Forge.

func system_label() -> String:
	return "world"

func execute() -> void:
	var world := system(SystemNames.WORLD)

	section("Criação do mundo privado com sinal")
	var waiter_created := capture(EventBus.world_created)
	var world_id: StringName = world.call("create_private_world", "Mundo de Teste", Invariants.HOST_PEER_ID)
	var created_args: Array = waiter_created.first()
	check_ne(String(world_id), "", "world_id deve ser retornado")
	check_eq(String(created_args[0]), String(world_id), "evento carrega o id do mundo")
	check_eq(int(created_args[1]), Invariants.HOST_PEER_ID, "evento carrega o anfitrião")
	check_not_null(world.call("active_world"), "sessão ativa registrada")
	check_eq(int(world.call("max_participants")), 8, "limite de 8 exposto pela API")
	check_eq(Game.state, GameStates.State.WORLD, "GameManager reage a world_created com estado WORLD")

	section("Limite de 8 participantes (anfitrião incluído)")
	for participant in range(2, 9): # participantes 2..8 completam o roster
		check_err(world.call("add_participant", participant), OK, "participante %d entra" % participant)
	var rejected_waiter := capture(EventBus.participant_limit_rejected)
	check_err(world.call("add_participant", 9), FAILED, "9º participante é recusado")
	var rejected_args: Array = rejected_waiter.first()
	check_eq(int(rejected_args[1]), 9, "evento de recusa carrega o participante")
	check_err(world.call("add_participant", Invariants.HOST_PEER_ID), ERR_ALREADY_IN_USE,
		"anfitrião duplicado é recusado")
	check_eq(int(world.call("active_world").participant_count()), 8, "roster fecha em exatamente 8")

	section("Remoção de participante com sinal")
	var waiter_removed := capture(EventBus.participant_removed)
	check_err(world.call("remove_participant", 5), OK, "participante sai")
	check_err(world.call("remove_participant", 99), ERR_DOES_NOT_EXIST, "participante inexistente recusa")

	section("Região atual: só regiões catalogadas")
	var waiter_region := capture(EventBus.region_entered)
	check_err(world.call("enter_region", &"REG-001"), OK, "região placeholder é aceita")
	check_eq(StringName(waiter_region.first()[0]), &"REG-001", "evento carrega a região")
	check_eq(String(world.call("current_region_id")), "REG-001", "região corrente preservada")
	check_err(world.call("enter_region", &"REG-999"), ERR_DOES_NOT_EXIST, "região fora do catálogo recusa")

	section("Ressurgimento: destino obrigatório = Hell Forge (invariante)")
	var waiter_respawn_requested := capture(EventBus.respawn_requested)
	var waiter_respawn_resolved := capture(EventBus.respawn_resolved)
	check_err(world.call("request_respawn", 3), OK, "pedido de ressurgimento de participante válido")
	check_eq(int(waiter_respawn_requested.first()[0]), 3, "evento de pedido carrega o participante")
	var resolved_args: Array = waiter_respawn_resolved.first()
	check_eq(int(resolved_args[0]), 3, "resolução carrega o participante")
	check_eq(String(resolved_args[1]), "hell_forge", "destino é SEMPRE o hub Hell Forge")
	check_err(world.call("request_respawn", 99), ERR_DOES_NOT_EXIST, "ressurgimento exige participante no mundo")
	check_eq(String(world.call("resolve_respawn", 4)), "hell_forge",
		"resolve_respawn retorna o hub diretamente (invariante codificada)")

	section("Encerramento do mundo com sinal")
	var waiter_closed := capture(EventBus.world_closed)
	check_err(world.call("close_private_world"), OK, "mundo encerra")
	check_null(world.call("active_world"), "sessão limpa após encerrar")
	check_err(world.call("close_private_world"), ERR_UNAVAILABLE, "encerrar sem mundo ativo recusa")
