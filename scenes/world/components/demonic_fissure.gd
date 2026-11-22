class_name DemonicFissure
extends Node3D
## DemonicFissure — Fenda Demoníaca do Exército de Azaroth (PROMPT 04).
##
## Representa aberturas magmáticas e abissais no solo da região invadida:
##   - Fase 1 (MINOR): Fumaça, enxofre e surgimento de demônios inferiores e superiores.
##   - Fase 2 (GREATER): Fenda expandida, campo de dano corrosivo aos jogadores, surgimento de primordiais.

enum ThreatLevel {
	MINOR = 1,
	GREATER = 2
}

signal unit_spawned(unit_id: StringName, rank: int, position: Vector3)
signal fissure_expanded(new_threat_level: int)
signal fissure_sealed(fissure_id: StringName)

@export var fissure_id: StringName = &""
@export var region_id: StringName = &""
@export var threat_level: ThreatLevel = ThreatLevel.MINOR

var _is_active: bool = true
var _hazard_radius: float = 6.0
var _hazard_dps: float = 5.0
var _pulse_timer: float = 0.0
var _spawn_count: int = 0
var _fissure_scale: float = 1.0

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	if not _is_active:
		return
	_pulse_timer += delta

func setup(id: StringName, reg_id: StringName, pos: Vector3, initial_threat: ThreatLevel = ThreatLevel.MINOR) -> void:
	fissure_id = id
	region_id = reg_id
	threat_level = initial_threat
	global_position = pos
	_is_active = true
	_update_threat_attributes()

func expand_threat() -> void:
	if threat_level == ThreatLevel.GREATER:
		return
	threat_level = ThreatLevel.GREATER
	_update_threat_attributes()
	fissure_expanded.emit(int(threat_level))
	EventBus.demonic_fissure_opened.emit(fissure_id, region_id, global_position, int(threat_level))

func _update_threat_attributes() -> void:
	match threat_level:
		ThreatLevel.MINOR:
			_hazard_radius = 6.0
			_hazard_dps = 4.0
			_fissure_scale = 1.0
		ThreatLevel.GREATER:
			_hazard_radius = 12.0
			_hazard_dps = 16.0
			_fissure_scale = 1.6
	scale = Vector3(_fissure_scale, _fissure_scale, _fissure_scale)

## Gera uma unidade militar emergindo fisicamente da fenda
func spawn_emerging_unit(rank: int, unit_id: StringName, demon_name: String = "") -> Dictionary:
	if not _is_active:
		return {}

	_spawn_count += 1
	var spawn_pos := global_position + Vector3(randf_range(-2.0, 2.0), 0.0, randf_range(-2.0, 2.0))

	var unit_info := {
		"unit_id": unit_id,
		"rank": rank,
		"fissure_id": fissure_id,
		"region_id": region_id,
		"position": spawn_pos,
		"initial_y_offset": -8.0, # Começa sob o solo da fenda e ascende
		"faction": Invariants.AZAROTH_ARMY_FACTION,
		"name": demon_name if not demon_name.is_empty() else ("Unidade do Exército %s" % unit_id),
		"threat_level": int(threat_level)
	}

	unit_spawned.emit(unit_id, rank, spawn_pos)
	EventBus.invasion_unit_emerged.emit(unit_id, rank, spawn_pos, Invariants.AZAROTH_ARMY_FACTION)
	return unit_info

## Aplica dano da área perigosa a combatentes próximos (Fase 2)
func deal_hazard_damage(delta: float, player_positions: Array) -> float:
	if not _is_active or threat_level != ThreatLevel.GREATER:
		return 0.0

	var total_applied := 0.0
	for p_pos in player_positions:
		var pos_v3: Vector3 = p_pos if p_pos is Vector3 else Vector3.ZERO
		var dist := global_position.distance_to(pos_v3)
		if dist <= _hazard_radius:
			var dmg := _hazard_dps * delta
			total_applied += dmg

	return total_applied

func seal() -> void:
	_is_active = false
	fissure_sealed.emit(fissure_id)
	EventBus.demonic_fissure_sealed.emit(fissure_id, region_id)

func is_sealed() -> bool:
	return not _is_active

func is_active() -> bool:
	return _is_active

func get_threat_level() -> ThreatLevel:
	return threat_level

func get_hazard_radius() -> float:
	return _hazard_radius

func get_hazard_dps() -> float:
	return _hazard_dps

func get_spawn_count() -> int:
	return _spawn_count
