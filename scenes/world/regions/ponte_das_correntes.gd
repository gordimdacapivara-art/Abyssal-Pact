class_name PonteDasCorrentesRegion
extends KarduumRegionBase
## Região REG-027: Ponte das Correntes (Continente KHAR-DUUM).
## Apresenta arquitetura vulcânica, industrial e subterrânea com relevos e monumentos dedicados.

func _init() -> void:
	region_id_code = &"REG-027"

func _setup_region_environment() -> void:
	var struct_root := get_node_or_null("Structures")
	if struct_root != null:
		if not struct_root.has_node("MonumentalChainBridge"):
			var mon := RegionAssetLoaderClass.instantiate_model("structures", "structure_monumental_chain_bridge")
			mon.name = "MonumentalChainBridge"
			mon.transform.origin = Vector3(0, 0, -45.0)
			struct_root.add_child(mon)
			RegionCollisionSystemClass.create_static_box(mon, "Mon_Col", Vector3(14.0, 12.0, 14.0), Vector3(0, 6.0, 0))

		if not struct_root.has_node("TitanChainAnchor"):
			var extra := RegionAssetLoaderClass.instantiate_model("props", "prop_titan_chain_link")
			extra.name = "TitanChainAnchor"
			extra.transform.origin = Vector3(15, 0, -20)
			struct_root.add_child(extra)
