class_name PauseMenuScreen
extends ScreenBase
## Tela de Menu de Pausa de ABYSSAL PACT.
##
## Fornece acesso centralizado aos 15 subsistemas do jogo, informações do
## personagem ativo, retorno emergencial à Hell Forge e opções de sessão.

var _lbl_character_info: Label
var _lbl_feedback: Label

func open(params: Dictionary = {}) -> void:
	super(params)
	screen_id = &"pause_menu"
	_build_ui()
	_refresh_character_info()

func _ready() -> void:
	_build_ui()
	_refresh_character_info()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		get_viewport().set_input_as_handled()
		_on_resume_pressed()

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	theme = DarkFantasyTheme.create()

	# Fundo escurecido semitransparente (overlay modal)
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.02, 0.03, 0.88)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Painel central modal
	var center_cont := CenterContainer.new()
	center_cont.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center_cont)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(680, 580)
	var panel_sb := StyleBoxFlat.new()
	panel_sb.bg_color = Color(0.07, 0.06, 0.09, 0.98)
	panel_sb.border_color = Color(0.48, 0.40, 0.28, 1.0)
	panel_sb.set_border_width_all(2)
	panel_sb.set_corner_radius_all(6)
	panel_sb.content_margin_left = 28
	panel_sb.content_margin_right = 28
	panel_sb.content_margin_top = 22
	panel_sb.content_margin_bottom = 24
	panel.add_theme_stylebox_override("panel", panel_sb)
	center_cont.add_child(panel)

	var v_box := VBoxContainer.new()
	v_box.add_theme_constant_override("separation", 14)
	panel.add_child(v_box)

	# Cabeçalho Dark Fantasy
	var header := DarkFantasyHeader.new("PAUSA DO JOGO", "❖ O ABISMO AGUARDA SUA DECISÃO ❖")
	header.close_requested.connect(_on_resume_pressed)
	v_box.add_child(header)

	# Banner do Personagem Ativo
	var char_panel := PanelContainer.new()
	var char_sb := StyleBoxFlat.new()
	char_sb.bg_color = Color(0.11, 0.09, 0.14, 0.9)
	char_sb.border_color = Color(0.35, 0.30, 0.22, 0.7)
	char_sb.set_border_width_all(1)
	char_sb.set_corner_radius_all(4)
	char_sb.content_margin_left = 12
	char_sb.content_margin_right = 12
	char_sb.content_margin_top = 8
	char_sb.content_margin_bottom = 8
	char_panel.add_theme_stylebox_override("panel", char_sb)
	v_box.add_child(char_panel)

	_lbl_character_info = Label.new()
	_lbl_character_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_character_info.add_theme_color_override("font_color", Color(0.85, 0.78, 0.65))
	_lbl_character_info.add_theme_font_size_override("font_size", 14)
	char_panel.add_child(_lbl_character_info)

	# Grade de Acesso Rápido aos Sistemas
	var grid_label := Label.new()
	grid_label.text = "SISTEMAS E INTERFACES"
	grid_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	grid_label.add_theme_color_override("font_color", Color(0.65, 0.58, 0.45))
	grid_label.add_theme_font_size_override("font_size", 13)
	v_box.add_child(grid_label)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	v_box.add_child(grid)

	_add_nav_button(grid, "🎒 Inventário", &"inventory")
	_add_nav_button(grid, "⚔️ Equipamentos", &"equipment")
	_add_nav_button(grid, "✨ Habilidades", &"abilities")
	_add_nav_button(grid, "📜 Árvore de Classes", &"class_tree")
	_add_nav_button(grid, "🔮 Pactos Abissais", &"pacts")
	_add_nav_button(grid, "🗺️ Mapa Mundial", &"world_map")
	_add_nav_button(grid, "🧭 Mapa Regional", &"regional_map")
	_add_nav_button(grid, "📖 Códice", &"codex")
	_add_nav_button(grid, "👹 Bestiário", &"bestiary")
	_add_nav_button(grid, "🎯 Missões", &"quests")
	_add_nav_button(grid, "👥 Grupo", &"party")
	_add_nav_button(grid, "⚙️ Configurações", &"settings")

	# Divisor
	var hsep := HSeparator.new()
	v_box.add_child(hsep)

	# Ações da Sessão
	var actions_box := VBoxContainer.new()
	actions_box.add_theme_constant_override("separation", 8)
	v_box.add_child(actions_box)

	var btn_resume := Button.new()
	btn_resume.text = "▶ RETOMAR JORNADA"
	btn_resume.custom_minimum_size = Vector2(0, 38)
	btn_resume.pressed.connect(_on_resume_pressed)
	actions_box.add_child(btn_resume)

	var h_actions := HBoxContainer.new()
	h_actions.add_theme_constant_override("separation", 10)
	actions_box.add_child(h_actions)

	var btn_respawn := Button.new()
	btn_respawn.text = "🔥 Retornar à Hell Forge"
	btn_respawn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_respawn.pressed.connect(_on_return_hell_forge_pressed)
	h_actions.add_child(btn_respawn)

	var btn_main_menu := Button.new()
	btn_main_menu.text = "🏛️ Menu Principal"
	btn_main_menu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_main_menu.pressed.connect(_on_main_menu_pressed)
	h_actions.add_child(btn_main_menu)

	var btn_quit := Button.new()
	btn_quit.text = "🚪 Sair do Jogo"
	btn_quit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_quit.pressed.connect(_on_quit_pressed)
	h_actions.add_child(btn_quit)

	_lbl_feedback = Label.new()
	_lbl_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_feedback.add_theme_color_override("font_color", Color(0.9, 0.75, 0.45))
	_lbl_feedback.add_theme_font_size_override("font_size", 13)
	v_box.add_child(_lbl_feedback)

func _add_nav_button(container: Container, title: String, screen_to_open: StringName) -> Button:
	var btn := Button.new()
	btn.text = title
	btn.custom_minimum_size = Vector2(0, 36)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(func() -> void:
		_open_subscreen(screen_to_open)
	)
	container.add_child(btn)
	return btn

func _refresh_character_info() -> void:
	if _lbl_character_info == null:
		return

	var char_mgr := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	var active_char: CharacterData = char_mgr.selected_character() if char_mgr != null else null
	if active_char == null:
		_lbl_character_info.text = "Nenhuma alma ativa no receptáculo mortal"
		return
	var pact_title := "Nenhum Pacto"
	if active_char.active_pact_id != &"":
		var pact_res := PactCatalog.get_pact(active_char.active_pact_id)
		var pact_name: String = pact_res.display_name if pact_res != null else String(active_char.active_pact_id)
		var p_tier: int = active_char.pact_tiers.get(active_char.active_pact_id, 1)
		pact_title = "%s (Grau %d)" % [pact_name, p_tier]

	var char_level: int = active_char.progression.level if active_char.progression != null else 1
	var cur_hp: int = int(active_char.progression.attributes.get("health", 100)) if active_char.progression != null else 100
	var max_hp: int = int(active_char.progression.attributes.get("max_health", 100)) if active_char.progression != null else 100

	_lbl_character_info.text = "%s — Nível %d %s %s | Pacto: %s | Vida: %d/%d" % [
		active_char.display_name,
		char_level,
		active_char.race_id,
		active_char.class_id,
		pact_title,
		cur_hp,
		max_hp
	]

func _open_subscreen(target_screen_id: StringName) -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.open_screen(target_screen_id)

func _on_resume_pressed() -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.close_screen(&"pause_menu")

func _on_return_hell_forge_pressed() -> void:
	var wm := Game.get_system(SystemNames.WORLD) as WorldManager
	if wm != null:
		wm.resolve_respawn(Invariants.HOST_PEER_ID)
		if _lbl_feedback != null:
			_lbl_feedback.text = "Retornando à Hell Forge..."
	_on_resume_pressed()

func _on_main_menu_pressed() -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.open_screen(&"main_menu")

func _on_quit_pressed() -> void:
	if OS.has_feature("web"):
		_on_main_menu_pressed()
	else:
		get_tree().quit()
