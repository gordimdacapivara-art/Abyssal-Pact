class_name TorreDeAsterRegion
extends VeyrathRegionBase
## Região REG-010: Torre de Aster — Estrutura Arcana Monumental na Caldeira.
## Apresenta a colossal Torre de Aster erguendo-se sobre a borda da caldeira vulcânica,
## o Anel Orbital Flutuante com glifos pulsantes e o portal cósmico para a Hell Forge.

func _init() -> void:
	region_id_code = &"REG-010"

func _setup_region_environment() -> void:
	var struct_root := get_node_or_null("Structures")
	if struct_root != null:
		# 1. A Colossal Torre Arcana de Aster
		if not struct_root.has_node("AsterTowerMonument"):
			var tower := RegionAssetLoaderClass.instantiate_model("structures", "structure_aster_arcane_tower")
			tower.name = "AsterTowerMonument"
			tower.transform.origin = Vector3(0, 0, -45.0)
			struct_root.add_child(tower)
			# Colisão sólida maciça na base da torre
			RegionCollisionSystemClass.create_static_cylinder(tower, "Tower_Base_Col", 8.5, 12.0, Vector3(0, 6.0, 0))
			RegionCollisionSystemClass.create_static_cylinder(tower, "Tower_Mid_Col", 5.5, 15.0, Vector3(0, 18.0, 0))

		# 2. O Anel Orbital Flutuante de Poder
		if not struct_root.has_node("AsterArcaneRing"):
			var ring := RegionAssetLoaderClass.instantiate_model("props", "prop_aster_arcane_ring")
			ring.name = "AsterArcaneRing"
			ring.transform.origin = Vector3(0, 14.0, -45.0)
			struct_root.add_child(ring)

		# 3. Altar e Obeliscos de Dobra Dimensional
		var exp_node := get_node_or_null("Exploration")
		if exp_node != null and not exp_node.has_node("DimensionalAltar"):
			var altar := Node3D.new()
			altar.name = "DimensionalAltar"
			altar.transform.origin = Vector3(0, 0, 10.0)
			exp_node.add_child(altar)

			for i in range(4):
				var ang := i * (PI / 2.0)
				var b := RegionAssetLoaderClass.instantiate_model("props", "prop_volcanic_brazier")
				b.name = "ArcanePylon_%02d" % (i + 1)
				b.transform.origin = Vector3(cos(ang) * 12.0, 0, sin(ang) * 12.0)
				altar.add_child(b)

				var flame_light := OmniLight3D.new()
				flame_light.name = "PurpleLight"
				flame_light.light_color = Color(0.7, 0.25, 1.0)
				flame_light.light_energy = 3.0
				flame_light.omni_range = 10.0
				flame_light.transform.origin = Vector3(0, 1.6, 0)
				b.add_child(flame_light)
