class_name ValeDosSinosRegion
extends VeyrathRegionBase
## Região REG-003: Vale dos Sinos — Desfiladeiro Profundo Coberto por Névoa.
## Apresenta torres sineiras arcaicas, grandes sinos abissais de bronze negro suspensos,
## gargantas rochosas estreitas e caminhos montanhosos ecomórficos.

func _init() -> void:
	region_id_code = &"REG-003"

func _setup_region_environment() -> void:
	var struct_root := get_node_or_null("Structures")
	if struct_root != null:
		# 1. Torre Sineira Arcaica Principal
		if not struct_root.has_node("BellTowerMain"):
			var tower := RegionAssetLoaderClass.instantiate_model("structures", "structure_bell_tower_ruin")
			tower.name = "BellTowerMain"
			tower.transform.origin = Vector3(-35.0, 0, -25.0)
			struct_root.add_child(tower)
			RegionCollisionSystemClass.create_static_box(tower, "Tower_Col", Vector3(5.0, 15.0, 5.0), Vector3(0, 7.5, 0))

		# 2. O Grande Sino Abissal (Marco Monumental e Exploração)
		var exp_node := get_node_or_null("Exploration")
		if exp_node != null and not exp_node.has_node("AbyssalBellMonolith"):
			var bell := RegionAssetLoaderClass.instantiate_model("props", "prop_abyssal_bell")
			bell.name = "AbyssalBellMonolith"
			bell.transform.origin = Vector3(30.0, 0, 20.0)
			exp_node.add_child(bell)
			RegionCollisionSystemClass.create_static_cylinder(bell, "Bell_Col", 2.0, 3.0, Vector3(0, 1.5, 0))

		# 3. Segunda torre sineira ao sul do desfiladeiro
		if not struct_root.has_node("BellTowerSouth"):
			var tower_s := RegionAssetLoaderClass.instantiate_model("structures", "structure_bell_tower_ruin")
			tower_s.name = "BellTowerSouth"
			tower_s.transform.origin = Vector3(40.0, 0, -40.0)
			struct_root.add_child(tower_s)
			RegionCollisionSystemClass.create_static_box(tower_s, "Tower_S_Col", Vector3(5.0, 15.0, 5.0), Vector3(0, 7.5, 0))

	# 4. Agulhas rochosas emoldurando o vale estreito
	var props_root := get_node_or_null("Props")
	if props_root != null and not props_root.has_node("ValleyCrags"):
		var crags := Node3D.new()
		crags.name = "ValleyCrags"
		props_root.add_child(crags)
		var crag_positions := [Vector3(-60, 0, -60), Vector3(-55, 0, 50), Vector3(60, 0, -50), Vector3(65, 0, 45)]
		for i in range(crag_positions.size()):
			var c := RegionAssetLoaderClass.instantiate_model("rocks", "rock_volcanic_crag")
			c.name = "ValleyCrag_%02d" % (i + 1)
			c.transform.origin = crag_positions[i]
			crags.add_child(c)
			RegionCollisionSystemClass.create_static_cylinder(c, "Col", 1.2, 4.5, Vector3(0, 2.25, 0))
