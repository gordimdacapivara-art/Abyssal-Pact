class_name EquipmentScreen
extends ScreenBase
## Tela de Equipamentos: Armas, Armaduras, Acessórios, Comparação de Atributos e Aparência 3D.

const SLOTS: Array[Dictionary] = [
	{"slot": &"weapon", "label": "Arma Principal"},
	{"slot": &"head", "label": "Elmo"},
	{"slot": &"chest", "label": "Peitoral"},
	{"slot": &"legs", "label": "Perneiras"},
	{"slot": &"boots", "label": "Botas"},
	{"slot": &"amulet", "label": "Amuleto"},
	{"slot": &"ring", "label": "Anel 1"},
	{"slot": &"ring2", "label": "Anel 2"},
]

var _selected_slot: StringName = &"weapon"
var _selected_inv_item: EquipmentData = null

var _header: DarkFantasyHeader
var _nav_bar: DarkFantasyNavBar
var _slot_ui_map: Dictionary = {} # StringName -> ItemSlotUI
var _stat_card: StatComparisonCard
var _inv_scroll_vbox: VBoxContainer
var _btn_equip: Button
var _btn_unequip: Button
var _lbl_feedback: Label

# Visual 3D
var _viewport_3d: SubViewport
var _model_slot: Node3D

func open(params: Dictionary = {}) -> void:
	super(params)
	screen_id = &"equipment"
	_build_ui()
	_refresh_loadout()
	_rebuild_character_preview()

func _ready() -> void:
	EventBus.equipment_changed.connect(_on_equipment_event)
	_build_ui()
	_refresh_loadout()

func _on_equipment_event(_char_id, _slot, _item_id) -> void:
	if is_visible_in_tree():
		_refresh_loadout()

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

	_header = DarkFantasyHeader.new("EQUIPAMENTOS DO PORTADOR", "Armas, Armaduras, Acessórios e Comparação de Atributos")
	_header.close_requested.connect(_on_close_pressed)
	main_vbox.add_child(_header)

	_nav_bar = DarkFantasyNavBar.new(&"equipment")
	main_vbox.add_child(_nav_bar)

	# Conteúdo principal: 3 Colunas (Slots Esquerdos / 3D Preview / Comparação e Itens)
	var content_hbox := HBoxContainer.new()
	content_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_theme_constant_override("separation", 16)
	main_vbox.add_child(content_hbox)

	# --- COLUNA 1: SLOTS DE EQUIPAMENTO ---
	var slots_panel := PanelContainer.new()
	slots_panel.custom_minimum_size = Vector2(280, 0)
	slots_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(slots_panel)

	var slots_vbox := VBoxContainer.new()
	slots_vbox.add_theme_constant_override("separation", 8)
	slots_vbox.offset_left = 10
	slots_vbox.offset_right = -10
	slots_vbox.offset_top = 10
	slots_vbox.offset_bottom = -10
	slots_panel.add_child(slots_vbox)

	var slots_title := Label.new()
	slots_title.text = "SLOTS DE COMBATE"
	slots_title.add_theme_font_size_override("font_size", 14)
	slots_title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.65))
	slots_vbox.add_child(slots_title)

	var slots_grid := GridContainer.new()
	slots_grid.columns = 2
	slots_grid.add_theme_constant_override("h_separation", 10)
	slots_grid.add_theme_constant_override("v_separation", 10)
	slots_vbox.add_child(slots_grid)

	for slot_info in SLOTS:
		var s_name: StringName = slot_info["slot"]
		var slot_box := VBoxContainer.new()
		slot_box.add_theme_constant_override("separation", 2)

		var s_lbl := Label.new()
		s_lbl.text = slot_info["label"]
		s_lbl.add_theme_font_size_override("font_size", 10)
		s_lbl.add_theme_color_override("font_color", Color(0.7, 0.65, 0.6))
		slot_box.add_child(s_lbl)

		var slot_ui := ItemSlotUI.new(null, 1, s_name)
		slot_ui.slot_clicked.connect(func(_u): _on_doll_slot_clicked(s_name))
		slot_box.add_child(slot_ui)
		slots_grid.add_child(slot_box)
		_slot_ui_map[s_name] = slot_ui

	_btn_unequip = Button.new()
	_btn_unequip.text = "Desequipar Slot Selecionado"
	_btn_unequip.custom_minimum_size = Vector2(0, 36)
	_btn_unequip.pressed.connect(_on_unequip_pressed)
	slots_vbox.add_child(_btn_unequip)

	# --- COLUNA 2: PREVIEW 3D DO PERSONAGEM ---
	var preview_panel := PanelContainer.new()
	preview_panel.custom_minimum_size = Vector2(320, 0)
	preview_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(preview_panel)

	var preview_vbox := VBoxContainer.new()
	preview_vbox.add_theme_constant_override("separation", 6)
	preview_vbox.offset_left = 10
	preview_vbox.offset_right = -10
	preview_vbox.offset_top = 10
	preview_vbox.offset_bottom = -10
	preview_panel.add_child(preview_vbox)

	var preview_title := Label.new()
	preview_title.text = "APARÊNCIA DO PERSONAGEM"
	preview_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_title.add_theme_font_size_override("font_size", 13)
	preview_title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.65))
	preview_vbox.add_child(preview_title)

	var vpc := SubViewportContainer.new()
	vpc.stretch = true
	vpc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_vbox.add_child(vpc)

	_viewport_3d = SubViewport.new()
	_viewport_3d.size = Vector2(300, 420)
	_viewport_3d.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vpc.add_child(_viewport_3d)

	var env_3d := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.05, 0.045, 0.06)
	env.ambient_light_color = Color(0.8, 0.75, 0.7)
	env.ambient_light_energy = 0.9
	env_3d.environment = env
	_viewport_3d.add_child(env_3d)

	var light := DirectionalLight3D.new()
	light.position = Vector3(1, 2, 2)
	_viewport_3d.add_child(light)
	light.look_at(Vector3.ZERO)

	var cam := Camera3D.new()
	cam.position = Vector3(0, 1.2, 2.5)
	_viewport_3d.add_child(cam)
	cam.look_at(Vector3(0, 0.9, 0))

	_model_slot = Node3D.new()
	_viewport_3d.add_child(_model_slot)

	# --- COLUNA 3: COMPARAÇÃO E ITENS DO INVENTÁRIO ---
	var right_panel := PanelContainer.new()
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(right_panel)

	var right_vbox := VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 10)
	right_vbox.offset_left = 12
	right_vbox.offset_right = -12
	right_vbox.offset_top = 10
	right_vbox.offset_bottom = -10
	right_panel.add_child(right_vbox)

	_stat_card = StatComparisonCard.new()
	right_vbox.add_child(_stat_card)

	var inv_title := Label.new()
	inv_title.text = "ITENS COMPATÍVEIS NO INVENTÁRIO"
	inv_title.add_theme_font_size_override("font_size", 12)
	inv_title.add_theme_color_override("font_color", Color(0.85, 0.8, 0.65))
	right_vbox.add_child(inv_title)

	var inv_scroll := ScrollContainer.new()
	inv_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vbox.add_child(inv_scroll)

	_inv_scroll_vbox = VBoxContainer.new()
	_inv_scroll_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_inv_scroll_vbox.add_theme_constant_override("separation", 6)
	inv_scroll.add_child(_inv_scroll_vbox)

	_btn_equip = Button.new()
	_btn_equip.text = "EQUIPAR ITEM SELECIONADO"
	_btn_equip.custom_minimum_size = Vector2(0, 40)
	_btn_equip.disabled = true
	_btn_equip.pressed.connect(_on_equip_pressed)
	right_vbox.add_child(_btn_equip)

	_lbl_feedback = Label.new()
	_lbl_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_feedback.add_theme_font_size_override("font_size", 11)
	_lbl_feedback.add_theme_color_override("font_color", Color(0.3, 0.85, 0.4))
	right_vbox.add_child(_lbl_feedback)

func _refresh_loadout() -> void:
	var char_mgr := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	var inv_mgr := Game.get_system(SystemNames.INVENTORY) as InventoryManager
	if inv_mgr == null:
		return

	var char_id := char_mgr.selected_character_id() if char_mgr != null else &"CHAR-001"
	var loadout := inv_mgr.loadout_of(char_id)

	for slot_info in SLOTS:
		var s_name: StringName = slot_info["slot"]
		var slot_ui: ItemSlotUI = _slot_ui_map.get(s_name)
		if slot_ui == null:
			continue
		var equipped_id := loadout.item_in_slot(s_name) if loadout != null else &""
		var item := inv_mgr.get_item(equipped_id) if not equipped_id.is_empty() else null
		slot_ui.set_item(item, 1)
		slot_ui.set_selected(s_name == _selected_slot)

	_refresh_compatible_inventory_list()

func _on_doll_slot_clicked(slot_name_clicked: StringName) -> void:
	_selected_slot = slot_name_clicked
	for s_name in _slot_ui_map.keys():
		var ui: ItemSlotUI = _slot_ui_map[s_name]
		ui.set_selected(s_name == _selected_slot)
	_selected_inv_item = null
	_refresh_compatible_inventory_list()

func _refresh_compatible_inventory_list() -> void:
	for child in _inv_scroll_vbox.get_children():
		child.queue_free()

	var char_mgr := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	var inv_mgr := Game.get_system(SystemNames.INVENTORY) as InventoryManager
	var char_id := char_mgr.selected_character_id() if char_mgr != null else &"CHAR-001"
	var inv := inv_mgr.inventory_of(char_id) if inv_mgr != null else null
	var loadout := inv_mgr.loadout_of(char_id) if inv_mgr != null else null

	var current_equipped_id := loadout.item_in_slot(_selected_slot) if loadout != null else &""
	var current_item := inv_mgr.get_item(current_equipped_id) if not current_equipped_id.is_empty() else null

	var matching_count := 0
	if inv != null:
		for slot in inv.slots:
			var item := inv_mgr.get_item(slot.item_id)
			if item == null or item.category != &"equipment":
				continue
			# Compatibilidade com slot
			var slot_matches := false
			if _selected_slot == &"weapon" and item.slot == &"weapon":
				slot_matches = true
			elif _selected_slot in [&"ring", &"ring2"] and item.slot in [&"ring", &"ring2"]:
				slot_matches = true
			elif item.slot == _selected_slot:
				slot_matches = true

			if not slot_matches:
				continue

			var row_btn := Button.new()
			row_btn.custom_minimum_size = Vector2(0, 36)
			row_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row_btn.text = " %s  [%s]  (Atq/Def: %s)" % [
				item.display_name,
				String(item.rarity).to_upper(),
				str(item.stats.get("attack", item.stats.get("defense", 0)))
			]
			row_btn.pressed.connect(func(): _on_inv_item_selected(item))
			_inv_scroll_vbox.add_child(row_btn)
			matching_count += 1

	if matching_count == 0:
		var empty_lbl := Label.new()
		empty_lbl.text = "Nenhum item compatível para o slot [%s] no inventário." % String(_selected_slot)
		empty_lbl.add_theme_color_override("font_color", Color(0.6, 0.55, 0.5))
		empty_lbl.add_theme_font_size_override("font_size", 11)
		_inv_scroll_vbox.add_child(empty_lbl)

	_stat_card.compare(current_item, _selected_inv_item)
	_btn_equip.disabled = _selected_inv_item == null

func _on_inv_item_selected(item: EquipmentData) -> void:
	_selected_inv_item = item
	var char_mgr := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	var inv_mgr := Game.get_system(SystemNames.INVENTORY) as InventoryManager
	var char_id := char_mgr.selected_character_id() if char_mgr != null else &"CHAR-001"
	var loadout := inv_mgr.loadout_of(char_id) if inv_mgr != null else null
	var current_equipped_id := loadout.item_in_slot(_selected_slot) if loadout != null else &""
	var current_item := inv_mgr.get_item(current_equipped_id) if not current_equipped_id.is_empty() else null
	_stat_card.compare(current_item, _selected_inv_item)
	_btn_equip.disabled = false

func _on_equip_pressed() -> void:
	if _selected_inv_item == null:
		return
	var char_mgr := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	var inv_mgr := Game.get_system(SystemNames.INVENTORY) as InventoryManager
	var char_id := char_mgr.selected_character_id() if char_mgr != null else &"CHAR-001"
	var err := inv_mgr.equip_item(char_id, _selected_slot, _selected_inv_item.id)
	if err == OK:
		_lbl_feedback.text = "Equipado: %s em [%s]" % [_selected_inv_item.display_name, String(_selected_slot)]
		_selected_inv_item = null
		_refresh_loadout()
	else:
		_lbl_feedback.text = "Erro ao equipar: %d" % err

func _on_unequip_pressed() -> void:
	var char_mgr := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	var inv_mgr := Game.get_system(SystemNames.INVENTORY) as InventoryManager
	var char_id := char_mgr.selected_character_id() if char_mgr != null else &"CHAR-001"
	var err := inv_mgr.unequip_slot(char_id, _selected_slot)
	if err == OK:
		_lbl_feedback.text = "Slot [%s] desequipado." % String(_selected_slot)
		_refresh_loadout()
	else:
		_lbl_feedback.text = "Slot já se encontra vazio."

func _rebuild_character_preview() -> void:
	if _model_slot == null:
		return
	for child in _model_slot.get_children():
		child.queue_free()

	var char_mgr := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	var race_mgr := Game.get_system(SystemNames.RACE) as RaceManager
	if char_mgr == null or race_mgr == null:
		return

	var char_data := char_mgr.selected_character()
	var race_id: StringName = char_data.race_id if char_data != null else &"RACE-001"
	var subrace_id: StringName = char_data.subrace_id if char_data != null else &"SUBRACE-001"
	var appearance: Dictionary = char_data.appearance if char_data != null else {}

	var builder_script := preload("res://race/race_visual_builder.gd")
	builder_script.build(_model_slot, race_id, subrace_id, race_mgr, appearance)

func _on_close_pressed() -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.close_screen(&"equipment")
