extends TestCase
## Suite QUEST — catálogo de missões, aceitar, progredir, concluir e abandonar.
## Regra da máquina de estados mínima: uma entrada por missão no diário
## (aceite recusa enquanto a entrada existir, em qualquer estado).

func system_label() -> String:
	return "quest"

func execute() -> void:
	var characters := system(SystemNames.CHARACTER)
	var quests := system(SystemNames.QUESTS)

	# Personagem A: fluxo de abandono (missão ativa → abandoned).
	var character_a := characters.call("create_character", "Portador de Missões", &"RACE-001", &"SUBRACE-001", &"CLASS-001") as CharacterData
	check_not_null(character_a, "personagem A criado")
	var char_a: StringName = character_a.id

	section("Aceitar missão com sinal e guarda de duplicidade")
	var waiter_accepted := capture(EventBus.quest_accepted)
	check_err(quests.call("accept_quest", char_a, &"QUEST-001"), OK, "missão do catálogo é aceita")
	var accepted_args: Array = waiter_accepted.first()
	check_eq(StringName(accepted_args[1]), &"QUEST-001", "evento carrega a missão")
	check_err(quests.call("accept_quest", char_a, &"QUEST-001"), ERR_ALREADY_IN_USE, "missão já ativa recusa")
	check_err(quests.call("accept_quest", char_a, &"QUEST-999"), ERR_DOES_NOT_EXIST, "missão fora do catálogo")
	check_eq(String(quests.call("quest_state", char_a, &"QUEST-001")), "active", "estado inicial é 'active'")

	section("Abandono de missão ativa com sinal")
	var waiter_abandoned := capture(EventBus.quest_abandoned)
	check_err(quests.call("abandon_quest", char_a, &"QUEST-001"), OK, "abandono de missão ativa")
	var abandoned_args: Array = waiter_abandoned.first()
	check_eq(StringName(abandoned_args[1]), &"QUEST-001", "evento de abandono carrega a missão")
	check_eq(String(quests.call("quest_state", char_a, &"QUEST-001")), "abandoned", "estado 'abandoned'")
	check_err(quests.call("abandon_quest", char_a, &"QUEST-001"), ERR_DOES_NOT_EXIST, "abandonar duas vezes recusa")
	check_err(quests.call("accept_quest", char_a, &"QUEST-001"), ERR_ALREADY_IN_USE,
		"entrada abandonada impede re-aceite (uma entrada por missão)")
	check_err(quests.call("progress_objective", char_a, &"QUEST-001", &"OBJ-001", 1), ERR_DOES_NOT_EXIST,
		"progresso em missão abandonada recusa")

	# Personagem B: fluxo de progresso e conclusão (diário limpo).
	var character_b := characters.call("create_character", "Portador de Conclusão", &"RACE-001", &"SUBRACE-001", &"CLASS-001") as CharacterData
	check_not_null(character_b, "personagem B criado")
	var char_b: StringName = character_b.id
	check_err(quests.call("accept_quest", char_b, &"QUEST-001"), OK, "missão aceita pelo personagem B")

	section("Progresso de objetivo clampado à meta (required=2)")
	var waiter_progress_1 := capture(EventBus.objective_progress)
	check_err(quests.call("progress_objective", char_b, &"QUEST-001", &"OBJ-001", 1), OK, "progresso 1")
	var progress_1: Array = waiter_progress_1.first()
	check_eq(int(progress_1[3]), 1, "primeiro progresso reporta valor 1")
	check_eq(int(progress_1[4]), 2, "meta é reportada junto")

	var waiter_completed := capture(EventBus.quest_completed)
	check_err(quests.call("progress_objective", char_b, &"QUEST-001", &"OBJ-001", 1), OK, "progresso final")
	check_eq(String(quests.call("quest_state", char_b, &"QUEST-001")), "completed", "estado final é 'completed'")
	check_err(quests.call("progress_objective", char_b, &"QUEST-001", &"OBJ-001", 1), ERR_DOES_NOT_EXIST,
		"progresso após conclusão recusa (entrada não está ativa)")

	section("Guardas de objetivo")
	check_err(quests.call("progress_objective", char_b, &"QUEST-999", &"OBJ-001", 1), ERR_DOES_NOT_EXIST,
		"objetivo exige missão em diário ativo")
	check_err(quests.call("progress_objective", char_b, &"QUEST-001", &"OBJ-999", 1), ERR_DOES_NOT_EXIST,
		"objetivo fora da missão recusa")

	check_true(characters.call("delete_character", char_a), "limpeza do personagem A")
	check_true(characters.call("delete_character", char_b), "limpeza do personagem B")
