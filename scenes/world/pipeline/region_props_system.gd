class_name RegionPropsSystem
extends RefCounted
## Sistema 6: Sistema de Objetos Ambientais 3D de Região (Props).
## Instancia rochas, crateras, monólitos e braseiros decorativos
## utilizando os modelos GLB exportados pelo pipeline Blender.

static func spawn_environmental_props(parent: Node3D, biome: String) -> Node3D:
	var props_root := Node3D.new()
	props_root.name = "EnvironmentalProps"
	parent.add_child(props_root)

	# 1. Volcanic Boulders along the terrain
	var boulder_positions := [
		Vector3(-25.0, 0, -35.0), Vector3(32.0, 0, -25.0),
		Vector3(-55.0, 0, 15.0), Vector3(45.0, 0, 45.0),
		Vector3(15.0, 0, -65.0), Vector3(-40.0, 0, 60.0)
	]
	for idx in range(boulder_positions.size()):
		var b := RegionAssetLoader.instantiate_model("rocks", "rock_volcanic_boulder")
		b.name = "VolcanicBoulder_%02d" % (idx + 1)
		b.transform.origin = boulder_positions[idx]
		b.rotation_degrees.y = (idx * 53) % 360
		props_root.add_child(b)
		_add_sphere_collision(b, 1.4, Vector3(0, 1.0, 0))

	# 2. Volcanic Needle Crags
	var crag_positions := [
		Vector3(-65.0, 0, -45.0), Vector3(60.0, 0, -50.0),
		Vector3(-70.0, 0, 30.0), Vector3(68.0, 0, 35.0)
	]
	for idx in range(crag_positions.size()):
		var crag := RegionAssetLoader.instantiate_model("rocks", "rock_volcanic_crag")
		crag.name = "VolcanicCrag_%02d" % (idx + 1)
		crag.transform.origin = crag_positions[idx]
		crag.rotation_degrees.y = (idx * 67) % 360
		props_root.add_child(crag)
		_add_cylinder_collision(crag, 1.2, 4.2, Vector3(0, 2.1, 0))

	# 3. Crater Rims
	var rim_positions := [
		Vector3(-35.0, 0, 35.0), Vector3(50.0, 0, -30.0)
	]
	for idx in range(rim_positions.size()):
		var rim := RegionAssetLoader.instantiate_model("rocks", "rock_crater_rim")
		rim.name = "CraterRim_%02d" % (idx + 1)
		rim.transform.origin = rim_positions[idx]
		props_root.add_child(rim)

	# 4. Braziers with OmniLights
	var brazier_positions := [
		Vector3(-3.5, 0, 18.0), Vector3(3.5, 0, 18.0),
		Vector3(-45.0, 0, -35.0), Vector3(40.0, 0, -55.0)
	]
	for idx in range(brazier_positions.size()):
		var brazier := RegionAssetLoader.instantiate_model("props", "prop_volcanic_brazier")
		brazier.name = "Brazier_%02d" % (idx + 1)
		brazier.transform.origin = brazier_positions[idx]
		props_root.add_child(brazier)

		# OmniLight for the fire/embers
		var fire_light := OmniLight3D.new()
		fire_light.name = "FireLight"
		fire_light.light_color = Color(1.0, 0.45, 0.15)
		fire_light.light_energy = 2.0
		fire_light.omni_range = 8.0
		fire_light.transform.origin = Vector3(0, 1.5, 0)
		brazier.add_child(fire_light)

	return props_root

static func _add_sphere_collision(parent: Node3D, radius: float, offset: Vector3) -> void:
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.transform.origin = offset
	var col := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = radius
	col.shape = sphere
	body.add_child(col)
	parent.add_child(body)

static func _add_cylinder_collision(parent: Node3D, radius: float, height: float, offset: Vector3) -> void:
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.transform.origin = offset
	var col := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = radius
	cyl.height = height
	col.shape = cyl
	body.add_child(col)
	parent.add_child(body)
