class_name MainMenuScreen
extends ScreenBase
## Tela de menu principal de ABYSSAL PACT — Dark Fantasy.

const START_ACTION := &"start_new_game"

var _btn_create_world: Button
var _btn_join_world: Button
var _btn_char_creation: Button
var _btn_settings: Button
var _btn_exit: Button
var _ui_built := false

func open(params: Dictionary = {}) -> void:
	super(params)
	screen_id = &"main_menu"
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if not _ui_built:
		_build_ui()
	_focus_first_button()

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if not _ui_built:
		_build_ui()
	_focus_first_button()

func _build_ui() -> void:
	if _ui_built:
		return
	_ui_built = true

	for child in get_children():
		child.queue_free()

	theme = DarkFantasyTheme.create()
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Fundo escuro com vinheta
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.035, 0.05, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(460, 520)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.text = "❖  ABYSSAL PACT  ❖"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 32)
	title_lbl.add_theme_color_override("font_color", Color(0.95, 0.85, 0.6))
	title_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(title_lbl)

	var subtitle_lbl := Label.new()
	subtitle_lbl.text = "RPG de Ação Dark Fantasy 3D\nSessões Privadas — Até 8 Jogadores"
	subtitle_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_lbl.add_theme_font_size_override("font_size", 13)
	subtitle_lbl.add_theme_color_override("font_color", Color(0.7, 0.65, 0.6))
	subtitle_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(subtitle_lbl)

	var sep := HSeparator.new()
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(sep)

	_btn_create_world = _create_menu_button("CRIAR MUNDO PRIVADO", _on_create_world_pressed)
	vbox.add_child(_btn_create_world)

	_btn_join_world = _create_menu_button("ENTRAR EM MUNDO PRIVADO", _on_join_world_pressed)
	vbox.add_child(_btn_join_world)

	_btn_char_creation = _create_menu_button("CRIAÇÃO DE PERSONAGEM", _on_char_creation_pressed)
	_btn_char_creation.name = "StartButton" # compatibilidade de teste
	vbox.add_child(_btn_char_creation)

	_btn_settings = _create_menu_button("CONFIGURAÇÕES", _on_settings_pressed)
	vbox.add_child(_btn_settings)

	_btn_exit = _create_menu_button("SAIR DO JOGO", _on_exit_pressed)
	vbox.add_child(_btn_exit)

func _create_menu_button(btn_text: String, callback: Callable) -> Button:
	var btn := Button.new()
	btn.text = btn_text
	btn.custom_minimum_size = Vector2(360, 44)
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	btn.focus_mode = Control.FOCUS_ALL
	btn.pressed.connect(callback)
	return btn

func _focus_first_button() -> void:
	if _btn_create_world != null and is_instance_valid(_btn_create_world):
		_btn_create_world.grab_focus.call_deferred()

func _on_create_world_pressed() -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.open_screen(&"create_world")

func _on_join_world_pressed() -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.open_screen(&"join_world")

func _on_char_creation_pressed() -> void:
	emit_ui_action(START_ACTION)
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.open_screen(&"character_creation")

func _on_settings_pressed() -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.open_screen(&"settings")

func _on_exit_pressed() -> void:
	Game.request_shutdown()
