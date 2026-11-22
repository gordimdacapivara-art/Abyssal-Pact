class_name WorldBossWidget
extends Control
## WorldBossWidget — Interface HUD para monitoramento do World Boss Azaroth.
##
## Exibe:
## - Status do ciclo de 5 horas compartilhado por todo o mundo privado.
## - Contagem regressiva em tempo real formatada em HH:MM:SS.
## - Barra de vida colossal e fase de combate ativa durante a invasão.
## - Alertas visuais pulsantes durante o estado de Warning e Spawning.
## - Independência total: continua processando e exibindo mesmo com outros menus abertos.

const WorldBossSystemScript := preload("res://core/world_boss_system.gd")

@onready var _panel: PanelContainer = $Panel
@onready var _title_label: Label = $Panel/VBox/Header/TitleLabel
@onready var _status_label: Label = $Panel/VBox/StatusLabel
@onready var _timer_label: Label = $Panel/VBox/Header/TimerLabel
@onready var _hp_bar: ProgressBar = $Panel/VBox/HPBar
@onready var _hp_label: Label = $Panel/VBox/HPBar/HPLabel
@onready var _phase_label: Label = $Panel/VBox/PhaseLabel

var _boss_system: Node = null
var _pulse_timer: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_resolve_boss_system()
	_connect_signals()
	_update_display()

func _resolve_boss_system() -> void:
	var bosses := Game.get_system(SystemNames.BOSSES) as Node if Engine.has_singleton("Game") or has_node("/root/Game") else null
	if bosses != null and bosses.has_method("world_boss_system"):
		_boss_system = bosses.call("world_boss_system") as Node

func _connect_signals() -> void:
	if not EventBus.world_boss_cycle_updated.is_connected(_on_cycle_updated):
		EventBus.world_boss_cycle_updated.connect(_on_cycle_updated)
	if not EventBus.world_boss_state_changed.is_connected(_on_state_changed):
		EventBus.world_boss_state_changed.connect(_on_state_changed)
	if not EventBus.world_boss_health_changed.is_connected(_on_health_changed):
		EventBus.world_boss_health_changed.connect(_on_health_changed)
	if not EventBus.world_boss_phase_transitioned.is_connected(_on_phase_transitioned):
		EventBus.world_boss_phase_transitioned.connect(_on_phase_transitioned)
	if not EventBus.azaroth_ability_telegraphed.is_connected(_on_ability_telegraphed):
		EventBus.azaroth_ability_telegraphed.connect(_on_ability_telegraphed)
	if not EventBus.azaroth_phase_cinematic_started.is_connected(_on_phase_cinematic_started):
		EventBus.azaroth_phase_cinematic_started.connect(_on_phase_cinematic_started)

func _process(delta: float) -> void:
	if _boss_system == null:
		_resolve_boss_system()
		if _boss_system == null:
			return

	# Atualização de animação de pulsação em aviso de invasão
	if bool(_boss_system.call("is_warning")):
		_pulse_timer += delta * 4.0
		var alpha := 0.65 + 0.35 * sin(_pulse_timer)
		modulate = Color(1.0, 0.4 + 0.3 * alpha, 0.4 + 0.3 * alpha, 1.0)
	elif bool(_boss_system.call("is_active")):
		_pulse_timer += delta * 2.0
		var alpha := 0.85 + 0.15 * sin(_pulse_timer)
		modulate = Color(1.0, alpha, alpha, 1.0)
	else:
		modulate = Color.WHITE

func _on_cycle_updated(_elapsed: float, _total: float, _state: int) -> void:
	_update_display()

func _on_state_changed(_prev_state: int, _new_state: int) -> void:
	_update_display()

func _on_health_changed(_boss_id: StringName, current_hp: float, max_hp: float) -> void:
	if _hp_bar != null:
		_hp_bar.max_value = max_hp
		_hp_bar.value = current_hp
	if _hp_label != null:
		var pct := (current_hp / max_hp * 100.0) if max_hp > 0.0 else 0.0
		_hp_label.text = "%.0f / %.0f (%.1f%%)" % [current_hp, max_hp, pct]

func _on_phase_transitioned(_boss_id: StringName, phase_idx: int, phase_name: String) -> void:
	if _phase_label != null:
		_phase_label.text = "Fase %d: %s" % [phase_idx, phase_name]

func _on_ability_telegraphed(_ability_id: StringName, ability_name: String, _target_pos: Vector3, _duration: float) -> void:
	if _status_label != null and _boss_system != null and bool(_boss_system.call("is_active")):
		_status_label.text = "⚡ TELEGRAFIA: %s!" % ability_name.to_upper()
		_status_label.modulate = Color(1.0, 0.2, 0.1)

func _on_phase_cinematic_started(_from_phase: int, to_phase: int, phase_name: String, _duration: float) -> void:
	if _phase_label != null:
		_phase_label.text = "FASE %d: %s (CANALIZANDO)" % [to_phase, phase_name]

func _update_display() -> void:
	if _boss_system == null:
		return

	var state: int = int(_boss_system.call("state"))
	match state:
		WorldBossSystemScript.State.DORMANT:
			if _status_label != null:
				_status_label.text = "Dormência Abissal • Próxima Invasão em:"
				_status_label.modulate = Color(0.7, 0.7, 0.8)
			if _timer_label != null:
				_timer_label.text = String(_boss_system.call("formatted_time_until_spawn"))
			if _hp_bar != null:
				_hp_bar.visible = false
			if _phase_label != null:
				_phase_label.visible = false

		WorldBossSystemScript.State.WARNING:
			if _status_label != null:
				_status_label.text = "⚠️ ALERTA: Fenda Abissal Abrindo em:"
				_status_label.modulate = Color(1.0, 0.3, 0.2)
			if _timer_label != null:
				_timer_label.text = String(_boss_system.call("formatted_time_until_spawn"))
			if _hp_bar != null:
				_hp_bar.visible = false
			if _phase_label != null:
				_phase_label.visible = true
				_phase_label.text = "Região: %s" % String(_boss_system.call("invasion_region"))

		WorldBossSystemScript.State.ACTIVE:
			if _status_label != null:
				_status_label.text = "🔥 EM COMBATE • Tempo Restante:"
				_status_label.modulate = Color(1.0, 0.8, 0.2)
			if _timer_label != null:
				_timer_label.text = String(_boss_system.call("formatted_combat_time"))
			var cur_hp: float = float(_boss_system.call("current_hp"))
			var max_val: float = float(_boss_system.call("max_hp"))
			if _hp_bar != null:
				_hp_bar.visible = true
				_hp_bar.max_value = max_val
				_hp_bar.value = cur_hp
			if _hp_label != null:
				var pct := (cur_hp / max_val * 100.0) if max_val > 0.0 else 0.0
				_hp_label.text = "%.0f / %.0f (%.1f%%)" % [cur_hp, max_val, pct]
			if _phase_label != null:
				_phase_label.visible = true
				_phase_label.text = "Fase %d de 4" % int(_boss_system.call("current_phase"))

		WorldBossSystemScript.State.DEFEATED:
			if _status_label != null:
				_status_label.text = "👑 AZAROTH FOI DERROTADO! Próximo ciclo em:"
				_status_label.modulate = Color(0.3, 1.0, 0.4)
			if _timer_label != null:
				_timer_label.text = String(_boss_system.call("formatted_time_remaining"))
			if _hp_bar != null:
				_hp_bar.visible = false
			if _phase_label != null:
				_phase_label.visible = false

		WorldBossSystemScript.State.RETREATED:
			if _status_label != null:
				_status_label.text = "🌑 O TITÃ RECUOU AO ABISMO! Próximo ciclo em:"
				_status_label.modulate = Color(0.6, 0.6, 0.6)
			if _timer_label != null:
				_timer_label.text = String(_boss_system.call("formatted_time_remaining"))
			if _hp_bar != null:
				_hp_bar.visible = false
			if _phase_label != null:
				_phase_label.visible = false
