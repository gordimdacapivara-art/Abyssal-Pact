class_name AzarothCinematicAlert
extends Control
## AzarothCinematicAlert — Alerta Cinematográfico de Azaroth (PROMPT 02).
##
## Apresenta uma notificação e animação cinematográfica no canto superior esquerdo do mapa/tela
## quando faltar exatamente 1 hora para a invasão do World Boss Azaroth.
##
## Recursos:
##   - Localização no canto superior esquerdo da interface;
##   - Elementos visuais demoníacos góticos (obsidiana, runas, bordas em brasa abissal);
##   - Animação cinematográfica de entrada (slide-in com amortecimento) e saída (slide-out fade);
##   - Efeito visual de ameaça iminente (pulsação contínua de luz escarlate/brasa e modulação);
##   - Mensagem dinâmica: "AZAROTH E SEU EXÉRCITO IRÃO INVADIR EM BREVE AS TERRAS DE [NOME DA REGIÃO], [NOME DO CONTINENTE].";
##   - Identificação automática da região, continente, horário previsto e coordenadas no mapa;
##   - Total independência: não reinicia o temporizador e não depende de o mapa estar aberto;
##   - Sincronização em rede autoritativa com o servidor/anfitrião.

signal alert_dismissed()
signal locate_requested(region_id: StringName, position_3d: Vector3)

const ENTRY_X: float = 24.0
const HIDDEN_X: float = -520.0
const TOP_Y: float = 24.0
const PANEL_WIDTH: float = 460.0

@onready var _panel: PanelContainer = $Panel
@onready var _vbox: VBoxContainer = $Panel/VBox
@onready var _crest_icon: Label = $Panel/VBox/Header/CrestIcon
@onready var _header_title: Label = $Panel/VBox/Header/HeaderTitle
@onready var _message_label: Label = $Panel/VBox/MessageLabel
@onready var _info_grid: GridContainer = $Panel/VBox/InfoGrid
@onready var _lbl_region_val: Label = $Panel/VBox/InfoGrid/RegionVal
@onready var _lbl_continent_val: Label = $Panel/VBox/InfoGrid/ContinentVal
@onready var _lbl_time_val: Label = $Panel/VBox/InfoGrid/TimeVal
@onready var _lbl_coords_val: Label = $Panel/VBox/InfoGrid/CoordsVal
@onready var _btn_locate: Button = $Panel/VBox/Actions/LocateButton
@onready var _btn_dismiss: Button = $Panel/VBox/Actions/DismissButton
@onready var _badge: Button = $Badge

var _region_id: StringName = &"REG-001"
var _region_name: String = "Cinzália"
var _continent_name: String = "Veyrath"
var _time_remaining: float = 3600.0
var _invasion_position: Vector3 = Vector3(0.0, 0.0, -50.0)

var _pulse_time: float = 0.0
var _auto_dismiss_timer: float = 0.0
var _auto_dismiss_delay: float = 25.0 # segundos até minimizar automaticamente
var _is_showing: bool = false
var _is_minimized: bool = false
var _tween: Tween = null
var _stylebox: StyleBoxFlat = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_demonic_theme()
	_connect_internal_signals()
	_update_display()
	visible = false

func _setup_demonic_theme() -> void:
	_stylebox = StyleBoxFlat.new()
	_stylebox.bg_color = Color(0.065, 0.015, 0.015, 0.96)
	_stylebox.border_color = Color(0.9, 0.22, 0.1, 1.0)
	_stylebox.set_border_width_all(2)
	_stylebox.set_corner_radius_all(6)
	_stylebox.shadow_color = Color(0.85, 0.15, 0.05, 0.45)
	_stylebox.shadow_size = 12
	_stylebox.content_margin_left = 14
	_stylebox.content_margin_top = 12
	_stylebox.content_margin_right = 14
	_stylebox.content_margin_bottom = 12

	if _panel != null:
		_panel.add_theme_stylebox_override("panel", _stylebox)

	if _badge != null:
		var badge_style := StyleBoxFlat.new()
		badge_style.bg_color = Color(0.12, 0.02, 0.02, 0.95)
		badge_style.border_color = Color(1.0, 0.35, 0.15, 1.0)
		badge_style.set_border_width_all(2)
		badge_style.set_corner_radius_all(4)
		badge_style.shadow_color = Color(0.9, 0.2, 0.1, 0.5)
		badge_style.shadow_size = 8
		_badge.add_theme_stylebox_override("normal", badge_style)
		_badge.visible = false

func _connect_internal_signals() -> void:
	if _btn_locate != null and not _btn_locate.pressed.is_connected(_on_locate_pressed):
		_btn_locate.pressed.connect(_on_locate_pressed)
	if _btn_dismiss != null and not _btn_dismiss.pressed.is_connected(_on_dismiss_pressed):
		_btn_dismiss.pressed.connect(_on_dismiss_pressed)
	if _badge != null and not _badge.pressed.is_connected(_on_badge_pressed):
		_badge.pressed.connect(_on_badge_pressed)

# ------------------------------------------------------------- CONFIGURAÇÃO --

## Configura e exibe o alerta cinematográfico com dados dinâmicos oficiais
func setup_alert(region_id: StringName, region_name: String, continent_name: String, remaining_seconds: float, pos: Vector3 = Vector3.ZERO) -> void:
	_region_id = region_id
	_region_name = region_name if not region_name.is_empty() else String(region_id)
	_continent_name = continent_name if not continent_name.is_empty() else "Veyrath"
	_time_remaining = remaining_seconds
	_invasion_position = pos
	_auto_dismiss_timer = 0.0
	_update_display()
	play_entry_animation()

func _update_display() -> void:
	# Mensagem dinâmica canônica exigida pelo PROMPT 02:
	# "AZAROTH E SEU EXÉRCITO IRÃO INVADIR EM BREVE AS TERRAS DE [NOME DA REGIÃO], [NOME DO CONTINENTE]."
	var full_msg := "AZAROTH E SEU EXÉRCITO IRÃO INVADIR EM BREVE AS TERRAS DE %s, %s." % [
		_region_name.to_upper(),
		_continent_name.to_upper()
	]

	if _message_label != null:
		_message_label.text = full_msg

	if _lbl_region_val != null:
		_lbl_region_val.text = "%s (%s)" % [_region_name, _region_id]
	if _lbl_continent_val != null:
		_lbl_continent_val.text = _continent_name
	if _lbl_time_val != null:
		_lbl_time_val.text = _format_remaining_time(_time_remaining)
	if _lbl_coords_val != null:
		_lbl_coords_val.text = "X: %.0f, Y: %.0f, Z: %.0f" % [_invasion_position.x, _invasion_position.y, _invasion_position.z]

	if _badge != null:
		_badge.text = "🔥 AMEAÇA: AZAROTH (%s)" % _format_seconds_short(_time_remaining)

func _format_remaining_time(seconds: float) -> String:
	var total_sec := int(maxf(0.0, seconds))
	var hours := total_sec / 3600
	var minutes := (total_sec % 3600) / 60
	var secs := total_sec % 60
	var time_str := "%02d:%02d:%02d" % [hours, minutes, secs]

	var unix_now := Time.get_unix_time_from_system()
	var invasion_unix := unix_now + total_sec
	var dt := Time.get_datetime_dict_from_unix_time(invasion_unix)
	var clock_str := "%02d:%02d" % [int(dt.get("hour", 0)), int(dt.get("minute", 0))]

	return "%s restantes (Previsão às %s)" % [time_str, clock_str]

func _format_seconds_short(seconds: float) -> String:
	var total_sec := int(maxf(0.0, seconds))
	var minutes := total_sec / 60
	var secs := total_sec % 60
	return "%02d:%02d" % [minutes, secs]

# ------------------------------------------------------------- GAME LOOP & FX --

func _process(delta: float) -> void:
	if not visible:
		return

	# Atualiza o temporizador em tempo real
	if _time_remaining > 0.0:
		_time_remaining = maxf(0.0, _time_remaining - delta)
		if _lbl_time_val != null and _is_showing:
			_lbl_time_val.text = _format_remaining_time(_time_remaining)
		if _badge != null and _is_minimized:
			_badge.text = "🔥 AMEAÇA: AZAROTH (%s)" % _format_seconds_short(_time_remaining)

	# Efeito visual de ameaça iminente (pulsação de brasa demoníaca)
	_pulse_time += delta
	var pulse := 0.5 + 0.5 * sin(_pulse_time * 3.8)
	var ember_color := Color(0.85 + 0.15 * pulse, 0.2 + 0.3 * pulse, 0.05 + 0.1 * pulse, 1.0)

	if _stylebox != null:
		_stylebox.border_color = ember_color
		_stylebox.shadow_color = Color(0.9, 0.15, 0.05, 0.35 + 0.25 * pulse)

	if _crest_icon != null:
		_crest_icon.modulate = Color(1.0, 0.7 + 0.3 * pulse, 0.6 + 0.4 * pulse, 1.0)

	# Temporizador de auto-dismiss para badge após tempo em tela
	if _is_showing and not _is_minimized:
		_auto_dismiss_timer += delta
		if _auto_dismiss_timer >= _auto_dismiss_delay:
			_auto_dismiss_timer = 0.0
			play_exit_animation(true)

# ------------------------------------------------------------- ANIMAÇÕES --

## Executa a animação cinematográfica de entrada no canto superior esquerdo
func play_entry_animation() -> void:
	visible = true
	_is_showing = true
	_is_minimized = false
	if _badge != null:
		_badge.visible = false
	if _panel != null:
		_panel.visible = true

	# Posição inicial fora da tela (à esquerda)
	position = Vector2(HIDDEN_X, TOP_Y)
	modulate.a = 0.0
	scale = Vector2(0.9, 0.9)

	if _tween != null and _tween.is_valid():
		_tween.kill()

	_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "position:x", ENTRY_X, 0.65)
	_tween.tween_property(self, "modulate:a", 1.0, 0.45)
	_tween.tween_property(self, "scale", Vector2.ONE, 0.6)

## Executa a animação de saída (fade out e slide out para a esquerda)
func play_exit_animation(minimize_to_badge: bool = true) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()

	_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "position:x", HIDDEN_X, 0.45)
	_tween.tween_property(self, "modulate:a", 0.0, 0.4)

	_tween.chain().tween_callback(func() -> void:
		_is_showing = false
		if minimize_to_badge:
			_show_minimized_badge()
		else:
			visible = false
			alert_dismissed.emit()
	)

func _show_minimized_badge() -> void:
	_is_minimized = true
	if _panel != null:
		_panel.visible = false
	if _badge != null:
		_badge.visible = true
		position = Vector2(ENTRY_X, TOP_Y)
		modulate.a = 0.0
		var badge_tween := create_tween().set_parallel(true)
		badge_tween.tween_property(self, "modulate:a", 1.0, 0.3)

# ------------------------------------------------------------- INTERAÇÕES --

func _on_locate_pressed() -> void:
	locate_requested.emit(_region_id, _invasion_position)
	var ui := Game.get_system(SystemNames.UI) as UIManager if Engine.has_singleton("Game") or has_node("/root/Game") else null
	if ui != null:
		ui.open_screen(&"world_map", {"region_id": _region_id})

func _on_dismiss_pressed() -> void:
	play_exit_animation(true)

func _on_badge_pressed() -> void:
	_auto_dismiss_timer = 0.0
	play_entry_animation()
