class_name RegionalMapScreen
extends ScreenBase
## RegionalMapScreen — Visualizador Cartográfico Interativo de Nível 2 (Mapa Regional) de ABYSSAL PACT.
##
## Apresenta:
##   - Topografia e relevo da região baseado no perfil de bioma e elevação;
##   - Limites naturais (Norte, Sul, Leste, Oeste);
##   - Estruturas, Assentamentos, Masmorras, Chefes, Portais e Gates de fronteira;
##   - Sistema de exploração gradual (Fog of War) em grade de 16x16 setores;
##   - Posição e orientação (Yaw) do jogador no terreno 3D;
##   - Aliados do grupo em tempo real (Multiplayer);
##   - Criação e remoção de marcadores pessoais pelo jogador;
##   - Objetivos de missões e filtros visuais de camadas.

var _region_id: StringName = &"REG-001"
var _selected_marker: Dictionary = {}

var _header: DarkFantasyHeader
var _nav_bar: DarkFantasyNavBar
var _opt_regions: OptionButton
var _lbl_region_name: Label
var _lbl_region_meta: Label
var _lbl_region_bounds: Label
var _lbl_exploration_ratio: Label
var _map_canvas: RegionalMapCanvas
var _markers_vbox: VBoxContainer
var _lbl_marker_details: Label
var _btn_travel: Button
var _btn_add_pin_mode: Button
var _lbl_feedback: Label
var _is_adding_pin: bool = false

func open(params: Dictionary = {}) -> void:
	super(params)
	screen_id = &"regional_map"
	if params.has("region_id"):
		_region_id = StringName(String(params["region_id"]))
	else:
		var world := Game.get_system(SystemNames.WORLD) as WorldManager if has_node("/root/Game") else null
		if world != null:
			var cur := world.current_region_id()
			if not cur.is_empty():
				_region_id = cur
	_build_ui()
	_refresh_regional_map()

func _ready() -> void:
	_build_ui()
	_refresh_regional_map()

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	theme = DarkFantasyTheme.create()

	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.025, 0.035, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var main_vbox := VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_vbox.offset_left = 16
	main_vbox.offset_right = -16
	main_vbox.offset_top = 12
	main_vbox.offset_bottom = -12
	main_vbox.add_theme_constant_override("separation", 8)
	add_child(main_vbox)

	_header = DarkFantasyHeader.new("MAPA REGIONAL DE ABYSSAL PACT", "Topografia Tática, Estruturas, Fronteiras e Exploração de Setores")
	_header.close_requested.connect(_on_close_pressed)
	main_vbox.add_child(_header)

	_nav_bar = DarkFantasyNavBar.new(&"regional_map")
	main_vbox.add_child(_nav_bar)

	# Barra Superior: Seleção de Região e Ferramentas
	var toolbar := HBoxContainer.new()
	toolbar.add_theme_constant_override("separation", 10)
	main_vbox.add_child(toolbar)

	var lbl_sel := Label.new()
	lbl_sel.text = "Região Atual:"
	lbl_sel.add_theme_color_override("font_color", Color(0.9, 0.85, 0.65))
	toolbar.add_child(lbl_sel)

	_opt_regions = OptionButton.new()
	_opt_regions.custom_minimum_size = Vector2(300, 32)
	var world := Game.get_system(SystemNames.WORLD) as WorldManager if has_node("/root/Game") else null
	if world != null:
		var reg_list := world.regions()
		var sel_idx := 0
		for i in range(reg_list.size()):
			var r := reg_list[i]
			_opt_regions.add_item("%s: %s (%s)" % [String(r.id), r.display_name, String(r.continent_id)], i)
			if r.id == _region_id:
				sel_idx = i
		_opt_regions.selected = sel_idx
		_opt_regions.item_selected.connect(func(idx):
			_region_id = reg_list[idx].id
			_refresh_regional_map()
		)
	toolbar.add_child(_opt_regions)

	toolbar.add_child(VSeparator.new())

	var btn_zoom_in := Button.new()
	btn_zoom_in.text = " ➕ Zoom In "
	btn_zoom_in.pressed.connect(func(): _adjust_zoom(1.2))
	toolbar.add_child(btn_zoom_in)

	var btn_zoom_out := Button.new()
	btn_zoom_out.text = " ➖ Zoom Out "
	btn_zoom_out.pressed.connect(func(): _adjust_zoom(0.833))
	toolbar.add_child(btn_zoom_out)

	var btn_recenter := Button.new()
	btn_recenter.text = " 🎯 Centralizar Jogador "
	btn_recenter.pressed.connect(_recenter_player)
	toolbar.add_child(btn_recenter)

	_btn_add_pin_mode = Button.new()
	_btn_add_pin_mode.text = " 📍 Adicionar Marcador "
	_btn_add_pin_mode.pressed.connect(_toggle_add_pin_mode)
	toolbar.add_child(_btn_add_pin_mode)

	# --- ÁREA CENTRAL: MAPA TÁTICO 2D + PAINEL DE MARCADORES ---
	var content_hbox := HBoxContainer.new()
	content_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_theme_constant_override("separation", 12)
	main_vbox.add_child(content_hbox)

	# Painel do Mapa Regional Canvas
	var map_panel := PanelContainer.new()
	map_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(map_panel)

	var map_vbox := VBoxContainer.new()
	map_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map_vbox.offset_left = 10
	map_vbox.offset_right = -10
	map_vbox.offset_top = 8
	map_vbox.offset_bottom = -8
	map_vbox.add_theme_constant_override("separation", 6)
	map_panel.add_child(map_vbox)

	var info_bar := HBoxContainer.new()
	map_vbox.add_child(info_bar)

	_lbl_region_name = Label.new()
	_lbl_region_name.add_theme_font_size_override("font_size", 15)
	_lbl_region_name.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
	info_bar.add_child(_lbl_region_name)

	info_bar.add_child(VSeparator.new())

	_lbl_exploration_ratio = Label.new()
	_lbl_exploration_ratio.text = "Exploração: 0.0%"
	_lbl_exploration_ratio.add_theme_color_override("font_color", Color(0.4, 0.9, 0.5))
	info_bar.add_child(_lbl_exploration_ratio)

	_lbl_region_meta = Label.new()
	_lbl_region_meta.add_theme_font_size_override("font_size", 11)
	_lbl_region_meta.add_theme_color_override("font_color", Color(0.7, 0.65, 0.6))
	map_vbox.add_child(_lbl_region_meta)

	_lbl_region_bounds = Label.new()
	_lbl_region_bounds.add_theme_font_size_override("font_size", 10)
	_lbl_region_bounds.add_theme_color_override("font_color", Color(0.55, 0.5, 0.45))
	map_vbox.add_child(_lbl_region_bounds)

	_map_canvas = RegionalMapCanvas.new()
	_map_canvas.screen = self
	_map_canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_map_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_vbox.add_child(_map_canvas)

	# Painel Lateral: Filtros, Lista de Marcadores, Detalhes e Viagem
	var side_panel := PanelContainer.new()
	side_panel.custom_minimum_size = Vector2(350, 0)
	side_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(side_panel)

	var side_vbox := VBoxContainer.new()
	side_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	side_vbox.offset_left = 12
	side_vbox.offset_right = -12
	side_vbox.offset_top = 10
	side_vbox.offset_bottom = -10
	side_vbox.add_theme_constant_override("separation", 8)
	side_panel.add_child(side_vbox)

	var lbl_markers_title := Label.new()
	lbl_markers_title.text = "MARCADORES E PONTOS DE INTERESSE"
	lbl_markers_title.add_theme_font_size_override("font_size", 12)
	lbl_markers_title.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6))
	side_vbox.add_child(lbl_markers_title)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side_vbox.add_child(scroll)

	_markers_vbox = VBoxContainer.new()
	_markers_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_markers_vbox.add_theme_constant_override("separation", 4)
	scroll.add_child(_markers_vbox)

	side_vbox.add_child(HSeparator.new())

	_lbl_marker_details = Label.new()
	_lbl_marker_details.text = "Clique em um ponto do mapa ou na lista para inspecionar."
	_lbl_marker_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_marker_details.add_theme_font_size_override("font_size", 11)
	side_vbox.add_child(_lbl_marker_details)

	_btn_travel = Button.new()
	_btn_travel.text = "VIAJAR PARA ESTA REGIÃO"
	_btn_travel.custom_minimum_size = Vector2(0, 38)
	_btn_travel.pressed.connect(_on_travel_pressed)
	side_vbox.add_child(_btn_travel)

	_lbl_feedback = Label.new()
	_lbl_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_feedback.add_theme_font_size_override("font_size", 11)
	_lbl_feedback.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5))
	side_vbox.add_child(_lbl_feedback)

# ------------------------------------------------------------- NAVEGAÇÃO & UI --

func _adjust_zoom(factor: float) -> void:
	if _map_canvas != null:
		_map_canvas.zoom = clampf(_map_canvas.zoom * factor, 0.6, 4.0)
		_map_canvas.queue_redraw()

func _recenter_player() -> void:
	if _map_canvas != null:
		_map_canvas.pan_offset = Vector2.ZERO
		_map_canvas.zoom = 1.0
		_map_canvas.queue_redraw()

func _toggle_add_pin_mode() -> void:
	_is_adding_pin = not _is_adding_pin
	if _is_adding_pin:
		_btn_add_pin_mode.text = " ✖ Cancelar Adição "
		_lbl_feedback.text = "Clique com o botão esquerdo no mapa para fincar um marcador."
	else:
		_btn_add_pin_mode.text = " 📍 Adicionar Marcador "
		_lbl_feedback.text = ""

func _refresh_regional_map() -> void:
	var world := Game.get_system(SystemNames.WORLD) as WorldManager if has_node("/root/Game") else null
	if world == null:
		return

	var reg := world.get_region(_region_id)
	if reg == null:
		return

	var map_sys: RefCounted = world.call("map_system") if world.has_method("map_system") else null
	var reg_geo: Dictionary = map_sys.get_region_geo(_region_id) if map_sys != null else {}

	_lbl_region_name.text = "❖ %s — %s ❖" % [String(reg.id), reg.display_name]
	_lbl_region_meta.text = "Bioma: %s | Faixa de Nível: %d–%d | Raio Territorial: %.0f m | Chefe: %s" % [
		reg.biome,
		reg.level_range.x,
		reg.level_range.y,
		float(reg.boundaries.get("radius", 150.0)),
		String(reg_geo.get("associated_boss", "Nenhum"))
	]

	var terrain: Dictionary = reg_geo.get("terrain", {})
	var bounds: Dictionary = terrain.get("natural_boundaries", {})
	_lbl_region_bounds.text = "Limites Naturais — N: %s | S: %s | L: %s | O: %s" % [
		String(bounds.get("north", "Fronteira Norte")),
		String(bounds.get("south", "Fronteira Sul")),
		String(bounds.get("east", "Fronteira Leste")),
		String(bounds.get("west", "Fronteira Oeste"))
	]

	if map_sys != null:
		var exp_pct: float = float(map_sys.get_region_exploration_percentage(_region_id)) * 100.0
		_lbl_exploration_ratio.text = "Exploração: %.1f%%" % exp_pct

	# Popula lista de marcadores
	for child in _markers_vbox.get_children():
		child.queue_free()

	var all_markers := get_all_regional_markers()
	for m in all_markers:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 32)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var icon_str := _marker_icon(String(m.get("type", "")))
		btn.text = " %s  %s  [%s]" % [icon_str, String(m.get("title", m.get("name", ""))), String(m.get("type", "")).to_upper()]
		btn.pressed.connect(func(): _select_marker(m))
		_markers_vbox.add_child(btn)

	if not all_markers.is_empty():
		_select_marker(all_markers[0])

	if _map_canvas != null:
		_map_canvas.queue_redraw()

func get_all_regional_markers() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	var world := Game.get_system(SystemNames.WORLD) as WorldManager if has_node("/root/Game") else null
	if world == null:
		return list

	# 1. Marcadores oficiais da região (POIs, gates, portais)
	var base_markers := world.get_region_markers(_region_id)
	list.append_array(base_markers)

	# 2. Marcadores pessoais do jogador
	var map_sys: RefCounted = world.call("map_system") if world.has_method("map_system") else null
	if map_sys != null:
		var personal: Array[Dictionary] = map_sys.get_personal_markers(_region_id)
		for pm in personal:
			list.append({
				"id": String(pm.get("id")),
				"title": String(pm.get("label")),
				"type": "personal",
				"position": pm.get("position", Vector3.ZERO),
				"discovered": true,
				"description": "Marcador pessoal fincado pelo jogador."
			})

		# 3. Objetivos de missões
		var quests: Array[Dictionary] = map_sys.get_quest_objective_markers(_region_id)
		list.append_array(quests)

	# 4. Invasão de Azaroth (World Boss Hazard - PROMPT 03)
	var bosses := Game.get_system(SystemNames.BOSSES) as Node if has_node("/root/Game") else null
	if bosses != null and bosses.has_method("world_boss_system"):
		var wb: Node = bosses.call("world_boss_system")
		if wb != null and wb.call("get_threatened_region_id") == _region_id:
			var wb_pos: Vector3 = wb.call("invasion_position")
			var stage_label := "Alerta 1H (Fenda Abissal)"
			if bool(wb.call("is_active")): stage_label = "AZAROTH DESPERTO (EM COMBATE)"
			elif bool(wb.call("is_warning")): stage_label = "Ruptura Iminente (15m)"
			elif bool(wb.call("is_defeated")): stage_label = "Selo Restaurado (Vitória)"
			elif bool(wb.call("is_retreated")): stage_label = "Fenda Colapsada"

			list.push_front({
				"id": "wb_azaroth_invasion",
				"title": "INVASÃO DE AZAROTH",
				"type": "world_boss",
				"position": wb_pos,
				"discovered": true,
				"description": "Epicentro da invasão demoníaca de Azaroth, o Devorador de Reinos.\nFase: %s\nDistância: ~1.0 km do centro de aproximação." % stage_label
			})

		# Fendas Demoníacas do Exército de Azaroth (PROMPT 04)
		if wb != null and wb.has_method("get_invasion_system"):
			var inv_sys = wb.call("get_invasion_system")
			if inv_sys != null and inv_sys.has_method("get_active_fissures"):
				var fissures: Array = inv_sys.call("get_active_fissures")
				for f in fissures:
					if is_instance_valid(f):
						var f_pos: Vector3 = f.global_position
						var f_id: String = String(f.fissure_id)
						var t_lvl: int = int(f.threat_level)
						var threat_name := "Menor (Tropas)" if t_lvl == 1 else "Maior (Dano de Área & Primordiais)"
						list.append({
							"id": f_id,
							"title": "Fenda Demoníaca (%s)" % f_id,
							"type": "demonic_fissure",
							"position": f_pos,
							"discovered": true,
							"description": "Fenda subterrânea aberta pelo exército de Azaroth.\nAmeaça: %s\nRaio de perigo: %.1fm (DPS: %.1f)" % [threat_name, f.get_hazard_radius(), f.get_hazard_dps()]
						})

	return list

func _marker_icon(mtype: String) -> String:
	match mtype:
		"world_boss": return "🔥"
		"demonic_fissure": return "🌋"
		"city", "settlement", "camp": return "🏙️"
		"dungeon": return "💀"
		"boss", "boss_arena": return "⚔️"
		"portal": return "🌀"
		"gate": return "🚪"
		"exploration", "landmark": return "🧭"
		"quest_objective": return "🎯"
		"personal": return "📍"
		_: return "•"

func _select_marker(m: Dictionary) -> void:
	_selected_marker = m
	var pos: Vector3 = m.get("position", Vector3.ZERO)
	var title: String = String(m.get("title", m.get("name", "Desconhecido")))
	var mtype: String = String(m.get("type", "Ponto")).capitalize()
	var desc: String = String(m.get("description", ""))

	_lbl_marker_details.text = "❖ %s [%s]\nPosição 3D: (%.1f, %.1f, %.1f)\n%s" % [title, mtype, pos.x, pos.y, pos.z, desc]

	if _map_canvas != null:
		_map_canvas.queue_redraw()

func _on_travel_pressed() -> void:
	var world := Game.get_system(SystemNames.WORLD) as WorldManager if has_node("/root/Game") else null
	if world != null:
		var err := world.load_region(_region_id, "default")
		if err == OK:
			_lbl_feedback.text = "Viagem para %s iniciada com sucesso!" % String(_region_id)
		else:
			_lbl_feedback.text = "Falha ao viajar para a região."

func _on_close_pressed() -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager if has_node("/root/Game") else null
	if ui != null:
		ui.close_screen(&"regional_map")

# ----------------------------------------------------------- CANVAS DE DESENHO --

class RegionalMapCanvas extends Control:
	var screen: RegionalMapScreen
	var zoom: float = 1.0
	var pan_offset: Vector2 = Vector2.ZERO
	var filters: Dictionary = {
		"fog_of_war": true,
		"terrain": true,
		"settlements": true,
		"dungeons": true,
		"bosses": true,
		"gates": true,
		"portals": true,
		"personal": true,
		"allies": true,
		"player": true
	}

	var _dragging := false
	var _drag_start := Vector2.ZERO
	var _pan_start := Vector2.ZERO

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton:
			var mb := event as InputEventMouseButton
			if mb.button_index == MOUSE_BUTTON_LEFT:
				if mb.pressed:
					if screen != null and screen._is_adding_pin:
						_handle_add_pin_click(mb.position)
					else:
						_dragging = true
						_drag_start = mb.position
						_pan_start = pan_offset
				else:
					if _dragging and mb.position.distance_to(_drag_start) < 5.0:
						_handle_marker_selection_click(mb.position)
					_dragging = false
			elif mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
				# Atalho com botão direito: adiciona marcador rápido
				_handle_add_pin_click(mb.position)
			elif mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
				zoom = clampf(zoom * 1.15, 0.6, 4.0)
				queue_redraw()
			elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
				zoom = clampf(zoom / 1.15, 0.6, 4.0)
				queue_redraw()
		elif event is InputEventMouseMotion and _dragging:
			var mm := event as InputEventMouseMotion
			pan_offset = _pan_start + (mm.position - _drag_start)
			queue_redraw()

	func _handle_add_pin_click(click_pos: Vector2) -> void:
		if screen == null:
			return
		var world := Game.get_system(SystemNames.WORLD) as WorldManager if screen.has_node("/root/Game") else null
		if world == null:
			return

		var map_sys := world.map_system()
		if map_sys == null:
			return

		var c_size := size
		var center := c_size * 0.5 + pan_offset
		var radius_px := minf(c_size.x, c_size.y) * 0.42 * zoom
		var reg := world.get_region(screen._region_id)
		var territory_radius := float(reg.boundaries.get("radius", 150.0)) if reg != null else 150.0

		var diff := click_pos - center
		var world_x: float = (diff.x / radius_px) * territory_radius
		var world_z: float = (diff.y / radius_px) * territory_radius
		var world_pos := Vector3(world_x, 0.0, world_z)

		var mid: StringName = map_sys.add_personal_marker(screen._region_id, "Ponto Tático", world_pos, &"pin", Color.GOLD)
		if screen._is_adding_pin:
			screen._toggle_add_pin_mode()
		screen._lbl_feedback.text = "Marcador fincado em (%.1f, %.1f)!" % [world_x, world_z]
		screen._refresh_regional_map()

	func _handle_marker_selection_click(click_pos: Vector2) -> void:
		if screen == null:
			return
		var all_markers := screen.get_all_regional_markers()
		var c_size := size
		var center := c_size * 0.5 + pan_offset
		var radius_px := minf(c_size.x, c_size.y) * 0.42 * zoom
		var territory_radius := 150.0

		for m in all_markers:
			var pos_3d: Vector3 = m.get("position", Vector3.ZERO)
			var m_pos_2d := center + Vector2(pos_3d.x / territory_radius, pos_3d.z / territory_radius) * radius_px
			if click_pos.distance_to(m_pos_2d) < 16.0 * zoom:
				screen._select_marker(m)
				break

	func _draw() -> void:
		var c_size := size
		if c_size.x <= 10 or c_size.y <= 10:
			return

		var center := c_size * 0.5 + pan_offset
		var radius_px := minf(c_size.x, c_size.y) * 0.42 * zoom
		var territory_radius := 150.0

		var world := Game.get_system(SystemNames.WORLD) as WorldManager if screen != null and screen.has_node("/root/Game") else null
		var map_sys: RefCounted = world.call("map_system") if world != null and world.has_method("map_system") else null
		var reg_geo: Dictionary = map_sys.get_region_geo(screen._region_id) if map_sys != null else {}

		# 1. Base do Terreno por Bioma
		var biome := String(reg_geo.get("biome", "default"))
		var terrain_col := _biome_base_color(biome)
		draw_circle(center, radius_px, terrain_col)

		# Linhas topográficas / anéis de elevação
		draw_arc(center, radius_px * 0.33, 0, TAU, 32, Color(0, 0, 0, 0.12), 1.0)
		draw_arc(center, radius_px * 0.66, 0, TAU, 48, Color(0, 0, 0, 0.12), 1.0)

		# 2. Caminhos e Estradas internas
		_draw_internal_paths(center, radius_px, territory_radius)

		# 3. Névoa de Exploração (Fog of War) em Grade de 16x16 setores
		if filters.get("fog_of_war", true) and map_sys != null:
			_draw_fog_of_war(center, radius_px, map_sys)

		# 4. Estruturas, Assentamentos, Masmorras, Chefes e Gates
		_draw_markers(center, radius_px, territory_radius)

		# 5. Aliados do Grupo (Multiplayer)
		if filters.get("allies", true) and map_sys != null:
			for ally in map_sys.get_party_member_positions(screen._region_id):
				var a_pos: Vector3 = ally.get("position", Vector3.ZERO)
				var a_2d := center + Vector2(a_pos.x / territory_radius, a_pos.z / territory_radius) * radius_px
				draw_circle(a_2d, 6.0 * zoom, Color(0.2, 0.75, 1.0))
				draw_arc(a_2d, 8.0 * zoom, 0, TAU, 16, Color(1, 1, 1), 1.5)
				draw_string(ThemeDB.fallback_font, a_2d + Vector2(8, 4), String(ally.get("name", "Aliado")), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.7, 0.9, 1.0))

		# 6. Posição e Direção (Yaw) do Jogador
		if filters.get("player", true):
			var player_3d := Vector3.ZERO
			# Obtém posição real se instanciado
			var p_2d := center + Vector2(player_3d.x / territory_radius, player_3d.z / territory_radius) * radius_px
			draw_circle(p_2d, 7.0 * zoom, Color(1.0, 0.85, 0.25))
			draw_arc(p_2d, 10.0 * zoom, 0, TAU, 24, Color(1.0, 1.0, 1.0), 2.0)
			# Seta de direção para o Norte (ou Yaw)
			var arrow_head := p_2d + Vector2(0, -14.0 * zoom)
			draw_line(p_2d, arrow_head, Color(1, 1, 1), 2.5)

		# 7. Borda Perimetral e Limites Naturais Cardeais
		draw_arc(center, radius_px, 0, TAU, 64, Color(0.5, 0.42, 0.3), 3.0)
		_draw_cardinal_limits(center, radius_px)

	func _draw_internal_paths(center: Vector2, radius_px: float, territory_radius: float) -> void:
		if screen == null:
			return
		var all_markers := screen.get_all_regional_markers()
		for m in all_markers:
			var pos_3d: Vector3 = m.get("position", Vector3.ZERO)
			var p_2d := center + Vector2(pos_3d.x / territory_radius, pos_3d.z / territory_radius) * radius_px
			# Traça caminho em linha pontilhada até o centro do assentamento
			draw_dashed_line(center, p_2d, Color(0.3, 0.25, 0.2, 0.4), 1.5, 4.0)

	func _draw_fog_of_war(center: Vector2, radius_px: float, map_sys: RefCounted) -> void:
		var grid_size := 16
		var cell_w := (radius_px * 2.0) / float(grid_size)
		var top_left := center - Vector2(radius_px, radius_px)

		for gx in range(grid_size):
			for gz in range(grid_size):
				if not map_sys.is_sector_explored(screen._region_id, gx, gz):
					var c_pos := top_left + Vector2(gx * cell_w, gz * cell_w)
					var cell_center := c_pos + Vector2(cell_w * 0.5, cell_w * 0.5)
					if cell_center.distance_to(center) <= radius_px:
						draw_rect(Rect2(c_pos, Vector2(cell_w, cell_w)), Color(0.04, 0.035, 0.05, 0.78))

	func _draw_markers(center: Vector2, radius_px: float, territory_radius: float) -> void:
		if screen == null:
			return
		var all_markers := screen.get_all_regional_markers()

		for m in all_markers:
			var pos_3d: Vector3 = m.get("position", Vector3.ZERO)
			var p_2d := center + Vector2(pos_3d.x / territory_radius, pos_3d.z / territory_radius) * radius_px
			var mtype := String(m.get("type", ""))
			var is_sel: bool = (screen._selected_marker.get("id", "") == m.get("id", ""))
			var col: Color

			match mtype:
				"world_boss":
					col = Color(1.0, 0.15, 0.1)
					var t := Time.get_ticks_msec() / 1000.0
					var p := 0.5 + 0.5 * sin(t * 5.0)
					var hazard_r := (22.0 + 8.0 * p) * zoom
					draw_circle(p_2d, hazard_r, Color(0.9, 0.1, 0.05, 0.35 + 0.2 * p))
					draw_arc(p_2d, hazard_r, 0, TAU, 28, Color(1.0, 0.6, 0.1, 0.95), 2.5)
				"demonic_fissure":
					col = Color(0.95, 0.3, 0.1)
					var t_f := Time.get_ticks_msec() / 1000.0
					var p_f := 0.5 + 0.5 * sin(t_f * 3.5)
					var f_r := (12.0 + 4.0 * p_f) * zoom
					draw_circle(p_2d, f_r, Color(0.85, 0.2, 0.05, 0.25 + 0.15 * p_f))
					draw_arc(p_2d, f_r, 0, TAU, 20, Color(0.95, 0.4, 0.1, 0.8), 1.8)
				"city", "settlement", "camp":
					col = Color(0.3, 0.85, 0.45)
					# Desenha área de SafeZone
					draw_arc(p_2d, 18.0 * zoom, 0, TAU, 24, Color(0.3, 0.85, 0.45, 0.35), 1.5)
				"dungeon": col = Color(0.85, 0.35, 0.35)
				"boss", "boss_arena": col = Color(1.0, 0.25, 0.2)
				"portal": col = Color(0.4, 0.7, 1.0)
				"gate": col = Color(0.85, 0.75, 0.3)
				"personal": col = Color.GOLD
				"quest_objective": col = Color(1.0, 0.8, 0.1)
				_: col = Color(0.8, 0.8, 0.8)

			var marker_r: float = (8.0 if is_sel else 5.5) * zoom
			draw_circle(p_2d, marker_r, col)
			if is_sel:
				draw_arc(p_2d, marker_r + 4.0 * zoom, 0, TAU, 16, Color(1, 1, 0.4), 2.0)

			# Rótulo resumido
			if zoom >= 1.0:
				var m_title := String(m.get("title", m.get("name", "")))
				draw_string(ThemeDB.fallback_font, p_2d + Vector2(marker_r + 3, 4), m_title, HORIZONTAL_ALIGNMENT_LEFT, -1, int(10 * zoom), Color(0.9, 0.85, 0.75))

	func _draw_cardinal_limits(center: Vector2, radius_px: float) -> void:
		var col_text := Color(0.85, 0.75, 0.5)
		draw_string(ThemeDB.fallback_font, center + Vector2(-15, -radius_px - 8), "NORTE", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, col_text)
		draw_string(ThemeDB.fallback_font, center + Vector2(-12, radius_px + 18), "SUL", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, col_text)
		draw_string(ThemeDB.fallback_font, center + Vector2(radius_px + 8, 4), "LESTE", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, col_text)
		draw_string(ThemeDB.fallback_font, center + Vector2(-radius_px - 45, 4), "OESTE", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, col_text)

	func _biome_base_color(biome: String) -> Color:
		match biome:
			"ash_plains", "soot_desert": return Color(0.18, 0.16, 0.17, 0.95)
			"sulfur_crags", "sunscorched_plateau": return Color(0.24, 0.22, 0.15, 0.95)
			"magma_gorge", "caldera_edge": return Color(0.26, 0.12, 0.11, 0.95)
			"whispering_woods", "ancient_roots": return Color(0.12, 0.20, 0.14, 0.95)
			"spectral_fen", "blood_mire": return Color(0.15, 0.14, 0.22, 0.95)
			"black_sand_dunes", "dry_canyon": return Color(0.22, 0.19, 0.14, 0.95)
			"glacial_peaks", "frozen_wastes": return Color(0.13, 0.18, 0.24, 0.95)
			_: return Color(0.14, 0.12, 0.16, 0.95)
