class_name JardimAfogadoRegion
extends SylvaranRegionBase
## Região REG-014: Jardim Afogado (Continente SYLVARAN).
## Apresenta arquitetura de natureza ancestral com relevos e monumentos dedicados.

func _init() -> void:
	region_id_code = &"REG-014"

func _setup_region_environment() -> void:
	var struct_root := get_node_or_null("Structures")
	if struct_root != null:
		if not struct_root.has_node("DrownedGardenPavilion"):
			var mon := RegionAssetLoaderClass.instantiate_model("structures", "structure_drowned_garden_pavilion")
			mon.name = "DrownedGardenPavilion"
			mon.transform.origin = Vector3(0, 0, -45.0)
			struct_root.add_child(mon)
			RegionCollisionSystemClass.create_static_box(mon, "Mon_Col", Vector3(12.0, 10.0, 12.0), Vector3(0, 5.0, 0))
