class_name CoroaPartidaRegion
extends VeyrathRegionBase
## Região REG-002: Coroa Partida — Antiga Capital Imperial de Veyrath.
## Apresenta as ruínas do Palácio Imperial, a Casa de Guarda, o Trono Caído,
## praças monumentais rachadas por fendas de enxofre e colunatas imperiais.

func _init() -> void:
	region_id_code = &"REG-002"

func _setup_region_environment() -> void:
	# 1. Palácio Imperial em Ruínas
	var struct_root := get_node_or_null("Structures")
	if struct_root != null:
		if not struct_root.has_node("ImperialPalaceRuin"):
			var palace := RegionAssetLoaderClass.instantiate_model("structures", "structure_imperial_palace_ruin")
			palace.name = "ImperialPalaceRuin"
			palace.transform.origin = Vector3(0, 0, -45.0)
			struct_root.add_child(palace)
			RegionCollisionSystemClass.create_static_box(palace, "Palace_Col", Vector3(16.0, 8.0, 12.0), Vector3(0, 4.0, 0))

		# 2. O Trono Caído (Ponto de Exploração)
		var exp_node := get_node_or_null("Exploration")
		if exp_node != null and not exp_node.has_node("BrokenThrone"):
			var throne := RegionAssetLoaderClass.instantiate_model("props", "prop_broken_throne")
			throne.name = "BrokenThrone"
			throne.transform.origin = Vector3(0, 1.5, -43.0)
			exp_node.add_child(throne)

		# 3. Casa de Guarda Imperial no acesso à cidade
		if not struct_root.has_node("ImperialGatehouse"):
			var gatehouse := RegionAssetLoaderClass.instantiate_model("structures", "structure_imperial_gatehouse")
			gatehouse.name = "ImperialGatehouse"
			gatehouse.transform.origin = Vector3(0, 0, 30.0)
			struct_root.add_child(gatehouse)
			RegionCollisionSystemClass.create_static_box(gatehouse, "Gatehouse_L_Col", Vector3(4.5, 8.0, 4.5), Vector3(-5.0, 4.0, 0))
			RegionCollisionSystemClass.create_static_box(gatehouse, "Gatehouse_R_Col", Vector3(4.5, 8.0, 4.5), Vector3(5.0, 4.0, 0))

		# 4. Pilares imperiais ao longo da grande avenida
		if not struct_root.has_node("PillarsAvenue"):
			var avenue := Node3D.new()
			avenue.name = "PillarsAvenue"
			struct_root.add_child(avenue)
			for i in range(6):
				var p := RegionAssetLoaderClass.instantiate_model("structures", "ruin_broken_pillar")
				p.name = "Pillar_%02d" % (i + 1)
				var z_pos := -20.0 + i * 10.0
				var x_pos := -7.0 if i % 2 == 0 else 7.0
				p.transform.origin = Vector3(x_pos, 0, z_pos)
				avenue.add_child(p)
				RegionCollisionSystemClass.create_static_cylinder(p, "Col", 0.6, 3.5, Vector3(0, 1.75, 0))
