class_name ValeDasMariposasRegion
extends SylvaranRegionBase
## Região REG-016: Vale das Mariposas (Continente SYLVARAN).
## Apresenta arquitetura de natureza ancestral com relevos e monumentos dedicados.

func _init() -> void:
	region_id_code = &"REG-016"

func _setup_region_environment() -> void:
	var struct_root := get_node_or_null("Structures")
	if struct_root != null:
		if not struct_root.has_node("ButterflyManaShrine"):
			var mon := RegionAssetLoaderClass.instantiate_model("props", "prop_butterfly_mana_shrine")
			mon.name = "ButterflyManaShrine"
			mon.transform.origin = Vector3(0, 0, -45.0)
			struct_root.add_child(mon)
			RegionCollisionSystemClass.create_static_box(mon, "Mon_Col", Vector3(12.0, 10.0, 12.0), Vector3(0, 5.0, 0))

		if not struct_root.has_node("ManaFlowerGrove"):
			var extra := RegionAssetLoaderClass.instantiate_model("nature", "nature_bioluminescent_lantern_plant")
			extra.name = "ManaFlowerGrove"
			extra.transform.origin = Vector3(-15, 0, -40)
			struct_root.add_child(extra)
