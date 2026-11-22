class_name PartyScreen
extends ScreenBase
## Tela de Gerenciamento de Grupo e Sessão Privada (máx. 8 participantes com anfitrião).

var _header: DarkFantasyHeader
var _nav_bar: DarkFantasyNavBar
var _lbl_session_status: Label
var _lbl_invite_code: Label
var _btn_copy_code: Button
var _slots_grid: GridContainer
var _btn_leave_session: Button
var _btn_debug_add_peer: Button
var _lbl_feedback: Label

func open(params: Dictionary = {}) -> void:
	super(params)
	screen_id = &"party"
	_build_ui()
	_refresh_roster()

func _ready() -> void:
	EventBus.peer_registered.connect(_on_peer_event)
	EventBus.peer_unregistered.connect(_on_peer_event)
	EventBus.session_left.connect(_on_peer_event)
	_build_ui()
	_refresh_roster()

func _on_peer_event(_a = null, _b = null) -> void:
	if is_visible_in_tree():
		_refresh_roster()

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

	_header = DarkFantasyHeader.new("GRUPO & SESSÃO PRIVADA", "Participantes conectados no mundo privado (limite total de 8)")
	_header.close_requested.connect(_on_close_pressed)
	main_vbox.add_child(_header)

	_nav_bar = DarkFantasyNavBar.new(&"party")
	main_vbox.add_child(_nav_bar)

	# Barra de Status da Sessão e Código de Convite
	var session_bar := HBoxContainer.new()
	session_bar.add_theme_constant_override("separation", 14)
	main_vbox.add_child(session_bar)

	_lbl_session_status = Label.new()
	_lbl_session_status.text = "Sessão: Ativa | Participantes: 1 / 8"
	_lbl_session_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lbl_session_status.add_theme_font_size_override("font_size", 13)
	_lbl_session_status.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
	session_bar.add_child(_lbl_session_status)

	_lbl_invite_code = Label.new()
	_lbl_invite_code.text = "Código de Convite: AP-0000"
	_lbl_invite_code.add_theme_font_size_override("font_size", 14)
	_lbl_invite_code.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	session_bar.add_child(_lbl_invite_code)

	_btn_copy_code = Button.new()
	_btn_copy_code.text = "Copiar Código"
	_btn_copy_code.pressed.connect(_on_copy_code_pressed)
	session_bar.add_child(_btn_copy_code)

	# Grid de 8 Slots de Participantes
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(scroll)

	_slots_grid = GridContainer.new()
	_slots_grid.columns = 4
	_slots_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_slots_grid.add_theme_constant_override("h_separation", 12)
	_slots_grid.add_theme_constant_override("v_separation", 12)
	scroll.add_child(_slots_grid)

	# Barra Inferior de Ações
	var action_bar := HBoxContainer.new()
	action_bar.add_theme_constant_override("separation", 12)
	main_vbox.add_child(action_bar)

	_btn_debug_add_peer = Button.new()
	_btn_debug_add_peer.text = "Convidar Aliado (Teste Roster)"
	_btn_debug_add_peer.custom_minimum_size = Vector2(0, 38)
	_btn_debug_add_peer.pressed.connect(_on_debug_add_peer_pressed)
	action_bar.add_child(_btn_debug_add_peer)

	_btn_leave_session = Button.new()
	_btn_leave_session.text = "Sair da Sessão / Desconectar"
	_btn_leave_session.custom_minimum_size = Vector2(0, 38)
	_btn_leave_session.pressed.connect(_on_leave_session_pressed)
	action_bar.add_child(_btn_leave_session)

	_lbl_feedback = Label.new()
	_lbl_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_feedback.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lbl_feedback.add_theme_font_size_override("font_size", 11)
	_lbl_feedback.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5))
	action_bar.add_child(_lbl_feedback)

func _refresh_roster() -> void:
	for child in _slots_grid.get_children():
		child.queue_free()

	var net := Game.get_system(SystemNames.NET) as MultiplayerManager
	var char_mgr := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	var class_mgr := Game.get_system(SystemNames.CLASS) as ClassManager
	if net == null:
		return

	# Garante que o host esteja no roster se vazio
	if net.participant_count() == 0:
		var host_name := "Anfitrião"
		if char_mgr != null and char_mgr.selected_character() != null:
			host_name = char_mgr.selected_character().display_name
		net.debug_register_participant(Invariants.HOST_PEER_ID, host_name)

	var participants := net.participants()
	var code := net.invite_code()
	if code.is_empty():
		code = "AP-7788"
	_lbl_invite_code.text = "Código de Convite: %s" % code
	_lbl_session_status.text = "Status: %s | Participantes: %d / %d" % [
		"Hospedando (Servidor)" if net.is_host() else "Conectado",
		participants.size(),
		Invariants.MAX_PARTICIPANTS
	]

	var peer_ids := participants.keys()
	peer_ids.sort()

	# Constrói os 8 slots do grupo
	for slot_idx in range(Invariants.MAX_PARTICIPANTS):
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(230, 200)

		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.06, 0.05, 0.08, 0.95)
		style.set_border_width_all(2)
		style.set_corner_radius_all(4)

		var card_vbox := VBoxContainer.new()
		card_vbox.offset_left = 10
		card_vbox.offset_right = -10
		card_vbox.offset_top = 10
		card_vbox.offset_bottom = -10
		card_vbox.add_theme_constant_override("separation", 6)
		card.add_child(card_vbox)

		if slot_idx < peer_ids.size():
			var pid: int = peer_ids[slot_idx]
			var pname: String = participants[pid]
			var is_host := (pid == Invariants.HOST_PEER_ID)
			style.border_color = Color(0.85, 0.7, 0.3) if is_host else Color(0.35, 0.55, 0.8)

			var header_lbl := Label.new()
			header_lbl.text = "%s Slot %d: %s" % ["👑 " if is_host else "• ", slot_idx + 1, pname]
			header_lbl.add_theme_font_size_override("font_size", 13)
			header_lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5) if is_host else Color(0.9, 0.85, 0.8))
			card_vbox.add_child(header_lbl)

			# Detalhes do membro
			var details := net.get_participant_details(pid)
			var class_str := String(details.get("class", "Arcanista"))
			var level_val := int(details.get("level", 1))
			var hp_val := int(details.get("hp", 100))
			var max_hp := int(details.get("max_hp", 100))

			var class_lbl := Label.new()
			class_lbl.text = "Classe: %s (Nv. %d)" % [class_str, level_val]
			class_lbl.add_theme_font_size_override("font_size", 11)
			class_lbl.add_theme_color_override("font_color", Color(0.7, 0.65, 0.6))
			card_vbox.add_child(class_lbl)

			# Barra de HP
			var hp_box := VBoxContainer.new()
			var hp_text := Label.new()
			hp_text.text = "Vida: %d / %d" % [hp_val, max_hp]
			hp_text.add_theme_font_size_override("font_size", 10)
			hp_box.add_child(hp_text)

			var hp_bar := ProgressBar.new()
			hp_bar.min_value = 0
			hp_bar.max_value = max_hp
			hp_bar.value = hp_val
			hp_bar.custom_minimum_size = Vector2(0, 10)
			hp_bar.show_percentage = false
			hp_box.add_child(hp_bar)
			card_vbox.add_child(hp_box)

			var status_lbl := Label.new()
			status_lbl.text = "Status: PRONTO PARA COMBATE"
			status_lbl.add_theme_font_size_override("font_size", 10)
			status_lbl.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5))
			card_vbox.add_child(status_lbl)

			if not is_host and net.is_host():
				var kick_btn := Button.new()
				kick_btn.text = "Expulsar do Grupo"
				kick_btn.pressed.connect(func():
					_on_kick_peer(pid)
				)
				card_vbox.add_child(kick_btn)
		else:
			style.border_color = Color(0.25, 0.22, 0.2, 0.5)
			var empty_lbl := Label.new()
			empty_lbl.text = "Slot %d: Vazio" % [slot_idx + 1]
			empty_lbl.add_theme_font_size_override("font_size", 12)
			empty_lbl.add_theme_color_override("font_color", Color(0.5, 0.45, 0.4))
			card_vbox.add_child(empty_lbl)

			var inv_btn := Button.new()
			inv_btn.text = "Convidar Aliado"
			inv_btn.custom_minimum_size = Vector2(0, 32)
			inv_btn.pressed.connect(_on_copy_code_pressed)
			card_vbox.add_child(inv_btn)

		card.add_theme_stylebox_override("panel", style)
		_slots_grid.add_child(card)

func _on_copy_code_pressed() -> void:
	var net := Game.get_system(SystemNames.NET) as MultiplayerManager
	if net != null:
		var code := net.invite_code()
		DisplayServer.clipboard_set(code)
		_lbl_feedback.text = "Código de convite [%s] copiado para a área de transferência!" % code

func _on_debug_add_peer_pressed() -> void:
	var net := Game.get_system(SystemNames.NET) as MultiplayerManager
	if net != null:
		var next_id := net.participant_count() + 1
		if next_id <= Invariants.MAX_PARTICIPANTS:
			var err := net.debug_register_participant(next_id, "Aliado_%02d" % next_id, {
				"class": "Guerreiro de Basalto",
				"level": 3 + next_id,
				"hp": 180 + next_id * 10,
				"max_hp": 180 + next_id * 10
			})
			if err == OK:
				_lbl_feedback.text = "Aliado_%02d entrou no grupo!" % next_id
				_refresh_roster()
		else:
			_lbl_feedback.text = "Grupo cheio! Limite máximo de 8 jogadores atingido."

func _on_kick_peer(pid: int) -> void:
	var net := Game.get_system(SystemNames.NET) as MultiplayerManager
	if net != null:
		EventBus.peer_unregistered.emit(pid)
		_lbl_feedback.text = "Jogador desconectado do grupo."
		_refresh_roster()

func _on_leave_session_pressed() -> void:
	var net := Game.get_system(SystemNames.NET) as MultiplayerManager
	if net != null:
		net.leave_session("Jogador saiu voluntariamente")
		_lbl_feedback.text = "Você saiu da sessão privada."
		_refresh_roster()

func _on_close_pressed() -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.close_screen(&"party")
