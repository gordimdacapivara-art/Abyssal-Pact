class_name TrainingDummy
extends Node3D
## Alvo provisório do protótipo de classes: caixa com Combatant e hurtbox.
##
## Sem lore, sem IA: recebe dano de AbilityBurst, reage (flash + stagger),
## morre (sinal target_died via Combatant.died) e ressurgi após um tempo.
## O inimigo real pertence ao sistema de combate completo (próximo passo).

const RESPAWN_DELAY := 1.5

@export var max_health := 200.0
## Resistência editorial de prova: 25% de redução de dano abissal.
@export var abyssal_resistance := 0.75

var _combatant: Combatant = null
var _mesh: MeshInstance3D = null
var _material: StandardMaterial3D = null
var _base_color := Color(0.25, 0.24, 0.28)
var _flash_color := Color(0.9, 0.35, 0.3)
var _dead := false

func _ready() -> void:
	_combatant = find_children("*", "Combatant", true, false)[0] as Combatant
	_mesh = find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
	_material = StandardMaterial3D.new()
	_material.albedo_color = _base_color
	_mesh.material_override = _material
	_combatant.max_health = max_health
	_combatant.health = max_health
	_combatant.resistances = {"abyssal": abyssal_resistance, "physical": 1.0}
	_combatant.damaged.connect(_on_damaged)
	_combatant.died.connect(_on_died)

func _on_damaged(_amount: float, _damage_type: StringName) -> void:
	_material.albedo_color = _flash_color
	var tween := create_tween()
	tween.tween_property(_material, "albedo_color", _base_color, 0.25)

func _on_died() -> void:
	_dead = true
	_material.albedo_color = Color(0.1, 0.09, 0.1)
	var tween := create_tween()
	tween.tween_property(_mesh, "scale", Vector3(1.0, 0.05, 1.0), 0.3)
	get_tree().create_timer(RESPAWN_DELAY).timeout.connect(_respawn)

func _respawn() -> void:
	_combatant.respawn()
	_mesh.scale = Vector3.ONE
	_material.albedo_color = _base_color
	_dead = false

func is_dead() -> bool:
	return _dead
