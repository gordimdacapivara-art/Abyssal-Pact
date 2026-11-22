class_name RegionNavigationSystem
extends RefCounted
## Sistema 8: Sistema de Navegação 3D de Região (NavMesh).
## Cria e configura o NavigationRegion3D para navegação de IA dos demônios e jogadores,
## definindo parâmetros de malha de navegação (NavigationMesh) para terrenos e obstáculos.

static func create_navigation_region(parent: Node3D, radius: float = 120.0) -> NavigationRegion3D:
	var nav_region := NavigationRegion3D.new()
	nav_region.name = "NavigationRegion3D"
	parent.add_child(nav_region)

	var nav_mesh := NavigationMesh.new()
	nav_mesh.agent_radius = 0.5
	nav_mesh.agent_height = 1.8
	nav_mesh.agent_max_climb = 0.5
	nav_mesh.agent_max_slope = 45.0
	nav_mesh.cell_size = 0.3
	nav_mesh.cell_height = 0.25
	nav_mesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	nav_mesh.geometry_collision_mask = RegionCollisionSystem.LAYER_WORLD

	# Cria malha de navegação base pré-gerada para o plano do terreno
	_build_base_navmesh_polygon(nav_mesh, radius)
	nav_region.navigation_mesh = nav_mesh

	return nav_region

## Constrói polígonos iniciais no NavigationMesh para cobrir a área caminhável da região
static func _build_base_navmesh_polygon(nav_mesh: NavigationMesh, radius: float) -> void:
	var half_size := radius * 0.95
	var vertices := PackedVector3Array([
		Vector3(-half_size, 0.05, -half_size),
		Vector3(half_size, 0.05, -half_size),
		Vector3(half_size, 0.05, half_size),
		Vector3(-half_size, 0.05, half_size)
	])
	nav_mesh.vertices = vertices

	# Dois triângulos cobrindo o quadrilátero caminhável
	nav_mesh.add_polygon(PackedInt32Array([0, 1, 2]))
	nav_mesh.add_polygon(PackedInt32Array([0, 2, 3]))

## Solicita rebake assíncrono do NavigationMesh no runtime da Godot 4
static func bake_navigation(nav_region: NavigationRegion3D) -> void:
	if nav_region != null and nav_region.navigation_mesh != null:
		nav_region.bake_navigation_mesh()
