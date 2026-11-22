class_name RegionCollisionSystem
extends RefCounted
## Sistema 7: Sistema de Colisão 3D de Região.
## Padroniza camadas de colisão físicas (layers), máscaras de consulta,
## corpos estáticos, geradores de colisão primitiva e barreiras perimetrais invisíveis.

# Camadas de colisão do projeto:
const LAYER_WORLD: int = 1          # Terreno, estruturas, rochas, obstáculos estáticos
const LAYER_PLAYER: int = 2         # Personagem do jogador
const LAYER_ENEMIES: int = 3        # Demônios, chefes e NPCs hostis
const LAYER_TRIGGERS: int = 4       # Áreas de gatilho (SafeZone, POI, Portais, Gates)
const LAYER_INTERACTABLES: int = 5  # Monólitos, baús, altares
const LAYER_BOUNDARIES: int = 6     # Barreiras invisíveis de fronteira de mundo

## Cria uma barreira cilíndrica poligonal de StaticBody3D no raio de fronteira da região.
static func setup_boundary_walls(parent: Node3D, radius: float = 120.0, height: float = 30.0, segments: int = 16) -> Node3D:
	var boundary_root := Node3D.new()
	boundary_root.name = "PerimeterCollision"
	parent.add_child(boundary_root)

	var angle_step := TAU / float(segments)
	var segment_width := (TAU * radius / float(segments)) * 1.05

	for i in range(segments):
		var angle := i * angle_step
		var wall_pos := Vector3(cos(angle) * radius, height * 0.5, sin(angle) * radius)

		var body := StaticBody3D.new()
		body.name = "BoundaryWall_%02d" % (i + 1)
		body.collision_layer = LAYER_BOUNDARIES
		body.collision_mask = 0
		body.transform.origin = wall_pos
		body.rotation.y = -angle + (PI * 0.5)

		var col := CollisionShape3D.new()
		col.name = "Collision"
		var box := BoxShape3D.new()
		box.size = Vector3(segment_width, height, 2.0)
		col.shape = box

		body.add_child(col)
		boundary_root.add_child(body)

	return boundary_root

## Cria corpo estático retangular genérico
static func create_static_box(parent: Node3D, node_name: String, size: Vector3, pos: Vector3 = Vector3.ZERO, layer: int = LAYER_WORLD) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.collision_layer = layer
	body.collision_mask = 0
	body.transform.origin = pos

	var col := CollisionShape3D.new()
	col.name = "Collision"
	var box := BoxShape3D.new()
	box.size = size
	col.shape = box

	body.add_child(col)
	parent.add_child(body)
	return body

## Cria corpo estático cilíndrico genérico
static func create_static_cylinder(parent: Node3D, node_name: String, radius: float, height: float, pos: Vector3 = Vector3.ZERO, layer: int = LAYER_WORLD) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.collision_layer = layer
	body.collision_mask = 0
	body.transform.origin = pos

	var col := CollisionShape3D.new()
	col.name = "Collision"
	var cyl := CylinderShape3D.new()
	cyl.radius = radius
	cyl.height = height
	col.shape = cyl

	body.add_child(col)
	parent.add_child(body)
	return body

## Gera colisor estático a partir de MeshInstance3D existente (trimesh ou convex)
static func generate_mesh_collision(mesh_node: MeshInstance3D, is_convex: bool = false, layer: int = LAYER_WORLD) -> StaticBody3D:
	if mesh_node == null or mesh_node.mesh == null:
		return null

	var body := StaticBody3D.new()
	body.name = mesh_node.name + "_StaticBody"
	body.collision_layer = layer
	body.collision_mask = 0

	var col := CollisionShape3D.new()
	col.name = "CollisionShape"

	if is_convex:
		col.shape = mesh_node.mesh.create_convex_shape()
	else:
		col.shape = mesh_node.mesh.create_trimesh_shape()

	body.add_child(col)
	mesh_node.add_child(body)
	return body
