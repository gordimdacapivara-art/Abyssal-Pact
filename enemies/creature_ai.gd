class_name CreatureAI
extends Node
## IA compartilhada e data-driven para as 200 criaturas regionais.
##
## Nenhum script por criatura: todos os parâmetros vêm de DemonData.ai
## (perception/aggro/deaggro, velocidades, alcance, cooldown, retorno).
## Estados implementados: idle, chase, attack, return, death (observado).
## Patrulha, esquiva/bloqueio, navegação e habilidades especiais em combate
## continuam PENDENTES (GAMEPLAY_SYSTEMS.md) — nada é apresentado como final.

const STATE_IDLE := &"idle"
const STATE_CHASE := &"chase"
const STATE_ATTACK := &"attack"
const STATE_RETURN := &"return"

var _creature: Creature = null
var _target: Node3D = null
var _state: StringName = STATE_IDLE
var _attack_cooldown := 0.0
var _home := Vector3.ZERO

## Liga a IA a uma criatura e a um alvo (jogador). O componente não cria nós.
func setup(creature: Creature, target: Node3D) -> void:
	_creature = creature
	_target = target
	if _creature != null:
		_home = _creature.global_position
	_state = STATE_IDLE
	_attack_cooldown = 0.0

func state() -> StringName:
	return _state

func target() -> Node3D:
	return _target

func _physics_process(delta: float) -> void:
	if _creature == null or not is_instance_valid(_creature):
		return
	if _creature.is_dead():
		_state = &"death"
		return
	if _attack_cooldown > 0.0:
		_attack_cooldown = maxf(_attack_cooldown - delta, 0.0)
	if _target == null or not is_instance_valid(_target):
		_state = STATE_IDLE
		return
	var config := _creature.ai_config()
	if config.is_empty():
		return
	var aggro := float(config.get("aggro_radius", 8.0))
	var deaggro := float(config.get("deaggro_radius", 16.0))
	var attack_range := float(config.get("attack_range", 2.0))
	var chase_speed := float(config.get("chase_speed", 3.0))
	var distance := _creature.global_position.distance_to(_target.global_position)

	# Otimização de IA: Distance Culling quando ocioso e distante dos jogadores (> 100m)
	if _state == STATE_IDLE and distance > 100.0:
		return

	match _state:
		STATE_IDLE, STATE_RETURN:
			if distance <= aggro:
				_state = STATE_CHASE
			elif _state == STATE_RETURN and _creature.global_position.distance_to(_home) > 0.4:
				_move_toward(_home, float(config.get("return_speed", 2.0)), delta)
			elif _state == STATE_RETURN:
				_state = STATE_IDLE
		STATE_CHASE:
			if distance > deaggro:
				_state = STATE_RETURN
			elif distance <= attack_range:
				_state = STATE_ATTACK
			else:
				_move_toward(_target.global_position, chase_speed, delta)
		STATE_ATTACK:
			if distance > attack_range * 1.2:
				_state = STATE_CHASE
			elif _attack_cooldown <= 0.0:
				_attack_cooldown = float(config.get("attack_cooldown", 1.5))
				_deal_damage()

func _move_toward(destination: Vector3, speed: float, delta: float) -> void:
	var flat_destination := Vector3(destination.x, _creature.global_position.y, destination.z)
	var direction := flat_destination - _creature.global_position
	if direction.length() <= 0.05:
		return
	var next := _creature.global_position + direction.normalized() * speed * delta
	_creature.global_position = next
	if direction.length() > 0.1:
		_creature.look_at(Vector3(destination.x, _creature.global_position.y, destination.z), Vector3.UP)

## Dano corpo a corpo da família (stats.damage), aplicado ao Combatant do alvo.
func _deal_damage() -> void:
	if _creature == null or _target == null:
		return
	var combatant := _combatant_of(_target)
	if combatant == null:
		return
	var stats: Dictionary = {}
	if _creature.demon_data() != null:
		stats = _creature.demon_data().stats
	elif _creature.boss_data() != null:
		stats = _creature.boss_data().stats
	combatant.take_damage(float(stats.get("damage", 1.0)), &"physical")

func _combatant_of(node: Node) -> Combatant:
	var search: Node = node
	for _depth in 4:
		for candidate in search.find_children("*", "Combatant", true, false):
			return candidate as Combatant
		if search is Combatant:
			return search as Combatant
		search = search.get_parent()
		if search == null:
			return null
	return null
