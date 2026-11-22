class_name PactsScreen
extends ScreenBase
## Tela do Sistema de Pactos Abissais: Seleção, Descrição, Efeitos, Evolução em Tiers e Desbloqueios.

var _selected_pact: PactData = null

var _header: DarkFantasyHeader
var _nav_bar: DarkFantasyNavBar
var _pacts_vbox: VBoxContainer
var _lbl_pact_title: Label
var _lbl_pact_status: Label
var _lbl_tier_display: Label
var _lbl_pact_desc: Label
var _lbl_pact_lore: Label
var _vbox_passives: VBoxContainer
var _vbox_stats: VBoxContainer
var _lbl_evolution_reqs: Label
var _btn_bind: Button
var _btn_evolve: Button
var _lbl_feedback: Label

func open(params: Dictionary = {}) -> void:
	super(params)
	screen_id = &"pacts"
	_build_ui()
	_refresh_pacts()

func _ready() -> void:
	_build_ui()
	_refresh_pacts()

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

	_header = DarkFantasyHeader.new("PACTOS ABISSAIS", "Vínculos cósmicos, evolução de tiers e bênçãos das profundezas")
	_header.close_requested.connect(_on_close_pressed)
	main_vbox.add_child(_header)

	_nav_bar = DarkFantasyNavBar.new(&"pacts")
	main_vbox.add_child(_nav_bar)

	var content_hbox := HBoxContainer.new()
	content_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_theme_constant_override("separation", 16)
	main_vbox.add_child(content_hbox)

	# --- COLUNA 1: LISTA DE PACTOS ---
	var list_panel := PanelContainer.new()
	list_panel.custom_minimum_size = Vector2(340, 0)
	list_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(list_panel)

	var list_vbox := VBoxContainer.new()
	list_vbox.add_theme_constant_override("separation", 8)
	list_vbox.offset_left = 12
	list_vbox.offset_right = -12
	list_vbox.offset_top = 12
	list_vbox.offset_bottom = -12
	list_panel.add_child(list_vbox)

	var list_title := Label.new()
	list_title.text = "PACTOS DISPONÍVEIS"
	list_title.add_theme_font_size_override("font_size", 14)
	list_title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
	list_vbox.add_child(list_title)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list_vbox.add_child(scroll)

	_pacts_vbox = VBoxContainer.new()
	_pacts_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_pacts_vbox.add_theme_constant_override("separation", 8)
	scroll.add_child(_pacts_vbox)

	# --- COLUNA 2: DETALHES, EFEITOS E EVOLUÇÃO ---
	var detail_panel := PanelContainer.new()
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(detail_panel)

	var detail_vbox := VBoxContainer.new()
	detail_vbox.add_theme_constant_override("separation", 10)
	detail_vbox.offset_left = 16
	detail_vbox.offset_right = -16
	detail_vbox.offset_top = 12
	detail_vbox.offset_bottom = -12
	detail_panel.add_child(detail_vbox)

	var header_hbox := HBoxContainer.new()
	detail_vbox.add_child(header_hbox)

	_lbl_pact_title = Label.new()
	_lbl_pact_title.text = "Selecione um Pacto"
	_lbl_pact_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lbl_pact_title.add_theme_font_size_override("font_size", 20)
	_lbl_pact_title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
	header_hbox.add_child(_lbl_pact_title)

	_lbl_pact_status = Label.new()
	_lbl_pact_status.text = ""
	_lbl_pact_status.add_theme_font_size_override("font_size", 13)
	header_hbox.add_child(_lbl_pact_status)

	_lbl_tier_display = Label.new()
	_lbl_tier_display.text = "Tier: —"
	_lbl_tier_display.add_theme_font_size_override("font_size", 14)
	_lbl_tier_display.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
	detail_vbox.add_child(_lbl_tier_display)

	detail_vbox.add_child(HSeparator.new())

	_lbl_pact_desc = Label.new()
	_lbl_pact_desc.text = "Selecione um pacto para ver sua essência e bênçãos."
	_lbl_pact_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_pact_desc.add_theme_font_size_override("font_size", 12)
	detail_vbox.add_child(_lbl_pact_desc)

	_lbl_pact_lore = Label.new()
	_lbl_pact_lore.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_pact_lore.add_theme_font_size_override("font_size", 11)
	_lbl_pact_lore.add_theme_color_override("font_color", Color(0.65, 0.6, 0.55))
	detail_vbox.add_child(_lbl_pact_lore)

	detail_vbox.add_child(HSeparator.new())

	var effects_hbox := HBoxContainer.new()
	effects_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	effects_hbox.add_theme_constant_override("separation", 16)
	detail_vbox.add_child(effects_hbox)

	# Efeitos Passivos
	var pass_box := VBoxContainer.new()
	pass_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	effects_hbox.add_child(pass_box)

	var pass_title := Label.new()
	pass_title.text = "EFEITOS PASSIVOS:"
	pass_title.add_theme_font_size_override("font_size", 12)
	pass_title.add_theme_color_override("font_color", Color(0.85, 0.8, 0.6))
	pass_box.add_child(pass_title)

	_vbox_passives = VBoxContainer.new()
	_vbox_passives.add_theme_constant_override("separation", 4)
	pass_box.add_child(_vbox_passives)

	# Modificadores de Atributos
	var stats_box := VBoxContainer.new()
	stats_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	effects_hbox.add_child(stats_box)

	var stats_title := Label.new()
	stats_title.text = "ATRIBUTOS POR TIER:"
	stats_title.add_theme_font_size_override("font_size", 12)
	stats_title.add_theme_color_override("font_color", Color(0.85, 0.8, 0.6))
	stats_box.add_child(stats_title)

	_vbox_stats = VBoxContainer.new()
	_vbox_stats.add_theme_constant_override("separation", 4)
	stats_box.add_child(_vbox_stats)

	detail_vbox.add_child(HSeparator.new())

	_lbl_evolution_reqs = Label.new()
	_lbl_evolution_reqs.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_evolution_reqs.add_theme_font_size_override("font_size", 11)
	_lbl_evolution_reqs.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6))
	detail_vbox.add_child(_lbl_evolution_reqs)

	var action_hbox := HBoxContainer.new()
	action_hbox.add_theme_constant_override("separation", 12)
	detail_vbox.add_child(action_hbox)

	_btn_bind = Button.new()
	_btn_bind.text = "VINCULAR AO PORTADOR"
	_btn_bind.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_btn_bind.custom_minimum_size = Vector2(0, 42)
	_btn_bind.disabled = true
	_btn_bind.pressed.connect(_on_bind_pressed)
	action_hbox.add_child(_btn_bind)

	_btn_evolve = Button.new()
	_btn_evolve.text = "EVOLUIR PACTO (TIER +1)"
	_btn_evolve.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_btn_evolve.custom_minimum_size = Vector2(0, 42)
	_btn_evolve.disabled = true
	_btn_evolve.pressed.connect(_on_evolve_pressed)
	action_hbox.add_child(_btn_evolve)

	_lbl_feedback = Label.new()
	_lbl_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_feedback.add_theme_font_size_override("font_size", 11)
	_lbl_feedback.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5))
	detail_vbox.add_child(_lbl_feedback)

func _refresh_pacts() -> void:
	for child in _pacts_vbox.get_children():
		child.queue_free()

	var char_mgr := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	var char_id := char_mgr.selected_character_id() if char_mgr != null else &"CHAR-001"
	var active_pact_id := char_mgr.get_character_pact(char_id) if char_mgr != null else &""

	var pact_list := PactCatalog.pacts()
	if pact_list.is_empty():
		return

	for pact in pact_list:
		var pid: StringName = pact.id
		var is_bound := pid == active_pact_id
		var char_tier: int = char_mgr.get_character_pact_tier(char_id, pid) if char_mgr != null else pact.tier

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 50)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.text = "%s %s\nTier %d/5  [%s]" % [
			"✦" if is_bound else " ",
			pact.display_name,
			char_tier,
			"ATIVO" if is_bound else ("DESBLOQUEADO" if pact.unlocked else "NÍVEL %d" % pact.unlock_level)
		]
		if is_bound:
			btn.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45))
		btn.pressed.connect(func(): _on_pact_selected(pact))
		_pacts_vbox.add_child(btn)

	if _selected_pact == null and not pact_list.is_empty():
		_on_pact_selected(pact_list[0])
	elif _selected_pact != null:
		_on_pact_selected(_selected_pact)

func _on_pact_selected(pact: PactData) -> void:
	_selected_pact = pact
	var char_mgr := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	var char_id := char_mgr.selected_character_id() if char_mgr != null else &"CHAR-001"
	var active_pact_id := char_mgr.get_character_pact(char_id) if char_mgr != null else &""
	var char_tier: int = char_mgr.get_character_pact_tier(char_id, pact.id) if char_mgr != null else pact.tier
	var is_bound: bool = pact.id == active_pact_id

	_lbl_pact_title.text = pact.display_name
	_lbl_pact_status.text = "[PACTO ATIVO]" if is_bound else "[INATIVO]"
	_lbl_pact_status.add_theme_color_override("font_color", Color(0.4, 0.9, 0.5) if is_bound else Color(0.6, 0.6, 0.6))

	# Estrelas de tier
	var stars := ""
	for i in range(1, 6):
		stars += "★ " if i <= char_tier else "☆ "
	_lbl_tier_display.text = "Evolução do Pacto:  %s  (Tier %d / %d)" % [stars, char_tier, pact.max_tier]

	_lbl_pact_desc.text = pact.description
	_lbl_pact_lore.text = "« %s »" % pact.lore

	# Passivas
	for child in _vbox_passives.get_children():
		child.queue_free()
	for p_desc in pact.passive_descriptions:
		var p_lbl := Label.new()
		p_lbl.text = "• " + p_desc
		p_lbl.add_theme_font_size_override("font_size", 11)
		p_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.75))
		_vbox_passives.add_child(p_lbl)

	# Stats escalados
	for child in _vbox_stats.get_children():
		child.queue_free()
	for s_key in pact.stat_modifiers.keys():
		var base_val: float = float(pact.stat_modifiers[s_key])
		var current_val: float = base_val * float(char_tier)
		var s_lbl := Label.new()
		s_lbl.text = "• %s: +%.0f" % [s_key.replace("_", " ").capitalize(), current_val]
		s_lbl.add_theme_font_size_override("font_size", 11)
		s_lbl.add_theme_color_override("font_color", Color(0.45, 0.85, 0.5))
		_vbox_stats.add_child(s_lbl)

	# Requisitos de evolução
	var souls_req: int = int(pact.evolution_requirements.get("souls_cost", 100)) * char_tier
	var item_req: String = String(pact.evolution_requirements.get("required_item_id", "EQ-016"))
	var item_qty: int = int(pact.evolution_requirements.get("item_quantity", 1)) * char_tier
	_lbl_evolution_reqs.text = "Custo para o próximo Tier: %d Almas e %dx item [%s]" % [souls_req, item_qty, item_req]

	_btn_bind.disabled = is_bound
	_btn_bind.text = "PACTO JÁ VINCULADO" if is_bound else "VINCULAR AO PORTADOR"
	_btn_evolve.disabled = char_tier >= pact.max_tier

func _on_bind_pressed() -> void:
	if _selected_pact == null:
		return
	var char_mgr := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	var char_id := char_mgr.selected_character_id() if char_mgr != null else &"CHAR-001"
	if char_mgr != null:
		char_mgr.set_character_pact(char_id, _selected_pact.id)
		_lbl_feedback.text = "Pacto '%s' vinculado com sucesso!" % _selected_pact.display_name
		_refresh_pacts()

func _on_evolve_pressed() -> void:
	if _selected_pact == null:
		return
	var char_mgr := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	var char_id := char_mgr.selected_character_id() if char_mgr != null else &"CHAR-001"
	if char_mgr != null:
		var new_tier := char_mgr.evolve_character_pact(char_id, _selected_pact.id)
		_lbl_feedback.text = "Pacto evoluído para o Tier %d!" % new_tier
		_refresh_pacts()

func _on_close_pressed() -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.close_screen(&"pacts")
