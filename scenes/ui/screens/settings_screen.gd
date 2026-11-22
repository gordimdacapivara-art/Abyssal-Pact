class_name SettingsScreen
extends ScreenBase
## Tela de Configurações de ABYSSAL PACT: Áudio, Gráficos, Controles e Acessibilidade.

var _active_tab: StringName = &"audio"

var _header: DarkFantasyHeader
var _nav_bar: DarkFantasyNavBar
var _content_box: VBoxContainer
var _lbl_feedback: Label

# Áudio sliders
var _slider_master: HSlider
var _slider_music: HSlider
var _slider_sfx: HSlider
var _slider_ui: HSlider

# Gráficos
var _opt_window_mode: OptionButton
var _opt_vsync: OptionButton
var _opt_quality: OptionButton

# Jogabilidade
var _slider_mouse_sens: HSlider
var _check_invert_y: CheckBox
var _check_screen_shake: CheckBox

func open(params: Dictionary = {}) -> void:
	super(params)
	screen_id = &"settings"
	_build_ui()
	_refresh_tab_content()

func _ready() -> void:
	_build_ui()
	_refresh_tab_content()

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	theme = DarkFantasyTheme.create()

	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.035, 0.05, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var main_vbox := VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_vbox.offset_left = 20
	main_vbox.offset_right = -20
	main_vbox.offset_top = 16
	main_vbox.offset_bottom = -16
	main_vbox.add_theme_constant_override("separation", 10)
	add_child(main_vbox)

	_header = DarkFantasyHeader.new("CONFIGURAÇÕES DO JOGO", "Ajustes de Áudio, Gráficos, Controles e Acessibilidade")
	_header.close_requested.connect(_on_close_pressed)
	main_vbox.add_child(_header)

	_nav_bar = DarkFantasyNavBar.new(&"settings")
	main_vbox.add_child(_nav_bar)

	# Barra de Abas de Configuração
	var tabs_bar := HBoxContainer.new()
	tabs_bar.add_theme_constant_override("separation", 8)
	main_vbox.add_child(tabs_bar)

	var tabs := [
		{"id": &"audio", "label": "🔊 Áudio & Sons"},
		{"id": &"graphics", "label": "🖥️ Gráficos & Vídeo"},
		{"id": &"controls", "label": "🎮 Controles & Câmera"},
		{"id": &"accessibility", "label": "♿ Acessibilidade"},
	]

	for t in tabs:
		var tid: StringName = t["id"]
		var btn := Button.new()
		btn.text = " " + t["label"] + " "
		btn.pressed.connect(func():
			_active_tab = tid
			_refresh_tab_content()
		)
		tabs_bar.add_child(btn)

	# Painel Central de Conteúdo
	var panel := PanelContainer.new()
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(panel)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 16
	scroll.offset_right = -16
	scroll.offset_top = 14
	scroll.offset_bottom = -14
	panel.add_child(scroll)

	_content_box = VBoxContainer.new()
	_content_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_box.add_theme_constant_override("separation", 12)
	scroll.add_child(_content_box)

	# Barra de Ações
	var action_bar := HBoxContainer.new()
	action_bar.add_theme_constant_override("separation", 12)
	main_vbox.add_child(action_bar)

	var btn_save := Button.new()
	btn_save.text = "SALVAR CONFIGURAÇÕES"
	btn_save.custom_minimum_size = Vector2(0, 40)
	btn_save.pressed.connect(_on_save_pressed)
	action_bar.add_child(btn_save)

	var btn_defaults := Button.new()
	btn_defaults.text = "Restaurar Padrões"
	btn_defaults.custom_minimum_size = Vector2(0, 40)
	btn_defaults.pressed.connect(_on_defaults_pressed)
	action_bar.add_child(btn_defaults)

	_lbl_feedback = Label.new()
	_lbl_feedback.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lbl_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_lbl_feedback.add_theme_font_size_override("font_size", 11)
	_lbl_feedback.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5))
	action_bar.add_child(_lbl_feedback)

func _refresh_tab_content() -> void:
	for child in _content_box.get_children():
		child.queue_free()

	match _active_tab:
		&"audio":
			_build_audio_tab()
		&"graphics":
			_build_graphics_tab()
		&"controls":
			_build_controls_tab()
		&"accessibility":
			_build_accessibility_tab()

func _build_audio_tab() -> void:
	var title := Label.new()
	title.text = "AJUSTES DE ÁUDIO (CANAIS AUDIOSERVER)"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
	_content_box.add_child(title)

	var buses := [
		{"name": "Volume Principal (Master)", "bus": 0},
		{"name": "Música Ambiente (Music)", "bus": 1},
		{"name": "Efeitos Sonoros (SFX)", "bus": 2},
		{"name": "Interface & Notificações (UI)", "bus": 3},
	]

	for b in buses:
		var b_name: String = b["name"]
		var b_idx: int = b["bus"]

		var row := HBoxContainer.new()
		var lbl := Label.new()
		lbl.text = b_name
		lbl.custom_minimum_size = Vector2(240, 0)
		lbl.add_theme_font_size_override("font_size", 12)
		row.add_child(lbl)

		var slider := HSlider.new()
		slider.min_value = 0.0
		slider.max_value = 100.0
		slider.value = 80.0
		slider.custom_minimum_size = Vector2(250, 24)
		slider.value_changed.connect(func(val):
			_on_audio_volume_changed(b_idx, val)
		)
		row.add_child(slider)

		var val_lbl := Label.new()
		val_lbl.text = "%.0f%%" % slider.value
		val_lbl.custom_minimum_size = Vector2(50, 0)
		val_lbl.add_theme_font_size_override("font_size", 11)
		slider.value_changed.connect(func(v): val_lbl.text = "%.0f%%" % v)
		row.add_child(val_lbl)

		_content_box.add_child(row)

	var test_btn := Button.new()
	test_btn.text = "Tocar Sinal Sonoro de Teste"
	test_btn.custom_minimum_size = Vector2(220, 36)
	test_btn.pressed.connect(func():
		var audio := Game.get_system(SystemNames.AUDIO)
		if audio != null and audio.has_method("play_ui_sound"):
			audio.call("play_ui_sound", "click")
		_lbl_feedback.text = "Sinal sonoro de teste emitido!"
	)
	_content_box.add_child(test_btn)

func _on_audio_volume_changed(bus_idx: int, percent: float) -> void:
	if bus_idx < AudioServer.bus_count:
		var db := linear_to_db(percent / 100.0) if percent > 0 else -80.0
		AudioServer.set_bus_volume_db(bus_idx, db)

func _build_graphics_tab() -> void:
	var title := Label.new()
	title.text = "AJUSTES DE VÍDEO & RENDERIZAÇÃO"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
	_content_box.add_child(title)

	# Modo de Janela
	var w_row := HBoxContainer.new()
	var w_lbl := Label.new()
	w_lbl.text = "Modo de Exibição:"
	w_lbl.custom_minimum_size = Vector2(220, 0)
	w_row.add_child(w_lbl)

	_opt_window_mode = OptionButton.new()
	_opt_window_mode.add_item("Janela Padrão", 0)
	_opt_window_mode.add_item("Tela Cheia Exclusiva", 1)
	_opt_window_mode.add_item("Sem Bordas Maximizado", 2)
	_opt_window_mode.selected = 0
	_opt_window_mode.item_selected.connect(func(idx):
		match idx:
			0:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			1:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			2:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	)
	w_row.add_child(_opt_window_mode)
	_content_box.add_child(w_row)

	# V-Sync
	var v_row := HBoxContainer.new()
	var v_lbl := Label.new()
	v_lbl.text = "Sincronização Vertical (V-Sync):"
	v_lbl.custom_minimum_size = Vector2(220, 0)
	v_row.add_child(v_lbl)

	_opt_vsync = OptionButton.new()
	_opt_vsync.add_item("Desativado", 0)
	_opt_vsync.add_item("Ativado (60 FPS)", 1)
	_opt_vsync.add_item("Adaptativo", 2)
	_opt_vsync.selected = 1
	_opt_vsync.item_selected.connect(func(idx):
		match idx:
			0:
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
			1:
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
			2:
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
	)
	v_row.add_child(_opt_vsync)
	_content_box.add_child(v_row)

	# Qualidade
	var q_row := HBoxContainer.new()
	var q_lbl := Label.new()
	q_lbl.text = "Predefinição de Qualidade:"
	q_lbl.custom_minimum_size = Vector2(220, 0)
	q_row.add_child(q_lbl)

	_opt_quality = OptionButton.new()
	_opt_quality.add_item("Baixa (Orçamento PC 4 GB)", 0)
	_opt_quality.add_item("Média (Padrão Equilibrado)", 1)
	_opt_quality.add_item("Alta (Texturas e Sombras)", 2)
	_opt_quality.add_item("Ultra (Máximo Detalhe)", 3)
	_opt_quality.selected = 1
	q_row.add_child(_opt_quality)
	_content_box.add_child(q_row)

func _build_controls_tab() -> void:
	var title := Label.new()
	title.text = "CONTROLES, SENSIBILIDADE E MAPEAMENTO DE ENTRADA"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
	_content_box.add_child(title)

	var sens_row := HBoxContainer.new()
	var sens_lbl := Label.new()
	sens_lbl.text = "Sensibilidade da Câmera:"
	sens_lbl.custom_minimum_size = Vector2(220, 0)
	sens_row.add_child(sens_lbl)

	_slider_mouse_sens = HSlider.new()
	_slider_mouse_sens.min_value = 0.2
	_slider_mouse_sens.max_value = 3.0
	_slider_mouse_sens.step = 0.1
	_slider_mouse_sens.value = 1.0
	_slider_mouse_sens.custom_minimum_size = Vector2(200, 24)
	sens_row.add_child(_slider_mouse_sens)

	var sens_val := Label.new()
	sens_val.text = "1.0x"
	_slider_mouse_sens.value_changed.connect(func(v): sens_val.text = "%.1fx" % v)
	sens_row.add_child(sens_val)
	_content_box.add_child(sens_row)

	_check_invert_y = CheckBox.new()
	_check_invert_y.text = "Inverter Eixo Vertical da Câmera (Invert Y)"
	_content_box.add_child(_check_invert_y)

	_content_box.add_child(HSeparator.new())

	var map_title := Label.new()
	map_title.text = "AÇÕES DO INPUTMAP CANÔNICO:"
	map_title.add_theme_font_size_override("font_size", 12)
	map_title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.6))
	_content_box.add_child(map_title)

	var key_bindings := [
		{"action": "Mover para Frente", "key": "W / Analógico Cima"},
		{"action": "Mover para Trás", "key": "S / Analógico Baixo"},
		{"action": "Mover para Esquerda", "key": "A / Analógico Esquerda"},
		{"action": "Mover para Direita", "key": "D / Analógico Direita"},
		{"action": "Salto / Pulo", "key": "Espaço / Botão A (Gamepad)"},
		{"action": "Corrida / Sprint", "key": "Shift Esquerdo / L3"},
		{"action": "Esquiva (Dodge)", "key": "Ctrl / Botão X (Gamepad)"},
		{"action": "Interagir com Objetos", "key": "Tecla E / Botão Y"},
		{"action": "Habilidade Ativa 1", "key": "Tecla 1 / R1"},
		{"action": "Habilidade Ativa 2", "key": "Tecla 2 / R2"},
		{"action": "Habilidade Especial", "key": "Tecla R / L2"},
	]

	for kb in key_bindings:
		var row := HBoxContainer.new()
		var a_lbl := Label.new()
		a_lbl.text = "• " + kb["action"]
		a_lbl.custom_minimum_size = Vector2(220, 0)
		a_lbl.add_theme_font_size_override("font_size", 11)
		row.add_child(a_lbl)

		var k_lbl := Label.new()
		k_lbl.text = kb["key"]
		k_lbl.add_theme_font_size_override("font_size", 11)
		k_lbl.add_theme_color_override("font_color", Color(0.85, 0.8, 0.65))
		row.add_child(k_lbl)
		_content_box.add_child(row)

func _build_accessibility_tab() -> void:
	var title := Label.new()
	title.text = "OPÇÕES DE ACESSIBILIDADE E CONFORTO VISUAL"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
	_content_box.add_child(title)

	_check_screen_shake = CheckBox.new()
	_check_screen_shake.text = "Trepidação de Câmera em Impactos (Screen Shake)"
	_check_screen_shake.button_pressed = true
	_content_box.add_child(_check_screen_shake)

	var font_row := HBoxContainer.new()
	var font_lbl := Label.new()
	font_lbl.text = "Tamanho de Texto da Interface:"
	font_lbl.custom_minimum_size = Vector2(220, 0)
	font_row.add_child(font_lbl)

	var opt_font := OptionButton.new()
	opt_font.add_item("Padrão (14–16px)", 0)
	opt_font.add_item("Grande (18–20px)", 1)
	opt_font.selected = 0
	font_row.add_child(opt_font)
	_content_box.add_child(font_row)

func _on_save_pressed() -> void:
	_lbl_feedback.text = "Configurações salvas e aplicadas com sucesso!"
	EventBus.ui_action_requested.emit(&"settings_saved")

func _on_defaults_pressed() -> void:
	_on_audio_volume_changed(0, 80.0)
	_on_audio_volume_changed(1, 80.0)
	_on_audio_volume_changed(2, 80.0)
	_on_audio_volume_changed(3, 80.0)
	_lbl_feedback.text = "Padrões de fábrica restaurados."
	_refresh_tab_content()

func _on_close_pressed() -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.close_screen(&"settings")
