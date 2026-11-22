class_name AbilitiesScreen
extends ScreenBase
## Tela de Habilidades de Combate e Conjurações.
## Lê dados reais do ClassManager e AbilityData do personagem ativo.

var _selected_slot: StringName = &"slot_1"
var _selected_ability: AbilityData = null

# Loadout ativo provisório do personagem
var _active_loadout: Dictionary = {
	"slot_1": &"ability_arcane_missile",
	"slot_2": &"ability_arcane_burst",
	"special": &"ability_arcane_nova",
	"passive": &"ability_arcane_flow"
}

var _header: DarkFantasyHeader
var _nav_bar: DarkFantasyNavBar
var _slot_buttons: Dictionary = {}
var _abilities_vbox: VBoxContainer
var _lbl_ability_name: Label
var _lbl_ability_kind: Label
var _lbl_ability_desc: Label
var _lbl_ability_stats: Label
var _btn_assign: Button
var _lbl_feedback: Label

func open(params: Dictionary = {}) -> void:
	super(params)
	screen_id = &"abilities"
	_build_ui()
	_refresh_abilities()

func _ready() -> void:
	_build_ui()
	_refresh_abilities()

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

	_header = DarkFantasyHeader.new("HABILIDADES & CONJURAÇÕES", "Gestão do loadout de combate e conjurações da classe")
	_header.close_requested.connect(_on_close_pressed)
	main_vbox.add_child(_header)

	_nav_bar = DarkFantasyNavBar.new(&"abilities")
	main_vbox.add_child(_nav_bar)

	var content_hbox := HBoxContainer.new()
	content_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_theme_constant_override("separation", 16)
	main_vbox.add_child(content_hbox)

	# --- COLUNA 1: SLOTS ATIVOS DE COMBATE ---
	var loadout_panel := PanelContainer.new()
	loadout_panel.custom_minimum_size = Vector2(300, 0)
	content_hbox.add_child(loadout_panel)

	var loadout_vbox := VBoxContainer.new()
	loadout_vbox.add_theme_constant_override("separation", 10)
	loadout_vbox.offset_left = 12
	loadout_vbox.offset_right = -12
	loadout_vbox.offset_top = 12
	loadout_vbox.offset_bottom = -12
	loadout_panel.add_child(loadout_vbox)

	var l_title := Label.new()
	l_title.text = "SLOTS DE HABILIDADE"
	l_title.add_theme_font_size_override("font_size", 14)
	l_title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
	loadout_vbox.add_child(l_title)

	var slot_defs := [
		{"id": &"slot_1", "label": "Habilidade Ativa 1 (Tecla 1)"},
		{"id": &"slot_2", "label": "Habilidade Ativa 2 (Tecla 2)"},
		{"id": &"special", "label": "Habilidade Especial (Tecla R)"},
		{"id": &"passive", "label": "Habilidade Passiva (Passivo)"},
	]

	for s in slot_defs:
		var sid: StringName = s["id"]
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 48)
		btn.text = "%s\n[Vazio]" % s["label"]
		btn.pressed.connect(func(): _select_loadout_slot(sid))
		loadout_vbox.add_child(btn)
		_slot_buttons[sid] = btn

	# --- COLUNA 2: CATÁLOGO DE HABILIDADES DA CLASSE ---
	var list_panel := PanelContainer.new()
	list_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(list_panel)

	var list_vbox := VBoxContainer.new()
	list_vbox.add_theme_constant_override("separation", 8)
	list_vbox.offset_left = 12
	list_vbox.offset_right = -12
	list_vbox.offset_top = 12
	list_vbox.offset_bottom = -12
	list_panel.add_child(list_vbox)

	var list_title := Label.new()
	list_title.text = "HABILIDADES DISPONÍVEIS DA CLASSE"
	list_title.add_theme_font_size_override("font_size", 14)
	list_title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.65))
	list_vbox.add_child(list_title)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list_vbox.add_child(scroll)

	_abilities_vbox = VBoxContainer.new()
	_abilities_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_abilities_vbox.add_theme_constant_override("separation", 6)
	scroll.add_child(_abilities_vbox)

	# --- COLUNA 3: DETALHES E ATRIBUIÇÃO ---
	var detail_panel := PanelContainer.new()
	detail_panel.custom_minimum_size = Vector2(300, 0)
	content_hbox.add_child(detail_panel)

	var detail_vbox := VBoxContainer.new()
	detail_vbox.add_theme_constant_override("separation", 10)
	detail_vbox.offset_left = 12
	detail_vbox.offset_right = -12
	detail_vbox.offset_top = 12
	detail_vbox.offset_bottom = -12
	detail_panel.add_child(detail_vbox)

	_lbl_ability_name = Label.new()
	_lbl_ability_name.text = "Selecione uma Habilidade"
	_lbl_ability_name.add_theme_font_size_override("font_size", 16)
	_lbl_ability_name.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
	detail_vbox.add_child(_lbl_ability_name)

	_lbl_ability_kind = Label.new()
	_lbl_ability_kind.text = "Tipo: —"
	_lbl_ability_kind.add_theme_font_size_override("font_size", 12)
	_lbl_ability_kind.add_theme_color_override("font_color", Color(0.7, 0.65, 0.6))
	detail_vbox.add_child(_lbl_ability_kind)

	detail_vbox.add_child(HSeparator.new())

	_lbl_ability_desc = Label.new()
	_lbl_ability_desc.text = "Selecione uma habilidade para inspecionar custos, tempo de recarga e efeitos."
	_lbl_ability_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_ability_desc.add_theme_font_size_override("font_size", 12)
	detail_vbox.add_child(_lbl_ability_desc)

	_lbl_ability_stats = Label.new()
	_lbl_ability_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_ability_stats.add_theme_font_size_override("font_size", 11)
	_lbl_ability_stats.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5))
	detail_vbox.add_child(_lbl_ability_stats)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_vbox.add_child(spacer)

	_btn_assign = Button.new()
	_btn_assign.text = "EQUIPAR NO SLOT SELECIONADO"
	_btn_assign.custom_minimum_size = Vector2(0, 40)
	_btn_assign.disabled = true
	_btn_assign.pressed.connect(_on_assign_pressed)
	detail_vbox.add_child(_btn_assign)

	_lbl_feedback = Label.new()
	_lbl_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_feedback.add_theme_font_size_override("font_size", 11)
	_lbl_feedback.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5))
	detail_vbox.add_child(_lbl_feedback)

func _select_loadout_slot(slot_id: StringName) -> void:
	_selected_slot = slot_id
	_refresh_slot_buttons()

func _refresh_slot_buttons() -> void:
	var class_mgr := Game.get_system(SystemNames.CLASS) as ClassManager
	for sid in _slot_buttons.keys():
		var btn: Button = _slot_buttons[sid]
		var aid: StringName = _active_loadout.get(String(sid), &"")
		var ab_data := class_mgr.get_ability(aid) if class_mgr != null and not aid.is_empty() else null
		var ab_name := ab_data.display_name if ab_data != null else "Vazio"
		var is_sel: bool = (sid == _selected_slot)
		btn.text = "%s [%s]\n%s" % [String(sid).to_upper(), "★" if is_sel else " ", ab_name]
		if is_sel:
			btn.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
		else:
			btn.remove_theme_color_override("font_color")

func _refresh_abilities() -> void:
	for child in _abilities_vbox.get_children():
		child.queue_free()

	var char_mgr := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	var class_mgr := Game.get_system(SystemNames.CLASS) as ClassManager
	if class_mgr == null:
		return

	var char_data := char_mgr.selected_character() if char_mgr != null else null
	var class_id: StringName = char_data.class_id if char_data != null else &"CLASS-001"
	var class_data := class_mgr.get_class_data(class_id)
	if class_data == null:
		return

	# Coleta habilidades ativas e passivas da classe
	var all_ids: Array = []
	for a in class_data.active_ability_ids:
		all_ids.append(a)
	for p in class_data.passive_ability_ids:
		all_ids.append(p)

	# Se a lista da classe for menor que 4, busca no catálogo de habilidades
	if all_ids.size() < 4:
		for ab in class_mgr.abilities():
			if not all_ids.has(ab.id):
				all_ids.append(ab.id)

	for aid in all_ids:
		var ab: AbilityData = class_mgr.get_ability(StringName(String(aid)))
		if ab == null:
			continue
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 40)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.text = " %s  [%s]  (Cooldown: %.1fs | Custo: %d)" % [
			ab.display_name,
			String(ab.kind).to_upper(),
			ab.cooldown,
			ab.cost
		]
		btn.pressed.connect(func(): _on_ability_selected(ab))
		_abilities_vbox.add_child(btn)

	_refresh_slot_buttons()

func _on_ability_selected(ab: AbilityData) -> void:
	_selected_ability = ab
	_lbl_ability_name.text = ab.display_name
	_lbl_ability_kind.text = "Tipo: %s | Alcance: %.1fm" % [String(ab.kind).capitalize(), ab.range_meters]
	_lbl_ability_desc.text = ab.description
	_lbl_ability_stats.text = "• Cooldown: %.1f s\n• Custo de Mana/Recurso: %d\n• Tipo de Dano: %s\n• Tempo de Conjuração: %.1f s" % [
		ab.cooldown,
		ab.cost,
		String(ab.damage_type).capitalize(),
		ab.cast_time
	]
	_btn_assign.disabled = false

func _on_assign_pressed() -> void:
	if _selected_ability == null:
		return
	_active_loadout[String(_selected_slot)] = _selected_ability.id
	_lbl_feedback.text = "Habilidade '%s' vinculada a [%s]!" % [_selected_ability.display_name, String(_selected_slot).to_upper()]
	EventBus.class_loadout_changed.emit(_selected_ability.id, _selected_slot)
	_refresh_slot_buttons()

func _on_close_pressed() -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.close_screen(&"abilities")
