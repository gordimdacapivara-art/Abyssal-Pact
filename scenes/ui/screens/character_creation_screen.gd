class_name CharacterCreationScreen
extends ScreenBase
## Tela de Criação de Personagens — ABYSSAL PACT (Dark Fantasy, 6 etapas).
##
## Etapas:
##   1. Seleção das 40 raças (com filtro de texto e descrição).
##   2. Seleção das 2 sub-raças da raça escolhida.
##   3. Seleção das 80 classes (com filtro de grupo editorial e busca).
##   4. Personalização visual (pele, cabelo, olhos, marcas, acessórios extras, escala).
##   5. Definição do nome e identidade (validação de nome não vazio).
##   6. Confirmação (resumo, salvamento persistente, envio à Hell Forge).
##
## Visualização 3D em tempo real com rotação por drag, zoom por scroll e preview
## dinâmico via RaceVisualBuilder.

const HUB_SCENE := "res://scenes/world/hub_placeholder.tscn"

var _current_stage := 1
var _selected_race_id: StringName = &"RACE-001"
var _selected_subrace_id: StringName = &"SUBRACE-001"
var _selected_class_id: StringName = &"CLASS-001"
var _character_name := "Portador Abissal"

# Dicionário de personalização (aparência JSON-safe persistida em CharacterData)
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

# Nós de UI
var _title_label: Label
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
	# Limpa filhos prévios
	for child in get_children():
		child.queue_free()

	theme = DarkFantasyTheme.create()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Fundo escuro rúnico
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.035, 0.05, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# Layout principal: HBox (Esquerda: 3D Preview + Nome | Direita: Passos + Conteúdo + Botões)
	var main_hbox := HBoxContainer.new()
	main_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_hbox.offset_left = 20
	main_hbox.offset_right = -20
	main_hbox.offset_top = 20
	main_hbox.offset_bottom = -20
	main_hbox.add_theme_constant_override("separation", 20)
	add_child(main_hbox)

	# --- COLUNA ESQUERDA: PREVIEW 3D ---
	var left_vbox := VBoxContainer.new()
	left_vbox.custom_minimum_size = Vector2(380, 0)
	left_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_vbox.add_theme_constant_override("separation", 10)
	main_hbox.add_child(left_vbox)

	var preview_panel := PanelContainer.new()
	preview_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_panel.custom_minimum_size = Vector2(380, 480)
	left_vbox.add_child(preview_panel)

	var viewport_container := SubViewportContainer.new()
	viewport_container.stretch = true
	viewport_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	viewport_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_panel.add_child(viewport_container)

	_viewport_3d = SubViewport.new()
	_viewport_3d.size = Vector2(380, 500)
	_viewport_3d.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_viewport_3d.transparent_bg = false
	_viewport_3d.msaa_3d = Viewport.MSAA_4X
	_viewport_3d.own_world_3d = true
	viewport_container.add_child(_viewport_3d)

	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.08, 0.07, 0.1, 1.0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.88, 0.84, 0.8, 1.0)
	env.ambient_light_energy = 1.0
	if _viewport_3d.world_3d:
		_viewport_3d.world_3d.environment = env

	var cam_rig := Node3D.new()
	cam_rig.name = "CamRig"
	_viewport_3d.add_child(cam_rig)

	_camera_3d = Camera3D.new()
	_camera_3d.name = "Camera3D"
	_camera_3d.current = true
	cam_rig.add_child(_camera_3d)
	_camera_3d.look_at_from_position(Vector3(0, 1.05, 2.5), Vector3(0, 0.9, 0))

	var light := DirectionalLight3D.new()
	light.transform = Transform3D(Basis().rotated(Vector3.UP, 0.5).rotated(Vector3.RIGHT, -0.6), Vector3(0, 5, 3))
	light.light_energy = 1.6
	light.light_color = Color(1.0, 0.96, 0.9)
	_viewport_3d.add_child(light)

	var fill_light := DirectionalLight3D.new()
	fill_light.transform = Transform3D(Basis().rotated(Vector3.UP, -2.4).rotated(Vector3.RIGHT, -0.3), Vector3(0, 3, -3))
	fill_light.light_energy = 0.8
	fill_light.light_color = Color(0.6, 0.7, 0.9)
	_viewport_3d.add_child(fill_light)

	_model_slot = Node3D.new()
	_model_slot.name = "ModelSlot"
	_viewport_3d.add_child(_model_slot)

	# Captura de input para orbitar a câmera
	var orbit_area := Control.new()
	orbit_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	orbit_area.gui_input.connect(_on_preview_gui_input)
	preview_panel.add_child(orbit_area)

	var preview_hint := Label.new()
	preview_hint.text = "Arraste para rotacionar | Roda do mouse: zoom"
	preview_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_hint.add_theme_color_override("font_color", Color(0.6, 0.55, 0.48))
	left_vbox.add_child(preview_hint)

	# --- COLUNA DIREITA: WIZARD DE ETAPAS ---
	var right_vbox := VBoxContainer.new()
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vbox.add_theme_constant_override("separation", 12)
	main_hbox.add_child(right_vbox)

	# Cabeçalho / Título da Etapa
	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", 24)
	_title_label.add_theme_color_override("font_color", Color(0.95, 0.88, 0.7))
	right_vbox.add_child(_title_label)

	# Painel de Conteúdo da Etapa
	var content_panel_wrap := PanelContainer.new()
	content_panel_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_panel_wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_panel_wrap.custom_minimum_size = Vector2(0, 380)
	right_vbox.add_child(content_panel_wrap)

	_content_panel = VBoxContainer.new()
	_content_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_panel.add_theme_constant_override("separation", 10)
	content_panel_wrap.add_child(_content_panel)

	# Painel de Descrição / Status
	var desc_panel := PanelContainer.new()
	desc_panel.custom_minimum_size = Vector2(0, 90)
	right_vbox.add_child(desc_panel)

	_desc_label = Label.new()
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.add_theme_color_override("font_color", Color(0.78, 0.74, 0.68))
	desc_panel.add_child(_desc_label)

	# Barra de Botões (Voltar / Avançar / Confirmar)
	var nav_hbox := HBoxContainer.new()
	nav_hbox.alignment = HBoxContainer.ALIGNMENT_END
	nav_hbox.add_theme_constant_override("separation", 15)
	right_vbox.add_child(nav_hbox)

	_btn_back = Button.new()
	_btn_back.text = "« Anterior"
	_btn_back.pressed.connect(_on_back_pressed)
	nav_hbox.add_child(_btn_back)

	_btn_next = Button.new()
	_btn_next.text = "Avançar »"
	_btn_next.pressed.connect(_on_next_pressed)
	nav_hbox.add_child(_btn_next)

func _on_preview_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_LEFT:
			_is_dragging = mouse_button.pressed
			_last_mouse_pos = mouse_button.position
		elif mouse_button.button_index == MOUSE_BUTTON_WHEEL_UP and _camera_3d:
			_camera_3d.position.z = maxf(1.5, _camera_3d.position.z - 0.2)
		elif mouse_button.button_index == MOUSE_BUTTON_WHEEL_DOWN and _camera_3d:
			_camera_3d.position.z = minf(6.0, _camera_3d.position.z + 0.2)
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
		child.queue_free()

	_btn_back.disabled = (_current_stage == 1)
	_btn_next.text = "Confirmar e Entrar »" if _current_stage == 6 else "Avançar »"
	_btn_next.disabled = (_current_stage == 5 and not _is_name_valid())

	match _current_stage:
		1:
			_title_label.text = "ETAPA 1/6 — SELEÇÃO DE RAÇA (40 Raças)"
			_desc_label.text = "Selecione a raça ancestral de seu combatente. O catálogo completo de 40 raças está disponível. O protótipo visual (RACE-001) exibe esqueleto modular em tempo real."
			_build_race_stage()
		2:
			_title_label.text = "ETAPA 2/6 — SELEÇÃO DE SUB-RAÇA"
			_desc_label.text = "Escolha uma das duas sub-raças associadas à raça escolhida. Cada sub-raça molda características visuais distintas."
			_build_subrace_stage()
		3:
			_title_label.text = "ETAPA 3/6 — SELEÇÃO DE CLASSE (80 Classes)"
			_desc_label.text = "Escolha sua classe de combate (8 grupos editoriais). O Arcanista (CLASS-001) é o protótipo funcional completo com habilidades demonstráveis."
			_build_class_stage()
		4:
			_title_label.text = "ETAPA 4/6 — PERSONALIZAÇÃO VISUAL"
			_desc_label.text = "Ajuste tintas, cabelo, olhos, marcas e acessórios rúnicos sobre o modelo modular."
			_build_customization_stage()
		5:
			_title_label.text = "ETAPA 5/6 — NOME E IDENTIDADE"
			_desc_label.text = "Insira o nome canônico do portador abissal para o registro nos anais da forja."
			_build_name_stage()
		6:
			_title_label.text = "ETAPA 6/6 — CONFIRMAÇÃO"
			_desc_label.text = "Revise suas escolhas. Ao confirmar, o personagem será salvo com persistência e você será enviado à Hell Forge."
			_build_confirmation_stage()

# --- CONSTRUTORES DE ETAPAS ---

func _build_race_stage() -> void:
	var race_service := Game.registry().get_system(SystemNames.RACE) as RaceManager
	if not race_service:
		return

	var filter_box := LineEdit.new()
	filter_box.placeholder_text = "Filtrar raças (ex: RACE-001)..."
	filter_box.text_changed.connect(func(text: String) -> void: _refresh_race_list(text))
	_content_panel.add_child(filter_box)

	var scroll := ScrollContainer.new()
	scroll.name = "ScrollContainer"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 320)
	_content_panel.add_child(scroll)

	var grid := VBoxContainer.new()
	grid.name = "RaceList"
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)

	_populate_races(grid, "")

func _populate_races(container: VBoxContainer, filter: String) -> void:
	for child in container.get_children():
		child.queue_free()
	var race_service := Game.registry().get_system(SystemNames.RACE) as RaceManager
	if not race_service:
		return
	for race: RaceData in race_service.races():
		if not filter.is_empty() and not race.id.contains(filter) and not race.display_name.to_lower().contains(filter.to_lower()):
			continue
		var btn := Button.new()
		var is_sel = (race.id == _selected_race_id)
		btn.text = "%s — %s%s" % [race.id, race.display_name, " (Protótipo)" if race.is_prototype else ""]
		if is_sel:
			btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
		btn.pressed.connect(func() -> void:
			_selected_race_id = race.id
			# Auto-seleciona a primeira sub-raça válida
			var subs := race_service.subraces_of(race.id)
			if not subs.is_empty():
				_selected_subrace_id = subs[0].id
			_update_stage_content()
			_rebuild_preview()
		)
		container.add_child(btn)

func _refresh_race_list(filter: String) -> void:
	var scroll := _content_panel.get_node_or_null("ScrollContainer")
	if scroll:
		var grid := scroll.get_node_or_null("RaceList") as VBoxContainer
		if grid:
			_populate_races(grid, filter)

func _build_subrace_stage() -> void:
	var race_service := Game.registry().get_system(SystemNames.RACE) as RaceManager
	if not race_service:
		return
	var race := race_service.get_race(_selected_race_id)
	if not race:
		return

	var info := Label.new()
	info.text = "Raça-mãe: %s (%s)" % [race.display_name, race.id]
	info.add_theme_color_override("font_color", Color(0.9, 0.82, 0.6))
	_content_panel.add_child(info)

	for subrace: SubraceData in race_service.subraces_of(_selected_race_id):
		var btn := Button.new()
		var is_sel = (subrace.id == _selected_subrace_id)
		btn.text = "%s — %s%s" % [subrace.id, subrace.display_name, " (Protótipo)" if subrace.is_prototype else ""]
		if is_sel:
			btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
		btn.pressed.connect(func() -> void:
			_selected_subrace_id = subrace.id
			_update_stage_content()
			_rebuild_preview()
		)
		_content_panel.add_child(btn)

func _build_class_stage() -> void:
	var class_service := Game.registry().get_system(SystemNames.CLASS) as ClassManager
	if not class_service:
		return

	var filter_hbox := HBoxContainer.new()
	_content_panel.add_child(filter_hbox)

	var search := LineEdit.new()
	search.placeholder_text = "Buscar classe..."
	search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search.text_changed.connect(func(t: String) -> void: _refresh_class_list(t))
	filter_hbox.add_child(search)

	var scroll := ScrollContainer.new()
	scroll.name = "ScrollContainer"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 320)
	_content_panel.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.name = "ClassList"
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)

	_populate_classes(vbox, "")

func _populate_classes(container: VBoxContainer, filter: String) -> void:
	for c in container.get_children():
		c.queue_free()
	var class_service := Game.registry().get_system(SystemNames.CLASS) as ClassManager
	var race_service := Game.registry().get_system(SystemNames.RACE) as RaceManager
	if not class_service:
		return

	for cls: ClassData in class_service.classes():
		if not filter.is_empty() and not cls.id.contains(filter) and not cls.display_name.to_lower().contains(filter.to_lower()):
			continue
		var btn := Button.new()
		var is_sel = (cls.id == _selected_class_id)
		var compatible = true
		if race_service:
			compatible = race_service.can_use_class(_selected_race_id, cls.id)

		btn.text = "%s — %s%s%s" % [
			cls.id,
			cls.display_name,
			" (Protótipo Funcional)" if cls.is_prototype else " (Pendente)",
			"" if compatible else " [Incompatível]"
		]
		if is_sel:
			btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
		elif not compatible:
			btn.disabled = true

		btn.pressed.connect(func() -> void:
			_selected_class_id = cls.id
			_update_stage_content()
		)
		container.add_child(btn)

func _refresh_class_list(filter: String) -> void:
	var scroll := _content_panel.get_node_or_null("ScrollContainer")
	if scroll:
		var grid := scroll.get_node_or_null("ClassList") as VBoxContainer
		if grid:
			_populate_classes(grid, filter)

func _build_customization_stage() -> void:
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 320)
	_content_panel.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 12)
	scroll.add_child(vbox)

	_add_color_picker_row(vbox, "Cor da Pele", "skin_color", ["#8a6a52", "#d2b48c", "#4a3b32", "#1e1e24"])
	_add_color_picker_row(vbox, "Cor dos Cabelos", "hair_color", ["#2b1d12", "#c0c0c0", "#8b0000", "#d4af37"])
	_add_color_picker_row(vbox, "Cor dos Olhos", "eye_color", ["#7fd4ff", "#ff4500", "#00ff7f", "#9370db"])

	var row_hair := HBoxContainer.new()
	vbox.add_child(row_hair)
	var lbl_hair := Label.new()
	lbl_hair.text = "Estilo de Cabelo: "
	row_hair.add_child(lbl_hair)
	for style in ["none", "short", "long"]:
		var b := Button.new()
		b.text = style.capitalize()
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
	row_mark.add_child(lbl_mark)
	for mark in ["none", "scar", "glow"]:
		var b := Button.new()
		b.text = mark.capitalize()
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
	row_vest.add_child(lbl_vest)
	for vest in ["robe", "armor"]:
		var b := Button.new()
		b.text = vest.capitalize()
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
	lbl_extra.text = "Acessórios Extras (PROVISÓRIOS): "
	row_extra.add_child(lbl_extra)
	for accessory in ["horn", "tail", "wing", "crystal"]:
		var b := Button.new()
		b.text = accessory.capitalize()
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
		b.text = hex
		if _appearance.get(key, "") == hex:
			b.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
		b.pressed.connect(func() -> void:
			_appearance[key] = hex
			_rebuild_preview()
			_update_stage_content()
		)
		row.add_child(b)

func _build_name_stage() -> void:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	_content_panel.add_child(vbox)

	var lbl := Label.new()
	lbl.text = "Nome do Portador Abissal:"
	vbox.add_child(lbl)

	var line := LineEdit.new()
	line.name = "NameInput"
	line.text = _character_name
	line.text_changed.connect(_on_name_changed)
	vbox.add_child(line)

	var hint := Label.new()
	hint.text = "O nome deve conter ao menos um caractere alfanumérico."
	hint.add_theme_color_override("font_color", Color(0.6, 0.55, 0.5))
	vbox.add_child(hint)

func _on_name_changed(value: String) -> void:
	_character_name = value
	if _btn_next != null:
		_btn_next.disabled = not _is_name_valid()

## Validação de identidade: ao menos um caractere alfanumérico (letras
## acentuadas contam como letras). Nada de regra de lore inventada.
func _is_name_valid() -> bool:
	var trimmed := _character_name.strip_edges()
	if trimmed.is_empty():
		return false
	for index in trimmed.length():
		var character := trimmed[index]
		if character.is_valid_int() or character.to_lower() != character.to_upper():
			return true
	return false

func _build_confirmation_stage() -> void:
	var race_service := Game.registry().get_system(SystemNames.RACE) as RaceManager
	var class_service := Game.registry().get_system(SystemNames.CLASS) as ClassManager
	var race = race_service.get_race(_selected_race_id) if race_service else null
	var subrace = race_service.get_subrace(_selected_subrace_id) if race_service else null
	var cls = class_service.get_class_data(_selected_class_id) if class_service else null

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	_content_panel.add_child(vbox)

	var text := """
	[Resumo do Combatente]
	• Nome: %s
	• Raça: %s (%s)
	• Sub-raça: %s (%s)
	• Classe: %s (%s)
	• Aparência configurada: Pele %s, Cabelo %s (%s), Olhos %s, Vestimenta %s
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
	vbox.add_child(summary)

# --- NAVEGAÇÃO / AÇÕES ---

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

## Validações por etapa (sem botões decorativos): classe compatível com a raça
## e nome com ao menos um caractere alfanumérico.
func _validate_current_stage() -> bool:
	if _current_stage == 3:
		var race_service := Game.get_system(SystemNames.RACE) as RaceManager
		if race_service != null and not race_service.can_use_class(_selected_race_id, _selected_class_id):
			_desc_label.text = "Classe incompatível com a raça selecionada. Escolha outra classe."
			return false
	if _current_stage == 5 and not _is_name_valid():
		_desc_label.text = "Informe um nome com ao menos um caractere alfanumérico."
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

	# Persistência: slot 0 (o save inclui raça/sub-raça/classe/aparência).
	var save_service := Game.get_system(SystemNames.SAVE) as SaveManager
	if save_service != null and save_service.save_slot(0) != OK:
		_desc_label.text = "Falha ao salvar o personagem. Tente novamente."
		return

	# Fecha a tela e envia à Hell Forge (hub de ressurgimento obrigatório).
	UI.close_screen(screen_id)
	Scenes.change_scene(HUB_SCENE, {
		"title": "Hell Forge — Portador %s" % _character_name.strip_edges(),
		"character_id": String(new_char.id),
	})

func _rebuild_preview() -> void:
	if not _model_slot or not Game.registry():
		return
	var race_service := Game.registry().get_system(SystemNames.RACE) as RaceManager
	if not race_service:
		return

	for child in _model_slot.get_children():
		child.queue_free()

	RaceVisualBuilder.build(_model_slot, _selected_race_id, _selected_subrace_id, race_service, _appearance)
