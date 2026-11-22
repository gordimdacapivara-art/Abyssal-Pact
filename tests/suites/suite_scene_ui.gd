extends TestCase
## Suite SCENE/UI — SceneManager (transições e params) e UIManager (router).

const HUB_SCENE := "res://scenes/world/hub_placeholder.tscn"
const BOOT_SCENE := "res://scenes/boot/boot.tscn"

func system_label() -> String:
	return "scene_ui"

func execute() -> void:
	await _test_scene_manager()
	await _test_ui_router()

func _test_scene_manager() -> void:
	section("SceneManager: troca para o hub Hell Forge com parâmetros")
	var scenes := system(SystemNames.SCENES)
	var waiter_started := capture(EventBus.scene_transition_started)
	var waiter_completed := capture(EventBus.scene_transition_completed)
	check_err(scenes.call("change_scene", HUB_SCENE, {"title": "Hell Forge (teste)"}), OK, "transição dispara")
	check_eq(String(waiter_started.first()[0]), HUB_SCENE, "evento de início carrega o caminho")
	await wait_frames(30) # a conclusão é assíncrona (chega em frames); espere antes das asserts de cena
	check_eq(String(waiter_completed.first()[0]), HUB_SCENE, "evento de conclusão carrega o caminho")
	check_eq(scenes.call("current_scene_path"), HUB_SCENE, "cena corrente é o hub")
	var hub := current_scene()
	check_not_null(hub, "cena corrente existe")
	check_true(hub.has_method("setup"), "cena do hub implementa o contrato setup(params)")
	var received: Dictionary = hub.call("received_params")
	check_eq(String(received.get("title", "")), "Hell Forge (teste)", "parâmetros entregues à cena")

	section("SceneManager: recusas documentadas")
	check_err(scenes.call("change_scene", "res://inexistente.tscn"), ERR_FILE_NOT_FOUND, "cena inexistente recusa")
	var waiter_failed := capture(EventBus.scene_transition_failed)
	check_err(scenes.call("change_scene", "res://nao_existe.tscn"), ERR_FILE_NOT_FOUND, "cena inexistente falha de novo")
	check_eq(String(waiter_failed.first()[0]), "res://nao_existe.tscn", "evento de falha carrega o caminho")

	section("SceneManager: retorno à cena de boot")
	var waiter_back := capture(EventBus.scene_transition_completed)
	check_err(scenes.call("change_scene", BOOT_SCENE), OK, "retorno à cena de boot")
	await wait_frames(30) # conclusão da troca chega em frames
	check_eq(String(waiter_back.first()[0]), BOOT_SCENE, "retorno concluído")
	check_eq(scenes.call("current_scene_path"), BOOT_SCENE, "cena corrente restaurada")

func _test_ui_router() -> void:
	section("UIManager: tela aberta no boot (estado MENU) e recusas")
	var ui := system(SystemNames.UI)
	check_true(ui.call("is_screen_open", &"main_menu"), "menu principal aberto pelo estado MENU pós-boot")
	check_eq(String(ui.call("current_screen_id")), "main_menu", "tela ativa é o menu principal")
	check_err(ui.call("open_screen", &"main_menu"), ERR_ALREADY_IN_USE, "abrir a mesma tela recusa")
	check_err(ui.call("open_screen", &"tela_inexistente"), ERR_DOES_NOT_EXIST, "tela não registrada recusa")

	section("UIManager: fechar/abrir com sinais")
	var waiter_closed := capture(EventBus.screen_closed)
	check_err(ui.call("close_screen", &"main_menu"), OK, "fechar tela ativa")
	check_eq(StringName(waiter_closed.first()[0]), &"main_menu", "evento de fechamento carrega o id")
	check_err(ui.call("close_screen", &"main_menu"), ERR_DOES_NOT_EXIST, "fechar tela inativa recusa")
	var waiter_opened := capture(EventBus.screen_opened)
	check_err(ui.call("open_screen", &"main_menu"), OK, "abrir novamente")
	check_eq(StringName(waiter_opened.first()[0]), &"main_menu", "evento de abertura carrega o id")

	section("UIManager: registro dinâmico com guardas")
	var packed := PackedScene.new()
	check_err(ui.call("register_screen", &"", packed), ERR_INVALID_PARAMETER, "id vazio recusa")
	check_err(ui.call("register_screen", &"main_menu", packed), ERR_ALREADY_EXISTS, "id duplicado recusa")
	var check_before: PackedStringArray = ui.call("registered_screen_ids")
	check_true(check_before.has(&"main_menu"), "router expõe telas registradas")

	section("Cena de menu: ação de UI sem fluxo implementado")
	var waiter_action := capture(EventBus.ui_action_requested)
	var screen: Node = ui.get_node("Screens").get_children()[0]
	check_not_null(screen, "tela instanciada na camada Screens")
	check_true(screen.has_method("emit_ui_action"), "ScreenBase expõe emissor de ação")
	screen.call("emit_ui_action", &"acao_teste")
	check_eq(StringName(waiter_action.first()[0]), &"acao_teste", "ação chega ao EventBus (consumidor pendente)")
