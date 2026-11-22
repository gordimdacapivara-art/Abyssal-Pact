class_name PlayerCameraRig
extends Node3D
## Câmera em terceira pessoa: órbita por mouse/gamepad, colisão com o cenário
## (SpringArm3D) e controle de distância (roda do mouse + API).
##
## Rig é filho do PlayerController e NUNCA altera a física do corpo — só
## observa. O pivô acompanha o corpo automaticamente (hierarquia); a rotação
## é totalmente independente (yaw no rig, pitch no braço).
##
## Mouse: eventos brutos (_unhandled_input) — olhar = InputEventMouseMotion,
## zoom = roda (WHEEL_UP/DOWN). Gamepad: ações camera_left/right/up/down
## (analógico, remapeável). zoom por roda não é ação do InputMap (exceção
## documentada; menu de opções futuro pode expor set_distance()).

@export_group("Órbita")
@export var mouse_sensitivity := 0.0028
@export var gamepad_look_speed := 2.8
@export var pitch_min_deg := -72.0
@export var pitch_max_deg := 62.0
@export var invert_y := false
@export_group("Distância")
@export var default_distance := 4.2
@export var min_distance := 1.8
@export var max_distance := 6.0
@export var zoom_step := 0.35
@export var zoom_smoothing := 10.0
@export_group("Colisão da câmera")
@export var collision_margin := 0.25

@onready var _arm: SpringArm3D = $SpringArm3D
@onready var _camera: Camera3D = $SpringArm3D/Camera3D

var _target_distance := 4.2

func _ready() -> void:
	rotation_order = EULER_ORDER_YXZ
	_target_distance = default_distance
	if _arm != null:
		_arm.spring_length = default_distance
		_arm.margin = collision_margin
		_arm.collision_mask = 1 # cenário (camada 1)
	if _camera != null:
		_camera.current = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			var motion := event as InputEventMouseMotion
			apply_look(Vector2(motion.relative.x, motion.relative.y) * mouse_sensitivity)
	elif event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		if not button.pressed:
			return
		if button.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()

func _process(delta: float) -> void:
	var stick := Input.get_vector(
		PlayerInputMap.CAMERA_LEFT, PlayerInputMap.CAMERA_RIGHT,
		PlayerInputMap.CAMERA_UP, PlayerInputMap.CAMERA_DOWN)
	if stick.length_squared() > 0.0001:
		apply_look(Vector2(stick.x, stick.y) * gamepad_look_speed * delta)
	if _arm != null:
		_arm.spring_length = move_toward(_arm.spring_length, _target_distance, zoom_smoothing * delta)

# ------------------------------------------------------------------ CONTRATO --

## Entrada de olhar em radianos (testável; mouse e gamepad convergem aqui).
## delta.x > 0 = olhar à direita; delta.y > 0 = olhar para baixo.
func apply_look(delta_radians: Vector2) -> void:
	rotation.y -= delta_radians.x
	var dy := -delta_radians.y if invert_y else delta_radians.y
	rotation.x = clampf(
		rotation.x - dy,
		deg_to_rad(pitch_min_deg),
		deg_to_rad(pitch_max_deg))

func zoom_in() -> void:
	_target_distance = clampf(_target_distance - zoom_step, min_distance, max_distance)

func zoom_out() -> void:
	_target_distance = clampf(_target_distance + zoom_step, min_distance, max_distance)

func set_distance(value: float) -> void:
	_target_distance = clampf(value, min_distance, max_distance)

func target_distance() -> float:
	return _target_distance

func distance() -> float:
	return _arm.spring_length if _arm != null else 0.0

func camera() -> Camera3D:
	return _camera

## Distância real após colisão com o cenário (0..spring_length).
func hit_length() -> float:
	return _arm.get_hit_length() if _arm != null else 0.0

## Base planar (yaw-only) do rig — referência para movimento relativo à câmera.
func flat_basis() -> Basis:
	return Basis(Vector3.UP, rotation.y)

## Exclui o corpo do personagem da colisão do braço.
func exclude_body(body: PhysicsBody3D) -> void:
	if _arm != null:
		_arm.add_excluded_object(body.get_rid())
