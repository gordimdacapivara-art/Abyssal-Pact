class_name CamposDeSalRegion
extends VeyrathRegionBase
## Região REG-009: Campos de Sal — Vasto Deserto Salino Cáustico.
## Apresenta uma planície árida esbranquiçada ressecada, formações pontiagudas
## de crosta de sal e minerais cáusticos e fendas secas de salmoura.

func _init() -> void:
	region_id_code = &"REG-009"

func _setup_region_environment() -> void:
	# 1. Grande Formação Central de Crosta de Sal
	var exp_node := get_node_or_null("Exploration")
	if exp_node != null and not exp_node.has_node("GreatSaltCrust"):
		var crust := RegionAssetLoaderClass.instantiate_model("rocks", "rock_salt_crust_formation")
		crust.name = "GreatSaltCrust"
		crust.transform.origin = Vector3(0, 0, 0)
		crust.scale = Vector3(1.8, 1.8, 1.8)
		exp_node.add_child(crust)
		RegionCollisionSystemClass.create_static_cylinder(crust, "Crust_Col", 5.5, 3.5, Vector3(0, 1.75, 0))

	# 2. Formações dispersas de cristais e salmoura no deserto
	var props_root := get_node_or_null("Props")
	if props_root != null and not props_root.has_node("SaltFormations"):
		var formations := Node3D.new()
		formations.name = "SaltFormations"
		props_root.add_child(formations)

		var salt_positions := [Vector3(-45, 0, -35), Vector3(50, 0, -30), Vector3(-40, 0, 45), Vector3(45, 0, 40), Vector3(-60, 0, 5)]
		for i in range(salt_positions.size()):
			var s := RegionAssetLoaderClass.instantiate_model("rocks", "rock_salt_crust_formation")
			s.name = "SaltPlate_%02d" % (i + 1)
			s.transform.origin = salt_positions[i]
			formations.add_child(s)
			RegionCollisionSystemClass.create_static_cylinder(s, "Col", 3.2, 2.0, Vector3(0, 1.0, 0))
