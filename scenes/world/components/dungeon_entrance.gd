class_name DungeonEntrance
extends Node3D
## Entrada de masmorra no mundo aberto.

signal entered(dungeon_id: StringName)

@export var dungeon_id: StringName = &"dungeon_001"
@export var dungeon_name: String = "Catacumbas de Basalto"
@export var min_level: int = 5
@export var interaction_radius: float = 3.5

func _ready() -> void:
	_build_visual()

func setup(config: Dictionary) -> void:
	dungeon_id = StringName(String(config.get("dungeon_id", dungeon_id)))
	dungeon_name = String(config.get("dungeon_name", dungeon_name))
	min_level = int(config.get("min_level", min_level))
	if config.has("position") and config["position"] is Vector3:
		position = config["position"]
	_build_visual()

func _build_visual() -> void:
	for child in get_children():
		child.queue_free()

	# Fachada da cripta / caverna
	var facade := MeshInstance3D.new()
	facade.name = "Facade"
	var box := BoxMesh.new()
	box.size = Vector3(6.0, 5.0, 3.0)
	facade.mesh = box
	var stone_mat := StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.2, 0.18, 0.22)
	facade.material_override = stone_mat
	facade.position.y = 2.5
	add_child(facade)

	# Vão da porta escura
	var doorway := MeshInstance3D.new()
	doorway.name = "Doorway"
	var door_mesh := BoxMesh.new()
	door_mesh.size = Vector3(2.4, 3.6, 0.4)
	doorway.mesh = door_mesh
	var dark_mat := StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.02, 0.01, 0.03)
	doorway.material_override = dark_mat
	doorway.position = Vector3(0, 1.8, 1.4)
	add_child(doorway)

	# Tochas laterais
	for side in [-1, 1]:
		var light := OmniLight3D.new()
		light.name = "Torch_%d" % side
		light.light_color = Color(1.0, 0.45, 0.2)
		light.light_energy = 1.5
		light.omni_range = 6.0
		light.position = Vector3(side * 2.2, 2.8, 1.6)
		add_child(light)

	# Label 3D
	var label := Label3D.new()
	label.name = "Label"
	label.text = "MASMORRA (Nvl %d+)\n%s" % [min_level, dungeon_name]
	label.font_size = 28
	label.modulate = Color(0.9, 0.3, 0.3)
	label.position = Vector3(0, 5.8, 1.5)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)
