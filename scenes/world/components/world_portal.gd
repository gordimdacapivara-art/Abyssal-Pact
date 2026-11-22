class_name WorldPortal
extends Area3D
## Portal arcano para viagens de longa distância e conexões intercontinentais / Hell Forge.

signal portal_used(target_region: StringName, target_spawn: StringName)

@export var portal_id: StringName = &"portal_hellforge"
@export var target_region: StringName = &"hell_forge"
@export var target_spawn: StringName = &"default"
@export var display_name: String = "Portal Abissal"
@export var is_intercontinental: bool = true
@export var activation_radius: float = 3.0

var _active := true
var _visual: Node3D = null

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1 # Camada do jogador
	monitoring = true
	monitorable = false
	body_entered.connect(_on_body_entered)
	_build_visual()

func setup(data: Dictionary) -> void:
	portal_id = StringName(String(data.get("portal_id", portal_id)))
	target_region = StringName(String(data.get("target_region", target_region)))
	target_spawn = StringName(String(data.get("target_spawn", target_spawn)))
	is_intercontinental = bool(data.get("is_intercontinental", is_intercontinental))
	if data.has("position") and data["position"] is Vector3:
		position = data["position"]
	_build_visual()

func _build_visual() -> void:
	for child in get_children():
		if child is CollisionShape3D or child is Node3D:
			child.queue_free()

	# Colisor
	var shape_node := CollisionShape3D.new()
	shape_node.name = "Shape"
	var cylinder := CylinderShape3D.new()
	cylinder.radius = activation_radius
	cylinder.height = 3.0
	shape_node.shape = cylinder
	shape_node.position.y = 1.5
	add_child(shape_node)

	# Visual
	_visual = Node3D.new()
	_visual.name = "PLACEHOLDER_PortalVisual"
	add_child(_visual)

	# Base de pedra circular
	var base := MeshInstance3D.new()
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = activation_radius * 1.1
	base_mesh.bottom_radius = activation_radius * 1.2
	base_mesh.height = 0.3
	base.mesh = base_mesh
	var stone_mat := StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.18, 0.16, 0.22)
	base.material_override = stone_mat
	base.position.y = 0.15
	_visual.add_child(base)

	# Anel de energia / vórtice
	var vortex := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 1.8
	torus.outer_radius = 2.4
	vortex.mesh = torus
	var vortex_mat := StandardMaterial3D.new()
	vortex_mat.albedo_color = Color(0.4, 0.1, 0.7)
	vortex_mat.emission_enabled = true
	vortex_mat.emission = Color(0.6, 0.2, 0.9)
	vortex_mat.emission_energy_multiplier = 2.5
	vortex.material_override = vortex_mat
	vortex.position.y = 2.6
	vortex.rotation.x = PI * 0.5
	_visual.add_child(vortex)

	# Luz mística
	var light := OmniLight3D.new()
	light.light_color = Color(0.7, 0.3, 1.0)
	light.light_energy = 2.0
	light.omni_range = 8.0
	light.position.y = 2.5
	_visual.add_child(light)

	# Identificação 3D
	var label := Label3D.new()
	label.name = "Label"
	label.text = "PORTAL ABISSAL\n%s → %s" % [portal_id, target_region]
	label.font_size = 30
	label.modulate = Color(0.8, 0.6, 1.0)
	label.position.y = 5.0
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_visual.add_child(label)

func _on_body_entered(body: Node3D) -> void:
	if not _active:
		return
	if body is CharacterBody3D or body.name == "Player":
		portal_used.emit(target_region, target_spawn)
		var world := Game.get_system(SystemNames.WORLD) as WorldManager
		if world != null:
			world.activate_portal(portal_id)
			world.transition_to_region(target_region, target_spawn)
