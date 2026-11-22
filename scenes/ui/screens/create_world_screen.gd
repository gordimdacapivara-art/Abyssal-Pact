class_name CreateWorldScreen
extends ScreenBase
## Tela de Criação e Hospedagem de Mundo Privado (máx. 8 participantes).

var _input_name: LineEdit
var _spin_players: SpinBox
var _spin_port: SpinBox
var _btn_host: Button
var _btn_start_play: Button
var _label_status: Label
var _label_invite_code: Label
var _btn_copy_code: Button
var _btn_back: Button

func open(params: Dictionary = {}) -> void:
	super(params)
	screen_id = &"create_world"
	_build_ui()

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	theme = DarkFantasyTheme.create()

	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.035, 0.05, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(500, 560)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)

	var header := DarkFantasyHeader.new("CRIAR MUNDO PRIVADO", "Hospedar sessão para até 8 jogadores (anfitrião incluído)")
	header.close_requested.connect(_on_back_pressed)
	vbox.add_child(header)

	var form_box := VBoxContainer.new()
	form_box.add_theme_constant_override("separation", 10)
	vbox.add_child(form_box)

	# Nome do mundo
	var lbl_name := Label.new()
	lbl_name.text = "Nome do Mundo:"
	form_box.add_child(lbl_name)

	_input_name = LineEdit.new()
	_input_name.text = "Reino de Veyrath"
	_input_name.placeholder_text = "Digite o nome do mundo..."
	form_box.add_child(_input_name)

	# Máximo de jogadores
	var lbl_players := Label.new()
	lbl_players.text = "Capacidade Máxima (Invariante: máx. 8 participantes):"
	form_box.add_child(lbl_players)

	_spin_players = SpinBox.new()
	_spin_players.min_value = 1
	_spin_players.max_value = Invariants.MAX_PARTICIPANTS
	_spin_players.value = Invariants.MAX_PARTICIPANTS
	form_box.add_child(_spin_players)

	# Porta
	var lbl_port := Label.new()
	lbl_port.text = "Porta de Rede (ENet):"
	form_box.add_child(lbl_port)

	_spin_port = SpinBox.new()
	_spin_port.min_value = 1024
	_spin_port.max_value = 65535
	_spin_port.value = MultiplayerManager.DEFAULT_PORT
	form_box.add_child(_spin_port)

	_btn_host = Button.new()
	_btn_host.text = "HOSPEDAR MUNDO PRIVADO"
	_btn_host.custom_minimum_size = Vector2(0, 42)
	_btn_host.pressed.connect(_on_host_pressed)
	vbox.add_child(_btn_host)

	# Status e código de convite
	_label_status = Label.new()
	_label_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label_status.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
	vbox.add_child(_label_status)

	var invite_box := HBoxContainer.new()
	invite_box.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(invite_box)

	_label_invite_code = Label.new()
	_label_invite_code.add_theme_font_size_override("font_size", 18)
	_label_invite_code.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	invite_box.add_child(_label_invite_code)

	_btn_copy_code = Button.new()
	_btn_copy_code.text = "Copiar Código"
	_btn_copy_code.visible = false
	_btn_copy_code.pressed.connect(_on_copy_code_pressed)
	invite_box.add_child(_btn_copy_code)

	_btn_start_play = Button.new()
	_btn_start_play.text = "INICIAR AVENTURA (HELL FORGE)"
	_btn_start_play.custom_minimum_size = Vector2(0, 42)
	_btn_start_play.visible = false
	_btn_start_play.pressed.connect(_on_start_play_pressed)
	vbox.add_child(_btn_start_play)

	_btn_back = Button.new()
	_btn_back.text = "Voltar ao Menu Principal"
	_btn_back.pressed.connect(_on_back_pressed)
	vbox.add_child(_btn_back)

func _on_host_pressed() -> void:
	var wname := _input_name.text.strip_edges()
	if wname.is_empty():
		_label_status.text = "Aviso: informe um nome válido para o mundo."
		return

	var net := Game.get_system(SystemNames.NET) as MultiplayerManager
	var world := Game.get_system(SystemNames.WORLD) as WorldManager

	if net != null:
		var port := int(_spin_port.value)
		var err := net.host_private_world(wname, port)
		if err == OK:
			if world != null:
				world.create_private_world(wname, Invariants.HOST_PEER_ID)
			var code := net.invite_code()
			_label_status.text = "Sessão privada hospedada com sucesso!"
			_label_invite_code.text = "CÓDIGO DE CONVITE: %s" % code
			_btn_copy_code.visible = true
			_btn_start_play.visible = true
			_btn_host.disabled = true
			emit_ui_action(&"world_hosted")
		else:
			_label_status.text = "Falha ao hospedar: código de erro %d" % err

func _on_copy_code_pressed() -> void:
	var net := Game.get_system(SystemNames.NET) as MultiplayerManager
	if net != null:
		DisplayServer.clipboard_set(net.invite_code())
		_label_status.text = "Código copiado para a área de transferência!"

func _on_start_play_pressed() -> void:
	var world := Game.get_system(SystemNames.WORLD) as WorldManager
	if world != null:
		world.load_region(&"REG-001", "default")
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.close_all_screens()

func _on_back_pressed() -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.open_screen(&"main_menu")
