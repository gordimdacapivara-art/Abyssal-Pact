class_name SafeZone
extends Area3D
## Zona segura (Cidades, santuários, forjas): desativa combate hostil e regenera recursos.

@export var zone_name: String = "Zona Segura"
@export var radius: float = 25.0

var _is_player_inside := false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	monitorable = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_build_col()

func _build_col() -> void:
	var shape_node := CollisionShape3D.new()
	shape_node.name = "Shape"
	var cylinder := CylinderShape3D.new()
	cylinder.radius = radius
	cylinder.height = 6.0
	shape_node.shape = cylinder
	shape_node.position.y = 3.0
	add_child(shape_node)

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D or body.name == "Player":
		_is_player_inside = true

func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D or body.name == "Player":
		_is_player_inside = false

func is_player_inside() -> bool:
	return _is_player_inside
