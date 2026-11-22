extends TestCase
## Suite INTEGRATION — cadeia completa de sinais cruzando todos os domínios.
##
## Padrão de captura: cada capture() é armado ANTES da ação que emite o sinal,
## provando ordem e payload sem recorder externo. Não usa rede real: fluxo
## local determinístico (sessão de rede é coberta pela suite NET).

func system_label() -> String:
	return "integration"

func execute() -> void:
	section("Fluxo: personagem → mundo → missão → itens → save → limpeza")
	var characters := system(SystemNames.CHARACTER)
	var world := system(SystemNames.WORLD)
	var inventory_service := system(SystemNames.INVENTORY)
	var quests := system(SystemNames.QUESTS)
	var save_service := system(SystemNames.SAVE)

	var waiter_created := capture(EventBus.character_created)
	var character: Resource = characters.call("create_character", "Portador da Cadeia", &"RACE-001", &"SUBRACE-001", &"CLASS-001")
	var created_id: StringName = waiter_created.first()[0]
	check_not_null(character, "personagem criado")
	check_eq(String(created_id), String(character.id), "character_created carrega o id")

	var waiter_selected := capture(EventBus.character_selected)
	check_err(characters.call("select_character", character.id), OK, "seleção")
	check_eq(StringName(waiter_selected.first()[0]), character.id, "character_selected carrega o id")

	var waiter_world_created := capture(EventBus.world_created)
	var world_id: StringName = world.call("create_private_world", "Mundo da Cadeia", Invariants.HOST_PEER_ID)
	check_eq(StringName(waiter_world_created.first()[0]), world_id, "world_created carrega o id")

	var waiter_participant := capture(EventBus.participant_added)
	check_err(world.call("add_participant", 2), OK, "convidado entra")
	var participant_args: Array = waiter_participant.first()
	check_eq(int(participant_args[1]), 2, "participant_added carrega o convidado")

	var waiter_quest_accepted := capture(EventBus.quest_accepted)
	check_err(quests.call("accept_quest", character.id, &"QUEST-001"), OK, "missão aceita")
	var quest_args: Array = waiter_quest_accepted.first()
	check_eq(StringName(quest_args[0]), character.id, "quest_accepted carrega o personagem")

	var waiter_item := capture(EventBus.item_added)
	check_err(inventory_service.call("add_item", character.id, &"EQ-001", 1), OK, "item adicionado")
	var item_args: Array = waiter_item.first()
	check_eq(StringName(item_args[0]), character.id, "item_added carrega o personagem")

	var waiter_equipment := capture(EventBus.equipment_changed)
	check_err(inventory_service.call("equip_item", character.id, &"weapon", &"EQ-001"), OK, "item equipado")
	var equipment_args: Array = waiter_equipment.first()
	check_eq(StringName(equipment_args[2]), &"EQ-001", "equipment_changed carrega o item")

	var waiter_objective := capture(EventBus.objective_progress)
	var waiter_quest_done := capture(EventBus.quest_completed)
	check_err(quests.call("progress_objective", character.id, &"QUEST-001", &"OBJ-001", 1), OK, "progresso 1/2")
	check_err(quests.call("progress_objective", character.id, &"QUEST-001", &"OBJ-001", 1), OK, "progresso 2/2")
	var objective_args: Array = waiter_objective.first()
	check_eq(int(objective_args[3]), 1, "objetivo reporta progresso inicial")
	check_eq(String(quests.call("quest_state", character.id, &"QUEST-001")), "completed", "missão concluída pela cadeia")

	var waiter_respawn_requested := capture(EventBus.respawn_requested)
	var waiter_respawn_resolved := capture(EventBus.respawn_resolved)
	check_err(world.call("request_respawn", Invariants.HOST_PEER_ID), OK, "ressurgimento do anfitrião")
	check_eq(int(waiter_respawn_requested.first()[0]), Invariants.HOST_PEER_ID, "pedido carrega o anfitrião")
	var resolved_args: Array = waiter_respawn_resolved.first()
	check_eq(int(resolved_args[0]), Invariants.HOST_PEER_ID, "resolução carrega o anfitrião")
	check_eq(String(resolved_args[1]), "hell_forge", "invariante: destino é a Hell Forge")

	var waiter_saved := capture(EventBus.save_completed)
	check_err(save_service.call("save_slot", 96), OK, "save da cadeia no slot 96")
	check_eq(int(waiter_saved.first()[0]), 96, "save_completed carrega o slot")
	check_err(save_service.call("delete_slot", 96), OK, "slot de teste removido")

	var waiter_world_closed := capture(EventBus.world_closed)
	check_err(world.call("close_private_world"), OK, "mundo encerrado")
	check_eq(StringName(waiter_world_closed.first()[0]), world_id, "world_closed carrega o id")

	var waiter_deleted := capture(EventBus.character_deleted)
	check_true(characters.call("delete_character", character.id), "personagem excluído")
	check_eq(StringName(waiter_deleted.first()[0]), character.id, "character_deleted carrega o id")

	section("Estado final consistente (verificação agregada)")
	check_eq((Game.verify_all() as Dictionary).size(), 0, "verify_all limpo após a cadeia completa")
	check_null(system(SystemNames.WORLD).call("active_world"), "nenhum mundo residual")
