class_name WorldBoundary
extends Node3D
## Limites geográficos da região: cria paredes estáticas de colisão e barreira visual.

@export var radius: float = 150.0
@export var barrier_height: float = 20.0
@export var segments: int = 16
@export var center: Vector3 = Vector3.ZERO

func _ready() -> void:
	_build_boundaries()

func setup(config: Dictionary) -> void:
	radius = float(config.get("radius", radius))
	if config.has("center") and config["center"] is Vector3:
		center = config["center"]
	_build_boundaries()

func _build_boundaries() -> void:
	for child in get_children():
		child.queue_free()

	position = center
	var static_body := StaticBody3D.new()
	static_body.name = "BoundaryColliders"
	static_body.collision_layer = 1 # Bloqueia o jogador
	static_body.collision_mask = 0
	add_child(static_body)

	var angle_step := (PI * 2.0) / float(segments)
	var segment_width := 2.0 * radius * sin(angle_step * 0.5) * 1.05

	for i in range(segments):
		var angle := float(i) * angle_step
		var next_angle := float(i + 1) * angle_step
		var mid_angle := (angle + next_angle) * 0.5

		var pos_x := cos(mid_angle) * radius
		var pos_z := sin(mid_angle) * radius

		# Forma de colisão
		var col_shape := CollisionShape3D.new()
		col_shape.name = "Shape_%d" % i
		var box := BoxShape3D.new()
		box.size = Vector3(segment_width, barrier_height, 2.0)
		col_shape.shape = box
		col_shape.position = Vector3(pos_x, barrier_height * 0.5, pos_z)
		col_shape.rotation.y = -mid_angle + (PI * 0.5)
		static_body.add_child(col_shape)

	# Marcador visual do limite
	var label := Label3D.new()
	label.name = "BoundaryInfo"
	label.text = "LIMITE REGIONAL (raio %.0f m)" % radius
	label.font_size = 24
	label.modulate = Color(0.6, 0.4, 0.4, 0.7)
	label.position = Vector3(0, 1.5, radius - 5.0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)
