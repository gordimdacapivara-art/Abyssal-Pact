class_name RegionStructureSystem
extends RefCounted
## Sistema 5: Sistema de Estruturas Modulares 3D de Região.
## Instancia e alinha ruínas, muros de bastião, arcos e torres imperiais
## utilizando os modelos GLB exportados pelo pipeline Blender.

static func spawn_ruins(parent: Node3D, biome: String) -> Node3D:
	var ruins_root := Node3D.new()
	ruins_root.name = "ModularStructures"
	parent.add_child(ruins_root)

	# 1. Monumental Imperial Arch no caminho do Baluarte
	var arch := RegionAssetLoader.instantiate_model("structures", "ruin_imperial_arch")
	arch.name = "ImperialArch_Main"
	arch.transform.origin = Vector3(0, 0, 22.0)
	arch.rotation_degrees.y = 0
	ruins_root.add_child(arch)
	_add_box_collision(arch, Vector3(0.9, 5.0, 0.9), Vector3(-2.0, 2.5, 0))
	_add_box_collision(arch, Vector3(0.9, 5.0, 0.9), Vector3(2.0, 2.5, 0))

	# 2. Bastion Walls flanking the settlement
	var wall_left := RegionAssetLoader.instantiate_model("structures", "structure_bastion_wall")
	wall_left.name = "BastionWall_West"
	wall_left.transform.origin = Vector3(-18.0, 0, 16.0)
	wall_left.rotation_degrees.y = 35
	ruins_root.add_child(wall_left)
	_add_box_collision(wall_left, Vector3(6.0, 3.6, 1.2), Vector3(0, 1.8, 0))

	var wall_right := RegionAssetLoader.instantiate_model("structures", "structure_bastion_wall")
	wall_right.name = "BastionWall_East"
	wall_right.transform.origin = Vector3(18.0, 0, 16.0)
	wall_right.rotation_degrees.y = -35
	ruins_root.add_child(wall_right)
	_add_box_collision(wall_right, Vector3(6.0, 3.6, 1.2), Vector3(0, 1.8, 0))

	# 3. Ruined Watchtower na elevação oeste
	var tower := RegionAssetLoader.instantiate_model("structures", "structure_watchtower_ruin")
	tower.name = "Watchtower_Ruin_West"
	tower.transform.origin = Vector3(-45.0, 0, -20.0)
	ruins_root.add_child(tower)
	_add_cylinder_collision(tower, 2.2, 5.5, Vector3(0, 2.75, 0))

	# 4. Broken Pillars along the ancient road
	for i in range(4):
		var pillar := RegionAssetLoader.instantiate_model("structures", "ruin_broken_pillar")
		pillar.name = "BrokenPillar_%02d" % (i + 1)
		var p_z := 28.0 + (i * 12.0)
		var p_x := -6.0 if i % 2 == 0 else 6.0
		pillar.transform.origin = Vector3(p_x, 0, p_z)
		pillar.rotation_degrees.y = (i * 90) % 360
		ruins_root.add_child(pillar)
		_add_cylinder_collision(pillar, 0.6, 3.2, Vector3(0, 1.6, 0))

	return ruins_root

static func _add_box_collision(parent: Node3D, size: Vector3, offset: Vector3) -> void:
	var body := StaticBody3D.new()
	body.collision_layer = 1 # World
	body.transform.origin = offset
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	col.shape = box
	body.add_child(col)
	parent.add_child(body)

static func _add_cylinder_collision(parent: Node3D, radius: float, height: float, offset: Vector3) -> void:
	var body := StaticBody3D.new()
	body.collision_layer = 1 # World
	body.transform.origin = offset
	var col := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = radius
	cyl.height = height
	col.shape = cyl
	body.add_child(col)
	parent.add_child(body)
