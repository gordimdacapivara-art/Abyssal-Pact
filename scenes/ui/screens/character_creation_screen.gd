class_name CharacterCreationScreen
extends ScreenBase
## Tela de Criação de Personagens — ABYSSAL PACT (Dark Fantasy, 6 etapas).
##
## Etapas:
##   1. Seleção das 40 raças (com busca e visualização modular).
##   2. Seleção das 2 sub-raças da raça escolhida.
##   3. Seleção das 80 classes (com botões estilizados de cada classe, grupos e busca).
##   4. Personalização visual (paleta de pele, cabelo, olhos, marcas e vestimenta).
##   5. Definição do nome e identidade (validação em tempo real).
##   6. Confirmação e ressurgimento na Hell Forge.
##
## Visualização 3D em tempo real com rotação por drag, zoom por scroll e preview
## dinâmico via RaceVisualBuilder.

const HUB_SCENE := "res://scenes/world/hub_placeholder.tscn"

var _current_stage := 1
var _selected_race_id: StringName = &"RACE-001"
var _selected_subrace_id: StringName = &"SUBRACE-001"
var _selected_class_id: StringName = &"CLASS-001"
var _character_name := "Portador Abissal"

# Filtro ativo do grupo de classes no estágio 3 ("all", "compat", ou "CLASS-GROUP-01".."08")
var _selected_class_group_filter := "all"
var _class_search_text := ""
var _race_search_text := ""

# Dicionário de personalização (aparência persistida em CharacterData)
var _appearance := {
	"skin_color": "#8a6a52",
	"hair_color": "#2b1d12",
	"hair_style": "short",
	"eye_color": "#7fd4ff",
	"face_mark": "none",
	"extra_accessories": [],
	"vestiment": "robe",
	"extra_scale": 1.0
}

# Nós principais de UI
var _title_label: Label
var _stage_stepper_hbox: HBoxContainer
var _content_panel: Control
var _desc_label: Label
var _btn_back: Button
var _btn_next: Button
var _viewport_3d: SubViewport
var _model_slot: Node3D
var _camera_3d: Camera3D
var _is_dragging := false
var _last_mouse_pos := Vector2.ZERO
var _camera_orbit_angle := 0.0

func open(_params: Dictionary = {}) -> void:
	screen_id = &"character_creation"
	_build_ui()
	_update_stage_content()
	_rebuild_preview()

func close() -> void:
	super()

func _build_ui() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	theme = DarkFantasyTheme.create()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Fundo escuro dark fantasy
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.035, 0.05, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# Layout principal: HBox (Esquerda: 3D Preview | Direita: Passos + Conteúdo + Botões)
	var main_hbox := HBoxContainer.new()
	main_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_hbox.offset_left = 24
	main_hbox.offset_right = -24
	main_hbox.offset_top = 20
	main_hbox.offset_bottom = -20
	main_hbox.add_theme_constant_override("separation", 24)
	add_child(main_hbox)

	# =========================================================================
	# COLUNA ESQUERDA: PREVIEW 3D DO PERSONAGEM
	# =========================================================================
	var left_vbox := VBoxContainer.new()
	left_vbox.custom_minimum_size = Vector2(380, 0)
	left_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_vbox.add_theme_constant_override("separation", 10)
	main_hbox.add_child(left_vbox)

	var preview_header := Label.new()
	preview_header.text = "✦ VISUALIZAÇÃO EM TEMPO REAL"
	preview_header.add_theme_font_size_override("font_size", 14)
	preview_header.add_theme_color_override("font_color", Color(0.85, 0.75, 0.5))
	preview_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left_vbox.add_child(preview_header)

	var preview_panel := PanelContainer.new()
	preview_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_panel.custom_minimum_size = Vector2(380, 500)
	left_vbox.add_child(preview_panel)

	var viewport_container := SubViewportContainer.new()
	viewport_container.stretch = true
	viewport_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	viewport_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	viewport_container.custom_minimum_size = Vector2(380, 500)
	preview_panel.add_child(viewport_container)

	_viewport_3d = SubViewport.new()
	_viewport_3d.size = Vector2i(380, 500)
	_viewport_3d.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_viewport_3d.transparent_bg = false
	_viewport_3d.msaa_3d = Viewport.MSAA_4X
	_viewport_3d.own_world_3d = true
	viewport_container.add_child(_viewport_3d)

	# Ambiente e Iluminação Dedicados
	var world := World3D.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.07, 0.065, 0.09, 1.0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.9, 0.86, 0.8, 1.0)
	env.ambient_light_energy = 1.3
	world.environment = env
	_viewport_3d.world_3d = world

	var world_env := WorldEnvironment.new()
	world_env.environment = env
	_viewport_3d.add_child(world_env)

	# Luz Principal (Key Light)
	var key_light := DirectionalLight3D.new()
	key_light.transform = Transform3D(Basis().rotated(Vector3.UP, 0.6).rotated(Vector3.RIGHT, -0.6), Vector3(0, 4, 3))
	key_light.light_energy = 1.8
	key_light.light_color = Color(1.0, 0.95, 0.88)
	_viewport_3d.add_child(key_light)

	# Luz de Preenchimento (Fill Light)
	var fill_light := DirectionalLight3D.new()
	fill_light.transform = Transform3D(Basis().rotated(Vector3.UP, -2.4).rotated(Vector3.RIGHT, -0.4), Vector3(0, 3, -3))
	fill_light.light_energy = 0.9
	fill_light.light_color = Color(0.55, 0.65, 0.9)
	_viewport_3d.add_child(fill_light)

	# Piso rúnico pedestal
	var floor_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(4, 4)
	floor_mesh.mesh = plane
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.12, 0.11, 0.15)
	floor_mat.roughness = 0.85
	floor_mesh.material_override = floor_mat
	floor_mesh.position = Vector3(0, 0, 0)
	_viewport_3d.add_child(floor_mesh)

	# Câmera e Rig de Rotação
	var cam_rig := Node3D.new()
	cam_rig.name = "CamRig"
	_viewport_3d.add_child(cam_rig)

	_camera_3d = Camera3D.new()
	_camera_3d.name = "Camera3D"
	_camera_3d.current = true
	_camera_3d.fov = 42.0
	cam_rig.add_child(_camera_3d)
	_camera_3d.look_at_from_position(Vector3(0, 1.05, 2.7), Vector3(0, 0.92, 0))

	_model_slot = Node3D.new()
	_model_slot.name = "ModelSlot"
	_viewport_3d.add_child(_model_slot)

	# Área transparente para captura de gestos do mouse
	var orbit_area := Control.new()
	orbit_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	orbit_area.gui_input.connect(_on_preview_gui_input)
	preview_panel.add_child(orbit_area)

	var preview_hint := Label.new()
	preview_hint.text = "Arraste para rotacionar | Roda do mouse: zoom"
	preview_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_hint.add_theme_font_size_override("font_size", 12)
	preview_hint.add_theme_color_override("font_color", Color(0.65, 0.6, 0.52))
	left_vbox.add_child(preview_hint)

	# =========================================================================
	# COLUNA DIREITA: WIZARD DE ETAPAS
	# =========================================================================
	var right_vbox := VBoxContainer.new()
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vbox.add_theme_constant_override("separation", 10)
	main_hbox.add_child(right_vbox)

	# Barra Stepper de Etapas
	_stage_stepper_hbox = HBoxContainer.new()
	_stage_stepper_hbox.add_theme_constant_override("separation", 6)
	right_vbox.add_child(_stage_stepper_hbox)
	_build_stepper()

	# Cabeçalho / Título da Etapa
	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", 22)
	_title_label.add_theme_color_override("font_color", Color(0.96, 0.88, 0.7))
	right_vbox.add_child(_title_label)

	# Painel de Conteúdo da Etapa
	var content_panel_wrap := PanelContainer.new()
	content_panel_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_panel_wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_panel_wrap.custom_minimum_size = Vector2(0, 420)
	right_vbox.add_child(content_panel_wrap)

	_content_panel = VBoxContainer.new()
	_content_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_panel.add_theme_constant_override("separation", 10)
	content_panel_wrap.add_child(_content_panel)

	# Painel de Descrição / Status
	var desc_panel := PanelContainer.new()
	desc_panel.custom_minimum_size = Vector2(0, 75)
	right_vbox.add_child(desc_panel)

	_desc_label = Label.new()
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.add_theme_font_size_override("font_size", 13)
	_desc_label.add_theme_color_override("font_color", Color(0.82, 0.78, 0.72))
	desc_panel.add_child(_desc_label)

	# Barra Inferior de Navegação
	var nav_hbox := HBoxContainer.new()
	nav_hbox.alignment = HBoxContainer.ALIGNMENT_END
	nav_hbox.add_theme_constant_override("separation", 15)
	right_vbox.add_child(nav_hbox)

	_btn_back = Button.new()
	_btn_back.text = "« Anterior"
	_btn_back.custom_minimum_size = Vector2(120, 36)
	_btn_back.pressed.connect(_on_back_pressed)
	nav_hbox.add_child(_btn_back)

	_btn_next = Button.new()
	_btn_next.text = "Avançar »"
	_btn_next.custom_minimum_size = Vector2(160, 36)
	_btn_next.pressed.connect(_on_next_pressed)
	nav_hbox.add_child(_btn_next)

func _build_stepper() -> void:
	for child in _stage_stepper_hbox.get_children():
		_stage_stepper_hbox.remove_child(child)
		child.queue_free()

	var steps := [
		"1. Raça",
		"2. Sub-raça",
		"3. Classe",
		"4. Aparência",
		"5. Identidade",
		"6. Hell Forge"
	]

	for i in range(steps.size()):
		var step_num := i + 1
		var btn := Button.new()
		btn.text = steps[i]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 12)

		if step_num == _current_stage:
			btn.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45))
			var highlight := StyleBoxFlat.new()
			highlight.bg_color = Color(0.24, 0.20, 0.12, 1.0)
			highlight.border_color = Color(0.9, 0.75, 0.35, 1.0)
			highlight.set_border_width_all(2)
			highlight.set_corner_radius_all(3)
			btn.add_theme_stylebox_override("normal", highlight)
		elif step_num < _current_stage:
			btn.add_theme_color_override("font_color", Color(0.7, 0.85, 0.7))
			btn.pressed.connect(func() -> void:
				_current_stage = step_num
				_update_stage_content()
			)
		else:
			btn.add_theme_color_override("font_color", Color(0.5, 0.48, 0.45))
			btn.disabled = true

		_stage_stepper_hbox.add_child(btn)

func _on_preview_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_LEFT:
			_is_dragging = mouse_button.pressed
			_last_mouse_pos = mouse_button.position
		elif mouse_button.button_index == MOUSE_BUTTON_WHEEL_UP and _camera_3d:
			_camera_3d.position.z = maxf(1.6, _camera_3d.position.z - 0.2)
		elif mouse_button.button_index == MOUSE_BUTTON_WHEEL_DOWN and _camera_3d:
			_camera_3d.position.z = minf(5.5, _camera_3d.position.z + 0.2)
	elif event is InputEventMouseMotion and _is_dragging and _model_slot:
		var motion := event as InputEventMouseMotion
		var delta := motion.position - _last_mouse_pos
		_last_mouse_pos = motion.position
		_camera_orbit_angle -= delta.x * 0.01
		var rig := _viewport_3d.get_node_or_null("CamRig")
		if rig:
			rig.rotation.y = _camera_orbit_angle

func _update_stage_content() -> void:
	for child in _content_panel.get_children():
		_content_panel.remove_child(child)
		child.queue_free()

	_build_stepper()
	_btn_back.disabled = (_current_stage == 1)
	_btn_next.text = "Confirmar e Entrar »" if _current_stage == 6 else "Avançar »"
	_btn_next.disabled = (_current_stage == 5 and not _is_name_valid())

	# Garante que a classe selecionada é válida para a raça atual
	_ensure_compatible_class_selected()

	match _current_stage:
		1:
			_title_label.text = "ETAPA 1/6 — ESCOLHA SUA RAÇA ANCESTRAL (40 Raças)"
			_desc_label.text = "Selecione a raça de seu combatente. O catálogo completo de 40 raças está disponível no sistema. O protótipo visual (RACE-001) exibe o esqueleto modular humanóide em tempo real."
			_build_race_stage()
		2:
			_title_label.text = "ETAPA 2/6 — ESCOLHA SUA SUB-RAÇA"
			_desc_label.text = "Cada raça possui duas sub-raças associadas que definem mutações rúnicas e variações visuais no personagem."
			_build_subrace_stage()
		3:
			_title_label.text = "ETAPA 3/6 — ESCOLHA SUA CLASSE DE COMBATE (80 Classes)"
			_desc_label.text = "Escolha sua classe entre os 8 grupos de combate. O Arcanista (CLASS-001) é o protótipo jogável completo com habilidades e árvore demonstráveis."
			_build_class_stage()
		4:
			_title_label.text = "ETAPA 4/6 — PERSONALIZAÇÃO VISUAL"
			_desc_label.text = "Ajuste tintas de pele, cabelo, olhos, marcas rúnicas faciais e vestimenta sobre o modelo 3D em tempo real."
			_build_customization_stage()
		5:
			_title_label.text = "ETAPA 5/6 — NOME E IDENTIDADE"
			_desc_label.text = "Insira o nome de seu combatente para ser registrado permanentemente nos anais da Hell Forge."
			_build_name_stage()
		6:
			_title_label.text = "ETAPA 6/6 — CONFIRMAÇÃO DO COMBATENTE"
			_desc_label.text = "Revise todas as características escolhidas. Ao confirmar, o personagem será gravado no slot de salvamento e você ressurgirá na Hell Forge."
			_build_confirmation_stage()

func _ensure_compatible_class_selected() -> void:
	var race_service := Game.get_system(SystemNames.RACE) as RaceManager
	var class_service := Game.get_system(SystemNames.CLASS) as ClassManager
	if not race_service or not class_service:
		return

	if not race_service.can_use_class(_selected_race_id, _selected_class_id):
		# Encontra a primeira classe compatível
		for cls: ClassData in class_service.classes():
			if race_service.can_use_class(_selected_race_id, cls.id):
				_selected_class_id = cls.id
				break

# =============================================================================
# ETAPA 1: RAÇAS (40 RAÇAS)
# =============================================================================

func _build_race_stage() -> void:
	var race_service := Game.get_system(SystemNames.RACE) as RaceManager
	if not race_service:
		return

	var top_bar := HBoxContainer.new()
	top_bar.add_theme_constant_override("separation", 10)
	_content_panel.add_child(top_bar)

	var search := LineEdit.new()
	search.placeholder_text = "Filtrar por nome ou ID (ex: RACE-001)..."
	search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search.text = _race_search_text
	search.text_changed.connect(func(t: String) -> void:
		_race_search_text = t
		_refresh_race_list()
	)
	top_bar.add_child(search)

	var count_badge := Label.new()
	count_badge.text = "Total: 40 Raças"
	count_badge.add_theme_color_override("font_color", Color(0.7, 0.65, 0.55))
	top_bar.add_child(count_badge)

	var scroll := ScrollContainer.new()
	scroll.name = "RaceScroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 340)
	_content_panel.add_child(scroll)

	var grid := GridContainer.new()
	grid.name = "RaceGrid"
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 6)
	scroll.add_child(grid)

	_populate_races(grid, _race_search_text)

func _populate_races(container: GridContainer, filter: String) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

	var race_service := Game.get_system(SystemNames.RACE) as RaceManager
	if not race_service:
		return

	for race: RaceData in race_service.races():
		if not filter.is_empty():
			var match_id := race.id.to_lower().contains(filter.to_lower())
			var match_name := race.display_name.to_lower().contains(filter.to_lower())
			if not match_id and not match_name:
				continue

		var is_sel = (race.id == _selected_race_id)
		var btn := Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 42)
		btn.text = "%s — %s%s" % [
			race.id,
			race.display_name,
			" ★" if race.is_prototype else ""
		]

		if is_sel:
			var sel_style := StyleBoxFlat.new()
			sel_style.bg_color = Color(0.24, 0.20, 0.10, 1.0)
			sel_style.border_color = Color(1.0, 0.85, 0.35, 1.0)
			sel_style.set_border_width_all(2)
			sel_style.set_corner_radius_all(3)
			btn.add_theme_stylebox_override("normal", sel_style)
			btn.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))

		btn.pressed.connect(func() -> void:
			_selected_race_id = race.id
			var subs := race_service.subraces_of(race.id)
			if not subs.is_empty():
				_selected_subrace_id = subs[0].id
			_ensure_compatible_class_selected()
			_update_stage_content()
			_rebuild_preview()
		)
		container.add_child(btn)

func _refresh_race_list() -> void:
	var scroll := _content_panel.get_node_or_null("RaceScroll")
	if scroll:
		var grid := scroll.get_node_or_null("RaceGrid") as GridContainer
		if grid:
			_populate_races(grid, _race_search_text)

# =============================================================================
# ETAPA 2: SUB-RAÇAS
# =============================================================================

func _build_subrace_stage() -> void:
	var race_service := Game.get_system(SystemNames.RACE) as RaceManager
	if not race_service:
		return
	var race := race_service.get_race(_selected_race_id)
	if not race:
		return

	var parent_card := PanelContainer.new()
	var pc_style := StyleBoxFlat.new()
	pc_style.bg_color = Color(0.1, 0.09, 0.12, 0.9)
	pc_style.border_color = Color(0.5, 0.42, 0.3, 1.0)
	pc_style.set_border_width_all(1)
	pc_style.set_corner_radius_all(4)
	pc_style.content_margin_left = 12
	pc_style.content_margin_top = 8
	pc_style.content_margin_bottom = 8
	parent_card.add_theme_stylebox_override("panel", pc_style)
	_content_panel.add_child(parent_card)

	var p_lbl := Label.new()
	p_lbl.text = "Raça Ancestral Escolhida: %s (%s)" % [race.display_name, race.id]
	p_lbl.add_theme_color_override("font_color", Color(0.95, 0.85, 0.55))
	parent_card.add_child(p_lbl)

	var subs_vbox := VBoxContainer.new()
	subs_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subs_vbox.add_theme_constant_override("separation", 12)
	_content_panel.add_child(subs_vbox)

	for subrace: SubraceData in race_service.subraces_of(_selected_race_id):
		var is_sel = (subrace.id == _selected_subrace_id)
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 56)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.text = "%s — %s%s\n%s" % [
			subrace.id,
			subrace.display_name,
			" (Protótipo Funcional)" if subrace.is_prototype else "",
			"Variante genética com características corporais e marcas exclusivas."
		]

		if is_sel:
			var sel_style := StyleBoxFlat.new()
			sel_style.bg_color = Color(0.24, 0.20, 0.10, 1.0)
			sel_style.border_color = Color(1.0, 0.85, 0.35, 1.0)
			sel_style.set_border_width_all(2)
			sel_style.set_corner_radius_all(4)
			btn.add_theme_stylebox_override("normal", sel_style)
			btn.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))

		btn.pressed.connect(func() -> void:
			_selected_subrace_id = subrace.id
			_update_stage_content()
			_rebuild_preview()
		)
		subs_vbox.add_child(btn)

# =============================================================================
# ETAPA 3: CLASSES (80 CLASSES COM BOTÕES, FILTROS E CARTÕES)
# =============================================================================

func _build_class_stage() -> void:
	var class_service := Game.get_system(SystemNames.CLASS) as ClassManager
	if not class_service:
		return

	# Barra de Busca e Filtro de Grupos
	var top_vbox := VBoxContainer.new()
	top_vbox.add_theme_constant_override("separation", 8)
	_content_panel.add_child(top_vbox)

	var search_box := LineEdit.new()
	search_box.placeholder_text = "Buscar classe por nome ou código (ex: Arcanista, CLASS-001)..."
	search_box.text = _class_search_text
	search_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search_box.text_changed.connect(func(t: String) -> void:
		_class_search_text = t
		_refresh_class_list()
	)
	top_vbox.add_child(search_box)

	# Abas / Filtros Rápidos de Grupos
	var group_bar := HBoxContainer.new()
	group_bar.add_theme_constant_override("separation", 6)
	top_vbox.add_child(group_bar)

	var filter_options := [
		{"key": "all", "label": "Todas (80)"},
		{"key": "compat", "label": "Compatíveis"},
		{"key": "CLASS-GROUP-01", "label": "G1: Arcano"},
		{"key": "CLASS-GROUP-02", "label": "G2: Marcial"},
		{"key": "CLASS-GROUP-03", "label": "G3: Sombrio"},
		{"key": "CLASS-GROUP-04", "label": "G4"},
		{"key": "CLASS-GROUP-05", "label": "G5"},
		{"key": "CLASS-GROUP-06", "label": "G6"},
		{"key": "CLASS-GROUP-07", "label": "G7"},
		{"key": "CLASS-GROUP-08", "label": "G8"}
	]

	for opt in filter_options:
		var chip := Button.new()
		chip.text = opt["label"]
		chip.add_theme_font_size_override("font_size", 11)
		chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if _selected_class_group_filter == opt["key"]:
			chip.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45))
			var active_box := StyleBoxFlat.new()
			active_box.bg_color = Color(0.24, 0.20, 0.12, 1.0)
			active_box.border_color = Color(0.9, 0.75, 0.35, 1.0)
			active_box.set_border_width_all(1)
			active_box.set_corner_radius_all(3)
			chip.add_theme_stylebox_override("normal", active_box)
		chip.pressed.connect(func() -> void:
			_selected_class_group_filter = opt["key"]
			_update_stage_content()
		)
		group_bar.add_child(chip)

	# Scroll Container para as Classes com Altura Mínima Garantida
	var scroll := ScrollContainer.new()
	scroll.name = "ClassScroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 240)
	_content_panel.add_child(scroll)

	var grid := GridContainer.new()
	grid.name = "ClassGrid"
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 6)
	scroll.add_child(grid)

	_populate_classes(grid, _class_search_text)

	# Painel de Destaque da Classe Selecionada
	_build_class_spotlight()

func _populate_classes(container: GridContainer, filter: String) -> void:
	for c in container.get_children():
		container.remove_child(c)
		c.queue_free()

	var class_service := Game.get_system(SystemNames.CLASS) as ClassManager
	var race_service := Game.get_system(SystemNames.RACE) as RaceManager
	if not class_service:
		return

	for cls: ClassData in class_service.classes():
		# Filtro de grupo
		if _selected_class_group_filter == "compat":
			if race_service and not race_service.can_use_class(_selected_race_id, cls.id):
				continue
		elif _selected_class_group_filter != "all":
			if String(cls.group_id) != _selected_class_group_filter:
				continue

		# Filtro de texto
		if not filter.is_empty():
			var match_id := cls.id.to_lower().contains(filter.to_lower())
			var match_name := cls.display_name.to_lower().contains(filter.to_lower())
			if not match_id and not match_name:
				continue

		var is_sel = (cls.id == _selected_class_id)
		var compatible = true
		if race_service:
			compatible = race_service.can_use_class(_selected_race_id, cls.id)

		var btn := Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 48)

		var badge_proto := " ★ PROTÓTIPO" if cls.is_prototype else ""
		var status_str := "✓ Compatível" if compatible else "✗ Incompatível"
		btn.text = "%s — %s%s\n[%s] %s" % [
			cls.id,
			cls.display_name,
			badge_proto,
			cls.group_id,
			status_str
		]

		if is_sel:
			var sel_box := StyleBoxFlat.new()
			sel_box.bg_color = Color(0.25, 0.20, 0.10, 1.0)
			sel_box.border_color = Color(1.0, 0.85, 0.35, 1.0)
			sel_box.set_border_width_all(2)
			sel_box.set_corner_radius_all(3)
			btn.add_theme_stylebox_override("normal", sel_box)
			btn.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
		elif not compatible:
			btn.add_theme_color_override("font_color", Color(0.5, 0.45, 0.45))
			btn.disabled = true
		elif cls.is_prototype:
			btn.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))

		btn.pressed.connect(func() -> void:
			_selected_class_id = cls.id
			_update_stage_content()
		)
		container.add_child(btn)

func _refresh_class_list() -> void:
	var scroll := _content_panel.get_node_or_null("ClassScroll")
	if scroll:
		var grid := scroll.get_node_or_null("ClassGrid") as GridContainer
		if grid:
			_populate_classes(grid, _class_search_text)

func _build_class_spotlight() -> void:
	var class_service := Game.get_system(SystemNames.CLASS) as ClassManager
	var race_service := Game.get_system(SystemNames.RACE) as RaceManager
	if not class_service:
		return

	var cls := class_service.get_class_data(_selected_class_id)
	if not cls:
		return

	var spotlight := PanelContainer.new()
	var sp_box := StyleBoxFlat.new()
	sp_box.bg_color = Color(0.09, 0.08, 0.11, 0.95)
	sp_box.border_color = Color(0.6, 0.5, 0.35, 1.0)
	sp_box.set_border_width_all(1)
	sp_box.set_corner_radius_all(4)
	sp_box.content_margin_left = 12
	sp_box.content_margin_right = 12
	sp_box.content_margin_top = 8
	sp_box.content_margin_bottom = 8
	spotlight.add_theme_stylebox_override("panel", sp_box)
	_content_panel.add_child(spotlight)

	var s_vbox := VBoxContainer.new()
	s_vbox.add_theme_constant_override("separation", 4)
	spotlight.add_child(s_vbox)

	var is_compat := true
	if race_service:
		is_compat = race_service.can_use_class(_selected_race_id, cls.id)

	var title := Label.new()
	title.text = "✦ CLASSE SELECIONADA: %s (%s) — Grupo %s" % [cls.display_name, cls.id, cls.group_id]
	title.add_theme_color_override("font_color", Color(0.98, 0.88, 0.6))
	title.add_theme_font_size_override("font_size", 14)
	s_vbox.add_child(title)

	var detail := Label.new()
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_theme_font_size_override("font_size", 12)

	if cls.is_prototype:
		detail.text = "★ Protótipo Funcional Completo: Conjurador arcano com 2 habilidades ativas (Projétil Arcano + Explosão do Caos) e passivas rúnicas. Árvore de talentos e atributos balanceados.\nEstado: " + ("✅ Totalmente compatível com sua raça." if is_compat else "⚠️ Incompatível.")
		detail.add_theme_color_override("font_color", Color(0.85, 0.9, 0.8))
	else:
		detail.text = "Classe oficial do catálogo de 80 classes. Habilidades e atributos prontos para alocação de atributos.\nEstado: " + ("✅ Compatível com sua raça ancestral." if is_compat else "⚠️ Incompatível.")
		detail.add_theme_color_override("font_color", Color(0.75, 0.72, 0.68))
	s_vbox.add_child(detail)

# =============================================================================
# ETAPA 4: PERSONALIZAÇÃO VISUAL
# =============================================================================

func _build_customization_stage() -> void:
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 340)
	_content_panel.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 14)
	scroll.add_child(vbox)

	_add_color_picker_row(vbox, "Cor da Pele", "skin_color", ["#8a6a52", "#d2b48c", "#4a3b32", "#1e1e24", "#7b9095"])
	_add_color_picker_row(vbox, "Cor dos Cabelos", "hair_color", ["#2b1d12", "#c0c0c0", "#8b0000", "#d4af37", "#111115"])
	_add_color_picker_row(vbox, "Cor dos Olhos", "eye_color", ["#7fd4ff", "#ff4500", "#00ff7f", "#9370db", "#f0e68c"])

	var row_hair := HBoxContainer.new()
	vbox.add_child(row_hair)
	var lbl_hair := Label.new()
	lbl_hair.text = "Estilo de Cabelo: "
	lbl_hair.custom_minimum_size = Vector2(140, 0)
	row_hair.add_child(lbl_hair)
	for style in ["none", "short", "long"]:
		var b := Button.new()
		b.text = "Nenhum" if style == "none" else ("Curto" if style == "short" else "Longo")
		if _appearance.get("hair_style", "") == style:
			b.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
		b.pressed.connect(func() -> void:
			_appearance["hair_style"] = style
			_rebuild_preview()
			_update_stage_content()
		)
		row_hair.add_child(b)

	var row_mark := HBoxContainer.new()
	vbox.add_child(row_mark)
	var lbl_mark := Label.new()
	lbl_mark.text = "Marca Rúnica: "
	lbl_mark.custom_minimum_size = Vector2(140, 0)
	row_mark.add_child(lbl_mark)
	for mark in ["none", "scar", "glow"]:
		var b := Button.new()
		b.text = "Nenhuma" if mark == "none" else ("Cicatriz" if mark == "scar" else "Brilho Rúnico")
		if _appearance.get("face_mark", "") == mark:
			b.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
		b.pressed.connect(func() -> void:
			_appearance["face_mark"] = mark
			_rebuild_preview()
			_update_stage_content()
		)
		row_mark.add_child(b)

	var row_vest := HBoxContainer.new()
	vbox.add_child(row_vest)
	var lbl_vest := Label.new()
	lbl_vest.text = "Vestimenta: "
	lbl_vest.custom_minimum_size = Vector2(140, 0)
	row_vest.add_child(lbl_vest)
	for vest in ["robe", "armor"]:
		var b := Button.new()
		b.text = "Túnica Mágica" if vest == "robe" else "Armadura Pesada"
		if _appearance.get("vestiment", "") == vest:
			b.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
		b.pressed.connect(func() -> void:
			_appearance["vestiment"] = vest
			_rebuild_preview()
			_update_stage_content()
		)
		row_vest.add_child(b)

	var row_extra := HBoxContainer.new()
	vbox.add_child(row_extra)
	var lbl_extra := Label.new()
	lbl_extra.text = "Acessórios Extras: "
	lbl_extra.custom_minimum_size = Vector2(140, 0)
	row_extra.add_child(lbl_extra)
	var extra_names := {"horn": "Chifres", "tail": "Cauda", "wing": "Asas", "crystal": "Cristal"}
	for accessory in ["horn", "tail", "wing", "crystal"]:
		var b := Button.new()
		b.text = extra_names.get(accessory, accessory)
		var extras: Array = _appearance.get("extra_accessories", [])
		if extras.has(accessory):
			b.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
		b.pressed.connect(func() -> void: _toggle_accessory(accessory))
		row_extra.add_child(b)

func _toggle_accessory(accessory: String) -> void:
	var extras: Array = _appearance.get("extra_accessories", [])
	if extras.has(accessory):
		extras.erase(accessory)
	else:
		extras.append(accessory)
	_appearance["extra_accessories"] = extras
	_rebuild_preview()
	_update_stage_content()

func _add_color_picker_row(parent: VBoxContainer, label_text: String, key: String, colors: Array) -> void:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var lbl := Label.new()
	lbl.text = label_text + ": "
	lbl.custom_minimum_size = Vector2(140, 0)
	row.add_child(lbl)
	for hex in colors:
		var b := Button.new()
		b.custom_minimum_size = Vector2(48, 30)
		var col := Color(hex)
		var sw_box := StyleBoxFlat.new()
		sw_box.bg_color = col
		sw_box.set_corner_radius_all(3)
		if _appearance.get(key, "") == hex:
			sw_box.border_color = Color(1.0, 0.9, 0.4, 1.0)
			sw_box.set_border_width_all(3)
		else:
			sw_box.border_color = Color(0.25, 0.25, 0.25, 1.0)
			sw_box.set_border_width_all(1)
		b.add_theme_stylebox_override("normal", sw_box)
		b.pressed.connect(func() -> void:
			_appearance[key] = hex
			_rebuild_preview()
			_update_stage_content()
		)
		row.add_child(b)

# =============================================================================
# ETAPA 5: NOME E IDENTIDADE
# =============================================================================

func _build_name_stage() -> void:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	_content_panel.add_child(vbox)

	var lbl := Label.new()
	lbl.text = "Nome Canônico do Portador Abissal:"
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
	vbox.add_child(lbl)

	var line := LineEdit.new()
	line.name = "NameInput"
	line.text = _character_name
	line.custom_minimum_size = Vector2(0, 42)
	line.text_changed.connect(_on_name_changed)
	vbox.add_child(line)

	var status_lbl := Label.new()
	status_lbl.name = "NameStatus"
	if _is_name_valid():
		status_lbl.text = "✓ Nome válido. Pronto para forjar seu destino."
		status_lbl.add_theme_color_override("font_color", Color(0.6, 0.9, 0.6))
	else:
		status_lbl.text = "✗ O nome deve conter ao menos um caractere alfanumérico."
		status_lbl.add_theme_color_override("font_color", Color(0.9, 0.5, 0.5))
	vbox.add_child(status_lbl)

func _on_name_changed(value: String) -> void:
	_character_name = value
	if _btn_next != null:
		_btn_next.disabled = not _is_name_valid()
	var status_lbl := _content_panel.get_node_or_null("NameStatus") as Label
	if status_lbl != null:
		if _is_name_valid():
			status_lbl.text = "✓ Nome válido. Pronto para forjar seu destino."
			status_lbl.add_theme_color_override("font_color", Color(0.6, 0.9, 0.6))
		else:
			status_lbl.text = "✗ O nome deve conter ao menos um caractere alfanumérico."
			status_lbl.add_theme_color_override("font_color", Color(0.9, 0.5, 0.5))

func _is_name_valid() -> bool:
	var trimmed := _character_name.strip_edges()
	if trimmed.is_empty():
		return false
	for index in trimmed.length():
		var character := trimmed[index]
		if character.is_valid_int() or character.to_lower() != character.to_upper():
			return true
	return false

# =============================================================================
# ETAPA 6: CONFIRMAÇÃO
# =============================================================================

func _build_confirmation_stage() -> void:
	var race_service := Game.get_system(SystemNames.RACE) as RaceManager
	var class_service := Game.get_system(SystemNames.CLASS) as ClassManager
	var race = race_service.get_race(_selected_race_id) if race_service else null
	var subrace = race_service.get_subrace(_selected_subrace_id) if race_service else null
	var cls = class_service.get_class_data(_selected_class_id) if class_service else null

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	_content_panel.add_child(vbox)

	var card := PanelContainer.new()
	var card_box := StyleBoxFlat.new()
	card_box.bg_color = Color(0.08, 0.07, 0.1, 0.95)
	card_box.border_color = Color(0.85, 0.72, 0.4, 1.0)
	card_box.set_border_width_all(2)
	card_box.set_corner_radius_all(6)
	card_box.content_margin_left = 18
	card_box.content_margin_right = 18
	card_box.content_margin_top = 16
	card_box.content_margin_bottom = 16
	card.add_theme_stylebox_override("panel", card_box)
	vbox.add_child(card)

	var text := """
	RESUMO DO COMBATENTE ABISSAL:
	• Nome Canônico: %s
	• Raça: %s (%s)
	• Sub-raça: %s (%s)
	• Classe de Combate: %s (%s)
	• Personalização: Pele %s | Cabelo %s (%s) | Olhos %s | Vestimenta: %s
	
	Ao confirmar, seu combatente será persistido no Slot 0 e enviado à Hell Forge.
	""" % [
		_character_name,
		race.display_name if race else _selected_race_id, _selected_race_id,
		subrace.display_name if subrace else _selected_subrace_id, _selected_subrace_id,
		cls.display_name if cls else _selected_class_id, _selected_class_id,
		_appearance.get("skin_color", ""),
		_appearance.get("hair_color", ""),
		_appearance.get("hair_style", ""),
		_appearance.get("eye_color", ""),
		_appearance.get("vestiment", "")
	]

	var summary := Label.new()
	summary.text = text.dedent()
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_font_size_override("font_size", 14)
	summary.add_theme_color_override("font_color", Color(0.92, 0.88, 0.8))
	card.add_child(summary)

# =============================================================================
# NAVEGAÇÃO E AÇÕES
# =============================================================================

func _on_back_pressed() -> void:
	if _current_stage > 1:
		_current_stage -= 1
		_update_stage_content()

func _on_next_pressed() -> void:
	if not _validate_current_stage():
		return
	if _current_stage < 6:
		_current_stage += 1
		_update_stage_content()
	else:
		_confirm_and_create()

func _validate_current_stage() -> bool:
	if _current_stage == 3:
		var race_service := Game.get_system(SystemNames.RACE) as RaceManager
		if race_service != null and not race_service.can_use_class(_selected_race_id, _selected_class_id):
			_desc_label.text = "Classe incompatível com a raça selecionada. Escolha outra classe compatível."
			return false
	if _current_stage == 5 and not _is_name_valid():
		_desc_label.text = "Informe um nome válido com ao menos um caractere alfanumérico."
		return false
	return true

func _confirm_and_create() -> void:
	var char_manager := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	if char_manager == null:
		_desc_label.text = "Serviço de personagens indisponível."
		return
	var race_service := Game.get_system(SystemNames.RACE) as RaceManager
	if race_service != null and not race_service.can_use_class(_selected_race_id, _selected_class_id):
		_desc_label.text = "Classe incompatível com a raça selecionada."
		return
	var new_char := char_manager.create_character(_character_name, _selected_race_id, _selected_subrace_id, _selected_class_id, _appearance)
	if new_char == null:
		_desc_label.text = "Não foi possível criar o personagem. Verifique as escolhas."
		return
	char_manager.select_character(new_char.id)

	# Persistência no slot 0
	var save_service := Game.get_system(SystemNames.SAVE) as SaveManager
	if save_service != null and save_service.save_slot(0) != OK:
		_desc_label.text = "Falha ao salvar o personagem. Tente novamente."
		return

	# Fecha a tela e envia à Hell Forge
	UI.close_screen(screen_id)
	Scenes.change_scene(HUB_SCENE, {
		"title": "Hell Forge — Portador %s" % _character_name.strip_edges(),
		"character_id": String(new_char.id),
	})

func _rebuild_preview() -> void:
	if not _model_slot or not Game.registry():
		return
	var race_service := Game.get_system(SystemNames.RACE) as RaceManager
	if not race_service:
		return

	for child in _model_slot.get_children():
		_model_slot.remove_child(child)
		child.queue_free()

	RaceVisualBuilder.build(_model_slot, _selected_race_id, _selected_subrace_id, race_service, _appearance)
