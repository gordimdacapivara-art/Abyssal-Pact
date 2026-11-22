class_name RegionSceneBuilder
extends RefCounted
## Sistema 1: Sistema de Cenas Regionais (Scene Builder / Orquestrador).
## Coordena os 12 subsistemas do pipeline para construir cenas 3D funcionais,
## ricas e otimizadas para qualquer uma das 40 regiões de ABYSSAL PACT.

static func build_complete_region(root: Node3D, region_data: RegionData) -> void:
	if root == null or region_data == null:
		return

	var continent_id := region_data.continent_id
	var biome := region_data.biome
	var radius: float = float(region_data.boundaries.get("radius", 120.0))
	var profile: Dictionary = region_data.lighting_profile

	# 1. Nó de Ambiente e Iluminação (Sistemas 9 e 10)
	var env_node := Node3D.new()
	env_node.name = "Environment"
	root.add_child(env_node)
	RegionAtmosphereSystem.setup_world_environment(env_node, continent_id, biome, profile)
	RegionLightingSystem.setup_lighting(env_node, continent_id, profile)
	RegionAtmosphereSystem.setup_atmosphere_particles(root, continent_id)

	# 2. Terreno (Sistemas 2 e 3)
	RegionTerrainSystem.build_terrain(root, continent_id, biome, radius)

	# 3. Malha de Navegação (Sistema 8)
	RegionNavigationSystem.create_navigation_region(root, radius)

	# 4. Estruturas Modulares e Ruínas (Sistema 5)
	RegionStructureSystem.spawn_ruins(root, biome)

	# 5. Objetos Ambientais e Rochas (Sistema 6)
	RegionPropsSystem.spawn_environmental_props(root, biome)

	# 6. Vegetação Procedural (Sistema 4)
	RegionVegetationSystem.spawn_vegetation(root, biome, radius)

	# 7. Colisores Perimetrais (Sistema 7)
	RegionCollisionSystem.setup_boundary_walls(root, radius, 30.0)

	# 8. Pontos de Interesse (Sistema 11)
	_setup_pois_and_travel(root, region_data)

static func _setup_pois_and_travel(root: Node3D, region_data: RegionData) -> void:
	var pois_node := Node3D.new()
	pois_node.name = "POIs"
	root.add_child(pois_node)

	for poi in region_data.points_of_interest:
		RegionPOISystem.create_poi(pois_node, poi)

	var travel_node := Node3D.new()
	travel_node.name = "Travel"
	root.add_child(travel_node)

	for gate_dict in region_data.gates:
		var gid := StringName(String(gate_dict.get("id", "")))
		var target_reg := StringName(String(gate_dict.get("target_region", "")))
		var target_sp := StringName(String(gate_dict.get("target_spawn", "default")))
		var name_str := String(gate_dict.get("name", "Portão Regional"))
		var pos: Vector3 = gate_dict.get("position", Vector3(0, 0, 90))
		RegionPOISystem.create_region_gate(travel_node, gid, target_reg, target_sp, name_str, pos)

	for portal_dict in region_data.portals:
		var pid := StringName(String(portal_dict.get("id", "")))
		var target_reg := StringName(String(portal_dict.get("target_region", "")))
		var target_sp := StringName(String(portal_dict.get("target_spawn", "default")))
		var name_str := String(portal_dict.get("name", "Portal"))
		var is_ic := bool(portal_dict.get("is_intercontinental", false))
		var pos: Vector3 = portal_dict.get("position", Vector3(30, 0, 20))
		RegionPOISystem.create_world_portal(travel_node, pid, target_reg, target_sp, name_str, pos, is_ic)
