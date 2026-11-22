class_name BestiaryScreen
extends ScreenBase
## Tela de Bestiário Especializado de ABYSSAL PACT: 230 Demônios (200 Regionais + 30 Chefes).

var _filter_continent: StringName = &"all"
var _filter_family: StringName = &"all"
var _search_filter: String = ""
var _selected_creature: Dictionary = {}

var _header: DarkFantasyHeader
var _nav_bar: DarkFantasyNavBar
var _input_search: LineEdit
var _lbl_count: Label
var _creatures_vbox: VBoxContainer
var _lbl_name: Label
var _lbl_category_rarity: Label
var _lbl_region: Label
var _lbl_desc: Label
var _vbox_attributes: VBoxContainer
var _vbox_resistances: VBoxContainer
var _vbox_abilities: VBoxContainer
var _lbl_model_status: Label

func open(params: Dictionary = {}) -> void:
	super(params)
	screen_id = &"bestiary"
	_build_ui()
	_refresh_bestiary()

func _ready() -> void:
	_build_ui()
	_refresh_bestiary()

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

	_header = DarkFantasyHeader.new("BESTIÁRIO DEMONÍACO", "Catálogo dos 230 Demônios e Chefes dos Quatro Continentes")
	_header.close_requested.connect(_on_close_pressed)
	main_vbox.add_child(_header)

	_nav_bar = DarkFantasyNavBar.new(&"bestiary")
	main_vbox.add_child(_nav_bar)

	# Barra de Filtros de Continente
	var cont_bar := HBoxContainer.new()
	cont_bar.add_theme_constant_override("separation", 8)
	main_vbox.add_child(cont_bar)

	var conts := [
		{"id": &"all", "label": "Todos os Continentes"},
		{"id": &"CONT-01", "label": "Veyrath"},
		{"id": &"CONT-02", "label": "Sylvaran"},
		{"id": &"CONT-03", "label": "Khar-Duum"},
		{"id": &"CONT-04", "label": "Nhal'Kora"},
	]
	for c in conts:
		var cid: StringName = c["id"]
		var btn := Button.new()
		btn.text = " " + c["label"] + " "
		btn.pressed.connect(func():
			_filter_continent = cid
			_refresh_bestiary()
		)
		cont_bar.add_child(btn)

	# Barra de Busca e Família
	var search_hbox := HBoxContainer.new()
	search_hbox.add_theme_constant_override("separation", 8)
	main_vbox.add_child(search_hbox)

	var opt_family := OptionButton.new()
	opt_family.custom_minimum_size = Vector2(180, 32)
	var families := ["all", "brute", "stalker", "caster", "swarm", "flyer", "sentinel", "boss"]
	var f_labels := ["Todas as Famílias", "Brute", "Stalker", "Caster", "Swarm", "Flyer", "Sentinel", "Chefe"]
	for i in range(families.size()):
		opt_family.add_item(f_labels[i], i)
	opt_family.item_selected.connect(func(idx):
		_filter_family = StringName(families[idx])
		_refresh_bestiary()
	)
	search_hbox.add_child(opt_family)

	_input_search = LineEdit.new()
	_input_search.placeholder_text = "Buscar por nome, região ou ID (ex: DEMON-001, BOSS-001)..."
	_input_search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_input_search.text_changed.connect(func(t):
		_search_filter = t.strip_edges().to_lower()
		_refresh_bestiary()
	)
	search_hbox.add_child(_input_search)

	_lbl_count = Label.new()
	_lbl_count.add_theme_color_override("font_color", Color(0.8, 0.75, 0.65))
	_lbl_count.add_theme_font_size_override("font_size", 12)
	search_hbox.add_child(_lbl_count)

	var content_hbox := HBoxContainer.new()
	content_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_theme_constant_override("separation", 16)
	main_vbox.add_child(content_hbox)

	# --- COLUNA 1: LISTA DE CRIATURAS ---
	var list_panel := PanelContainer.new()
	list_panel.custom_minimum_size = Vector2(360, 0)
	list_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(list_panel)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 10
	scroll.offset_right = -10
	scroll.offset_top = 10
	scroll.offset_bottom = -10
	list_panel.add_child(scroll)

	_creatures_vbox = VBoxContainer.new()
	_creatures_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_creatures_vbox.add_theme_constant_override("separation", 4)
	scroll.add_child(_creatures_vbox)

	# --- COLUNA 2: FICHA DA CRIATURA ---
	var detail_panel := PanelContainer.new()
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(detail_panel)

	var detail_scroll := ScrollContainer.new()
	detail_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	detail_scroll.offset_left = 16
	detail_scroll.offset_right = -16
	detail_scroll.offset_top = 12
	detail_scroll.offset_bottom = -12
	detail_panel.add_child(detail_scroll)

	var detail_vbox := VBoxContainer.new()
	detail_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_vbox.add_theme_constant_override("separation", 8)
	detail_scroll.add_child(detail_vbox)

	_lbl_name = Label.new()
	_lbl_name.text = "Selecione uma Criatura"
	_lbl_name.add_theme_font_size_override("font_size", 20)
	_lbl_name.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
	detail_vbox.add_child(_lbl_name)

	var sub_hbox := HBoxContainer.new()
	detail_vbox.add_child(sub_hbox)

	_lbl_category_rarity = Label.new()
	_lbl_category_rarity.text = ""
	_lbl_category_rarity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lbl_category_rarity.add_theme_font_size_override("font_size", 12)
	_lbl_category_rarity.add_theme_color_override("font_color", Color(0.8, 0.75, 0.65))
	sub_hbox.add_child(_lbl_category_rarity)

	_lbl_region = Label.new()
	_lbl_region.text = ""
	_lbl_region.add_theme_font_size_override("font_size", 12)
	_lbl_region.add_theme_color_override("font_color", Color(0.85, 0.45, 0.35))
	sub_hbox.add_child(_lbl_region)

	detail_vbox.add_child(HSeparator.new())

	_lbl_desc = Label.new()
	_lbl_desc.text = ""
	_lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_desc.add_theme_font_size_override("font_size", 12)
	detail_vbox.add_child(_lbl_desc)

	detail_vbox.add_child(HSeparator.new())

	# Atributos e Resistências
	var stats_hbox := HBoxContainer.new()
	stats_hbox.add_theme_constant_override("separation", 16)
	detail_vbox.add_child(stats_hbox)

	var attr_box := VBoxContainer.new()
	attr_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_hbox.add_child(attr_box)

	var a_title := Label.new()
	a_title.text = "ATRIBUTOS DE COMBATE:"
	a_title.add_theme_font_size_override("font_size", 12)
	a_title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.6))
	attr_box.add_child(a_title)

	_vbox_attributes = VBoxContainer.new()
	_vbox_attributes.add_theme_constant_override("separation", 3)
	attr_box.add_child(_vbox_attributes)

	var res_box := VBoxContainer.new()
	res_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_hbox.add_child(res_box)

	var r_title := Label.new()
	r_title.text = "RESISTÊNCIAS ELEMENTAIS:"
	r_title.add_theme_font_size_override("font_size", 12)
	r_title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.6))
	res_box.add_child(r_title)

	_vbox_resistances = VBoxContainer.new()
	_vbox_resistances.add_theme_constant_override("separation", 3)
	res_box.add_child(_vbox_resistances)

	detail_vbox.add_child(HSeparator.new())

	var ab_title := Label.new()
	ab_title.text = "HABILIDADES & COMPORTAMENTOS:"
	ab_title.add_theme_font_size_override("font_size", 12)
	ab_title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.6))
	detail_vbox.add_child(ab_title)

	_vbox_abilities = VBoxContainer.new()
	_vbox_abilities.add_theme_constant_override("separation", 3)
	detail_vbox.add_child(_vbox_abilities)

	detail_vbox.add_child(HSeparator.new())

	_lbl_model_status = Label.new()
	_lbl_model_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_model_status.add_theme_font_size_override("font_size", 11)
	detail_vbox.add_child(_lbl_model_status)

func _refresh_bestiary() -> void:
	for child in _creatures_vbox.get_children():
		child.queue_free()

	var dm := Game.get_system(SystemNames.DEMONS) as DemonManager
	var bm := Game.get_system(SystemNames.BOSSES) as BossManager

	var list: Array[Dictionary] = []

	# Demônios Regionais (200)
	if dm != null:
		for d in dm.demons():
			if _filter_continent != &"all" and d.continent_id != _filter_continent:
				continue
			if _filter_family != &"all" and d.category != _filter_family:
				continue
			var name_l := d.display_name.to_lower()
			var id_l := String(d.id).to_lower()
			var reg_l := String(d.region_id).to_lower()
			if not _search_filter.is_empty() and not (_search_filter in name_l or _search_filter in id_l or _search_filter in reg_l):
				continue
			list.append({
				"is_boss": false,
				"id": String(d.id),
				"name": d.display_name,
				"category": String(d.category),
				"rarity": String(d.rarity),
				"continent": String(d.continent_id),
				"region": String(d.region_id),
				"desc": d.description,
				"health": int(d.stats.get("health", 100)),
				"attrs": d.stats,
				"resists": d.resistances,
				"abilities": d.ability_ids,
				"model_pending": d.model_pending,
				"model_path": d.model_path
			})

	# Chefes Especiais (30)
	if bm != null:
		for b in bm.bosses():
			if _filter_continent != &"all" and b.continent_id != _filter_continent:
				continue
			if _filter_family != &"all" and _filter_family != &"boss":
				continue
			var name_l := b.display_name.to_lower()
			var id_l := String(b.id).to_lower()
			if not _search_filter.is_empty() and not (_search_filter in name_l or _search_filter in id_l):
				continue
			list.append({
				"is_boss": true,
				"id": String(b.id),
				"name": b.display_name,
				"category": "boss",
				"rarity": "special_boss",
				"continent": String(b.continent_id),
				"region": String(b.region_id),
				"desc": "%s\n\nIdentidade Narrativa: %s" % [b.description, b.narrative_identity],
				"health": int(b.stats.get("health", 1000)),
				"attrs": {"fases": b.phases.size(), "dano": "Extremo"},
				"resists": b.resistances,
				"abilities": b.special_abilities,
				"model_pending": b.model_pending,
				"model_path": b.model_path
			})

	_lbl_count.text = "Exibindo %d de 230 criaturas" % list.size()

	for c in list:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 38)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var prefix := "👑 " if c["is_boss"] else "• "
		btn.text = "%s%s — %s [%s]" % [prefix, c["id"], c["name"], c["category"].to_upper()]
		if c["is_boss"]:
			btn.add_theme_color_override("font_color", Color(1.0, 0.45, 0.35))
		btn.pressed.connect(func(): _display_creature(c))
		_creatures_vbox.add_child(btn)

	if not list.is_empty():
		_display_creature(list[0])
	else:
		_display_creature({})

func _display_creature(c: Dictionary) -> void:
	_selected_creature = c
	for child in _vbox_attributes.get_children():
		child.queue_free()
	for child in _vbox_resistances.get_children():
		child.queue_free()
	for child in _vbox_abilities.get_children():
		child.queue_free()

	if c.is_empty():
		_lbl_name.text = "Nenhuma Criatura Encontrada"
		_lbl_category_rarity.text = ""
		_lbl_region.text = ""
		_lbl_desc.text = "Ajuste os filtros de continente ou família."
		_lbl_model_status.text = ""
		return

	_lbl_name.text = "%s  (%s)" % [c["name"], c["id"]]
	_lbl_category_rarity.text = "Categoria: %s | Raridade: %s" % [c["category"].capitalize(), c["rarity"].capitalize()]
	_lbl_region.text = "Continente: %s | Região/Arena: %s" % [c["continent"], c["region"]]
	_lbl_desc.text = c["desc"]

	# Atributos
	var hp_lbl := Label.new()
	hp_lbl.text = "• Vida Base: %d" % c["health"]
	hp_lbl.add_theme_font_size_override("font_size", 11)
	_vbox_attributes.add_child(hp_lbl)

	var attrs: Dictionary = c["attrs"]
	for a in attrs.keys():
		var a_lbl := Label.new()
		a_lbl.text = "• %s: %s" % [a.replace("_", " ").capitalize(), str(attrs[a])]
		a_lbl.add_theme_font_size_override("font_size", 11)
		_vbox_attributes.add_child(a_lbl)

	# Resistências
	var resists: Dictionary = c["resists"]
	for r in resists.keys():
		var r_lbl := Label.new()
		r_lbl.text = "• %s: %s%%" % [r.capitalize(), str(resists[r])]
		r_lbl.add_theme_font_size_override("font_size", 11)
		_vbox_resistances.add_child(r_lbl)

	# Habilidades
	var abils: Array = c["abilities"]
	for ab in abils:
		var ab_lbl := Label.new()
		ab_lbl.text = "• " + str(ab)
		ab_lbl.add_theme_font_size_override("font_size", 11)
		_vbox_abilities.add_child(ab_lbl)

	if c["model_pending"]:
		_lbl_model_status.text = "STATUS DE MODELAGEM 3D: Asset GLB Pendente de Arte Final.\nO jogo utiliza um placeholder identificado com geometria e material dedicados para validação técnica sem falsa representação."
		_lbl_model_status.add_theme_color_override("font_color", Color(0.9, 0.75, 0.35))
	else:
		_lbl_model_status.text = "STATUS 3D: Modelo GLB Integrado: %s" % c["model_path"]
		_lbl_model_status.add_theme_color_override("font_color", Color(0.35, 0.85, 0.45))

func _on_close_pressed() -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.close_screen(&"bestiary")
