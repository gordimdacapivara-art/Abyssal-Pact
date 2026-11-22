class_name Creature
extends Node3D
## Criatura reutilizável (demônios regionais E chefes) — UMA cena, ZERO scripts
## por criatura. Toda a configuração vem de DemonData/BossData:
## vida, resistências, recompensas, animações (nomes de clipe) e IA.
##
## Modelo: nenhum GLB de criatura existe no projeto; o visual é um PLACEHOLDER
## claramente identificado (nome do nó + Label3D + material), nunca apresentado
## como arte final. Quando o GLB definitivo existir (model_pending=false), a
## cena poderá instanciá-lo sem alterar este componente.

signal defeated(demon_id: StringName, rewards: Dictionary)

const TARGET_LAYER := 8
const FAMILY_COLORS := {
	&"brute": Color(0.55, 0.18, 0.16),
	&"stalker": Color(0.32, 0.2, 0.42),
	&"caster": Color(0.18, 0.35, 0.55),
	&"swarm": Color(0.55, 0.42, 0.12),
	&"flyer": Color(0.2, 0.45, 0.38),
	&"sentinel": Color(0.35, 0.34, 0.38),
}

## Opcional: id para setup automático em cena (arena/level).
@export var demon_id: StringName = &""

var _data: Resource = null
var _demon: DemonData = null
var _boss: BossData = null
var _combatant: Combatant = null
var _hurtbox: Area3D = null
var _visual: Node3D = null
var _label: Label3D = null
var _material: StandardMaterial3D = null
var _base_color := Color(0.4, 0.35, 0.4)
var _dead := false
var _respawn_timer: SceneTreeTimer = null

func _ready() -> void:
	if _data == null and demon_id != &"":
		var demons := Game.registry().get_system(SystemNames.DEMONS) as DemonManager
		if demons != null and demons.has_demon(demon_id):
			setup(demons.get_demon(demon_id))

## Configura a criatura a partir de DemonData ou BossData. Retorna false para
## recurso inválido (nenhuma suposição é feita).
func setup(data: Resource) -> bool:
	if data is DemonData:
		_demon = data as DemonData
	elif data is BossData:
		_boss = data as BossData
	else:
		push_warning("Creature: recurso inválido (esperado DemonData/BossData)")
		return false
	_data = data
	_build()
	return true

func data() -> Resource:
	return _data

func demon_data() -> DemonData:
	return _demon

func boss_data() -> BossData:
	return _boss

func combatant() -> Combatant:
	return _combatant

func is_dead() -> bool:
	return _dead

## true quando o visual é o placeholder provisório (nenhum GLB definitivo).
func is_placeholder() -> bool:
	if _demon != null:
		return not _demon.has_model()
	if _boss != null:
		return not _boss.has_model()
	return true

func display_name() -> String:
	if _demon != null:
		return _demon.display_name
	if _boss != null:
		return _boss.display_name
	return "Criatura sem dados"

func entity_id() -> StringName:
	if _demon != null:
		return _demon.id
	if _boss != null:
		return _boss.id
	return &""

func ai_config() -> Dictionary:
	if _demon != null:
		return _demon.ai
	if _boss != null:
		return _boss.ai
	return {}

func rewards() -> Dictionary:
	if _demon != null:
		return _demon.rewards
	if _boss != null:
		return _boss.rewards
	return {}

# ------------------------------------------------------------------ CONSTRUÇÃO --

func _build() -> void:
	for child in get_children():
		child.queue_free()
	_dead = false
	var family := _family()
	_base_color = FAMILY_COLORS.get(family, Color(0.4, 0.35, 0.4))
	_build_placeholder(family)
	_build_hurtbox(family)
	_build_combatant()
	_connect_combatant()
	_apply_data()

## Família visual: chefes usam a silhueta "sentinel" ampliada.
func _family() -> StringName:
	if _demon != null:
		return _demon.family
	return &"sentinel"

func _build_placeholder(family: StringName) -> void:
	_visual = Node3D.new()
	_visual.name = "PLACEHOLDER_Visual"
	add_child(_visual)
	var size := Vector3(0.8, 1.6, 0.8)
	match family:
		&"brute": size = Vector3(1.2, 1.9, 1.0)
		&"stalker": size = Vector3(0.6, 1.7, 0.6)
		&"caster": size = Vector3(0.7, 1.8, 0.7)
		&"swarm": size = Vector3(0.5, 0.8, 0.5)
		&"flyer": size = Vector3(0.8, 1.2, 0.8)
		&"sentinel": size = Vector3(1.1, 1.9, 1.1)
	if _boss != null:
		size *= 1.6
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "PLACEHOLDER_Mesh"
	var capsule := CapsuleMesh.new()
	capsule.radius = size.x * 0.5
	capsule.height = size.y
	mesh_instance.mesh = capsule
	_material = StandardMaterial3D.new()
	_material.albedo_color = _base_color
	mesh_instance.material_override = _material
	mesh_instance.position.y = size.y * 0.5
	_visual.add_child(mesh_instance)
	# Asas/cauda provisórias apenas como silhueta de família (não é arte final).
	if family == &"flyer" or family == &"brute":
		for side in 2:
			var wing := MeshInstance3D.new()
			wing.name = "PLACEHOLDER_Wing"
			var box := BoxMesh.new()
			box.size = Vector3(size.x * 0.7, size.y * 0.25, 0.08)
			wing.mesh = box
			wing.material_override = _material
			wing.position = Vector3((size.x * 0.5 + 0.2) * (1 if side == 0 else -1), size.y * 0.8, -0.1)
			wing.rotation.z = 0.5 * (1 if side == 0 else -1)
			_visual.add_child(wing)
	_label = Label3D.new()
	_label.name = "PLACEHOLDER_Label"
	_label.text = "PLACEHOLDER\n%s" % display_name()
	_label.font_size = 32
	_label.modulate = Color(1.0, 0.85, 0.4)
	_label.position.y = size.y + 0.45
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_visual.add_child(_label)

func _build_hurtbox(family: StringName) -> void:
	_hurtbox = Area3D.new()
	_hurtbox.name = "Hurtbox"
	_hurtbox.collision_layer = 1 << (TARGET_LAYER - 1)
	_hurtbox.collision_mask = 0
	_hurtbox.monitoring = false
	var shape_node := CollisionShape3D.new()
	shape_node.name = "Shape"
	var shape := CapsuleShape3D.new()
	var height := 1.6
	if family == &"brute" or family == &"sentinel":
		height = 1.9
	elif family == &"swarm":
		height = 0.8
	if _boss != null:
		height *= 1.6
	shape.radius = 0.55 if _boss != null else 0.45
	shape.height = height
	shape_node.shape = shape
	shape_node.position.y = height * 0.5
	_hurtbox.add_child(shape_node)
	add_child(_hurtbox)

func _build_combatant() -> void:
	_combatant = Combatant.new()
	_combatant.name = "Combatant"
	_combatant.resource_regeneration = 0.0
	add_child(_combatant)

func _connect_combatant() -> void:
	_combatant.damaged.connect(_on_damaged)
	_combatant.died.connect(_on_died)
	_combatant.health_changed.connect(_on_health_changed)

func _apply_data() -> void:
	if _demon != null:
		_combatant.max_health = _demon.health()
		_combatant.resistances = _demon.resistances.duplicate()
	elif _boss != null:
		_combatant.max_health = _boss.health()
		_combatant.resistances = _boss.resistances.duplicate()
	_combatant.health = _combatant.max_health

# ------------------------------------------------------------------- REAÇÕES --

func _on_damaged(_amount: float, _damage_type: StringName) -> void:
	if _material == null:
		return
	_material.albedo_color = Color(0.95, 0.3, 0.25)
	var tween := create_tween()
	tween.tween_property(_material, "albedo_color", _base_color, 0.25)

func _on_health_changed(_current: float, _maximum: float) -> void:
	pass

func _on_died() -> void:
	if _dead:
		return
	_dead = true
	if _hurtbox != null:
		_hurtbox.set_deferred("monitorable", false)
	if _visual != null:
		_visual.visible = false
	var payload := rewards()
	var xp := int(payload.get("xp", 0))
	var gold := int(payload.get("gold", 0))
	if _demon != null:
		EventBus.creature_defeated.emit(_demon.id, get_instance_id(), xp, gold)
	else:
		EventBus.creature_defeated.emit(_boss.id, get_instance_id(), xp, gold)
	defeated.emit(entity_id(), payload)
	_schedule_respawn()

## Respawn configurável pelos dados de IA (chefes não ressurgem).
func _schedule_respawn() -> void:
	var config := ai_config()
	if not bool(config.get("respawn_enabled", false)):
		return
	var seconds := float(config.get("respawn_seconds", 0.0))
	if seconds <= 0.0:
		return
	_respawn_timer = get_tree().create_timer(seconds)
	_respawn_timer.timeout.connect(_respawn)

func _respawn() -> void:
	if not is_inside_tree() or _combatant == null:
		return
	_dead = false
	_combatant.respawn()
	if _hurtbox != null:
		_hurtbox.set_deferred("monitorable", true)
	if _visual != null:
		_visual.visible = true
	if _material != null:
		_material.albedo_color = _base_color
	EventBus.creature_respawned.emit(entity_id(), get_instance_id())

func respawn_now() -> void:
	_respawn()
