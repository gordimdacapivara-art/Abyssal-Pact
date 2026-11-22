class_name BosqueOcoRegion
extends VeyrathRegionBase
## Região REG-004: Bosque Oco — Floresta Petrificada Deteriorada.
## Apresenta árvores ocas colossais que servem de passagens e abrigos,
## árvores calcinadas, pântanos de cinzas e ramificações retorcidas.

func _init() -> void:
	region_id_code = &"REG-004"

func _setup_region_environment() -> void:
	var struct_root := get_node_or_null("Structures")
	if struct_root != null:
		# 1. Grande Árvore Oca Monumental no centro do bosque
		if not struct_root.has_node("HollowTreeCenter"):
			var tree := RegionAssetLoaderClass.instantiate_model("nature", "nature_hollow_tree_monument")
			tree.name = "HollowTreeCenter"
			tree.transform.origin = Vector3(0, 0, 0)
			struct_root.add_child(tree)
			RegionCollisionSystemClass.create_static_cylinder(tree, "Tree_Col", 3.5, 9.0, Vector3(0, 4.5, 0))

		# 2. Segunda árvore oca marcando o ponto de exploração
		var exp_node := get_node_or_null("Exploration")
		if exp_node != null and not exp_node.has_node("HollowTreeNorth"):
			var tree_n := RegionAssetLoaderClass.instantiate_model("nature", "nature_hollow_tree_monument")
			tree_n.name = "HollowTreeNorth"
			tree_n.transform.origin = Vector3(45.0, 0, -35.0)
			exp_node.add_child(tree_n)
			RegionCollisionSystemClass.create_static_cylinder(tree_n, "Tree_N_Col", 3.5, 9.0, Vector3(0, 4.5, 0))

	# 3. Denso agrupamento de árvores de cinzas secas e espinhos
	var nature_root := get_node_or_null("Nature")
	if nature_root != null and not nature_root.has_node("HollowGroves"):
		var groves := Node3D.new()
		groves.name = "HollowGroves"
		nature_root.add_child(groves)
		for i in range(12):
			var ang := i * (TAU / 12.0)
			var dist := 35.0 + (i * 19 % 45)
			var pos := Vector3(cos(ang) * dist, 0, sin(ang) * dist)
			var tree := RegionAssetLoaderClass.instantiate_model("nature", "tree_charred_ash")
			tree.name = "GroveTree_%02d" % (i + 1)
			tree.transform.origin = pos
			groves.add_child(tree)
			RegionCollisionSystemClass.create_static_cylinder(tree, "Col", 0.5, 4.0, Vector3(0, 2.0, 0))
