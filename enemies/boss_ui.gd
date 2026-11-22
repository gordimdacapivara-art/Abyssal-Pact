class_name BossUI
extends Control
## Interface de chefe compartilhada (barra segmentada por fases, nome, fase
## ativa e barra de conjuração). Configuração vem de BossData.boss_ui:
## {bar_style, name_color, phase_markers, show_cast_bar}.
##
## É uma tela de DADOS: nenhuma arte final. A barra é uma ProgressBar estilizada
## por código e os marcadores de fase são textuais — o layout definitivo de UI
## (UI_AND_MENUS.md) continua pendente.

var _data: BossData = null
var _built := false
var _name_label: Label = null
var _health_bar: ProgressBar = null
var _phase_label: Label = null
var _cast_bar: ProgressBar = null
var _status_label: Label = null

func _ready() -> void:
	_build()

func setup(data: BossData) -> void:
	_data = data
	_build()
	_refresh()

func _build() -> void:
	if _built:
		return
	_built = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_TOP_WIDE)
	offset_left = 40.0
	offset_right = -40.0
	offset_top = 16.0
	offset_bottom = 150.0

	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	panel.add_child(vbox)

	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 22)
	_name_label.add_theme_color_override("font_color", Color(0.85, 0.72, 0.3))
	vbox.add_child(_name_label)

	_health_bar = ProgressBar.new()
	_health_bar.custom_minimum_size = Vector2(0, 24)
	_health_bar.show_percentage = false
	_health_bar.max_value = 1.0
	_health_bar.value = 1.0
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.06, 0.05, 0.07, 1.0)
	background.border_color = Color(0.4, 0.33, 0.2, 1.0)
	background.set_border_width_all(2)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.62, 0.16, 0.18, 1.0)
	fill.border_color = Color(0.85, 0.6, 0.25, 1.0)
	fill.set_border_width_all(1)
	_health_bar.add_theme_stylebox_override("background", background)
	_health_bar.add_theme_stylebox_override("fill", fill)
	vbox.add_child(_health_bar)

	_phase_label = Label.new()
	_phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_phase_label.add_theme_color_override("font_color", Color(0.78, 0.72, 0.62))
	vbox.add_child(_phase_label)

	_cast_bar = ProgressBar.new()
	_cast_bar.custom_minimum_size = Vector2(0, 10)
	_cast_bar.show_percentage = false
	_cast_bar.max_value = 1.0
	_cast_bar.value = 0.0
	_cast_bar.visible = false
	vbox.add_child(_cast_bar)

	_status_label = Label.new()
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_color_override("font_color", Color(0.9, 0.45, 0.35))
	vbox.add_child(_status_label)

func _refresh() -> void:
	if _data == null or _health_bar == null:
		return
	_name_label.text = _data.display_name
	var config := _data.boss_ui
	var color_hex := String(config.get("name_color", "#c9a227"))
	_name_label.add_theme_color_override("font_color", Color.from_string(color_hex, Color(0.85, 0.72, 0.3)))
	_health_bar.max_value = maxf(_data.health(), 1.0)
	_health_bar.value = _data.health()
	_phase_label.text = "Fase 1/%d" % _data.phase_count
	_cast_bar.visible = bool(config.get("show_cast_bar", false)) and false
	_status_label.text = ""

## Atualiza a barra de vida (chamado pelo BossEncounter a cada dano).
func update_health(current: float, maximum: float) -> void:
	if _health_bar == null:
		return
	_health_bar.max_value = maxf(maximum, 1.0)
	_health_bar.value = clampf(current, 0.0, maximum)
	if current <= 0.0:
		show_defeated()

func set_phase(index: int, behavior: StringName) -> void:
	if _phase_label == null or _data == null:
		return
	_phase_label.text = "Fase %d/%d — %s" % [index, _data.phase_count, String(behavior)]
	var fill := _health_bar.get_theme_stylebox("fill") as StyleBoxFlat
	if fill != null:
		fill.bg_color = Color(0.75, 0.12, 0.14) if index >= 3 else Color(0.62, 0.16, 0.18)

func set_cast(progress: float) -> void:
	if _cast_bar == null:
		return
	var show_cast := bool(_data.boss_ui.get("show_cast_bar", false)) if _data != null else false
	_cast_bar.visible = show_cast and progress > 0.0
	_cast_bar.value = clampf(progress, 0.0, 1.0)

func show_defeated() -> void:
	if _health_bar != null:
		_health_bar.value = 0.0
	if _status_label != null:
		_status_label.text = "DERROTADO"
	if _name_label != null:
		_name_label.add_theme_color_override("font_color", Color(0.55, 0.5, 0.45))

func boss_name() -> String:
	return "" if _data == null else _data.display_name

func phase_text() -> String:
	return "" if _phase_label == null else _phase_label.text
