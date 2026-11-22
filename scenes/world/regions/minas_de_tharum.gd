class_name MinasDeTharumRegion
extends KarduumRegionBase
## Região REG-026: Minas de Tharum (Continente KHAR-DUUM).
## Apresenta arquitetura vulcânica, industrial e subterrânea com relevos e monumentos dedicados.

func _init() -> void:
	region_id_code = &"REG-026"

func _setup_region_environment() -> void:
	var struct_root := get_node_or_null("Structures")
	if struct_root != null:
		if not struct_root.has_node("TharumMineHeadframe"):
			var mon := RegionAssetLoaderClass.instantiate_model("structures", "structure_tharum_mine_headframe")
			mon.name = "TharumMineHeadframe"
			mon.transform.origin = Vector3(0, 0, -45.0)
			struct_root.add_child(mon)
			RegionCollisionSystemClass.create_static_box(mon, "Mon_Col", Vector3(14.0, 12.0, 14.0), Vector3(0, 6.0, 0))

		if not struct_root.has_node("OreCartTracksNorth"):
			var extra := RegionAssetLoaderClass.instantiate_model("props", "prop_mining_ore_cart_track")
			extra.name = "OreCartTracksNorth"
			extra.transform.origin = Vector3(0, 0, 18)
			struct_root.add_child(extra)
