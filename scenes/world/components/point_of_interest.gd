class_name PointOfInterest
extends Area3D
## Ponto de Interesse (POI): Cidades, Masmorras, Áreas de Chefes, Exploração, etc.

signal discovered(poi_id: StringName, poi_name: String, poi_type: String)

@export var poi_id: StringName = &"poi_001"
@export var poi_name: String = "Ponto de Interesse"
@export var poi_type: String = "exploration" # city, dungeon, boss_arena, exploration, portal, camp
@export var description: String = ""
@export var discovery_radius: float = 16.0
@export var discovery_xp: int = 50

var _discovered := false
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
	poi_id = StringName(String(data.get("id", poi_id)))
	poi_name = String(data.get("name", poi_name))
	poi_type = String(data.get("type", poi_type))
	description = String(data.get("description", description))
	discovery_xp = int(data.get("discovery_xp", discovery_xp))
	if data.has("position") and data["position"] is Vector3:
		position = data["position"]
	_build_visual()

func is_discovered() -> bool:
	return _discovered

func mark_discovered() -> void:
	_discovered = true
	if _label != null:
		_label.modulate = Color(0.4, 0.9, 0.5)

func _build_visual() -> void:
	for child in get_children():
		if child is CollisionShape3D or child is Node3D:
			child.queue_free()

	# Colisor de detecção
	var shape_node := CollisionShape3D.new()
	shape_node.name = "Shape"
	var sphere := SphereShape3D.new()
	sphere.radius = discovery_radius
	shape_node.shape = sphere
	add_child(shape_node)

	# Marcador visual
	_visual = Node3D.new()
	_visual.name = "PLACEHOLDER_POIVisual"
	add_child(_visual)

	var icon_mesh := MeshInstance3D.new()
	var prism := PrismMesh.new()
	prism.size = Vector3(1.0, 1.4, 1.0)
	icon_mesh.mesh = prism
	var mat := StandardMaterial3D.new()
	mat.albedo_color = _type_color()
	mat.emission_enabled = true
	mat.emission = _type_color() * 0.6
	icon_mesh.material_override = mat
	icon_mesh.position.y = 3.5
	icon_mesh.rotation.x = PI # Ponta para baixo
	_visual.add_child(icon_mesh)

	# Label 3D flutuante
	_label = Label3D.new()
	_label.name = "Label"
	_label.text = "[%s]\n%s" % [poi_type.to_upper(), poi_name]
	_label.font_size = 28
	_label.modulate = Color(1.0, 0.85, 0.4)
	_label.position.y = 5.0
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_visual.add_child(_label)

func _type_color() -> Color:
	match poi_type:
		"city": return Color(0.3, 0.7, 1.0)
		"dungeon": return Color(0.8, 0.2, 0.2)
		"boss_arena": return Color(0.9, 0.5, 0.1)
		"portal": return Color(0.7, 0.3, 0.9)
		"camp": return Color(0.4, 0.8, 0.4)
		_: return Color(0.9, 0.8, 0.3)

func _on_body_entered(body: Node3D) -> void:
	if _discovered:
		return
	if body is CharacterBody3D or body.name == "Player":
		_discovered = true
		mark_discovered()
		discovered.emit(poi_id, poi_name, poi_type)
		var world := Game.get_system(SystemNames.WORLD) as WorldManager
		if world != null:
			world.discover_poi(world.current_region_id(), poi_id)
