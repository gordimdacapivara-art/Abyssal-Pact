class_name InventoryScreen
extends ScreenBase
## Tela de Inventário completa com 5 categorias: equipamentos, consumíveis, materiais, relíquias e itens de missão.

var _active_category: StringName = &"all"
var _selected_item: EquipmentData = null

var _header: DarkFantasyHeader
var _nav_bar: DarkFantasyNavBar
var _grid_container: GridContainer
var _lbl_capacity: Label
var _lbl_item_name: Label
var _lbl_item_category: Label
var _lbl_item_rarity: Label
var _lbl_item_desc: Label
var _vbox_stats: VBoxContainer
var _btn_equip: Button
var _btn_use: Button
var _btn_discard: Button
var _lbl_action_feedback: Label

func open(params: Dictionary = {}) -> void:
	super(params)
	screen_id = &"inventory"
	_build_ui()
	_refresh_inventory()

func _ready() -> void:
	EventBus.item_added.connect(_on_inventory_event)
	EventBus.item_removed.connect(_on_inventory_event)
	EventBus.equipment_changed.connect(_on_inventory_event)
	_build_ui()
	_refresh_inventory()

func _on_inventory_event(_a = null, _b = null, _c = null) -> void:
	if is_visible_in_tree():
		_refresh_inventory()

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

	_header = DarkFantasyHeader.new("INVENTÁRIO ABISSAL", "Gestão de itens, consumíveis, relíquias e materiais")
	_header.close_requested.connect(_on_close_pressed)
	main_vbox.add_child(_header)

	_nav_bar = DarkFantasyNavBar.new(&"inventory")
	main_vbox.add_child(_nav_bar)

	# Barra de Filtros por Categoria
	var filter_bar := HBoxContainer.new()
	filter_bar.add_theme_constant_override("separation", 8)
	main_vbox.add_child(filter_bar)

	var categories := [
		{"id": &"all", "label": "Todos os Itens"},
		{"id": &"equipment", "label": "Equipamentos"},
		{"id": &"consumable", "label": "Consumíveis"},
		{"id": &"material", "label": "Materiais"},
		{"id": &"relic", "label": "Relíquias"},
		{"id": &"quest", "label": "Itens de Missão"},
	]

	for cat in categories:
		var btn := Button.new()
		btn.text = "  " + cat["label"] + "  "
		var cid: StringName = cat["id"]
		btn.pressed.connect(func(): _set_category(cid))
		filter_bar.add_child(btn)

	_lbl_capacity = Label.new()
	_lbl_capacity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lbl_capacity.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_lbl_capacity.add_theme_color_override("font_color", Color(0.8, 0.75, 0.65))
	filter_bar.add_child(_lbl_capacity)

	# Área principal: Grid de Itens (esquerda) + Painel de Detalhes (direita)
	var content_hbox := HBoxContainer.new()
	content_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_theme_constant_override("separation", 16)
	main_vbox.add_child(content_hbox)

	# Painel do Grid
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(500, 0)
	content_hbox.add_child(scroll)

	_grid_container = GridContainer.new()
	_grid_container.columns = 6
	_grid_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid_container.add_theme_constant_override("h_separation", 8)
	_grid_container.add_theme_constant_override("v_separation", 8)
	scroll.add_child(_grid_container)

	# Painel de Detalhes
	var details_panel := PanelContainer.new()
	details_panel.custom_minimum_size = Vector2(340, 0)
	details_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(details_panel)

	var details_vbox := VBoxContainer.new()
	details_vbox.add_theme_constant_override("separation", 10)
	details_vbox.offset_left = 12
	details_vbox.offset_right = -12
	details_vbox.offset_top = 12
	details_vbox.offset_bottom = -12
	details_panel.add_child(details_vbox)

	_lbl_item_name = Label.new()
	_lbl_item_name.text = "Selecione um Item"
	_lbl_item_name.add_theme_font_size_override("font_size", 18)
	_lbl_item_name.add_theme_color_override("font_color", Color(0.95, 0.85, 0.6))
	details_vbox.add_child(_lbl_item_name)

	var meta_hbox := HBoxContainer.new()
	details_vbox.add_child(meta_hbox)

	_lbl_item_category = Label.new()
	_lbl_item_category.text = "Categoria: —"
	_lbl_item_category.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lbl_item_category.add_theme_color_override("font_color", Color(0.7, 0.65, 0.6))
	_lbl_item_category.add_theme_font_size_override("font_size", 12)
	meta_hbox.add_child(_lbl_item_category)

	_lbl_item_rarity = Label.new()
	_lbl_item_rarity.text = "Raridade: —"
	_lbl_item_rarity.add_theme_font_size_override("font_size", 12)
	meta_hbox.add_child(_lbl_item_rarity)

	details_vbox.add_child(HSeparator.new())

	_lbl_item_desc = Label.new()
	_lbl_item_desc.text = "Clique em um item do inventário para ver seus atributos, efeitos e opções de ação."
	_lbl_item_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_item_desc.add_theme_font_size_override("font_size", 12)
	details_vbox.add_child(_lbl_item_desc)

	details_vbox.add_child(HSeparator.new())

	var stats_title := Label.new()
	stats_title.text = "ATRIBUTOS / EFEITOS:"
	stats_title.add_theme_font_size_override("font_size", 11)
	stats_title.add_theme_color_override("font_color", Color(0.85, 0.75, 0.5))
	details_vbox.add_child(stats_title)

	_vbox_stats = VBoxContainer.new()
	_vbox_stats.add_theme_constant_override("separation", 3)
	details_vbox.add_child(_vbox_stats)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	details_vbox.add_child(spacer)

	_lbl_action_feedback = Label.new()
	_lbl_action_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_action_feedback.add_theme_font_size_override("font_size", 11)
	_lbl_action_feedback.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5))
	details_vbox.add_child(_lbl_action_feedback)

	# Botões de Ação
	_btn_equip = Button.new()
	_btn_equip.text = "EQUIPAR ITEM"
	_btn_equip.custom_minimum_size = Vector2(0, 38)
	_btn_equip.pressed.connect(_on_equip_pressed)
	_btn_equip.disabled = true
	details_vbox.add_child(_btn_equip)

	_btn_use = Button.new()
	_btn_use.text = "USAR CONSUMÍVEL"
	_btn_use.custom_minimum_size = Vector2(0, 38)
	_btn_use.pressed.connect(_on_use_pressed)
	_btn_use.disabled = true
	details_vbox.add_child(_btn_use)

	_btn_discard = Button.new()
	_btn_discard.text = "DESCARTAR (1)"
	_btn_discard.custom_minimum_size = Vector2(0, 34)
	_btn_discard.pressed.connect(_on_discard_pressed)
	_btn_discard.disabled = true
	details_vbox.add_child(_btn_discard)

func _set_category(cat: StringName) -> void:
	_active_category = cat
	_refresh_inventory()

func _refresh_inventory() -> void:
	if _grid_container == null:
		return

	for child in _grid_container.get_children():
		child.queue_free()

	var char_mgr := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	var inv_mgr := Game.get_system(SystemNames.INVENTORY) as InventoryManager
	if inv_mgr == null:
		return

	var active_char_id: StringName = char_mgr.selected_character_id() if char_mgr != null else &""
	if active_char_id.is_empty():
		# Se não há personagem selecionado, usa o primeiro criado ou o ID de teste
		var chars := char_mgr.characters() if char_mgr != null else []
		if not chars.is_empty():
			active_char_id = chars[0].id
		else:
			active_char_id = &"CHAR-001"

	var inv: InventoryData = inv_mgr.inventory_of(active_char_id)
	# Se inventário estiver vazio, garante itens de prova do catálogo
	if inv != null and inv.slots.is_empty():
		inv_mgr.add_item(active_char_id, &"EQ-001", 1)
		inv_mgr.add_item(active_char_id, &"EQ-005", 1)
		inv_mgr.add_item(active_char_id, &"EQ-012", 5)
		inv_mgr.add_item(active_char_id, &"EQ-015", 10)
		inv_mgr.add_item(active_char_id, &"EQ-018", 1)
		inv_mgr.add_item(active_char_id, &"EQ-020", 1)

	var display_count := 0
	if inv != null:
		for slot in inv.slots:
			var item := inv_mgr.get_item(slot.item_id)
			if item == null:
				continue
			if _active_category != &"all" and item.category != _active_category:
				continue

			var slot_ui := ItemSlotUI.new(item, slot.quantity)
			slot_ui.slot_clicked.connect(_on_slot_clicked)
			_grid_container.add_child(slot_ui)
			display_count += 1

	# Preenche o restante até 30 células visuais
	var total_slots: int = int(max(30, display_count))
	for i in range(display_count, total_slots):
		var empty_slot := ItemSlotUI.new(null, 0)
		empty_slot.slot_clicked.connect(_on_slot_clicked)
		_grid_container.add_child(empty_slot)

	var current_used := inv.slots.size() if inv != null else 0
	_lbl_capacity.text = "Capacidade: %d / %d slots" % [current_used, 40]
	_update_details_panel()

func _on_slot_clicked(slot_ui: ItemSlotUI) -> void:
	for child in _grid_container.get_children():
		if child is ItemSlotUI:
			child.set_selected(child == slot_ui)
	_selected_item = slot_ui.item_data
	_update_details_panel()

func _update_details_panel() -> void:
	for child in _vbox_stats.get_children():
		child.queue_free()

	if _selected_item == null:
		_lbl_item_name.text = "Selecione um Item"
		_lbl_item_category.text = "Categoria: —"
		_lbl_item_rarity.text = "Raridade: —"
		_lbl_item_desc.text = "Clique em um item do inventário para inspecionar atributos e ações."
		_btn_equip.disabled = true
		_btn_use.disabled = true
		_btn_discard.disabled = true
		_lbl_action_feedback.text = ""
		return

	_lbl_item_name.text = _selected_item.display_name
	_lbl_item_category.text = "Categoria: %s" % String(_selected_item.category).capitalize()
	_lbl_item_rarity.text = "Raridade: %s" % String(_selected_item.rarity).to_upper()
	_lbl_item_desc.text = _selected_item.description

	if not _selected_item.stats.is_empty():
		for stat in _selected_item.stats.keys():
			var s_lbl := Label.new()
			s_lbl.text = "• %s: +%s" % [stat.replace("_", " ").capitalize(), str(_selected_item.stats[stat])]
			s_lbl.add_theme_font_size_override("font_size", 11)
			_vbox_stats.add_child(s_lbl)
	elif not _selected_item.use_effect.is_empty():
		var u_lbl := Label.new()
		u_lbl.text = "• Efeito: %s (+%s)" % [
			String(_selected_item.use_effect.get("type", "")).capitalize(),
			str(_selected_item.use_effect.get("value", ""))
		]
		u_lbl.add_theme_font_size_override("font_size", 11)
		u_lbl.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5))
		_vbox_stats.add_child(u_lbl)
	else:
		var n_lbl := Label.new()
		n_lbl.text = "• Sem atributos adicionais."
		n_lbl.add_theme_font_size_override("font_size", 11)
		_vbox_stats.add_child(n_lbl)

	_btn_equip.disabled = _selected_item.category != &"equipment" or String(_selected_item.slot).is_empty() or String(_selected_item.slot) == "none"
	_btn_use.disabled = _selected_item.category != &"consumable"
	_btn_discard.disabled = false

func _on_equip_pressed() -> void:
	if _selected_item == null:
		return
	var char_mgr := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	var inv_mgr := Game.get_system(SystemNames.INVENTORY) as InventoryManager
	var char_id := char_mgr.selected_character_id() if char_mgr != null else &"CHAR-001"
	var err := inv_mgr.equip_item(char_id, _selected_item.slot, _selected_item.id)
	if err == OK:
		_lbl_action_feedback.text = "Item equipado em [%s] com sucesso!" % String(_selected_item.slot)
	else:
		_lbl_action_feedback.text = "Falha ao equipar: erro %d" % err

func _on_use_pressed() -> void:
	if _selected_item == null:
		return
	var char_mgr := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	var inv_mgr := Game.get_system(SystemNames.INVENTORY) as InventoryManager
	var char_id := char_mgr.selected_character_id() if char_mgr != null else &"CHAR-001"
	var err := inv_mgr.use_item(char_id, _selected_item.id)
	if err == OK:
		_lbl_action_feedback.text = "Consumível utilizado com sucesso!"
		_refresh_inventory()
	else:
		_lbl_action_feedback.text = "Não foi possível consumir o item."

func _on_discard_pressed() -> void:
	if _selected_item == null:
		return
	var char_mgr := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	var inv_mgr := Game.get_system(SystemNames.INVENTORY) as InventoryManager
	var char_id := char_mgr.selected_character_id() if char_mgr != null else &"CHAR-001"
	var err := inv_mgr.remove_item(char_id, _selected_item.id, 1)
	if err == OK:
		_lbl_action_feedback.text = "1 unidade descartada."
		_refresh_inventory()

func _on_close_pressed() -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.close_screen(&"inventory")
