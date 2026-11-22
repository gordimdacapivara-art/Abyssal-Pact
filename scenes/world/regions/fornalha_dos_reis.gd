class_name FornalhaDosReisRegion
extends KarduumRegionBase
## Região REG-022: Fornalha dos Reis (Continente KHAR-DUUM).
## Apresenta arquitetura vulcânica, industrial e subterrânea com relevos e monumentos dedicados.

func _init() -> void:
	region_id_code = &"REG-022"

func _setup_region_environment() -> void:
	var struct_root := get_node_or_null("Structures")
	if struct_root != null:
		if not struct_root.has_node("KingsForgeCitadel"):
			var mon := RegionAssetLoaderClass.instantiate_model("structures", "structure_kings_forge_citadel")
			mon.name = "KingsForgeCitadel"
			mon.transform.origin = Vector3(0, 0, -45.0)
			struct_root.add_child(mon)
			RegionCollisionSystemClass.create_static_box(mon, "Mon_Col", Vector3(14.0, 12.0, 14.0), Vector3(0, 6.0, 0))

		if not struct_root.has_node("GreatAnvilSquare"):
			var extra := RegionAssetLoaderClass.instantiate_model("props", "prop_colossal_forge_anvil")
			extra.name = "GreatAnvilSquare"
			extra.transform.origin = Vector3(0, 0, 25)
			struct_root.add_child(extra)
