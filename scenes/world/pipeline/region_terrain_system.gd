class_name RegionTerrainSystem
extends RefCounted
## Sistema 2: Sistema de Terrenos 3D de Região.
## Constrói a malha de solo, relevo escalonado, crateras, caminhos e colisões estáticas.

static func build_terrain(parent: Node3D, continent_id: StringName, biome: String, radius: float = 150.0) -> Node3D:
	var terrain_root := Node3D.new()
	terrain_root.name = "Terrain"
	parent.add_child(terrain_root)

	# 1. Main Ground StaticBody
	var ground_body := StaticBody3D.new()
	ground_body.name = "MainGround"
	ground_body.collision_layer = 1 # Layer 1: World / Ground
	ground_body.collision_mask = 0
	ground_body.transform.origin = Vector3(0, -1.0, 0)
	terrain_root.add_child(ground_body)

	var ground_mesh := MeshInstance3D.new()
	ground_mesh.name = "Mesh"
	var box := BoxMesh.new()
	var ground_size := radius * 2.2
	box.size = Vector3(ground_size, 2.0, ground_size)
	box.material = RegionMaterialSystem.create_terrain_material(continent_id, biome)
	ground_mesh.mesh = box
	ground_body.add_child(ground_mesh)

	var ground_col := CollisionShape3D.new()
	ground_col.name = "Collision"
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(ground_size, 2.0, ground_size)
	ground_col.shape = box_shape
	ground_body.add_child(ground_col)

	# 2. Lava Fissure (se bioma vulcânico / Veyrath)
	if continent_id == &"CONT-01" or "magma" in biome or "fissure" in biome:
		var fissure := MeshInstance3D.new()
		fissure.name = "LavaFissure"
		var fissure_box := BoxMesh.new()
		fissure_box.size = Vector3(6.0, 0.4, 50.0)
		fissure_box.material = RegionMaterialSystem.create_lava_material()
		fissure.mesh = fissure_box
		fissure.transform.origin = Vector3(-30, 0.1, 10)
		fissure.rotation_degrees = Vector3(0, 15, 0)
		terrain_root.add_child(fissure)

		var lava_light := OmniLight3D.new()
		lava_light.name = "LavaLight"
		lava_light.light_color = Color(1.0, 0.45, 0.15)
		lava_light.light_energy = 2.5
		lava_light.omni_range = 18.0
		lava_light.transform.origin = Vector3(0, 2.0, 0)
		fissure.add_child(lava_light)

	return terrain_root
