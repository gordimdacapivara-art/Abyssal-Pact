class_name AzarothPhaseCinematicBanner
extends Control
## AzarothPhaseCinematicBanner — Banner Cinematográfico de Transição de Fases de Azaroth (PROMPT 05).
##
## Exibe animação na tela com runas demoníacas, título épico da nova fase,
## pulsação de energia e anúncio de vitória final com restauração do selo abissal.

signal banner_animation_completed()

var _is_showing: bool = false
var _elapsed: float = 0.0
var _display_duration: float = Invariants.WORLD_BOSS_PHASE_TRANSITION_DURATION

var _title_text: String = ""
var _subtitle_text: String = ""
var _banner_color: Color = Color(1.0, 0.2, 0.1)
var _shake_intensity: float = 0.0

var _lbl_title: Label = null
var _lbl_subtitle: Label = null
var _panel_bg: ColorRect = null

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	anchor_right = 1.0
	anchor_bottom = 1.0

func _ready() -> void:
	_build_ui()
	_connect_signals()
	visible = false

func _build_ui() -> void:
	_panel_bg = ColorRect.new()
	_panel_bg.name = "Background"
	_panel_bg.color = Color(0.08, 0.02, 0.03, 0.0)
	_panel_bg.anchor_right = 1.0
	_panel_bg.anchor_bottom = 1.0
	_panel_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_panel_bg)

	var center_box := VBoxContainer.new()
	center_box.name = "CenterBox"
	center_box.alignment = BoxContainer.ALIGNMENT_CENTER
	center_box.anchor_left = 0.1
	center_box.anchor_right = 0.9
	center_box.anchor_top = 0.3
	center_box.anchor_bottom = 0.7
	center_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center_box)

	_lbl_title = Label.new()
	_lbl_title.name = "Title"
	_lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_title.add_theme_font_size_override("font_size", 34)
	_lbl_title.modulate = Color(1.0, 0.25, 0.15)
	center_box.add_child(_lbl_title)

	_lbl_subtitle = Label.new()
	_lbl_subtitle.name = "Subtitle"
	_lbl_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_subtitle.add_theme_font_size_override("font_size", 16)
	_lbl_subtitle.modulate = Color(0.9, 0.75, 0.5)
	center_box.add_child(_lbl_subtitle)

func _connect_signals() -> void:
	if not EventBus.azaroth_phase_cinematic_started.is_connected(_on_phase_cinematic_started):
		EventBus.azaroth_phase_cinematic_started.connect(_on_phase_cinematic_started)
	if not EventBus.azaroth_victory_cinematic_started.is_connected(_on_victory_cinematic_started):
		EventBus.azaroth_victory_cinematic_started.connect(_on_victory_cinematic_started)

func _process(delta: float) -> void:
	if not _is_showing:
		return

	_elapsed += delta
	var progress := clampf(_elapsed / _display_duration, 0.0, 1.0)

	# Curva de opacidade com pico no centro da transição
	var alpha := sin(progress * PI)
	if _panel_bg != null:
		_panel_bg.color = Color(0.08, 0.02, 0.03, alpha * 0.75)

	# Pulso e leve tremor visual
	_shake_intensity = alpha * 6.0
	var offset_x := (randf() - 0.5) * _shake_intensity
	var offset_y := (randf() - 0.5) * _shake_intensity
	position = Vector2(offset_x, offset_y)

	if _lbl_title != null:
		_lbl_title.modulate = _banner_color
		_lbl_title.modulate.a = alpha

	if _lbl_subtitle != null:
		_lbl_subtitle.modulate.a = alpha

	if _elapsed >= _display_duration:
		_is_showing = false
		visible = false
		position = Vector2.ZERO
		banner_animation_completed.emit()

func show_phase_banner(phase_idx: int, phase_name: String, duration: float = Invariants.WORLD_BOSS_PHASE_TRANSITION_DURATION) -> void:
	_title_text = "⚡ FASE %d: %s" % [phase_idx, phase_name.to_upper()]
	_subtitle_text = "O TITÃ CANALIZA A ENERGIA DO ABISMO — ADAPTEM SUAS TÁTICAS!"
	_banner_color = Color(1.0, 0.25, 0.1) if phase_idx < 4 else Color(1.0, 0.05, 0.25)
	_display_duration = duration
	_elapsed = 0.0
	_is_showing = true
	visible = true

	if _lbl_title != null:
		_lbl_title.text = _title_text
	if _lbl_subtitle != null:
		_lbl_subtitle.text = _subtitle_text

func show_victory_banner(duration: float = Invariants.WORLD_BOSS_VICTORY_COLLAPSE_DURATION) -> void:
	_title_text = "👑 VITÓRIA MUNDIAL: AZAROTH FOI DERROTADO!"
	_subtitle_text = "O SELO ABISSAL FOI RESTAURADO • AS TREVAS FORAM EXPURGADAS DO TERRITÓRIO"
	_banner_color = Color(0.3, 1.0, 0.4)
	_display_duration = duration
	_elapsed = 0.0
	_is_showing = true
	visible = true

	if _lbl_title != null:
		_lbl_title.text = _title_text
	if _lbl_subtitle != null:
		_lbl_subtitle.text = _subtitle_text

func is_showing_banner() -> bool:
	return _is_showing

func _on_phase_cinematic_started(_from_phase: int, to_phase: int, phase_name: String, duration: float) -> void:
	show_phase_banner(to_phase, phase_name, duration)

func _on_victory_cinematic_started(_boss_id: StringName, _participants: PackedInt64Array) -> void:
	show_victory_banner()
