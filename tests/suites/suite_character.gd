extends TestCase
## Suite CHARACTER — criação, validação, seleção, progressão e descobertas.

func system_label() -> String:
	return "character"

func execute() -> void:
	section("Criação válida: catálogos respeitados + sinais")
	var characters := system(SystemNames.CHARACTER)
	var before_count: int = characters.call("character_count")
	var waiter_created := capture(EventBus.character_created)
	var character: Resource = characters.call("create_character", "Portador de Teste", &"RACE-001", &"SUBRACE-001", &"CLASS-001")
	var created_id: StringName = waiter_created.first()[0]
	check_not_null(character, "personagem válido deve ser criado")
	check_eq(String(created_id), String(character.id), "evento deve carregar o id do personagem")
	check_eq(characters.call("character_count"), before_count + 1, "roster deve crescer")

	section("Criação inválida: recusas documentadas")
	check_null(characters.call("create_character", "Sem classe", &"RACE-001", &"SUBRACE-001", &"CLASS-999"),
		"classe fora do catálogo recusa criação")
	check_null(characters.call("create_character", "Sub-raça errada", &"RACE-001", &"SUBRACE-999", &"CLASS-001"),
		"sub-raça fora do catálogo recusa criação")
	check_null(characters.call("create_character", "", &"RACE-001", &"SUBRACE-001", &"CLASS-001"),
		"nome vazio recusa criação")

	section("Vínculo raça/sub-raça validado na criação")
	check_null(characters.call("create_character", "Incompatível", &"RACE-001", &"SUBRACE-003", &"CLASS-001"),
		"sub-raça de outra raça-mãe recusa criação")

	section("Seleção com sinais e recusas")
	var waiter_selected := capture(EventBus.character_selected)
	check_err(characters.call("select_character", character.id), OK, "seleção de personagem criado")
	check_eq(StringName(waiter_selected.first()[0]), character.id, "evento de seleção carrega o id")
	check_err(characters.call("select_character", character.id), ERR_ALREADY_IN_USE, "re-seleção é recusada")
	check_err(characters.call("select_character", &"CHAR-999"), ERR_DOES_NOT_EXIST, "seleção inexistente é recusada")
	check_eq(String(characters.call("selected_character_id")), String(character.id), "seleção ativa preservada")

	section("Progressão mínima com sinais")
	var waiter_progress := capture(EventBus.progression_changed)
	check_err(characters.call("add_progression", character.id, &"experience", 15), OK, "xp positivo é aceito")
	var progress_args: Array = waiter_progress.first()
	check_eq(int(progress_args[2]), 15, "evento reporta o total de xp")
	check_err(characters.call("add_progression", character.id, &"experience", 0), ERR_INVALID_PARAMETER,
		"xp não-positivo é recusado")
	check_err(characters.call("add_progression", character.id, &"nivel", 1), ERR_INVALID_PARAMETER,
		"tipo sem regra definida é recusado (design pendente)")
	check_err(characters.call("add_progression", &"CHAR-999", &"experience", 1), ERR_DOES_NOT_EXIST,
		"progressão exige personagem existente")

	section("Descobertas: deduplicação e evento")
	var waiter_discovery := capture(EventBus.discovery_recorded)
	check_true(characters.call("record_discovery", character.id, &"demon", &"DEMON-001"),
		"primeira descoberta retorna true")
	check_eq(StringName(waiter_discovery.first()[0]), character.id, "evento carrega o personagem")
	check_false(characters.call("record_discovery", character.id, &"demon", &"DEMON-001"),
		"descoberta repetida retorna false")
	check_true(characters.call("record_discovery", character.id, &"demon", &"DEMON-999"),
		"log é agnóstico: registra qualquer ref_id (validação de domínio é do chamador)")

	section("Exclusão com sinal")
	var waiter_deleted := capture(EventBus.character_deleted)
	check_true(characters.call("delete_character", character.id), "exclusão do personagem criado")
	check_eq(StringName(waiter_deleted.first()[0]), character.id, "evento de exclusão carrega o id")
	check_null(characters.call("get_character", character.id), "personagem excluído não é retornado")
	check_eq(String(characters.call("selected_character_id")), "", "seleção é limpa ao excluir")
