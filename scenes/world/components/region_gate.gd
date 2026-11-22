class_name RegionGate
extends Area3D
## Portão de transição entre regiões adjacentes no continente.
## Detecta o jogador e dispara a transição para a região de destino.

signal transition_triggered(target_region: StringName, target_spawn: StringName)

@export var gate_id: StringName = &"gate_north"
@export var target_region: StringName = &"REG-002"
@export var target_spawn: StringName = &"gate_south"
@export var display_name: String = "Estrada para Região Vizinha"
@export var radius: float = 4.0

var _visual: Node3D = null
var _label: Label3D = null

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1 # Camada do jogador
	monitoring = true
	monitorable = false
	body_entered.connect(_on_body_entered)
	_build_visual()

func setup(data: Dictionary) -> void:
	gate_id = StringName(String(data.get("gate_id", gate_id)))
	target_region = StringName(String(data.get("target_region", target_region)))
	target_spawn = StringName(String(data.get("target_spawn", target_spawn)))
	radius = float(data.get("radius", radius))
	if data.has("position") and data["position"] is Vector3:
		position = data["position"]
	_build_visual()

func _build_visual() -> void:
	for child in get_children():
		if child is CollisionShape3D or child is Node3D:
			child.queue_free()

	# Colisor do gatilho
	var shape_node := CollisionShape3D.new()
	shape_node.name = "TriggerShape"
	var cylinder := CylinderShape3D.new()
	cylinder.radius = radius
	cylinder.height = 3.0
	shape_node.shape = cylinder
	shape_node.position.y = 1.5
	add_child(shape_node)

	# Visual do portão / marcos de fronteira
	_visual = Node3D.new()
	_visual.name = "PLACEHOLDER_GateVisual"
	add_child(_visual)

	for side in [-1, 1]:
		var post := MeshInstance3D.new()
		post.name = "Pillar_%d" % side
		var cylinder_mesh := CylinderMesh.new()
		cylinder_mesh.top_radius = 0.4
		cylinder_mesh.bottom_radius = 0.5
		cylinder_mesh.height = 4.0
		post.mesh = cylinder_mesh
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.28, 0.25, 0.23)
		post.material_override = mat
		post.position = Vector3(side * (radius * 0.8), 2.0, 0)
		_visual.add_child(post)

	# Arco superior
	var arch := MeshInstance3D.new()
	arch.name = "Arch"
	var box := BoxMesh.new()
	box.size = Vector3(radius * 1.8, 0.5, 0.6)
	arch.mesh = box
	var arch_mat := StandardMaterial3D.new()
	arch_mat.albedo_color = Color(0.35, 0.28, 0.22)
	arch.material_override = arch_mat
	arch.position = Vector3(0, 4.0, 0)
	_visual.add_child(arch)

	# Label 3D indicador
	_label = Label3D.new()
	_label.name = "GateLabel"
	_label.text = "FRONTEIRA\n%s → %s" % [gate_id, target_region]
	_label.font_size = 28
	_label.modulate = Color(1.0, 0.85, 0.4)
	_label.position = Vector3(0, 4.8, 0)
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_visual.add_child(_label)

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D or body.name == "Player":
		transition_triggered.emit(target_region, target_spawn)
		var world := Game.get_system(SystemNames.WORLD) as WorldManager
		if world != null:
			world.transition_to_region(target_region, target_spawn)
