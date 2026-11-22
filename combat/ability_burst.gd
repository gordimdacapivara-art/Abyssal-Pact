class_name AbilityBurst
extends Area3D
## Área de impacto de habilidade (protótipo data-driven, sem física de projétil).
##
## Spawnada pelo PlayerClassComponent na frente do caster; aplica o dano da
## AbilityData ao primeiro Combatant detectado e se autodestrói. VFX é um
## placeholder neutro (esfera emissiva desvanecendo) até o pipeline de VFX.
##
## Camadas: colide apenas com hurtboxes de alvos (layer configurada pelo
## criador via collision_mask; padrão 8 = layer "targets" do protótipo).

const DEFAULT_TARGET_LAYER := 8

var _ability: AbilityData = null
var _source_id: int = 0
var _spent := false

static func spawn(caster: Node3D, ability: AbilityData, target_layer: int = DEFAULT_TARGET_LAYER) -> AbilityBurst:
	if caster == null or ability == null or not ability.is_active():
		return null
	var burst := AbilityBurst.new()
	burst.name = "AbilityBurst"
	burst._ability = ability
	burst._source_id = caster.get_instance_id()
	burst.collision_layer = 0
	burst.collision_mask = 1 << (target_layer - 1)
	burst.monitoring = true
	burst.position = caster.global_position + (-caster.global_transform.basis.z) * (ability.range_m * 0.5)
	# Impacto na altura do peito do alvo.
	burst.position.y += 1.0
	var shape := CollisionShape3D.new()
	shape.name = "Shape"
	var sphere := SphereShape3D.new()
	sphere.radius = maxf(ability.range_m * 0.6, 0.8)
	shape.shape = sphere
	burst.add_child(shape)
	caster.get_tree().current_scene.add_child(burst)
	burst._spawn_placeholder_vfx()
	return burst

func _ready() -> void:
	body_entered.connect(_on_target)
	area_entered.connect(_on_target)
	# Área é efêmera: expira rápido para não reaplicar dano.
	var timer := get_tree().create_timer(0.2)
	timer.timeout.connect(queue_free)

func _on_target(node: Node3D) -> void:
	if _spent or _ability == null:
		return
	var target_combatant := _combatant_of(node)
	if target_combatant == null:
		return
	_spent = true
	var effective := target_combatant.take_damage(_ability.damage, _ability.damage_type)
	EventBus.target_damaged.emit(node.get_instance_id(), effective, _source_id, _ability.id)
	EventBus.ability_cast_resolved.emit(_source_id, _ability.id)

## Procura Combatant no nó detectado e subindo pela cena (hurtbox pode ser
## irmã do Combatant, não pai dele).
func _combatant_of(node: Node3D) -> Combatant:
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

## VFX placeholder neutro (sem lore): esfera emissiva que desvanece.
func _spawn_placeholder_vfx() -> void:
	var mesh_instance := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = maxf(_ability.range_m * 0.45, 0.6)
	sphere.height = sphere.radius * 2.0
	sphere.radial_segments = 12
	sphere.rings = 6
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.5, 0.2, 0.7, 0.45)
	material.emission_enabled = true
	material.emission = Color(0.55, 0.25, 0.85)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance.mesh = sphere
	mesh_instance.material_override = material
	add_child(mesh_instance)
	var tween := create_tween()
	tween.tween_property(mesh_instance, "scale", Vector3.ONE * 1.4, 0.18)
	tween.tween_property(material, "albedo_color:a", 0.0, 0.18)
