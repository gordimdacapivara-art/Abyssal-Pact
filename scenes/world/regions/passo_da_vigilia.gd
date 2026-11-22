class_name PassoDaVigiliaRegion
extends VeyrathRegionBase
## Região REG-007: Passo da Vigília — Desfiladeiro de Alta Montanha e Fortalezas.
## Apresenta bastiões de pedra encravados nos despenhadeiros, muralhas
## de contenção com ameias defensivas e torres de vigia sobre desfiladeiros estreitos.

func _init() -> void:
	region_id_code = &"REG-007"

func _setup_region_environment() -> void:
	var struct_root := get_node_or_null("Structures")
	if struct_root != null:
		# 1. Bastião de Alta Montanha Fortificado
		if not struct_root.has_node("MountainBastion"):
			var bastion := RegionAssetLoaderClass.instantiate_model("structures", "structure_mountain_fortress_bastion")
			bastion.name = "MountainBastion"
			bastion.transform.origin = Vector3(0, 0, -40.0)
			struct_root.add_child(bastion)
			RegionCollisionSystemClass.create_static_box(bastion, "Bastion_Col", Vector3(13.0, 9.5, 7.5), Vector3(0, 4.75, 0))

		# 2. Muralhas de contenção dos flancos da garganta
		if not struct_root.has_node("PassWalls"):
			var walls := Node3D.new()
			walls.name = "PassWalls"
			struct_root.add_child(walls)

			var wall_w := RegionAssetLoaderClass.instantiate_model("structures", "structure_bastion_wall")
			wall_w.name = "Wall_West"
			wall_w.transform.origin = Vector3(-16.0, 0, -35.0)
			wall_w.rotation_degrees.y = 25.0
			walls.add_child(wall_w)
			RegionCollisionSystemClass.create_static_box(wall_w, "Col", Vector3(6.0, 3.6, 1.2), Vector3(0, 1.8, 0))

			var wall_e := RegionAssetLoaderClass.instantiate_model("structures", "structure_bastion_wall")
			wall_e.name = "Wall_East"
			wall_e.transform.origin = Vector3(16.0, 0, -35.0)
			wall_e.rotation_degrees.y = -25.0
			walls.add_child(wall_e)
			RegionCollisionSystemClass.create_static_box(wall_e, "Col", Vector3(6.0, 3.6, 1.2), Vector3(0, 1.8, 0))

		# 3. Torre de Vigia no pico mais alto
		var exp_node := get_node_or_null("Exploration")
		if exp_node != null and not exp_node.has_node("HighWatchtower"):
			var tower := RegionAssetLoaderClass.instantiate_model("structures", "structure_watchtower_ruin")
			tower.name = "HighWatchtower"
			tower.transform.origin = Vector3(35.0, 0, 25.0)
			exp_node.add_child(tower)
			RegionCollisionSystemClass.create_static_cylinder(tower, "Col", 2.2, 5.5, Vector3(0, 2.75, 0))
