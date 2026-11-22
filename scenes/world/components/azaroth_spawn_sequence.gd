class_name AzarothSpawnSequence
extends Node3D
## AzarothSpawnSequence — Sequência Cinematográfica de Invasão Demoníaca de Azaroth (PROMPT 03).
##
## Garante que a chegada de Azaroth respeite a geografia do mundo sem teletransporte
## visível ou surgimento artificial:
##   1. Tectonic Tremor: Abalo sísmico, rachadura no terreno e labaredas de enxofre;
##   2. Emergence: Ascensão física do titã subindo do magma subterrâneo (-35m até a superfície);
##   3. Shockwave Roar: Rugido cataclísmico e expansão radial de onda de choque de cinzas (360°);
##   4. Completed: Titã totalmente assentado no terreno, iniciando o combate ativo.

enum Stage {
	NONE = 0,
	TECTONIC_TREMOR = 1,
	EMERGENCE = 2,
	SHOCKWAVE_ROAR = 3,
	COMPLETED = 4
}

signal stage_started(stage: int, stage_name: String)
signal stage_completed(stage: int)
signal sequence_finished()

const TREMOR_DURATION: float = Invariants.WORLD_BOSS_ARRIVAL_TREMOR_DURATION # 4.0s
const EMERGENCE_DURATION: float = Invariants.WORLD_BOSS_ARRIVAL_EMERGENCE_DURATION # 6.0s
const SHOCKWAVE_DURATION: float = Invariants.WORLD_BOSS_ARRIVAL_SHOCKWAVE_DURATION # 3.0s
const SUBTERRANEAN_DEPTH: float = -35.0 # Metros abaixo do solo no início da subida
const MAX_SHOCKWAVE_RADIUS: float = 200.0 # Metros de raio da onda de choque

var _stage: Stage = Stage.NONE
var _stage_elapsed: float = 0.0
var _spawn_position: Vector3 = Vector3.ZERO
var _target_boss_node: Node3D = null
var _is_active: bool = false
var _boss_current_y_offset: float = SUBTERRANEAN_DEPTH
var _current_shockwave_radius: float = 0.0
var _ground_vibration_intensity: float = 0.0

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	if _is_active:
		advance_sequence(delta)

func _safe_set_pos(node_3d: Node3D, pos: Vector3) -> void:
	if node_3d == null:
		return
	if node_3d.is_inside_tree():
		node_3d.global_position = pos
	else:
		node_3d.position = pos

## Inicia a sequência de invasão demoníaca no ponto geográfico designado
func start_sequence(position: Vector3, boss_node: Node3D = null) -> void:
	_spawn_position = position
	_target_boss_node = boss_node
	_safe_set_pos(self, position)
	_is_active = true
	_stage_elapsed = 0.0
	_boss_current_y_offset = SUBTERRANEAN_DEPTH
	_current_shockwave_radius = 0.0
	_ground_vibration_intensity = 0.0

	if _target_boss_node != null:
		_safe_set_pos(_target_boss_node, _spawn_position + Vector3(0.0, SUBTERRANEAN_DEPTH, 0.0))
		_target_boss_node.visible = true

	_enter_stage(Stage.TECTONIC_TREMOR)

## Avança manualmente ou a cada frame a simulação da chegada
func advance_sequence(delta: float) -> void:
	if not _is_active or _stage == Stage.NONE or _stage == Stage.COMPLETED:
		return

	_stage_elapsed += delta

	match _stage:
		Stage.TECTONIC_TREMOR:
			var progress := clampf(_stage_elapsed / TREMOR_DURATION, 0.0, 1.0)
			_ground_vibration_intensity = lerpf(0.2, 1.0, progress)
			if _stage_elapsed >= TREMOR_DURATION:
				_exit_stage(Stage.TECTONIC_TREMOR)
				_enter_stage(Stage.EMERGENCE)

		Stage.EMERGENCE:
			var progress := clampf(_stage_elapsed / EMERGENCE_DURATION, 0.0, 1.0)
			# Curva suave de elevação física sem corte ou teletransporte
			var smooth_progress := sin(progress * PI * 0.5)
			_boss_current_y_offset = lerpf(SUBTERRANEAN_DEPTH, 0.0, smooth_progress)
			if _target_boss_node != null:
				_safe_set_pos(_target_boss_node, _spawn_position + Vector3(0.0, _boss_current_y_offset, 0.0))
			if _stage_elapsed >= EMERGENCE_DURATION:
				_boss_current_y_offset = 0.0
				if _target_boss_node != null:
					_safe_set_pos(_target_boss_node, _spawn_position)
				_exit_stage(Stage.EMERGENCE)
				_enter_stage(Stage.SHOCKWAVE_ROAR)

		Stage.SHOCKWAVE_ROAR:
			var progress := clampf(_stage_elapsed / SHOCKWAVE_DURATION, 0.0, 1.0)
			_current_shockwave_radius = lerpf(5.0, MAX_SHOCKWAVE_RADIUS, progress)
			_ground_vibration_intensity = lerpf(1.0, 0.0, progress)
			if _stage_elapsed >= SHOCKWAVE_DURATION:
				_exit_stage(Stage.SHOCKWAVE_ROAR)
				_enter_stage(Stage.COMPLETED)

func _enter_stage(new_stage: Stage) -> void:
	_stage = new_stage
	_stage_elapsed = 0.0
	var s_name := get_stage_name(_stage)
	stage_started.emit(int(_stage), s_name)
	EventBus.world_boss_arrival_stage_changed.emit(int(_stage), s_name, _spawn_position)

	if new_stage == Stage.COMPLETED:
		_is_active = false
		sequence_finished.emit()

func _exit_stage(completed_stage: Stage) -> void:
	stage_completed.emit(int(completed_stage))

func get_current_stage() -> Stage:
	return _stage

func get_stage_name(stage: Stage) -> String:
	match stage:
		Stage.NONE: return "Inativo"
		Stage.TECTONIC_TREMOR: return "Abalo Sísmico & Fissura Magmática"
		Stage.EMERGENCE: return "Ascensão Abissal das Profundezas"
		Stage.SHOCKWAVE_ROAR: return "Rugido Titânico & Onda de Choque"
		Stage.COMPLETED: return "Chegada Concluída"
		_: return "Desconhecido"

func get_current_stage_name() -> String:
	return get_stage_name(_stage)

func is_in_progress() -> bool:
	return _is_active and _stage != Stage.NONE and _stage != Stage.COMPLETED

func is_completed() -> bool:
	return _stage == Stage.COMPLETED

func get_boss_vertical_offset() -> float:
	return _boss_current_y_offset

func get_shockwave_radius() -> float:
	return _current_shockwave_radius

func get_vibration_intensity() -> float:
	return _ground_vibration_intensity

func reset_sequence() -> void:
	_stage = Stage.NONE
	_stage_elapsed = 0.0
	_is_active = false
	_boss_current_y_offset = SUBTERRANEAN_DEPTH
	_current_shockwave_radius = 0.0
	_ground_vibration_intensity = 0.0
