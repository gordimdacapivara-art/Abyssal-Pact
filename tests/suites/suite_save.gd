extends TestCase
## Suite SAVE — ciclo completo: coleta por contribuidores → JSON → aplicação.

const SLOT := 97
const EMPTY_SLOT := 98

func system_label() -> String:
	return "save"

func execute() -> void:
	section("Preparação: estado espalhado por 4 gerenciadores")
	var characters := system(SystemNames.CHARACTER)
	var character: Resource = characters.call("create_character", "Portador de Save", &"RACE-001", &"SUBRACE-001", &"CLASS-001")
	check_not_null(character, "personagem de suporte criado")
	var char_id: StringName = character.id
	check_err(characters.call("select_character", char_id), OK, "seleção incluída no save")
	check_err(system(SystemNames.INVENTORY).call("add_item", char_id, &"EQ-001", 2), OK, "item incluído no save")
	check_err(system(SystemNames.QUESTS).call("accept_quest", char_id, &"QUEST-001"), OK, "missão incluída no save")
	check_err(system(SystemNames.QUESTS).call("progress_objective", char_id, &"QUEST-001", &"OBJ-001", 1), OK,
		"progresso parcial incluído no save")
	var world := system(SystemNames.WORLD)
	check_ne(String(world.call("create_private_world", "Mundo do Save", Invariants.HOST_PEER_ID)), "",
		"mundo incluído no save")
	check_err(world.call("add_participant", 2), OK, "participante incluído no save")
	check_eq(String(world.call("resolve_respawn", Invariants.HOST_PEER_ID)), "hell_forge",
		"ressurgimento pendente incluído no save (retorno = hub)")

	section("Save: coleta + JSON com sinal")
	var waiter_saved := capture(EventBus.save_completed)
	check_err(system(SystemNames.SAVE).call("save_slot", SLOT), OK, "save do slot %d" % SLOT)
	check_eq(int(waiter_saved.first()[0]), SLOT, "evento carrega o slot salvo")
	var metadata: Dictionary = system(SystemNames.SAVE).call("read_slot_metadata", SLOT)
	check_eq(int(metadata.get("slot", -1)), SLOT, "metadados apontam o slot")
	check_eq(int(metadata.get("format_version", -1)), Invariants.SAVE_FORMAT_VERSION, "versão de formato registrada")
	var contributions: Array = metadata.get("contributions", [])
	for expected in ["World", "Character", "Inventory", "Quests"]:
		check_true(contributions.has(expected), "contribuição presente: %s" % expected)

	section("Mutação: estado diverge do save")
	check_true(characters.call("delete_character", char_id), "personagem excluído após o save")
	check_err(world.call("close_private_world"), OK, "mundo fechado após o save")
	check_err(system(SystemNames.INVENTORY).call("add_item", StringName("CHAR-000"), &"EQ-001", 5), OK,
		"inventário órfão criado para divergir")
	check_null(characters.call("get_character", char_id), "confirmação da mutação")

	section("Load: aplicação idempotente restaura o estado")
	var waiter_loaded := capture(EventBus.load_completed)
	check_err(system(SystemNames.SAVE).call("load_slot", SLOT), OK, "load do slot %d" % SLOT)
	check_eq(int(waiter_loaded.first()[0]), SLOT, "evento carrega o slot carregado")
	var restored: Resource = characters.call("get_character", char_id)
	check_not_null(restored, "personagem restaurado")
	check_eq(String(characters.call("selected_character_id")), String(char_id), "seleção restaurada")
	check_eq(int(restored.progression.experience), 0, "progressão mínima preservada")
	check_eq(system(SystemNames.INVENTORY).call("count_item", char_id, &"EQ-001"), 2, "inventário restaurado (2 itens)")
	check_eq(system(SystemNames.INVENTORY).call("count_item", StringName("CHAR-000"), &"EQ-001"), 0,
		"inventário órfão é descartado pela carga (estado substituído)")
	var restored_world: Resource = world.call("active_world")
	check_not_null(restored_world, "mundo restaurado")
	check_eq(int(restored_world.participant_count()), 2, "roster do mundo restaurado (2 participantes)")
	check_eq(String(restored_world.pending_respawns.get("1", "")), "hell_forge",
		"ressurgimento pendente aponta para o hub Hell Forge")

	section("Falhas documentadas: slot inválido e slot inexistente")
	var waiter_save_failed := capture(EventBus.save_failed)
	check_err(system(SystemNames.SAVE).call("save_slot", -1), FAILED, "save de slot negativo falha")
	check_eq(int(waiter_save_failed.first()[0]), -1, "evento de falha carrega o slot")
	system(SystemNames.SAVE).call("delete_slot", EMPTY_SLOT) # limpa resíduo de execuções anteriores
	var waiter_load_failed := capture(EventBus.load_failed)
	check_err(system(SystemNames.SAVE).call("load_slot", EMPTY_SLOT), FAILED, "load de slot vazio falha")
	check_eq(int(waiter_load_failed.first()[0]), EMPTY_SLOT, "evento de falha de carga carrega o slot")

	section("Limpeza")
	check_err(system(SystemNames.SAVE).call("delete_slot", SLOT), OK, "slot de teste removido")
	check_err(system(SystemNames.SAVE).call("delete_slot", SLOT), ERR_FILE_NOT_FOUND, "remover slot ausente recusa")
	check_err(world.call("close_private_world"), OK, "mundo restaurado encerrado")
	check_true(characters.call("delete_character", char_id), "personagem restaurado removido")
