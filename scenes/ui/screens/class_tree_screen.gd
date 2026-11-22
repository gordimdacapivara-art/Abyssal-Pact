class_name ClassTreeScreen
extends ScreenBase
## Tela da Árvore de Habilidades e Progressão de Classe de ABYSSAL PACT.

var _header: DarkFantasyHeader
var _nav_bar: DarkFantasyNavBar
var _lbl_class_title: Label
var _lbl_class_desc: Label
var _vbox_attributes: VBoxContainer
var _tree_container: HBoxContainer
var _lbl_node_title: Label
var _lbl_node_reqs: Label
var _lbl_node_desc: Label
var _btn_unlock_node: Button
var _lbl_feedback: Label

var _selected_node: Dictionary = {}
var _unlocked_nodes: Array[String] = ["node_t1_1"]

func open(params: Dictionary = {}) -> void:
	super(params)
	screen_id = &"class_tree"
	_build_ui()
	_refresh_tree()

func _ready() -> void:
	_build_ui()
	_refresh_tree()

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

	_header = DarkFantasyHeader.new("ÁRVORE DE HABILIDADES DA CLASSE", "Evolução de nodos, especializações e atributos da classe")
	_header.close_requested.connect(_on_close_pressed)
	main_vbox.add_child(_header)

	_nav_bar = DarkFantasyNavBar.new(&"class_tree")
	main_vbox.add_child(_nav_bar)

	var content_hbox := HBoxContainer.new()
	content_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_theme_constant_override("separation", 16)
	main_vbox.add_child(content_hbox)

	# --- COLUNA 1: IDENTIDADE E ATRIBUTOS DA CLASSE ---
	var class_panel := PanelContainer.new()
	class_panel.custom_minimum_size = Vector2(280, 0)
	class_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(class_panel)

	var class_vbox := VBoxContainer.new()
	class_vbox.add_theme_constant_override("separation", 10)
	class_vbox.offset_left = 12
	class_vbox.offset_right = -12
	class_vbox.offset_top = 12
	class_vbox.offset_bottom = -12
	class_panel.add_child(class_vbox)

	_lbl_class_title = Label.new()
	_lbl_class_title.text = "Classe: Arcanista"
	_lbl_class_title.add_theme_font_size_override("font_size", 18)
	_lbl_class_title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
	class_vbox.add_child(_lbl_class_title)

	_lbl_class_desc = Label.new()
	_lbl_class_desc.text = "Canalizador das energias cósmicas e abissais de Veyrath."
	_lbl_class_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_class_desc.add_theme_font_size_override("font_size", 12)
	_lbl_class_desc.add_theme_color_override("font_color", Color(0.7, 0.65, 0.6))
	class_vbox.add_child(_lbl_class_desc)

	class_vbox.add_child(HSeparator.new())

	var attr_title := Label.new()
	attr_title.text = "ATRIBUTOS BASE:"
	attr_title.add_theme_font_size_override("font_size", 12)
	attr_title.add_theme_color_override("font_color", Color(0.85, 0.8, 0.6))
	class_vbox.add_child(attr_title)

	_vbox_attributes = VBoxContainer.new()
	_vbox_attributes.add_theme_constant_override("separation", 4)
	class_vbox.add_child(_vbox_attributes)

	# --- COLUNA 2: ÁRVORE DE TIERS ---
	var tree_panel := PanelContainer.new()
	tree_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tree_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(tree_panel)

	var tree_vbox := VBoxContainer.new()
	tree_vbox.add_theme_constant_override("separation", 8)
	tree_vbox.offset_left = 12
	tree_vbox.offset_right = -12
	tree_vbox.offset_top = 12
	tree_vbox.offset_bottom = -12
	tree_panel.add_child(tree_vbox)

	var tree_title := Label.new()
	tree_title.text = "CAMINHOS DE ASCENSÃO (TIERS 1 A 5)"
	tree_title.add_theme_font_size_override("font_size", 14)
	tree_title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
	tree_vbox.add_child(tree_title)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tree_vbox.add_child(scroll)

	_tree_container = HBoxContainer.new()
	_tree_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tree_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tree_container.add_theme_constant_override("separation", 16)
	scroll.add_child(_tree_container)

	# --- COLUNA 3: DETALHES DO NODO ---
	var detail_panel := PanelContainer.new()
	detail_panel.custom_minimum_size = Vector2(280, 0)
	detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(detail_panel)

	var detail_vbox := VBoxContainer.new()
	detail_vbox.add_theme_constant_override("separation", 10)
	detail_vbox.offset_left = 12
	detail_vbox.offset_right = -12
	detail_vbox.offset_top = 12
	detail_vbox.offset_bottom = -12
	detail_panel.add_child(detail_vbox)

	_lbl_node_title = Label.new()
	_lbl_node_title.text = "Selecione um Nodo"
	_lbl_node_title.add_theme_font_size_override("font_size", 16)
	_lbl_node_title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
	detail_vbox.add_child(_lbl_node_title)

	_lbl_node_reqs = Label.new()
	_lbl_node_reqs.text = "Requisito: —"
	_lbl_node_reqs.add_theme_font_size_override("font_size", 12)
	_lbl_node_reqs.add_theme_color_override("font_color", Color(0.7, 0.65, 0.6))
	detail_vbox.add_child(_lbl_node_reqs)

	detail_vbox.add_child(HSeparator.new())

	_lbl_node_desc = Label.new()
	_lbl_node_desc.text = "Clique em um nodo da árvore para inspecionar os bônus concedidos e desbloqueá-lo."
	_lbl_node_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_node_desc.add_theme_font_size_override("font_size", 12)
	detail_vbox.add_child(_lbl_node_desc)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_vbox.add_child(spacer)

	_btn_unlock_node = Button.new()
	_btn_unlock_node.text = "DESBLOQUEAR NODO"
	_btn_unlock_node.custom_minimum_size = Vector2(0, 40)
	_btn_unlock_node.disabled = true
	_btn_unlock_node.pressed.connect(_on_unlock_pressed)
	detail_vbox.add_child(_btn_unlock_node)

	_lbl_feedback = Label.new()
	_lbl_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_feedback.add_theme_font_size_override("font_size", 11)
	_lbl_feedback.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5))
	detail_vbox.add_child(_lbl_feedback)

func _refresh_tree() -> void:
	var char_mgr := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	var class_mgr := Game.get_system(SystemNames.CLASS) as ClassManager
	if class_mgr == null:
		return

	var char_data := char_mgr.selected_character() if char_mgr != null else null
	var class_id: StringName = char_data.class_id if char_data != null else &"CLASS-001"
	var class_data: ClassData = class_mgr.get_class_data(class_id)
	if class_data == null:
		return

	_lbl_class_title.text = "Classe: %s (%s)" % [class_data.display_name, String(class_data.id)]
	_lbl_class_desc.text = class_data.identity if not class_data.identity.is_empty() else "Registro editorial da classe %s" % class_data.display_name

	# Atributos base
	for child in _vbox_attributes.get_children():
		child.queue_free()

	var default_attrs := {
		"Vida Máxima": class_data.base_attributes.get("health", 100),
		"Mana Máxima": class_data.base_attributes.get("mana", 100),
		"Poder Mágico": class_data.base_attributes.get("spell_power", 25),
		"Força Física": class_data.base_attributes.get("might", 10),
		"Defesa": class_data.base_attributes.get("defense", 15),
		"Velocidade": class_data.base_attributes.get("speed_ratio", 1.0),
	}

	for k in default_attrs.keys():
		var row := HBoxContainer.new()
		var k_lbl := Label.new()
		k_lbl.text = k
		k_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		k_lbl.add_theme_font_size_override("font_size", 11)
		row.add_child(k_lbl)

		var v_lbl := Label.new()
		v_lbl.text = str(default_attrs[k])
		v_lbl.add_theme_font_size_override("font_size", 11)
		v_lbl.add_theme_color_override("font_color", Color(0.8, 0.75, 0.6))
		row.add_child(v_lbl)
		_vbox_attributes.add_child(row)

	# Limpa árvore
	for child in _tree_container.get_children():
		child.queue_free()

	# Gera Tiers 1 a 5
	var tree_data: Array = class_data.skill_tree
	if tree_data.is_empty():
		# Gera estrutura de nodos padrão se classe não possuir árvore customizada
		tree_data = [
			{"node_id": "node_t1_1", "tier": 1, "name": "Condução Básica", "unlocks_at_level": 1, "desc": "Aumenta o dano mágico em +5%."},
			{"node_id": "node_t1_2", "tier": 1, "name": "Fluxo Concentrado", "unlocks_at_level": 1, "desc": "Reduz o consumo de mana em 8%."},
			{"node_id": "node_t2_1", "tier": 2, "name": "Impacto Ressoante", "unlocks_at_level": 5, "desc": "Habilidades causam dano em área expandido."},
			{"node_id": "node_t2_2", "tier": 2, "name": "Escudo Astral", "unlocks_at_level": 5, "desc": "Concede barreira protetora ao sofrer dano."},
			{"node_id": "node_t3_1", "tier": 3, "name": "Maestria Arcana", "unlocks_at_level": 10, "desc": "Desbloqueia conjurações avançadas da classe."},
			{"node_id": "node_t3_2", "tier": 3, "name": "Transcendência", "unlocks_at_level": 10, "desc": "Acelera a recarga de habilidades em 15%."},
			{"node_id": "node_t4_1", "tier": 4, "name": "Canalização Abissal", "unlocks_at_level": 20, "desc": "Aumenta o dano crítico mágico em +25%."},
			{"node_id": "node_t5_1", "tier": 5, "name": "Vórtice Primordial", "unlocks_at_level": 30, "desc": "A habilidade especial atinge poder catastrófico."}
		]

	var tier_groups := {1: [], 2: [], 3: [], 4: [], 5: []}
	for node in tree_data:
		var t: int = int(node.get("tier", 1))
		if tier_groups.has(t):
			tier_groups[t].append(node)

	for t in range(1, 6):
		var tier_col := VBoxContainer.new()
		tier_col.custom_minimum_size = Vector2(140, 0)
		tier_col.size_flags_vertical = Control.SIZE_EXPAND_FILL
		tier_col.add_theme_constant_override("separation", 10)

		var t_header := Label.new()
		t_header.text = "TIER %d\n(Nível %d+)" % [t, (t - 1) * 5 if t > 1 else 1]
		t_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		t_header.add_theme_font_size_override("font_size", 12)
		t_header.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
		tier_col.add_child(t_header)

		var nodes: Array = tier_groups.get(t, [])
		for n in nodes:
			var nid: String = n.get("node_id", "")
			var n_name: String = n.get("name", "Nodo %s" % nid)
			var is_unlocked := _unlocked_nodes.has(nid)

			var n_btn := Button.new()
			n_btn.custom_minimum_size = Vector2(0, 48)
			n_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			n_btn.text = "%s\n[%s]" % [n_name, "APRENDIDO" if is_unlocked else "BLOQUEADO"]
			if is_unlocked:
				n_btn.add_theme_color_override("font_color", Color(0.35, 0.85, 0.45))
			else:
				n_btn.add_theme_color_override("font_color", Color(0.65, 0.6, 0.55))
			n_btn.pressed.connect(func(): _on_node_clicked(n))
			tier_col.add_child(n_btn)

		_tree_container.add_child(tier_col)

func _on_node_clicked(node: Dictionary) -> void:
	_selected_node = node
	var nid: String = node.get("node_id", "")
	var n_name: String = node.get("name", nid)
	var req_lvl: int = int(node.get("unlocks_at_level", 1))
	var is_unlocked := _unlocked_nodes.has(nid)

	_lbl_node_title.text = n_name
	_lbl_node_reqs.text = "Nível Requerido: %d | Status: %s" % [req_lvl, "Desbloqueado" if is_unlocked else "Disponível"]
	_lbl_node_desc.text = node.get("desc", "Aprimoramento permanente para o combate.")

	_btn_unlock_node.disabled = is_unlocked
	_btn_unlock_node.text = "NODO JÁ APRENDIDO" if is_unlocked else "DESBLOQUEAR NODO"

func _on_unlock_pressed() -> void:
	var nid: String = _selected_node.get("node_id", "")
	if not nid.is_empty() and not _unlocked_nodes.has(nid):
		_unlocked_nodes.append(nid)
		_lbl_feedback.text = "Nodo '%s' desbloqueado com sucesso!" % _selected_node.get("name", nid)
		EventBus.ui_action_requested.emit(&"skill_tree_node_unlocked")
		_refresh_tree()
		_on_node_clicked(_selected_node)

func _on_close_pressed() -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.close_screen(&"class_tree")
