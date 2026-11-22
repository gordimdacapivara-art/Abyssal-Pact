class_name PantanoDasLanternasRegion
extends SylvaranRegionBase
## Região REG-012: Pântano das Lanternas (Continente SYLVARAN).
## Apresenta arquitetura de natureza ancestral com relevos e monumentos dedicados.

func _init() -> void:
	region_id_code = &"REG-012"

func _setup_region_environment() -> void:
	var struct_root := get_node_or_null("Structures")
	if struct_root != null:
		if not struct_root.has_node("LanternPlantCluster"):
			var mon := RegionAssetLoaderClass.instantiate_model("nature", "nature_bioluminescent_lantern_plant")
			mon.name = "LanternPlantCluster"
			mon.transform.origin = Vector3(0, 0, -45.0)
			struct_root.add_child(mon)
			RegionCollisionSystemClass.create_static_box(mon, "Mon_Col", Vector3(12.0, 10.0, 12.0), Vector3(0, 5.0, 0))

		if not struct_root.has_node("SwampLanternPost"):
			var extra := RegionAssetLoaderClass.instantiate_model("props", "prop_swamp_lantern_post")
			extra.name = "SwampLanternPost"
			extra.transform.origin = Vector3(8, 0, -10)
			struct_root.add_child(extra)
