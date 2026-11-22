class_name GeleiraDosEcosRegion
extends NhalkoraRegionBase
## Região REG-031: Geleira dos Ecos (Continente NHAL'KORA).
## Apresenta arquitetura glacial, misteriosa, cristalina e monumental com relevos e monumentos dedicados.

func _init() -> void:
	region_id_code = &"REG-031"

func _setup_region_environment() -> void:
	var struct_root := get_node_or_null("Structures")
	if struct_root != null:
		if not struct_root.has_node("GlacialEchoCliff"):
			var mon := RegionAssetLoaderClass.instantiate_model("rocks", "rock_glacial_echo_cliff")
			mon.name = "GlacialEchoCliff"
			mon.transform.origin = Vector3(0, 0, -45.0)
			struct_root.add_child(mon)
			RegionCollisionSystemClass.create_static_box(mon, "Mon_Col", Vector3(14.0, 12.0, 14.0), Vector3(0, 6.0, 0))

		if not struct_root.has_node("IceResonatorCrystal"):
			var extra := RegionAssetLoaderClass.instantiate_model("props", "prop_ice_resonator_crystal")
			extra.name = "IceResonatorCrystal"
			extra.transform.origin = Vector3(20, 0, -25)
			struct_root.add_child(extra)
