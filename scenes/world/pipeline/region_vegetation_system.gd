class_name RegionVegetationSystem
extends RefCounted
## Sistema 4: Sistema de Vegetação 3D de Região.
## Gerencia o espalhamento procedural de árvores, arbustos e flora
## utilizando os modelos GLB exportados pelo pipeline Blender.

static func spawn_vegetation(parent: Node3D, biome: String, bounds_radius: float = 120.0, count: int = 14) -> Node3D:
	var veg_root := Node3D.new()
	veg_root.name = "Vegetation"
	parent.add_child(veg_root)

	var tree_model := "tree_charred_ash"
	var shrub_model := "shrub_ashen_thorn"

	# Dispersão procedural em posições predefinidas sem bloquear caminhos centrais
	for i in range(count):
		var angle := (float(i) / count) * TAU + 0.25
		var dist := 35.0 + (i * 17 % 70)
		var pos := Vector3(cos(angle) * dist, 0.0, sin(angle) * dist)

		# Evita o centro da cidade (raio 25m)
		if pos.length() < 28.0:
			pos = pos.normalized() * 32.0

		var is_tree := (i % 2 == 0)
		var model_name := tree_model if is_tree else shrub_model
		var inst := RegionAssetLoader.instantiate_model("nature", model_name)
		inst.name = "%s_%02d" % [model_name, i + 1]
		inst.transform.origin = pos
		inst.rotation_degrees.y = (i * 47) % 360
		veg_root.add_child(inst)

		# Colisor estático para troncos de árvores
		if is_tree:
			var trunk_body := StaticBody3D.new()
			trunk_body.name = "ColTrunk"
			trunk_body.collision_layer = 1 # World
			trunk_body.transform.origin = Vector3(0, 2.0, 0)
			var col_shape := CollisionShape3D.new()
			var cyl := CylinderShape3D.new()
			cyl.radius = 0.5
			cyl.height = 4.0
			col_shape.shape = cyl
			trunk_body.add_child(col_shape)
			inst.add_child(trunk_body)

	return veg_root
