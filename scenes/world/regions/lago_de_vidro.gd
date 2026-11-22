class_name LagoDeVidroRegion
extends VeyrathRegionBase
## Região REG-005: Lago de Vidro — Bacia Cristalina de Obsidiana Polida.
## Apresenta uma vasta superfície vítrea espelhada de obsidiana negra,
## pináculos de cristais pontiagudos que brotam do solo e passarelas cerimoniais.

func _init() -> void:
	region_id_code = &"REG-005"

func _setup_region_environment() -> void:
	# 1. Aglomerado Central de Pináculos de Cristais de Obsidiana
	var exp_node := get_node_or_null("Exploration")
	if exp_node != null and not exp_node.has_node("ObsidianSpireCluster"):
		var spire_cluster := Node3D.new()
		spire_cluster.name = "ObsidianSpireCluster"
		exp_node.add_child(spire_cluster)

		var center_spire := RegionAssetLoaderClass.instantiate_model("rocks", "rock_obsidian_crystal_spire")
		center_spire.name = "CentralCrystalSpire"
		center_spire.transform.origin = Vector3(0, 0, 0)
		spire_cluster.add_child(center_spire)
		RegionCollisionSystemClass.create_static_cylinder(center_spire, "Spire_Col", 1.8, 8.5, Vector3(0, 4.25, 0))

		# Pináculos menores ao redor da bacia
		var spire_positions := [Vector3(-40, 0, -30), Vector3(45, 0, -35), Vector3(-35, 0, 40), Vector3(38, 0, 45)]
		for i in range(spire_positions.size()):
			var s := RegionAssetLoaderClass.instantiate_model("rocks", "rock_obsidian_crystal_spire")
			s.name = "Spire_%02d" % (i + 1)
			s.transform.origin = spire_positions[i]
			spire_cluster.add_child(s)
			RegionCollisionSystemClass.create_static_cylinder(s, "Col", 1.4, 7.0, Vector3(0, 3.5, 0))

	# 2. Ruínas cerimoniais nas margens do espelho vítreo
	var struct_root := get_node_or_null("Structures")
	if struct_root != null and not struct_root.has_node("GlassShrineArch"):
		var arch := RegionAssetLoaderClass.instantiate_model("structures", "ruin_imperial_arch")
		arch.name = "GlassShrineArch"
		arch.transform.origin = Vector3(0, 0, 35.0)
		struct_root.add_child(arch)
		RegionCollisionSystemClass.create_static_box(arch, "Arch_Col_L", Vector3(1.0, 5.0, 1.0), Vector3(-2.0, 2.5, 0))
		RegionCollisionSystemClass.create_static_box(arch, "Arch_Col_R", Vector3(1.0, 5.0, 1.0), Vector3(2.0, 2.5, 0))
