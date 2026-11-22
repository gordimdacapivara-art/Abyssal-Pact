class_name MinimapHUD
extends Control
## MinimapHUD — Componente de Visualização Cartográfica de Nível 3 (Minimapa / Radar Tático).
##
## Apresenta:
##   - Posição do jogador no centro do radar tático;
##   - Direção e orientação angular (Yaw / agulha da bússola);
##   - Estruturas próximas (cidades, masmorras, chefes, portais e gates);
##   - Aliados do grupo em mundos privados multiplayer (até 8 participantes);
##   - Inimigos e criaturas detectadas na vizinhança tática;
##   - Marcadores pessoais e waypoints de navegação;
##   - Objetivos de missões ativas na vizinhança;
##   - Controles de zoom, exibição de coordenadas (X, Z) e atalho para o Mapa Regional.

@export var radar_range_meters: float = 120.0
@export var min_range: float = 60.0
@export var max_range: float = 250.0

var _radar_control: MinimapRadar
var _lbl_region: Label
var _lbl_coords: Label
var _btn_zoom_in: Button
var _btn_zoom_out: Button
var _btn_open_map: Button
var _btn_toggle: Button

var _player_node: Node3D = null
var _player_pos: Vector3 = Vector3.ZERO
var _player_yaw: float = 0.0
var _current_region_id: StringName = &"REG-001"
var _detected_enemies: Array[Dictionary] = []

func _ready() -> void:
	_build_ui()
	set_process(true)

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	custom_minimum_size = Vector2(210, 260)
	set_anchors_preset(Control.PRESET_TOP_RIGHT)
	offset_left = -225
	offset_right = -15
	offset_top = 15
	offset_bottom = 275

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 4)
	add_child(vbox)

	# Barra de Cabeçalho (Região e Coordenadas)
	var header_panel := PanelContainer.new()
	vbox.add_child(header_panel)

	var header_hbox := HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 6)
	header_panel.add_child(header_hbox)

	_lbl_region = Label.new()
	_lbl_region.text = "Cinzália"
	_lbl_region.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lbl_region.add_theme_font_size_override("font_size", 11)
	_lbl_region.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
	header_hbox.add_child(_lbl_region)

	_lbl_coords = Label.new()
	_lbl_coords.text = "X: 0  Z: 0"
	_lbl_coords.add_theme_font_size_override("font_size", 10)
	_lbl_coords.add_theme_color_override("font_color", Color(0.7, 0.65, 0.55))
	header_hbox.add_child(_lbl_coords)

	# Controle do Radar Circular
	var radar_box := CenterContainer.new()
	vbox.add_child(radar_box)

	_radar_control = MinimapRadar.new()
	_radar_control.hud = self
	_radar_control.custom_minimum_size = Vector2(190, 190)
	radar_box.add_child(_radar_control)

	# Barra de Controles Rápidos (Zoom, Abrir Mapa, Toggle)
	var ctrl_hbox := HBoxContainer.new()
	ctrl_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	ctrl_hbox.add_theme_constant_override("separation", 6)
	vbox.add_child(ctrl_hbox)

	_btn_zoom_in = Button.new()
	_btn_zoom_in.text = "➕"
	_btn_zoom_in.tooltip_text = "Aumentar Zoom do Radar"
	_btn_zoom_in.pressed.connect(_on_zoom_in_pressed)
	ctrl_hbox.add_child(_btn_zoom_in)

	_btn_zoom_out = Button.new()
	_btn_zoom_out.text = "➖"
	_btn_zoom_out.tooltip_text = "Diminuir Zoom do Radar"
	_btn_zoom_out.pressed.connect(_on_zoom_out_pressed)
	ctrl_hbox.add_child(_btn_zoom_out)

	_btn_open_map = Button.new()
	_btn_open_map.text = "🗺️ Mapa"
	_btn_open_map.tooltip_text = "Abrir Mapa Regional [M]"
	_btn_open_map.pressed.connect(_on_open_map_pressed)
	ctrl_hbox.add_child(_btn_open_map)

func _process(_delta: float) -> void:
	_update_tracking()
	if _radar_control != null:
		_radar_control.queue_redraw()

func _update_tracking() -> void:
	var world := Game.get_system(SystemNames.WORLD) as WorldManager if has_node("/root/Game") else null
	if world != null:
		_current_region_id = world.current_region_id()
		var reg := world.get_region(_current_region_id)
		if reg != null and _lbl_region != null:
			_lbl_region.text = reg.display_name

	# Rastreia nó do jogador ativo se presente na cena
	if _player_node == null or not is_instance_valid(_player_node):
		var tree := get_tree()
		if tree != null:
			var players := tree.get_nodes_in_group("player")
			if not players.is_empty() and players[0] is Node3D:
				_player_node = players[0] as Node3D

	if _player_node != null and is_instance_valid(_player_node):
		_player_pos = _player_node.global_position
		_player_yaw = _player_node.rotation.y
		if _lbl_coords != null:
			_lbl_coords.text = "X: %d  Z: %d" % [int(_player_pos.x), int(_player_pos.z)]

		# Explora gradualmente o mapa na posição atual
		if world != null and world.map_system() != null:
			world.map_system().explore_position(_current_region_id, _player_pos, 35.0)

	# Atualiza inimigos detectados na árvore (grupos "enemies" ou "demons")
	_scan_nearby_enemies()

func _scan_nearby_enemies() -> void:
	_detected_enemies.clear()
	var tree := get_tree()
	if tree == null:
		return

	var enemy_nodes := tree.get_nodes_in_group("enemies")
	for node in enemy_nodes:
		if node is Node3D and is_instance_valid(node):
			var n3d := node as Node3D
			var dist := _player_pos.distance_to(n3d.global_position)
			if dist <= radar_range_meters:
				_detected_enemies.append({
					"name": n3d.name,
					"position": n3d.global_position,
					"is_boss": n3d.is_in_group("bosses")
				})

func _on_zoom_in_pressed() -> void:
	radar_range_meters = clampf(radar_range_meters * 0.8, min_range, max_range)
	EventBus.minimap_zoom_changed.emit(radar_range_meters)

func _on_zoom_out_pressed() -> void:
	radar_range_meters = clampf(radar_range_meters * 1.25, min_range, max_range)
	EventBus.minimap_zoom_changed.emit(radar_range_meters)

func _on_open_map_pressed() -> void:
	var ui := Game.get_system(SystemNames.UI) as UIManager if has_node("/root/Game") else null
	if ui != null:
		ui.open_screen(&"regional_map", {"region_id": _current_region_id})

func set_radar_range(range_meters: float) -> void:
	radar_range_meters = clampf(range_meters, min_range, max_range)

func set_mock_player_tracking(pos: Vector3, yaw: float, region_id: StringName = &"REG-001") -> void:
	_player_pos = pos
	_player_yaw = yaw
	_current_region_id = region_id
	if _lbl_coords != null:
		_lbl_coords.text = "X: %d  Z: %d" % [int(pos.x), int(pos.z)]
	if _radar_control != null:
		_radar_control.queue_redraw()

# ----------------------------------------------------------- RADAR CONTROL --

class MinimapRadar extends Control:
	var hud: MinimapHUD

	func _draw() -> void:
		if hud == null:
			return

		var c_size := size
		var center := c_size * 0.5
		var radius: float = minf(c_size.x, c_size.y) * 0.46
		var range_m := hud.radar_range_meters

		# 1. Fundo Circular de Pergaminho Noturno
		draw_circle(center, radius, Color(0.08, 0.07, 0.10, 0.88))
		draw_arc(center, radius * 0.5, 0, TAU, 32, Color(0.25, 0.22, 0.2, 0.35), 1.0)

		# Linhas Cardeais
		draw_line(center - Vector2(radius, 0), center + Vector2(radius, 0), Color(0.3, 0.25, 0.2, 0.3), 1.0)
		draw_line(center - Vector2(0, radius), center + Vector2(0, radius), Color(0.3, 0.25, 0.2, 0.3), 1.0)

		var world := Game.get_system(SystemNames.WORLD) as WorldManager if hud.has_node("/root/Game") else null
		var map_sys := world.map_system() if world != null else null

		# 2. Estruturas Próximas (Settlements, Dungeons, Bosses, Portais, Gates)
		if world != null:
			var markers := world.get_region_markers(hud._current_region_id)
			for m in markers:
				var pos_3d: Vector3 = m.get("position", Vector3.ZERO)
				var rel := pos_3d - hud._player_pos
				var dist_2d := Vector2(rel.x, rel.z).length()
				if dist_2d <= range_m:
					var p_2d := center + Vector2(rel.x / range_m, rel.z / range_m) * radius
					var mtype := String(m.get("type", ""))
					var col: Color
					match mtype:
						"city", "settlement": col = Color(0.3, 0.85, 0.45)
						"dungeon": col = Color(0.85, 0.35, 0.35)
						"boss", "boss_arena": col = Color(1.0, 0.25, 0.2)
						"portal": col = Color(0.4, 0.75, 1.0)
						"gate": col = Color(0.9, 0.8, 0.3)
						_: col = Color(0.7, 0.7, 0.7)
					draw_circle(p_2d, 4.5, col)

		# 3. Marcadores Pessoais do Jogador
		if map_sys != null:
			for pm in map_sys.get_personal_markers(hud._current_region_id):
				var pm_pos: Vector3 = pm.get("position", Vector3.ZERO)
				var rel := pm_pos - hud._player_pos
				if Vector2(rel.x, rel.z).length() <= range_m:
					var p_2d := center + Vector2(rel.x / range_m, rel.z / range_m) * radius
					draw_circle(p_2d, 5.0, Color.GOLD)
					draw_arc(p_2d, 7.0, 0, TAU, 12, Color(1, 1, 1), 1.2)

		# 4. Aliados no Grupo (Multiplayer)
		if map_sys != null:
			for ally in map_sys.get_party_member_positions(hud._current_region_id):
				var a_pos: Vector3 = ally.get("position", Vector3.ZERO)
				var rel := a_pos - hud._player_pos
				if Vector2(rel.x, rel.z).length() <= range_m:
					var p_2d := center + Vector2(rel.x / range_m, rel.z / range_m) * radius
					draw_circle(p_2d, 5.0, Color(0.25, 0.8, 1.0))
					draw_arc(p_2d, 7.0, 0, TAU, 12, Color(1, 1, 1), 1.2)

		# 5. Inimigos Detectados (Blips Vermelhos)
		for enemy in hud._detected_enemies:
			var e_pos: Vector3 = enemy.get("position", Vector3.ZERO)
			var rel := e_pos - hud._player_pos
			var p_2d := center + Vector2(rel.x / range_m, rel.z / range_m) * radius
			var is_boss: bool = enemy.get("is_boss", false)
			var e_col := Color(1.0, 0.2, 0.2) if is_boss else Color(0.85, 0.3, 0.2)
			var e_radius := 5.0 if is_boss else 3.5
			draw_circle(p_2d, e_radius, e_col)

		# 5.5 Invasão de Azaroth e Fendas Demoníacas (PROMPT 03, 04, 05)
		var bosses := Game.get_system(SystemNames.BOSSES) as Node if hud.has_node("/root/Game") else null
		if bosses != null and bosses.has_method("world_boss_system"):
			var wb: Node = bosses.call("world_boss_system")
			if wb != null and wb.has_method("get_threatened_region_id"):
				var threatened_reg: StringName = wb.call("get_threatened_region_id")
				if threatened_reg == hud._current_region_id:
					var is_act: bool = bool(wb.call("is_active"))
					var is_wrn: bool = bool(wb.call("is_warning"))
					if is_act or is_wrn:
						var wb_pos: Vector3 = wb.call("invasion_position")
						var rel_wb := wb_pos - hud._player_pos
						var dist_wb := Vector2(rel_wb.x, rel_wb.z).length()
						if dist_wb <= range_m:
							var p_wb := center + Vector2(rel_wb.x / range_m, rel_wb.z / range_m) * radius
							draw_circle(p_wb, 7.0, Color(0.9, 0.1, 0.1, 0.95))
							draw_arc(p_wb, 10.0, 0, TAU, 16, Color(1.0, 0.4, 0.2), 1.8)
							draw_string(ThemeDB.fallback_font, p_wb + Vector2(-6, 4), "💀", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color.WHITE)
						else:
							# Ponteiro direcional na borda do radar apontando para Azaroth
							var dir_wb := Vector2(rel_wb.x, rel_wb.z).normalized()
							var edge_pt := center + dir_wb * (radius - 8.0)
							draw_circle(edge_pt, 4.0, Color(1.0, 0.2, 0.1, 0.9))
							draw_line(edge_pt, edge_pt + dir_wb * 6.0, Color(1.0, 0.8, 0.2), 2.0)

					# Fendas Demoníacas próximas
					if wb.has_method("get_invasion_system"):
						var inv_sys: Node = wb.call("get_invasion_system")
						if inv_sys != null and inv_sys.has_method("get_active_fissures"):
							for f in inv_sys.call("get_active_fissures"):
								if f is Node3D and is_instance_valid(f):
									var f_pos: Vector3 = f.global_position if f.is_inside_tree() else f.position
									var rel_f := f_pos - hud._player_pos
									var dist_f := Vector2(rel_f.x, rel_f.z).length()
									if dist_f <= range_m:
										var p_f := center + Vector2(rel_f.x / range_m, rel_f.z / range_m) * radius
										draw_circle(p_f, 4.0, Color(0.75, 0.15, 0.35, 0.85))
										draw_arc(p_f, 6.0, 0, TAU, 12, Color(1.0, 0.3, 0.5), 1.0)

		# 6. Jogador no Centro com Seta de Orientação
		draw_circle(center, 5.5, Color(1.0, 0.85, 0.25))
		draw_arc(center, 7.5, 0, TAU, 16, Color(1, 1, 1), 1.5)

		# Seta de Visão / Direção
		var forward_dir := Vector2(-sin(hud._player_yaw), -cos(hud._player_yaw)).normalized()
		var arrow_tip := center + forward_dir * 14.0
		var arrow_left := center + forward_dir.rotated(2.5) * 6.0
		var arrow_right := center + forward_dir.rotated(-2.5) * 6.0
		var pts: PackedVector2Array = [arrow_tip, arrow_left, arrow_right]
		draw_colored_polygon(pts, Color(1.0, 0.9, 0.4))

		# 7. Moldura Externa Rúnica e Letras Cardeais
		draw_arc(center, radius, 0, TAU, 64, Color(0.55, 0.45, 0.3), 2.5)
		draw_string(ThemeDB.fallback_font, center + Vector2(-4, -radius + 12), "N", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(0.9, 0.8, 0.6))
		draw_string(ThemeDB.fallback_font, center + Vector2(radius - 14, 4), "L", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(0.9, 0.8, 0.6))
		draw_string(ThemeDB.fallback_font, center + Vector2(-4, radius - 4), "S", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(0.9, 0.8, 0.6))
		draw_string(ThemeDB.fallback_font, center + Vector2(-radius + 6, 4), "O", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(0.9, 0.8, 0.6))
