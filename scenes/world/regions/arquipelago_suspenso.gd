class_name ArquipelagoSuspensoRegion
extends SylvaranRegionBase
## Região REG-015: Arquipélago Suspenso (Continente SYLVARAN).
## Apresenta arquitetura de natureza ancestral com relevos e monumentos dedicados.

func _init() -> void:
	region_id_code = &"REG-015"

func _setup_region_environment() -> void:
	var struct_root := get_node_or_null("Structures")
	if struct_root != null:
		if not struct_root.has_node("FloatingIslandChunk"):
			var mon := RegionAssetLoaderClass.instantiate_model("rocks", "rock_floating_island_chunk")
			mon.name = "FloatingIslandChunk"
			mon.transform.origin = Vector3(0, 0, -45.0)
			struct_root.add_child(mon)
			RegionCollisionSystemClass.create_static_box(mon, "Mon_Col", Vector3(12.0, 10.0, 12.0), Vector3(0, 5.0, 0))

		if not struct_root.has_node("AerialVineBridge"):
			var extra := RegionAssetLoaderClass.instantiate_model("nature", "nature_vine_suspension_bridge")
			extra.name = "AerialVineBridge"
			extra.transform.origin = Vector3(0, 2.5, 10)
			struct_root.add_child(extra)
