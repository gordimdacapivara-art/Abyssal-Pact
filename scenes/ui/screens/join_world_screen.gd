class_name JoinWorldScreen
extends ScreenBase
## Tela para Conectar a um Mundo Privado existente via Código de Convite.

var _input_address: LineEdit
var _spin_port: SpinBox
var _input_code: LineEdit
var _btn_join: Button
var _label_status: Label
var _btn_back: Button

func open(params: Dictionary = {}) -> void:
	super(params)
	screen_id = &"join_world"
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
	panel.custom_minimum_size = Vector2(480, 480)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)

	var header := DarkFantasyHeader.new("ENTRAR EM MUNDO PRIVADO", "Conecte-se a uma sessão hospedada por outro jogador")
	header.close_requested.connect(_on_back_pressed)
	vbox.add_child(header)

	var form_box := VBoxContainer.new()
	form_box.add_theme_constant_override("separation", 10)
	vbox.add_child(form_box)

	# Endereço
	var lbl_addr := Label.new()
	lbl_addr.text = "Endereço do Servidor (IP):"
	form_box.add_child(lbl_addr)

	_input_address = LineEdit.new()
	_input_address.text = "127.0.0.1"
	form_box.add_child(_input_address)

	# Porta
	var lbl_port := Label.new()
	lbl_port.text = "Porta (ENet):"
	form_box.add_child(lbl_port)

	_spin_port = SpinBox.new()
	_spin_port.min_value = 1024
	_spin_port.max_value = 65535
	_spin_port.value = MultiplayerManager.DEFAULT_PORT
	form_box.add_child(_spin_port)

	# Código de Convite
	var lbl_code := Label.new()
	lbl_code.text = "Código de Convite Privado (ex: AP-1234):"
	form_box.add_child(lbl_code)

	_input_code = LineEdit.new()
	_input_code.placeholder_text = "AP-0000"
	_input_code.text = "AP-1001"
	form_box.add_child(_input_code)

	_btn_join = Button.new()
	_btn_join.text = "CONECTAR AO MUNDO"
	_btn_join.custom_minimum_size = Vector2(0, 42)
	_btn_join.pressed.connect(_on_join_pressed)
	vbox.add_child(_btn_join)

	_label_status = Label.new()
	_label_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label_status.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
	vbox.add_child(_label_status)

	_btn_back = Button.new()
	_btn_back.text = "Voltar ao Menu Principal"
	_btn_back.pressed.connect(_on_back_pressed)
	vbox.add_child(_btn_back)

func _on_join_pressed() -> void:
	var addr := _input_address.text.strip_edges()
	var code := _input_code.text.strip_edges()
	var port := int(_spin_port.value)

	if addr.is_empty():
		_label_status.text = "Aviso: informe o endereço do servidor."
		return

	var net := Game.get_system(SystemNames.NET) as MultiplayerManager
	if net != null:
		var err := net.join_private_world(addr, port, code)
		if err == OK:
			_label_status.text = "Conectando ao mundo '%s' com código '%s'..." % [addr, code]
			emit_ui_action(&"joining_world")
		else:
			_label_status.text = "Falha ao conectar: erro %d" % err

func _on_back_pressed() -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.open_screen(&"main_menu")
