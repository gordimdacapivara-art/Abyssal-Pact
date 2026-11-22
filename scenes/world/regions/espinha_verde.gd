class_name EspinhaVerdeRegion
extends SylvaranRegionBase
## Região REG-017: Espinha Verde (Continente SYLVARAN).
## Apresenta arquitetura de natureza ancestral com relevos e monumentos dedicados.

func _init() -> void:
	region_id_code = &"REG-017"

func _setup_region_environment() -> void:
	var struct_root := get_node_or_null("Structures")
	if struct_root != null:
		if not struct_root.has_node("EmeraldCrystalCrag"):
			var mon := RegionAssetLoaderClass.instantiate_model("rocks", "rock_sylvaran_emerald_crystal")
			mon.name = "EmeraldCrystalCrag"
			mon.transform.origin = Vector3(0, 0, -45.0)
			struct_root.add_child(mon)
			RegionCollisionSystemClass.create_static_box(mon, "Mon_Col", Vector3(12.0, 10.0, 12.0), Vector3(0, 5.0, 0))
