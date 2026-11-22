class_name StatComparisonCard
extends PanelContainer
## Painel de comparação de atributos entre equipamento atual e item selecionado.

var _vbox: VBoxContainer
var _title_label: Label
var _content_box: VBoxContainer

func _init() -> void:
	custom_minimum_size = Vector2(240, 160)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.05, 0.08, 0.95)
	style.border_color = Color(0.35, 0.3, 0.22, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	add_theme_stylebox_override("panel", style)

	_vbox = VBoxContainer.new()
	_vbox.add_theme_constant_override("separation", 6)
	add_child(_vbox)

	_title_label = Label.new()
	_title_label.text = "COMPARAÇÃO DE ATRIBUTOS"
	_title_label.add_theme_color_override("font_color", Color(0.9, 0.82, 0.65))
	_title_label.add_theme_font_size_override("font_size", 12)
	_vbox.add_child(_title_label)

	_content_box = VBoxContainer.new()
	_content_box.add_theme_constant_override("separation", 4)
	_vbox.add_child(_content_box)

func compare(current_item: EquipmentData, candidate_item: EquipmentData) -> void:
	for child in _content_box.get_children():
		child.queue_free()

	if candidate_item == null and current_item == null:
		var empty_lbl := Label.new()
		empty_lbl.text = "Selecione um item para comparar."
		empty_lbl.add_theme_color_override("font_color", Color(0.5, 0.45, 0.4))
		empty_lbl.add_theme_font_size_override("font_size", 11)
		_content_box.add_child(empty_lbl)
		return

	var current_stats: Dictionary = current_item.stats if current_item != null else {}
	var cand_stats: Dictionary = candidate_item.stats if candidate_item != null else {}

	var all_stat_keys: Array = []
	for k in current_stats.keys():
		if not all_stat_keys.has(k):
			all_stat_keys.append(k)
	for k in cand_stats.keys():
		if not all_stat_keys.has(k):
			all_stat_keys.append(k)

	if all_stat_keys.is_empty():
		var none_lbl := Label.new()
		none_lbl.text = "Itens sem atributos modificadores diretos."
		none_lbl.add_theme_color_override("font_color", Color(0.6, 0.55, 0.5))
		none_lbl.add_theme_font_size_override("font_size", 11)
		_content_box.add_child(none_lbl)
		return

	for key: String in all_stat_keys:
		var cur_val: float = float(current_stats.get(key, 0.0))
		var new_val: float = float(cand_stats.get(key, 0.0))
		var delta: float = new_val - cur_val

		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_lbl := Label.new()
		name_lbl.text = key.replace("_", " ").capitalize()
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_font_size_override("font_size", 11)
		row.add_child(name_lbl)

		var val_lbl := Label.new()
		val_lbl.text = "%.0f → %.0f" % [cur_val, new_val]
		val_lbl.add_theme_font_size_override("font_size", 11)
		val_lbl.add_theme_color_override("font_color", Color(0.8, 0.75, 0.7))
		row.add_child(val_lbl)

		var delta_lbl := Label.new()
		if delta > 0.0:
			delta_lbl.text = " (+%.0f)" % delta
			delta_lbl.add_theme_color_override("font_color", Color(0.3, 0.85, 0.4))
		elif delta < 0.0:
			delta_lbl.text = " (%.0f)" % delta
			delta_lbl.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
		else:
			delta_lbl.text = " (=)"
			delta_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		delta_lbl.add_theme_font_size_override("font_size", 11)
		row.add_child(delta_lbl)

		_content_box.add_child(row)
