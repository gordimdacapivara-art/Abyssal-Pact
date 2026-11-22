class_name QuestsScreen
extends ScreenBase
## Tela de Diário de Missões de ABYSSAL PACT: Principais, Secundárias, Regionais, de Classe e de Raça.

var _active_category: StringName = &"main"
var _selected_quest: QuestData = null

var _header: DarkFantasyHeader
var _nav_bar: DarkFantasyNavBar
var _quests_vbox: VBoxContainer
var _lbl_quest_title: Label
var _lbl_quest_meta: Label
var _lbl_quest_desc: Label
var _vbox_objectives: VBoxContainer
var _vbox_rewards: VBoxContainer
var _btn_accept_toggle: Button
var _btn_progress: Button
var _btn_track_map: Button
var _lbl_feedback: Label

func open(params: Dictionary = {}) -> void:
	super(params)
	screen_id = &"quests"
	_build_ui()
	_refresh_quests()

func _ready() -> void:
	EventBus.quest_accepted.connect(_on_quest_event)
	EventBus.quest_completed.connect(_on_quest_event)
	EventBus.objective_progress.connect(_on_quest_event)
	_build_ui()
	_refresh_quests()

func _on_quest_event(_a = null, _b = null, _c = null, _d = null, _e = null) -> void:
	if is_visible_in_tree():
		_refresh_quests()

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

	_header = DarkFantasyHeader.new("DIÁRIO DE MISSÕES", "Objetivos dos Quatro Continentes, Hell Forge e linhagens")
	_header.close_requested.connect(_on_close_pressed)
	main_vbox.add_child(_header)

	_nav_bar = DarkFantasyNavBar.new(&"quests")
	main_vbox.add_child(_nav_bar)

	# Barra de Categorias de Missão
	var cat_bar := HBoxContainer.new()
	cat_bar.add_theme_constant_override("separation", 8)
	main_vbox.add_child(cat_bar)

	var categories := [
		{"id": &"main", "label": "👑 Missões Principais"},
		{"id": &"side", "label": "📜 Secundárias"},
		{"id": &"regional", "label": "🗺️ Regionais"},
		{"id": &"class", "label": "⚔️ De Classe"},
		{"id": &"race", "label": "🧬 De Raça"},
	]

	for c in categories:
		var cid: StringName = c["id"]
		var btn := Button.new()
		btn.text = " " + c["label"] + " "
		btn.pressed.connect(func():
			_active_category = cid
			_refresh_quests()
		)
		cat_bar.add_child(btn)

	var content_hbox := HBoxContainer.new()
	content_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_theme_constant_override("separation", 16)
	main_vbox.add_child(content_hbox)

	# --- COLUNA 1: LISTA DE MISSÕES ---
	var list_panel := PanelContainer.new()
	list_panel.custom_minimum_size = Vector2(340, 0)
	list_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(list_panel)

	var list_vbox := VBoxContainer.new()
	list_vbox.offset_left = 12
	list_vbox.offset_right = -12
	list_vbox.offset_top = 12
	list_vbox.offset_bottom = -12
	list_vbox.add_theme_constant_override("separation", 8)
	list_panel.add_child(list_vbox)

	var l_title := Label.new()
	l_title.text = "MISSÕES REGISTRADAS"
	l_title.add_theme_font_size_override("font_size", 14)
	l_title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
	list_vbox.add_child(l_title)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list_vbox.add_child(scroll)

	_quests_vbox = VBoxContainer.new()
	_quests_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_quests_vbox.add_theme_constant_override("separation", 6)
	scroll.add_child(_quests_vbox)

	# --- COLUNA 2: DETALHES DA MISSÃO ---
	var detail_panel := PanelContainer.new()
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(detail_panel)

	var detail_vbox := VBoxContainer.new()
	detail_vbox.offset_left = 16
	detail_vbox.offset_right = -16
	detail_vbox.offset_top = 12
	detail_vbox.offset_bottom = -12
	detail_vbox.add_theme_constant_override("separation", 10)
	detail_panel.add_child(detail_vbox)

	_lbl_quest_title = Label.new()
	_lbl_quest_title.text = "Selecione uma Missão"
	_lbl_quest_title.add_theme_font_size_override("font_size", 20)
	_lbl_quest_title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
	detail_vbox.add_child(_lbl_quest_title)

	_lbl_quest_meta = Label.new()
	_lbl_quest_meta.text = ""
	_lbl_quest_meta.add_theme_font_size_override("font_size", 12)
	_lbl_quest_meta.add_theme_color_override("font_color", Color(0.7, 0.65, 0.6))
	detail_vbox.add_child(_lbl_quest_meta)

	detail_vbox.add_child(HSeparator.new())

	_lbl_quest_desc = Label.new()
	_lbl_quest_desc.text = "Os detalhes e objetivos da missão selecionada aparecerão aqui."
	_lbl_quest_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_quest_desc.add_theme_font_size_override("font_size", 12)
	detail_vbox.add_child(_lbl_quest_desc)

	detail_vbox.add_child(HSeparator.new())

	var obj_title := Label.new()
	obj_title.text = "OBJETIVOS DA MISSÃO:"
	obj_title.add_theme_font_size_override("font_size", 12)
	obj_title.add_theme_color_override("font_color", Color(0.85, 0.8, 0.6))
	detail_vbox.add_child(obj_title)

	_vbox_objectives = VBoxContainer.new()
	_vbox_objectives.add_theme_constant_override("separation", 6)
	detail_vbox.add_child(_vbox_objectives)

	detail_vbox.add_child(HSeparator.new())

	var rew_title := Label.new()
	rew_title.text = "RECOMPENSAS PREVISTAS:"
	rew_title.add_theme_font_size_override("font_size", 12)
	rew_title.add_theme_color_override("font_color", Color(0.85, 0.8, 0.6))
	detail_vbox.add_child(rew_title)

	_vbox_rewards = VBoxContainer.new()
	_vbox_rewards.add_theme_constant_override("separation", 3)
	detail_vbox.add_child(_vbox_rewards)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_vbox.add_child(spacer)

	var actions_hbox := HBoxContainer.new()
	actions_hbox.add_theme_constant_override("separation", 10)
	detail_vbox.add_child(actions_hbox)

	_btn_accept_toggle = Button.new()
	_btn_accept_toggle.text = "ACEITAR MISSÃO"
	_btn_accept_toggle.custom_minimum_size = Vector2(0, 40)
	_btn_accept_toggle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_btn_accept_toggle.pressed.connect(_on_accept_toggle_pressed)
	actions_hbox.add_child(_btn_accept_toggle)

	_btn_progress = Button.new()
	_btn_progress.text = "AVANÇAR OBJETIVO"
	_btn_progress.custom_minimum_size = Vector2(0, 40)
	_btn_progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_btn_progress.pressed.connect(_on_progress_pressed)
	actions_hbox.add_child(_btn_progress)

	_btn_track_map = Button.new()
	_btn_track_map.text = "VER NO MAPA"
	_btn_track_map.custom_minimum_size = Vector2(0, 40)
	_btn_track_map.pressed.connect(_on_track_map_pressed)
	actions_hbox.add_child(_btn_track_map)

	_lbl_feedback = Label.new()
	_lbl_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_feedback.add_theme_font_size_override("font_size", 11)
	_lbl_feedback.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5))
	detail_vbox.add_child(_lbl_feedback)

func _refresh_quests() -> void:
	for child in _quests_vbox.get_children():
		child.queue_free()

	var qm := Game.get_system(SystemNames.QUESTS) as QuestManager
	var cm := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	if qm == null:
		return

	var char_id := cm.selected_character_id() if cm != null else &"CHAR-001"
	var qlog := qm.log_of(char_id)

	var list := qm.quests_of_category(_active_category)
	for q in list:
		var qid: StringName = q.id
		var q_state: String = qm.quest_state(char_id, qid)
		var is_active: bool = (q_state == "active")
		var is_done: bool = (q_state == "completed")

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 42)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var status_str := "EM PROGRESSO" if is_active else ("CONCLUÍDA" if is_done else "DISPONÍVEL")
		btn.text = " %s  —  %s\n[%s]" % [String(qid), q.display_name, status_str]

		if is_done:
			btn.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5))
		elif is_active:
			btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))

		btn.pressed.connect(func(): _display_quest(q))
		_quests_vbox.add_child(btn)

	if not list.is_empty():
		_display_quest(list[0])
	else:
		_display_quest(null)

func _display_quest(q: QuestData) -> void:
	_selected_quest = q
	for child in _vbox_objectives.get_children():
		child.queue_free()
	for child in _vbox_rewards.get_children():
		child.queue_free()

	if q == null:
		_lbl_quest_title.text = "Nenhuma Missão Encontrada"
		_lbl_quest_meta.text = ""
		_lbl_quest_desc.text = "Selecione outra categoria de missão."
		_btn_accept_toggle.disabled = true
		_btn_progress.disabled = true
		_btn_track_map.disabled = true
		return

	var qm := Game.get_system(SystemNames.QUESTS) as QuestManager
	var cm := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	var char_id := cm.selected_character_id() if cm != null else &"CHAR-001"
	var qlog := qm.log_of(char_id) if qm != null else null

	var q_state: String = qm.quest_state(char_id, q.id)
	var is_active: bool = (q_state == "active")
	var is_done: bool = (q_state == "completed")

	_lbl_quest_title.text = "%s  (%s)" % [q.display_name, String(q.id)]
	_lbl_quest_meta.text = "Categoria: %s | Nível Requerido: %d | Região: %s" % [
		String(q.category).capitalize(),
		q.level_requirement,
		String(q.region_id)
	]
	_lbl_quest_desc.text = q.description

	# Objetivos com barra de progresso
	for oid in q.get_objective_ids():
		var req: int = q.get_objective_required(oid)
		var desc_text := q.get_objective_description(oid)
		var cur := 0
		if is_active and qlog != null:
			var entry: QuestEntryData = qlog.find_entry(q.id)
			if entry != null and entry.progress.has(String(oid)):
				cur = int(entry.progress.get(String(oid), 0))
		elif is_done:
			cur = req

		var obj_box := VBoxContainer.new()
		var obj_lbl := Label.new()
		obj_lbl.text = "• %s (%d / %d)" % [desc_text, cur, req]
		obj_lbl.add_theme_font_size_override("font_size", 11)
		obj_box.add_child(obj_lbl)

		var bar := ProgressBar.new()
		bar.min_value = 0
		bar.max_value = req
		bar.value = cur
		bar.custom_minimum_size = Vector2(0, 14)
		bar.show_percentage = true
		obj_box.add_child(bar)
		_vbox_objectives.add_child(obj_box)

	# Recompensas
	var rew_dict: Dictionary = q.rewards
	var xp_val := int(rew_dict.get("xp", 100))
	var souls_val := int(rew_dict.get("souls", 50))
	var xp_lbl := Label.new()
	xp_lbl.text = "• Experiência: +%d XP" % xp_val
	xp_lbl.add_theme_font_size_override("font_size", 11)
	xp_lbl.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5))
	_vbox_rewards.add_child(xp_lbl)

	var souls_lbl := Label.new()
	souls_lbl.text = "• Almas Abissais: +%d" % souls_val
	souls_lbl.add_theme_font_size_override("font_size", 11)
	souls_lbl.add_theme_color_override("font_color", Color(0.9, 0.8, 0.4))
	_vbox_rewards.add_child(souls_lbl)

	_btn_accept_toggle.disabled = is_done
	_btn_accept_toggle.text = "ABANDONAR MISSÃO" if is_active else ("CONCLUÍDA" if is_done else "ACEITAR MISSÃO")
	_btn_progress.disabled = not is_active
	_btn_track_map.disabled = false

func _on_accept_toggle_pressed() -> void:
	if _selected_quest == null:
		return
	var qm := Game.get_system(SystemNames.QUESTS) as QuestManager
	var cm := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	var char_id := cm.selected_character_id() if cm != null else &"CHAR-001"
	var qlog := qm.log_of(char_id) if qm != null else null

	if qlog != null and qlog.is_active(_selected_quest.id):
		qm.abandon_quest(char_id, _selected_quest.id)
		_lbl_feedback.text = "Missão '%s' abandonada." % _selected_quest.display_name
	else:
		qm.accept_quest(char_id, _selected_quest.id)
		_lbl_feedback.text = "Missão '%s' aceita com sucesso!" % _selected_quest.display_name
	_refresh_quests()

func _on_progress_pressed() -> void:
	if _selected_quest == null:
		return
	var qm := Game.get_system(SystemNames.QUESTS) as QuestManager
	var cm := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	var char_id := cm.selected_character_id() if cm != null else &"CHAR-001"
	var oids := _selected_quest.get_objective_ids()
	if not oids.is_empty():
		qm.progress_objective(char_id, _selected_quest.id, oids[0], 1)
		_lbl_feedback.text = "Progresso registrado no objetivo!"
		_refresh_quests()

func _on_track_map_pressed() -> void:
	if _selected_quest == null:
		return
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.open_screen(&"regional_map", {"region_id": _selected_quest.region_id})

func _on_close_pressed() -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.close_screen(&"quests")
