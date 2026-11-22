class_name CopaCelesteRegion
extends SylvaranRegionBase
## Região REG-013: Copa Celeste (Continente SYLVARAN).
## Apresenta arquitetura de natureza ancestral com relevos e monumentos dedicados.

func _init() -> void:
	region_id_code = &"REG-013"

func _setup_region_environment() -> void:
	var struct_root := get_node_or_null("Structures")
	if struct_root != null:
		if not struct_root.has_node("CanopyPlatformBranch"):
			var mon := RegionAssetLoaderClass.instantiate_model("nature", "nature_canopy_platform_branch")
			mon.name = "CanopyPlatformBranch"
			mon.transform.origin = Vector3(0, 0, -45.0)
			struct_root.add_child(mon)
			RegionCollisionSystemClass.create_static_box(mon, "Mon_Col", Vector3(12.0, 10.0, 12.0), Vector3(0, 5.0, 0))

		if not struct_root.has_node("VineBridgeWalkway"):
			var extra := RegionAssetLoaderClass.instantiate_model("nature", "nature_vine_suspension_bridge")
			extra.name = "VineBridgeWalkway"
			extra.transform.origin = Vector3(0, 3.5, 20)
			struct_root.add_child(extra)
