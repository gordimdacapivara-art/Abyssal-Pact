class_name CostaDasCinzasRegion
extends VeyrathRegionBase
## Região REG-006: Costa das Cinzas — Litoral Escuro e Ruínas Portuárias.
## Apresenta praias de areia vulcânica negra frente ao Mar da Cicatriz,
## carcaças de navios naufragados, píer de fortaleza marítima em basalto e falésias.

func _init() -> void:
	region_id_code = &"REG-006"

func _setup_region_environment() -> void:
	var struct_root := get_node_or_null("Structures")
	if struct_root != null:
		# 1. Píer de Fortaleza Costeira em Basalto
		if not struct_root.has_node("SeaPier"):
			var pier := RegionAssetLoaderClass.instantiate_model("structures", "structure_sea_fortress_pier")
			pier.name = "SeaPier"
			pier.transform.origin = Vector3(0, 0, -35.0)
			struct_root.add_child(pier)
			RegionCollisionSystemClass.create_static_box(pier, "Pier_Col", Vector3(6.5, 3.5, 16.5), Vector3(0, 1.75, 0))

		# 2. Carcaça de Navio Naufragado na arrebentação
		var exp_node := get_node_or_null("Exploration")
		if exp_node != null and not exp_node.has_node("FlagshipWreck"):
			var wreck := RegionAssetLoaderClass.instantiate_model("props", "prop_shipwreck_ribs")
			wreck.name = "FlagshipWreck"
			wreck.transform.origin = Vector3(-45.0, 0, -25.0)
			wreck.rotation_degrees.y = 35.0
			exp_node.add_child(wreck)
			RegionCollisionSystemClass.create_static_box(wreck, "Wreck_Col", Vector3(4.5, 4.0, 14.0), Vector3(0, 2.0, 0))

		# 3. Segundo naufrágio menor na praia leste
		if exp_node != null and not exp_node.has_node("SecondaryWreck"):
			var wreck_e := RegionAssetLoaderClass.instantiate_model("props", "prop_shipwreck_ribs")
			wreck_e.name = "SecondaryWreck"
			wreck_e.transform.origin = Vector3(40.0, 0, -15.0)
			wreck_e.rotation_degrees.y = -40.0
			exp_node.add_child(wreck_e)
			RegionCollisionSystemClass.create_static_box(wreck_e, "Wreck_E_Col", Vector3(4.5, 4.0, 14.0), Vector3(0, 2.0, 0))
