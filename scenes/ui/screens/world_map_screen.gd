class_name WorldMapScreen
extends ScreenBase
## WorldMapScreen — Visualizador Cartográfico Interativo de Nível 1 (Mapa-Múndi) de ABYSSAL PACT.
##
## Apresenta:
##   - Quatro Continentes (Veyrath, Sylvaran, Khar-Duum, Nhal'Kora);
##   - Mar da Cicatriz (Oceano Central com linhas náuticas e rotas marítimas);
##   - Hell Forge como Dimensão Independente (Nexus Dimensional central);
##   - 40 Regiões catalogadas com limites e polígonos de fronteira;
##   - Diferenciação visual entre regiões Descobertas e Não Descobertas (Fog of War);
##   - Portais arcanos e conduítes dimensionais permanentes;
##   - Rastreamento em tempo real do jogador e de até 7 aliados (Multiplayer);
##   - Navegação completa com Zoom, Pan/Drag, Seleção de Continentes/Regiões, Filtros e Legenda.

var _selected_continent_id: StringName = &"CONT-01"
var _selected_region_id: StringName = &"REG-001"

var _header: DarkFantasyHeader
var _nav_bar: DarkFantasyNavBar
var _map_canvas: WorldMapCanvas
var _lbl_details_title: Label
var _lbl_details_meta: Label
var _lbl_details_desc: Label
var _lbl_exploration_stats: Label
var _filter_checkboxes: Dictionary = {}
var _regions_list: ItemList
var _btn_open_regional_map: Button
var _btn_warp_hell_forge: Button
var _lbl_feedback: Label

func open(params: Dictionary = {}) -> void:
	super(params)
	screen_id = &"world_map"
	if params.has("continent_id"):
		_selected_continent_id = StringName(String(params["continent_id"]))
	if params.has("region_id"):
		_selected_region_id = StringName(String(params["region_id"]))
	_build_ui()
	_refresh_display()

func _ready() -> void:
	_build_ui()
	_refresh_display()

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	theme = DarkFantasyTheme.create()

	# Fundo gótico profundo
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

	_header = DarkFantasyHeader.new("MAPA-MÚNDI DE ABYSSAL PACT", "Os Quatro Continentes, Mar da Cicatriz e o Nexus da Hell Forge")
	_header.close_requested.connect(_on_close_pressed)
	main_vbox.add_child(_header)

	_nav_bar = DarkFantasyNavBar.new(&"world_map")
	main_vbox.add_child(_nav_bar)

	# Barra de Ferramentas: Foco Continental, Zoom e Filtros Rápidos
	var toolbar := HBoxContainer.new()
	toolbar.add_theme_constant_override("separation", 10)
	main_vbox.add_child(toolbar)

	var lbl_focus := Label.new()
	lbl_focus.text = "Foco Geográfico:"
	lbl_focus.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6))
	toolbar.add_child(lbl_focus)

	var continents_btn_data := [
		{"id": &"ALL", "label": "❖ Todo o Mundo", "color": Color(0.95, 0.9, 0.8)},
		{"id": &"CONT-01", "label": "Veyrath (NO)", "color": Color(0.9, 0.45, 0.35)},
		{"id": &"CONT-02", "label": "Sylvaran (NE)", "color": Color(0.4, 0.85, 0.5)},
		{"id": &"CONT-03", "label": "Khar-Duum (SO)", "color": Color(0.95, 0.8, 0.35)},
		{"id": &"CONT-04", "label": "Nhal'Kora (SE)", "color": Color(0.45, 0.75, 0.95)},
		{"id": &"HELL_FORGE", "label": "🔥 Hell Forge", "color": Color(1.0, 0.6, 0.2)}
	]

	for c in continents_btn_data:
		var btn := Button.new()
		btn.text = c["label"]
		btn.add_theme_color_override("font_color", c["color"])
		var cid: StringName = c["id"]
		btn.pressed.connect(func(): _focus_geographic_area(cid))
		toolbar.add_child(btn)

	toolbar.add_child(VSeparator.new())

	# Controles de Zoom
	var btn_zoom_in := Button.new()
	btn_zoom_in.text = " ➕ Zoom In "
	btn_zoom_in.pressed.connect(func(): _adjust_zoom(1.2))
	toolbar.add_child(btn_zoom_in)

	var btn_zoom_out := Button.new()
	btn_zoom_out.text = " ➖ Zoom Out "
	btn_zoom_out.pressed.connect(func(): _adjust_zoom(0.833))
	toolbar.add_child(btn_zoom_out)

	var btn_reset_view := Button.new()
	btn_reset_view.text = " ↺ Centralizar "
	btn_reset_view.pressed.connect(_reset_camera_view)
	toolbar.add_child(btn_reset_view)

	# --- ÁREA CENTRAL: MAPA-MÚNDI CANVAS + PAINEL LATERAL DE INFORMAÇÕES ---
	var content_hbox := HBoxContainer.new()
	content_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_theme_constant_override("separation", 12)
	main_vbox.add_child(content_hbox)

	# Canvas do Mapa-Múndi
	var map_panel := PanelContainer.new()
	map_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(map_panel)

	_map_canvas = WorldMapCanvas.new()
	_map_canvas.screen = self
	_map_canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_map_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_panel.add_child(_map_canvas)

	# Painel Lateral: Filtros, Lista de Regiões, Detalhes e Ações
	var side_panel := PanelContainer.new()
	side_panel.custom_minimum_size = Vector2(360, 0)
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

	# Filtros de Camadas
	var lbl_filt := Label.new()
	lbl_filt.text = "FILTROS CARTOGRÁFICOS"
	lbl_filt.add_theme_font_size_override("font_size", 12)
	lbl_filt.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6))
	side_vbox.add_child(lbl_filt)

	var filters_grid := GridContainer.new()
	filters_grid.columns = 2
	filters_grid.add_theme_constant_override("h_separation", 8)
	side_vbox.add_child(filters_grid)

	var filter_keys := [
		{"key": "continents", "label": "Continentes"},
		{"key": "regions", "label": "40 Regiões"},
		{"key": "portals", "label": "Portais & Nexus"},
		{"key": "routes", "label": "Rotas Terrestres/Marítimas"},
		{"key": "player", "label": "Posição do Jogador"},
		{"key": "allies", "label": "Aliados (Grupo)"},
		{"key": "fog_of_war", "label": "Névoa de Exploração"},
	]

	for f in filter_keys:
		var cb := CheckBox.new()
		cb.text = f["label"]
		cb.button_pressed = true
		var fkey: String = f["key"]
		cb.toggled.connect(func(pressed: bool):
			_map_canvas.filters[fkey] = pressed
			_map_canvas.queue_redraw()
		)
		filters_grid.add_child(cb)
		_filter_checkboxes[fkey] = cb

	side_vbox.add_child(HSeparator.new())

	# Estatísticas de Exploração do Mundo
	_lbl_exploration_stats = Label.new()
	_lbl_exploration_stats.text = "Exploração Global: 0.0% | Descobertas: 0/40"
	_lbl_exploration_stats.add_theme_font_size_override("font_size", 11)
	_lbl_exploration_stats.add_theme_color_override("font_color", Color(0.5, 0.9, 0.6))
	side_vbox.add_child(_lbl_exploration_stats)

	side_vbox.add_child(HSeparator.new())

	# Detalhes da Região Selecionada
	_lbl_details_title = Label.new()
	_lbl_details_title.text = "Planície Cinzenta de Veyrath (REG-001)"
	_lbl_details_title.add_theme_font_size_override("font_size", 14)
	_lbl_details_title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
	side_vbox.add_child(_lbl_details_title)

	_lbl_details_meta = Label.new()
	_lbl_details_meta.text = "Continente: Veyrath | Nível: 1–5 | Bioma: ash_plains"
	_lbl_details_meta.add_theme_font_size_override("font_size", 11)
	_lbl_details_meta.add_theme_color_override("font_color", Color(0.7, 0.65, 0.6))
	side_vbox.add_child(_lbl_details_meta)

	_lbl_details_desc = Label.new()
	_lbl_details_desc.text = "Descrição geográfica da região selecionada..."
	_lbl_details_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_details_desc.add_theme_font_size_override("font_size", 11)
	side_vbox.add_child(_lbl_details_desc)

	# Seletor de Regiões Rápido
	var lbl_sel_reg := Label.new()
	lbl_sel_reg.text = "ÍNDICE DE REGIÕES DO CONTINENTE:"
	lbl_sel_reg.add_theme_font_size_override("font_size", 11)
	lbl_sel_reg.add_theme_color_override("font_color", Color(0.8, 0.75, 0.65))
	side_vbox.add_child(lbl_sel_reg)

	_regions_list = ItemList.new()
	_regions_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_regions_list.item_selected.connect(_on_region_item_selected)
	side_vbox.add_child(_regions_list)

	# Ações
	_btn_open_regional_map = Button.new()
	_btn_open_regional_map.text = "🗺️ ABRIR MAPA REGIONAL DETALHADO"
	_btn_open_regional_map.custom_minimum_size = Vector2(0, 38)
	_btn_open_regional_map.pressed.connect(_on_open_regional_map_pressed)
	side_vbox.add_child(_btn_open_regional_map)

	_btn_warp_hell_forge = Button.new()
	_btn_warp_hell_forge.text = "🔥 CONDUÍTE PARA HELL FORGE"
	_btn_warp_hell_forge.custom_minimum_size = Vector2(0, 36)
	_btn_warp_hell_forge.add_theme_color_override("font_color", Color(1.0, 0.7, 0.3))
	_btn_warp_hell_forge.pressed.connect(_on_hell_forge_warp_pressed)
	side_vbox.add_child(_btn_warp_hell_forge)

	_lbl_feedback = Label.new()
	_lbl_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_feedback.add_theme_font_size_override("font_size", 11)
	_lbl_feedback.add_theme_color_override("font_color", Color(0.4, 0.85, 0.5))
	side_vbox.add_child(_lbl_feedback)

# ------------------------------------------------------------- NAVEGAÇÃO & UI --

func _focus_geographic_area(area_id: StringName) -> void:
	if _map_canvas == null:
		return

	match area_id:
		&"ALL":
			_map_canvas.zoom = 1.0
			_map_canvas.pan_offset = Vector2.ZERO
		&"CONT-01": # Veyrath (NW)
			_selected_continent_id = &"CONT-01"
			_map_canvas.zoom = 1.8
			_map_canvas.pan_offset = Vector2(180, 180)
		&"CONT-02": # Sylvaran (NE)
			_selected_continent_id = &"CONT-02"
			_map_canvas.zoom = 1.8
			_map_canvas.pan_offset = Vector2(-180, 180)
		&"CONT-03": # Khar-Duum (SW)
			_selected_continent_id = &"CONT-03"
			_map_canvas.zoom = 1.8
			_map_canvas.pan_offset = Vector2(180, -180)
		&"CONT-04": # Nhal'Kora (SE)
			_selected_continent_id = &"CONT-04"
			_map_canvas.zoom = 1.8
			_map_canvas.pan_offset = Vector2(-180, -180)
		&"HELL_FORGE":
			_map_canvas.zoom = 2.2
			_map_canvas.pan_offset = Vector2.ZERO

	_refresh_display()
	_map_canvas.queue_redraw()

func _adjust_zoom(factor: float) -> void:
	if _map_canvas != null:
		_map_canvas.zoom = clampf(_map_canvas.zoom * factor, 0.5, 3.5)
		_map_canvas.queue_redraw()

func _reset_camera_view() -> void:
	if _map_canvas != null:
		_map_canvas.zoom = 1.0
		_map_canvas.pan_offset = Vector2.ZERO
		_map_canvas.queue_redraw()

func select_region(region_id: StringName) -> void:
	_selected_region_id = region_id
	var world := Game.get_system(SystemNames.WORLD) as WorldManager if has_node("/root/Game") else null
	if world != null:
		var reg := world.get_region(region_id)
		if reg != null:
			_selected_continent_id = reg.continent_id
	_refresh_display()
	if _map_canvas != null:
		_map_canvas.queue_redraw()

func _refresh_display() -> void:
	var world := Game.get_system(SystemNames.WORLD) as WorldManager if has_node("/root/Game") else null
	if world == null:
		return

	var map_sys: RefCounted = world.call("map_system") if world.has_method("map_system") else null
	var reg_geo: Dictionary = map_sys.get_region_geo(_selected_region_id) if map_sys != null else {}

	if not reg_geo.is_empty():
		var r_name := String(reg_geo.get("name", _selected_region_id))
		var r_cont := String(reg_geo.get("continent_name", _selected_continent_id))
		var levels: Array = reg_geo.get("level_range", [1, 5])
		var biome := String(reg_geo.get("biome", "default"))
		var desc := String(reg_geo.get("description", ""))
		var dungeon := String(reg_geo.get("dungeon", "Nenhuma"))
		var boss := String(reg_geo.get("associated_boss", "Nenhum"))

		_lbl_details_title.text = "❖ %s (%s)" % [r_name, String(_selected_region_id)]
		_lbl_details_meta.text = "Continente: %s | Nível: %d–%d | Bioma: %s" % [r_cont, levels[0], levels[1], biome]
		_lbl_details_desc.text = "%s\n\n• Masmorra: %s\n• Chefe Associado: %s" % [desc, dungeon, boss]

		# Alerta e rastreamento de invasão do World Boss Azaroth (PROMPT 03)
		var bosses := Game.get_system(SystemNames.BOSSES) as Node if has_node("/root/Game") else null
		if bosses != null and bosses.has_method("world_boss_system"):
			var wb: Node = bosses.call("world_boss_system")
			if wb != null and wb.call("get_threatened_region_id") == _selected_region_id:
				var inv_pos: Vector3 = wb.call("invasion_position")
				var state_label := "Alerta 1H (Fenda Detectada)"
				if bool(wb.call("is_active")): state_label = "EM COMBATE ATIVO"
				elif bool(wb.call("is_warning")): state_label = "RUPTURA IMINENTE (15M)"
				elif bool(wb.call("is_defeated")): state_label = "DERROTADO (SELO RESTAURADO)"
				elif bool(wb.call("is_retreated")): state_label = "RECUADO PARA O ABISMO"
				var invasion_details := ""
				if wb.has_method("get_invasion_system"):
					var inv_sys = wb.call("get_invasion_system")
					if inv_sys != null:
						var phase_name: String = inv_sys.call("get_phase_name")
						var corr_pct: float = float(inv_sys.call("get_corruption_level")) * 100.0
						var fiss_cnt: int = int(inv_sys.call("get_fissures_count"))
						var unit_cnt: int = int(inv_sys.call("get_units_count"))
						invasion_details = "\n• Exército: %s\n• Corrupção do Território: %.0f%%\n• Fendas Demoníacas: %d\n• Tropas Ativas: %d" % [
							phase_name, corr_pct, fiss_cnt, unit_cnt
						]

				_lbl_details_desc.text += "\n\n⚠️ INVASÃO DO WORLD BOSS AZAROTH:\n• Estado: %s\n• Continente: %s\n• Coordenadas: (%.1f, %.1f, %.1f)\n• Distância estimada dos jogadores: ~1.0 km%s" % [
					state_label,
					wb.call("get_threatened_continent_name"),
					inv_pos.x, inv_pos.y, inv_pos.z,
					invasion_details
				]

	# Atualiza estatísticas de exploração
	if map_sys != null:
		var world_pct: float = float(map_sys.get_world_exploration_percentage()) * 100.0
		var disc_count := 0
		for r in world.regions():
			if map_sys.is_region_discovered(r.id):
				disc_count += 1
		_lbl_exploration_stats.text = "Exploração Global: %.1f%% | Descobertas: %d/40" % [world_pct, disc_count]

	# Atualiza Lista de Regiões do continente ativo
	_regions_list.clear()
	var cont_regions := world.regions_of_continent(_selected_continent_id)
	for i in range(cont_regions.size()):
		var r := cont_regions[i]
		var is_disc: bool = bool(map_sys.is_region_discovered(r.id)) if map_sys != null else false
		var status_str := "✓" if is_disc else "🔒"
		var item_text := "%s %s — %s (Nv. %d–%d)" % [status_str, String(r.id), r.display_name, r.level_range.x, r.level_range.y]
		_regions_list.add_item(item_text)
		_regions_list.set_item_metadata(i, r.id)
		if r.id == _selected_region_id:
			_regions_list.select(i)

func _on_region_item_selected(index: int) -> void:
	var rid = _regions_list.get_item_metadata(index)
	if rid != null:
		select_region(StringName(String(rid)))

func _on_open_regional_map_pressed() -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager if has_node("/root/Game") else null
	if ui != null:
		ui.open_screen(&"regional_map", {"region_id": _selected_region_id})

func _on_hell_forge_warp_pressed() -> void:
	var world := Game.get_system(SystemNames.WORLD) as WorldManager if has_node("/root/Game") else null
	if world != null:
		world.respawn_at_hell_forge()
		_lbl_feedback.text = "Canalizando energia arcana para a Hell Forge..."

func _on_close_pressed() -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager if has_node("/root/Game") else null
	if ui != null:
		ui.close_screen(&"world_map")

# ----------------------------------------------------------- CANVAS DE DESENHO --

class WorldMapCanvas extends Control:
	var screen: WorldMapScreen
	var zoom: float = 1.0
	var pan_offset: Vector2 = Vector2.ZERO
	var filters: Dictionary = {
		"continents": true,
		"regions": true,
		"portals": true,
		"routes": true,
		"player": true,
		"allies": true,
		"fog_of_war": true
	}

	var _dragging := false
	var _drag_start := Vector2.ZERO
	var _pan_start := Vector2.ZERO

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton:
			var mb := event as InputEventMouseButton
			if mb.button_index == MOUSE_BUTTON_LEFT:
				if mb.pressed:
					_dragging = true
					_drag_start = mb.position
					_pan_start = pan_offset
				else:
					if _dragging and mb.position.distance_to(_drag_start) < 5.0:
						_handle_map_click(mb.position)
					_dragging = false
			elif mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
				zoom = clampf(zoom * 1.12, 0.5, 3.5)
				queue_redraw()
			elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
				zoom = clampf(zoom / 1.12, 0.5, 3.5)
				queue_redraw()
		elif event is InputEventMouseMotion and _dragging:
			var mm := event as InputEventMouseMotion
			pan_offset = _pan_start + (mm.position - _drag_start)
			queue_redraw()

	func _handle_map_click(click_pos: Vector2) -> void:
		if screen == null:
			return
		var world := Game.get_system(SystemNames.WORLD) as WorldManager if screen.has_node("/root/Game") else null
		if world == null:
			return

		var map_sys: RefCounted = world.call("map_system") if world.has_method("map_system") else null
		if map_sys == null:
			return

		# Converte clique de tela para espaço normalizado [0.0, 1.0]
		var c_size := size
		var center := c_size * 0.5 + pan_offset
		var base_size := minf(c_size.x, c_size.y) * 0.92 * zoom
		var top_left := center - Vector2(base_size, base_size) * 0.5

		var norm_click := Vector2(
			(click_pos.x - top_left.x) / base_size,
			(click_pos.y - top_left.y) / base_size
		)

		# Verifica colisão com regiões
		var regions: Dictionary = map_sys.regions_data() if map_sys != null else {}
		for rid_str in regions.keys():
			var r_data: Dictionary = regions[rid_str]
			var carto: Dictionary = r_data.get("cartographic_position", {})
			var bbox: Array = carto.get("normalized_bbox", [0, 0, 0, 0])
			if norm_click.x >= bbox[0] and norm_click.x <= bbox[2] and norm_click.y >= bbox[1] and norm_click.y <= bbox[3]:
				screen.select_region(StringName(rid_str))
				break

	func _draw() -> void:
		var c_size := size
		if c_size.x <= 10 or c_size.y <= 10:
			return

		var center := c_size * 0.5 + pan_offset
		var base_size := minf(c_size.x, c_size.y) * 0.92 * zoom
		var top_left := center - Vector2(base_size, base_size) * 0.5

		# 1. Fundo de Pergaminho e Mar da Cicatriz
		draw_rect(Rect2(top_left, Vector2(base_size, base_size)), Color(0.12, 0.10, 0.14, 0.95))

		# Oceano Central: Mar da Cicatriz
		var ocean_rect := Rect2(top_left + Vector2(base_size * 0.32, base_size * 0.32), Vector2(base_size * 0.36, base_size * 0.36))
		draw_rect(ocean_rect, Color(0.08, 0.12, 0.16, 0.85))
		draw_rect(ocean_rect, Color(0.2, 0.35, 0.45, 0.5), false, 2.0)
		draw_string(ThemeDB.fallback_font, ocean_rect.position + Vector2(ocean_rect.size.x * 0.15, ocean_rect.size.y * 0.5), "MAR DA CICATRIZ", HORIZONTAL_ALIGNMENT_LEFT, -1, int(11 * zoom), Color(0.4, 0.65, 0.75, 0.7))

		var world := Game.get_system(SystemNames.WORLD) as WorldManager if screen != null and screen.has_node("/root/Game") else null
		var map_sys := world.map_system() if world != null else null

		# 2. Desenho das Rotas (Terrestres, Marítimas e Conduítes Dimensionais)
		if filters.get("routes", true) and map_sys != null:
			_draw_routes(top_left, base_size, map_sys)

		# 3. Desenho dos 4 Continentes e 40 Regiões
		if map_sys != null:
			_draw_regions(top_left, base_size, map_sys)

		# 4. Hell Forge (Nexus Dimensional)
		if filters.get("portals", true):
			var hf_center := top_left + Vector2(base_size * 0.5, base_size * 0.5)
			var hf_radius := 18.0 * zoom
			draw_circle(hf_center, hf_radius, Color(0.7, 0.15, 0.05, 0.9))
			draw_arc(hf_center, hf_radius + 4.0 * zoom, 0, TAU, 32, Color(1.0, 0.65, 0.2), 2.0)
			draw_circle(hf_center, hf_radius * 0.45, Color(1.0, 0.85, 0.4))
			draw_string(ThemeDB.fallback_font, hf_center + Vector2(-40 * zoom, hf_radius + 14 * zoom), "HELL FORGE", HORIZONTAL_ALIGNMENT_LEFT, -1, int(10 * zoom), Color(1.0, 0.75, 0.3))

		# 5. Marcadores de Aliados (Multiplayer)
		if filters.get("allies", true) and map_sys != null:
			for ally in map_sys.get_party_member_positions():
				var a_pos: Vector3 = ally.get("position", Vector3.ZERO)
				var a_rid: StringName = ally.get("region_id", &"REG-001")
				var a_norm: Vector2 = map_sys.world_to_world_map_normalized(a_rid, a_pos)
				var a_screen: Vector2 = top_left + a_norm * base_size
				draw_circle(a_screen, 6.0 * zoom, Color(0.2, 0.7, 1.0))
				draw_arc(a_screen, 8.0 * zoom, 0, TAU, 16, Color(1, 1, 1), 1.5)
				draw_string(ThemeDB.fallback_font, a_screen + Vector2(8, 4), String(ally.get("name", "Aliado")), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.7, 0.9, 1.0))

		# 6. Posição do Jogador Local
		if filters.get("player", true) and map_sys != null and world != null:
			var cur_rid: StringName = world.current_region_id()
			if not cur_rid.is_empty():
				var p_norm: Vector2 = map_sys.world_to_world_map_normalized(cur_rid, Vector3.ZERO)
				var p_screen: Vector2 = top_left + p_norm * base_size
				draw_circle(p_screen, 7.0 * zoom, Color(1.0, 0.85, 0.2))
				draw_arc(p_screen, 11.0 * zoom, 0, TAU, 24, Color(1.0, 1.0, 1.0), 2.0)
				draw_string(ThemeDB.fallback_font, p_screen + Vector2(10, 4), "VOCÊ", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.9, 0.4))

		# 6.5 Alerta de Invasão de Azaroth (World Boss Hazard — PROMPT 02 & PROMPT 03)
		var bosses := Game.get_system(SystemNames.BOSSES) as Node if screen != null and screen.has_node("/root/Game") else null
		if bosses != null and bosses.has_method("world_boss_system"):
			var wb: Node = bosses.call("world_boss_system")
			if wb != null and (bool(wb.call("is_one_hour_alert_issued")) or bool(wb.call("is_warning")) or bool(wb.call("is_active")) or bool(wb.call("is_defeated")) or bool(wb.call("is_retreated"))):
				var target_rid: StringName = wb.call("get_threatened_region_id")
				var target_pos: Vector3 = wb.call("invasion_position")
				var wb_norm: Vector2 = map_sys.world_to_world_map_normalized(target_rid, target_pos) if map_sys != null else Vector2(0.2, 0.2)
				var wb_screen: Vector2 = top_left + wb_norm * base_size
				var t := Time.get_ticks_msec() / 1000.0
				var p := 0.5 + 0.5 * sin(t * 4.0)

				var is_act: bool = bool(wb.call("is_active"))
				var is_warn: bool = bool(wb.call("is_warning"))
				var is_def: bool = bool(wb.call("is_defeated"))
				var is_ret: bool = bool(wb.call("is_retreated"))

				if is_act:
					var outer_r := (18.0 + 8.0 * p) * zoom
					draw_circle(wb_screen, outer_r, Color(1.0, 0.1, 0.05, 0.45 + 0.25 * p))
					draw_arc(wb_screen, outer_r, 0, TAU, 32, Color(1.0, 0.8, 0.1, 0.95), 2.5)
					draw_circle(wb_screen, 8.0 * zoom, Color(0.8, 0.05, 0.05))
					var hp_ratio: float = float(wb.call("hp_percentage"))
					draw_rect(Rect2(wb_screen + Vector2(-15 * zoom, -14 * zoom), Vector2(30 * zoom, 4 * zoom)), Color(0.1, 0.1, 0.1, 0.8))
					draw_rect(Rect2(wb_screen + Vector2(-15 * zoom, -14 * zoom), Vector2(30 * zoom * hp_ratio, 4 * zoom)), Color(0.9, 0.15, 0.1))
					draw_string(ThemeDB.fallback_font, wb_screen + Vector2(14 * zoom, 4 * zoom), "💀 AZAROTH DESPERTO (%.0f%%)" % (hp_ratio * 100.0), HORIZONTAL_ALIGNMENT_LEFT, -1, int(11 * zoom), Color(1.0, 0.3, 0.2))
				elif is_warn:
					var outer_r := (22.0 + 10.0 * p) * zoom
					draw_circle(wb_screen, outer_r, Color(0.95, 0.3, 0.0, 0.35 + 0.25 * p))
					draw_arc(wb_screen, outer_r, 0, TAU, 28, Color(1.0, 0.5, 0.0, 0.9), 2.0)
					draw_circle(wb_screen, 7.0 * zoom, Color(1.0, 0.4, 0.0))
					draw_string(ThemeDB.fallback_font, wb_screen + Vector2(12 * zoom, 4 * zoom), "🔥 RUPTURA IMINENTE (15M)", HORIZONTAL_ALIGNMENT_LEFT, -1, int(10 * zoom), Color(1.0, 0.6, 0.2))
				elif is_def:
					draw_circle(wb_screen, 10.0 * zoom, Color(0.2, 0.9, 0.4, 0.4))
					draw_arc(wb_screen, 12.0 * zoom, 0, TAU, 20, Color(0.3, 1.0, 0.5, 0.8), 2.0)
					draw_string(ThemeDB.fallback_font, wb_screen + Vector2(12 * zoom, 4 * zoom), "✨ SELO RESTAURADO", HORIZONTAL_ALIGNMENT_LEFT, -1, int(10 * zoom), Color(0.4, 1.0, 0.6))
				elif is_ret:
					draw_circle(wb_screen, 8.0 * zoom, Color(0.5, 0.2, 0.6, 0.4))
					draw_string(ThemeDB.fallback_font, wb_screen + Vector2(12 * zoom, 4 * zoom), "🌑 FENDA COLAPSADA", HORIZONTAL_ALIGNMENT_LEFT, -1, int(10 * zoom), Color(0.7, 0.5, 0.8))
				else:
					var outer_r := (14.0 + 6.0 * p) * zoom
					draw_circle(wb_screen, outer_r, Color(0.9, 0.2, 0.0, 0.35 + 0.2 * p))
					draw_arc(wb_screen, outer_r, 0, TAU, 24, Color(1.0, 0.3, 0.1, 0.8), 2.0)
					draw_circle(wb_screen, 6.0 * zoom, Color(1.0, 0.2, 0.1))
					draw_string(ThemeDB.fallback_font, wb_screen + Vector2(12 * zoom, 4 * zoom), "⚠️ ALERTA 1H: FENDA ABISSAL", HORIZONTAL_ALIGNMENT_LEFT, -1, int(10 * zoom), Color(1.0, 0.4, 0.2))

		# 7. Moldura Ornamental e Rosa dos Ventos
		draw_rect(Rect2(top_left, Vector2(base_size, base_size)), Color(0.45, 0.38, 0.25), false, 3.0)
		_draw_compass_rose(top_left + Vector2(45, 45))

	func _draw_regions(top_left: Vector2, base_size: float, map_sys: RefCounted) -> void:
		var regions: Dictionary = map_sys.regions_data() if map_sys != null else {}
		var bosses := Game.get_system(SystemNames.BOSSES) as Node if screen != null and screen.has_node("/root/Game") else null

		for rid_str in regions.keys():
			var r_data: Dictionary = regions[rid_str]
			var rid := StringName(rid_str)
			var carto: Dictionary = r_data.get("cartographic_position", {})
			var poly: Array = carto.get("polygon_vertices", [])
			var center_arr: Array = carto.get("normalized_center", [0.5, 0.5])
			var center_screen := top_left + Vector2(float(center_arr[0]), float(center_arr[1])) * base_size

			var is_discovered: bool = bool(map_sys.is_region_discovered(rid))
			var is_selected: bool = (screen != null and screen._selected_region_id == rid)

			# Destaque de ameaça de invasão na borda da região
			var is_threatened := false
			if bosses != null and bosses.has_method("world_boss_system"):
				var wb_node: Node = bosses.call("world_boss_system")
				if wb_node != null and wb_node.call("get_threatened_region_id") == rid and (bool(wb_node.call("is_one_hour_alert_issued")) or bool(wb_node.call("is_warning")) or bool(wb_node.call("is_active"))):
					is_threatened = true

			# Cor por continente
			var cont_id := String(r_data.get("continent_id", "CONT-01"))
			var base_col: Color
			match cont_id:
				"CONT-01": base_col = Color(0.85, 0.35, 0.25) # Veyrath
				"CONT-02": base_col = Color(0.3, 0.75, 0.45) # Sylvaran
				"CONT-03": base_col = Color(0.85, 0.7, 0.25) # Khar-Duum
				"CONT-04": base_col = Color(0.35, 0.65, 0.95) # Nhal'Kora
				_: base_col = Color(0.7, 0.7, 0.7)

			var fill_col: Color
			if is_discovered or not filters.get("fog_of_war", true):
				fill_col = Color(base_col.r, base_col.g, base_col.b, 0.35 if not is_selected else 0.65)
			else:
				fill_col = Color(0.06, 0.05, 0.07, 0.85) # Névoa de Exploração

			# Desenho do polígono regional
			if poly.size() >= 3:
				var pts: PackedVector2Array = []
				for v in poly:
					pts.append(top_left + Vector2(float(v[0]), float(v[1])) * base_size)
				draw_colored_polygon(pts, fill_col)
				var line_col := Color(1.0, 0.9, 0.4) if is_selected else Color(base_col.r, base_col.g, base_col.b, 0.8)
				var line_width := 2.5 if is_selected else 1.2
				if is_threatened:
					var tp := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 250.0)
					line_col = Color(1.0, 0.2 + 0.3 * tp, 0.1, 0.95)
					line_width = 3.5
				draw_polyline(pts, line_col, line_width)
				draw_line(pts[pts.size() - 1], pts[0], line_col, line_width)

			# Rótulo da região
			if zoom >= 0.9:
				var lbl_text := "%s" % String(r_data.get("name", rid_str))
				if not is_discovered and filters.get("fog_of_war", true):
					lbl_text = "??? (%s)" % rid_str
				var font_size := int(clampf(9.0 * zoom, 8.0, 14.0))
				draw_string(ThemeDB.fallback_font, center_screen + Vector2(-30, 0), lbl_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(0.95, 0.9, 0.8))

	func _draw_routes(top_left: Vector2, base_size: float, map_sys: RefCounted) -> void:
		var regions: Dictionary = map_sys.regions_data() if map_sys != null else {}
		var hf_screen := top_left + Vector2(base_size * 0.5, base_size * 0.5)

		for rid_str in regions.keys():
			var r_data: Dictionary = regions[rid_str]
			var carto: Dictionary = r_data.get("cartographic_position", {})
			var c1: Array = carto.get("normalized_center", [0.5, 0.5])
			var p1 := top_left + Vector2(float(c1[0]), float(c1[1])) * base_size

			# Conexões terrestres
			var conns: Dictionary = r_data.get("connections", {})
			for neighbor in conns.get("terrestrial_neighbors", []):
				var n_data: Dictionary = regions.get(neighbor, {})
				if not n_data.is_empty():
					var n_carto: Dictionary = n_data.get("cartographic_position", {})
					var c2: Array = n_carto.get("normalized_center", [0.5, 0.5])
					var p2 := top_left + Vector2(float(c2[0]), float(c2[1])) * base_size
					draw_line(p1, p2, Color(0.35, 0.28, 0.2, 0.4), 1.0)

			# Conexões marítimas pelo Mar da Cicatriz
			for m_route in conns.get("maritime_routes", []):
				var m_data: Dictionary = regions.get(m_route, {})
				if not m_data.is_empty():
					var m_carto: Dictionary = m_data.get("cartographic_position", {})
					var c2: Array = m_carto.get("normalized_center", [0.5, 0.5])
					var p2 := top_left + Vector2(float(c2[0]), float(c2[1])) * base_size
					draw_dashed_line(p1, p2, Color(0.2, 0.5, 0.6, 0.4), 1.2, 4.0)

			# Conduítes dimensionais para Hell Forge
			for p in conns.get("dimensional_portals", []):
				draw_dashed_line(p1, hf_screen, Color(0.85, 0.35, 0.1, 0.45), 1.5, 5.0)

	func _draw_compass_rose(origin: Vector2) -> void:
		var size_cr := 24.0
		# Braços cardeais
		draw_line(origin - Vector2(0, size_cr), origin + Vector2(0, size_cr), Color(0.85, 0.7, 0.35), 2.0)
		draw_line(origin - Vector2(size_cr, 0), origin + Vector2(size_cr, 0), Color(0.85, 0.7, 0.35), 2.0)
		draw_string(ThemeDB.fallback_font, origin - Vector2(4, size_cr + 2), "N", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(1, 0.9, 0.6))
		draw_string(ThemeDB.fallback_font, origin + Vector2(size_cr + 2, 4), "L", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(1, 0.9, 0.6))
		draw_string(ThemeDB.fallback_font, origin + Vector2(-4, size_cr + 12), "S", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(1, 0.9, 0.6))
		draw_string(ThemeDB.fallback_font, origin - Vector2(size_cr + 12, -4), "O", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(1, 0.9, 0.6))
		draw_circle(origin, 3.0, Color(1.0, 0.85, 0.3))
