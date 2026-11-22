class_name RaizAntigaRegion
extends SylvaranRegionBase
## Região REG-011: Raiz Antiga (Continente SYLVARAN).
## Apresenta arquitetura de natureza ancestral com relevos e monumentos dedicados.

func _init() -> void:
	region_id_code = &"REG-011"

func _setup_region_environment() -> void:
	var struct_root := get_node_or_null("Structures")
	if struct_root != null:
		if not struct_root.has_node("ColossalTreeAncient"):
			var mon := RegionAssetLoaderClass.instantiate_model("nature", "nature_colossal_tree_ancient")
			mon.name = "ColossalTreeAncient"
			mon.transform.origin = Vector3(0, 0, -45.0)
			struct_root.add_child(mon)
			RegionCollisionSystemClass.create_static_box(mon, "Mon_Col", Vector3(12.0, 10.0, 12.0), Vector3(0, 5.0, 0))

		if not struct_root.has_node("RootsArchway"):
			var extra := RegionAssetLoaderClass.instantiate_model("nature", "nature_monumental_roots_arch")
			extra.name = "RootsArchway"
			extra.transform.origin = Vector3(0, 0, 15)
			struct_root.add_child(extra)
