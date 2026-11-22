class_name CatacumbasDeOrunRegion
extends VeyrathRegionBase
## Região REG-008: Catacumbas de Orun — Complexo Fúnebre e Necrópole Subterrânea.
## Apresenta pórticos monumentais de mausoléu com inscrições rúnicas de Orun,
## grandes sarcófagos imperiais de mármore e ouro, colunatas fúnebres e terraços de ardósia.

func _init() -> void:
	region_id_code = &"REG-008"

func _setup_region_environment() -> void:
	var struct_root := get_node_or_null("Structures")
	if struct_root != null:
		# 1. Pórtico Monumental de Entrada do Hipogeu de Orun
		if not struct_root.has_node("MausoleumEntrance"):
			var mausoleum := RegionAssetLoaderClass.instantiate_model("structures", "structure_mausoleum_crypt_entrance")
			mausoleum.name = "MausoleumEntrance"
			mausoleum.transform.origin = Vector3(0, 0, -42.0)
			struct_root.add_child(mausoleum)
			RegionCollisionSystemClass.create_static_box(mausoleum, "Mausoleum_Col", Vector3(10.0, 8.5, 4.0), Vector3(0, 4.25, 0))

		# 2. Alameda dos Sarcófagos Imperiais (A Via dos Mortos)
		if not struct_root.has_node("SarcophagiAvenue"):
			var avenue := Node3D.new()
			avenue.name = "SarcophagiAvenue"
			struct_root.add_child(avenue)

			for i in range(4):
				var s := RegionAssetLoaderClass.instantiate_model("props", "prop_imperial_sarcophagus")
				s.name = "ImperialSarcophagus_%02d" % (i + 1)
				var z_pos := -20.0 + i * 14.0
				var x_pos := -8.0 if i % 2 == 0 else 8.0
				s.transform.origin = Vector3(x_pos, 0, z_pos)
				s.rotation_degrees.y = 90.0 if i % 2 == 0 else -90.0
				avenue.add_child(s)
				RegionCollisionSystemClass.create_static_box(s, "Col", Vector3(2.6, 2.0, 4.2), Vector3(0, 1.0, 0))

		# 3. Grande Tumba Central de Orun (Ponto de Exploração)
		var exp_node := get_node_or_null("Exploration")
		if exp_node != null and not exp_node.has_node("GreatDynastyTomb"):
			var central_tomb := RegionAssetLoaderClass.instantiate_model("props", "prop_imperial_sarcophagus")
			central_tomb.name = "GreatDynastyTomb"
			central_tomb.transform.origin = Vector3(0, 0, 15.0)
			central_tomb.scale = Vector3(1.5, 1.5, 1.5)
			exp_node.add_child(central_tomb)
			RegionCollisionSystemClass.create_static_box(central_tomb, "Col", Vector3(3.9, 3.0, 6.3), Vector3(0, 1.5, 0))
