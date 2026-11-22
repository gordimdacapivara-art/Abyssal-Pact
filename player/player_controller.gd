class_name PlayerController
extends CharacterBody3D
## Controlador do personagem em terceira pessoa — movimentação, câmera,
## estados e interação.
##
## ESCOPO DESTA ETAPA: caminhada/corrida/sprint, salto, queda, aterrissagem,
## esquiva (Ctrl), câmera em 3ª pessoa com colisão e distância controlável,
## interação via contrato PlayerInteractable e máquina de estados de movimento
## com âncoras de animação (PlayerAnimator). NÃO implementa combate,
## progressão, dano, morte ou sincronização de rede — estrutura pronta para
## receber essas camadas depois.
##
## Integração:
##   - Sinais LOCAIS (não são eventos de domínio cruzado): movement_state_changed,
##     dodged, landed, interaction_target_changed. UI/HUD e sistemas futuros
##     conectam aqui; quando a interação tocar missões/itens/descobertas,
##     quem emite no EventBus será o sistema de domínio acionado.
##   - Modelo PROVISÓRIO: cápsula + marca de face (ModelRoot). A substituição
##     por GLB deve preservar os nomes de clipe do PlayerAnimator (contrato).
##
## Esquema de velocidades: WASD = caminhada; Shift = corrida; Shift mantido
## em movimento por `sprint_hold_time` = sprint (auto-sprint; remapeável).

signal movement_state_changed(previous: int, current: int)
signal dodged(direction: Vector3)
signal landed(impact_speed: float)
signal interaction_target_changed(target: Node3D)

## Modelo visual provisório (cápsula); falso quando GLB definitivo entrar.
const MODEL_IS_PLACEHOLDER := true

@export_group("Locomoção")
@export var walk_speed := 3.2
@export var run_speed := 5.6
@export var sprint_speed := 8.2
@export var sprint_hold_time := 0.9
@export var turn_speed := 11.0
@export_group("Aceleração")
@export var ground_accel := 26.0
@export var ground_decel := 30.0
@export var air_accel := 9.0
@export var air_decel := 3.0
@export var dodge_accel := 60.0
@export_group("Salto e gravidade")
@export var jump_velocity := 7.4
@export var gravity := 18.0
@export var fall_gravity_multiplier := 1.35
@export var max_fall_speed := 40.0
@export var coyote_time := 0.12
@export var jump_buffer_time := 0.14
@export_group("Aterrissagem")
@export var land_lock_time := 0.14
@export var land_control_factor := 0.35
@export var land_impact_threshold := 4.5
@export_group("Esquiva")
@export var dodge_speed := 10.0
@export var dodge_duration := 0.34
@export var dodge_cooldown := 0.6
@export_group("Nós")
@export var camera_rig_path: NodePath = ^"CameraRig"
@export var sensor_path: NodePath = ^"InteractionSensor"
@export var animator_path: NodePath = ^"Animator"
@export var model_slot_path: NodePath = ^"ModelRoot"
@export_group("Modelo do pipeline")
@export var load_reference_model := true
@export var reference_model_path := "res://assets/models/characters/reference/char_ref_humanoid.glb"
@export_group("Multiplayer em Rede")
@export var peer_id: int = 1

var is_local_player: bool = true
var _network_target_position := Vector3.ZERO
var _network_target_rotation_y := 0.0
var _net_sync_timer := 0.0

var _state: int = MovementStates.State.IDLE
var _sprint_hold := 0.0
var _coyote := 0.0
var _jump_buffer := 0.0
var _dodge_timer := 0.0
var _dodge_cooldown := 0.0
var _dodge_dir := Vector3.ZERO
var _land_timer := 0.0
var _was_airborne := false
var _impact_speed := 0.0

@onready var _rig: PlayerCameraRig = get_node_or_null(camera_rig_path) as PlayerCameraRig
@onready var _sensor: InteractionSensor = get_node_or_null(sensor_path) as InteractionSensor
@onready var _animator: PlayerAnimator = get_node_or_null(animator_path) as PlayerAnimator

func _ready() -> void:
	floor_snap_length = 0.4
	floor_max_angle = deg_to_rad(50.0)
	floor_stop_on_slope = true
	if _rig != null:
		_rig.exclude_body(self)
	if _sensor != null:
		_sensor.target_changed.connect(_on_sensor_target_changed)

	# Configuração de autoridade multiplayer
	var net_mgr := Game.get_system(SystemNames.NET) as MultiplayerManager if Engine.has_singleton("Game") or get_tree().root.has_node("Net") else null
	if net_mgr != null and net_mgr.is_session_active():
		if peer_id != multiplayer.get_unique_id():
			is_local_player = false
			if _rig != null:
				_rig.set_process(false)
				_rig.set_physics_process(false)
				var cam := _rig.get_node_or_null("SpringArm3D/Camera3D") as Camera3D
				if cam != null:
					cam.current = false
		net_mgr.register_player_pawn(peer_id, self)

	# Cena de gameplay: mouse capturado por padrão para o jogador local (menus liberam).
	if is_local_player:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if load_reference_model:
		var model := PlayerModelLoader.attach(self, reference_model_path)
		if model != null:
			print("[Player] modelo do pipeline anexado: %s" % reference_model_path)

## Atualiza estado e transform recebidos da replicação de rede para proxies remotos.
func apply_network_state(pos: Vector3, rot_y: float, vel: Vector3, state_id: int) -> void:
	_network_target_position = pos
	_network_target_rotation_y = rot_y
	velocity = vel
	_set_state(state_id)

## Accessor para subsistemas (loader de modelo, combate, testes).
func animator() -> PlayerAnimator:
	return _animator

## Slot onde o pipeline anexa modelos GLB (ModelRoot).
func model_slot() -> Node3D:
	return get_node_or_null(model_slot_path) as Node3D

func _physics_process(delta: float) -> void:
	if not is_local_player:
		global_position = global_position.lerp(_network_target_position, clampf(delta * 15.0, 0.0, 1.0))
		rotation.y = lerp_angle(rotation.y, _network_target_rotation_y, clampf(delta * 15.0, 0.0, 1.0))
		if _animator != null:
			_animator.update(_state, _planar_speed_ratio())
		return

	# Velocidade vertical de impacto (do frame anterior) para aterrissagem.
	_impact_speed = -velocity.y if velocity.y < 0.0 else 0.0
	_update_cooldowns(delta)

	var input_dir := _camera_relative_input()
	_update_sprint_hold(delta, input_dir)

	if Input.is_action_just_pressed(PlayerInputMap.DODGE):
		_try_start_dodge(input_dir)
	if Input.is_action_just_pressed(PlayerInputMap.INTERACT):
		request_interact()
	if Input.is_action_just_pressed(PlayerInputMap.JUMP):
		_jump_buffer = jump_buffer_time

	# Gravidade: queda mais pesada que subida (sensação dark fantasy).
	if not is_on_floor():
		var g := gravity * (fall_gravity_multiplier if velocity.y < 0.0 else 1.0)
		velocity.y = maxf(velocity.y - g * delta, -max_fall_speed)

	# Salto (buffer + coyote; cancela aterrissagem; bloqueado em esquiva).
	if _jump_buffer > 0.0 and _coyote > 0.0 and _dodge_timer <= 0.0:
		velocity.y = jump_velocity
		_jump_buffer = 0.0
		_coyote = 0.0
		_land_timer = 0.0
		_set_state(MovementStates.State.RISE)

	# Locomoção horizontal (direção relativa à câmera; analógica).
	var target := _horizontal_target(input_dir)
	var accel := _acceleration()
	velocity.x = move_toward(velocity.x, target.x, accel * delta)
	velocity.z = move_toward(velocity.z, target.z, accel * delta)

	move_and_slide()
	_resolve_state(input_dir)
	_face_motion(delta, input_dir)
	if _animator != null:
		_animator.update(_state, _planar_speed_ratio())

	# Sincronização periódica de rede para o jogador local
	var net_mgr := Game.get_system(SystemNames.NET) as MultiplayerManager if Engine.has_singleton("Game") or get_tree().root.has_node("Net") else null
	if net_mgr != null and net_mgr.is_session_active():
		_net_sync_timer += delta
		if _net_sync_timer >= 0.05:
			_net_sync_timer = 0.0
			net_mgr.rpc_send_player_transform(global_position, rotation.y, velocity, _state)

# ---------------------------------------------------------------- ESTADOS ---

func state() -> int:
	return _state

func state_name() -> String:
	return MovementStates.name_of(_state)

func is_sprint_ready() -> bool:
	return _sprint_hold >= sprint_hold_time

func sprint_hold_ratio() -> float:
	return clampf(_sprint_hold / maxf(sprint_hold_time, 0.001), 0.0, 1.0)

func planar_speed() -> float:
	return Vector2(velocity.x, velocity.z).length()

func interaction_target() -> Node3D:
	return _sensor.current_target() if _sensor != null else null

## Interação explícita (tecla E; API pública para testes/UI futuros).
func request_interact() -> bool:
	if _sensor == null:
		return false
	return _sensor.try_interact(self)

## Reusa o corpo em outro ponto (spawn/ressurgimento/testes): zera dinâmica.
func teleport_to(position: Vector3) -> void:
	global_position = position
	velocity = Vector3.ZERO
	_dodge_timer = 0.0
	_dodge_cooldown = 0.0
	_land_timer = 0.0
	_jump_buffer = 0.0
	_coyote = 0.0
	_set_state(MovementStates.State.IDLE)

func debug_summary() -> String:
	var grounded := "chão" if is_on_floor() else "ar"
	return "%s | %.1f m/s | %s" % [state_name(), planar_speed(), grounded]

# ------------------------------------------------------------------ INTERNO --

func _update_cooldowns(delta: float) -> void:
	if is_on_floor():
		_coyote = coyote_time
	else:
		_coyote = maxf(_coyote - delta, 0.0)
	_jump_buffer = maxf(_jump_buffer - delta, 0.0)
	_dodge_cooldown = maxf(_dodge_cooldown - delta, 0.0)
	_dodge_timer = maxf(_dodge_timer - delta, 0.0)
	_land_timer = maxf(_land_timer - delta, 0.0)

func _update_sprint_hold(delta: float, input_dir: Vector3) -> void:
	var sprint_pressed := Input.is_action_pressed(PlayerInputMap.SPRINT)
	var moving := input_dir.length_squared() > 0.0001
	if sprint_pressed and moving:
		_sprint_hold = minf(_sprint_hold + delta, sprint_hold_time * 2.0)
	else:
		_sprint_hold = 0.0

func _locomotion_state() -> int:
	if Input.is_action_pressed(PlayerInputMap.SPRINT):
		if _sprint_hold >= sprint_hold_time:
			return MovementStates.State.SPRINT
		return MovementStates.State.RUN
	return MovementStates.State.WALK

func _horizontal_target(input_dir: Vector3) -> Vector3:
	if _dodge_timer > 0.0:
		return _dodge_dir * dodge_speed
	if input_dir.length_squared() <= 0.0001:
		return Vector3.ZERO
	var speed := _locomotion_speed()
	if _land_timer > 0.0:
		speed *= land_control_factor
	return input_dir * speed

func _locomotion_speed() -> float:
	match _locomotion_state():
		MovementStates.State.SPRINT:
			return sprint_speed
		MovementStates.State.RUN:
			return run_speed
		_:
			return walk_speed

func _acceleration() -> float:
	if _dodge_timer > 0.0:
		return dodge_accel
	if is_on_floor():
		return ground_accel if _is_pushing() else ground_decel
	return air_accel if _is_pushing() else air_decel

func _is_pushing() -> bool:
	if _dodge_timer > 0.0:
		return true
	return _horizontal_target(_camera_relative_input()).length_squared() > 0.0001

## Direção de movimento planar relativa à câmera (magnitude analógica 0..1).
func _camera_relative_input() -> Vector3:
	var planar := Input.get_vector(
		PlayerInputMap.MOVE_LEFT, PlayerInputMap.MOVE_RIGHT,
		PlayerInputMap.MOVE_FORWARD, PlayerInputMap.MOVE_BACK)
	if planar.length_squared() < 0.0001:
		return Vector3.ZERO
	var reference := _rig.flat_basis() if _rig != null else Basis.IDENTITY
	var forward := Vector3(-reference.z.x, 0.0, -reference.z.z)
	var right := Vector3(reference.x.x, 0.0, reference.x.z)
	return right * planar.x + forward * (-planar.y)

func _try_start_dodge(input_dir: Vector3) -> void:
	if _dodge_cooldown > 0.0 or _dodge_timer > 0.0:
		return
	if not is_on_floor():
		return # decisão provisória: esquiva só no chão
	if input_dir.length_squared() > 0.0001:
		_dodge_dir = input_dir.normalized()
	else:
		_dodge_dir = _facing().normalized()
	_dodge_timer = dodge_duration
	_dodge_cooldown = dodge_duration + dodge_cooldown
	_land_timer = 0.0
	velocity.x = _dodge_dir.x * dodge_speed
	velocity.z = _dodge_dir.z * dodge_speed
	_set_state(MovementStates.State.DODGE)
	dodged.emit(_dodge_dir)

## Direção planar de face corrente (-Z da base global).
func _facing() -> Vector3:
	var forward := -global_basis.z
	forward.y = 0.0
	return forward

func _resolve_state(input_dir: Vector3) -> void:
	var grounded := is_on_floor()
	# Aterrissagem: estava no ar e agora há chão (impacto relevante).
	if _was_airborne and grounded and _dodge_timer <= 0.0:
		if _impact_speed > land_impact_threshold:
			_land_timer = land_lock_time
			landed.emit(_impact_speed)
	_was_airborne = not grounded

	if _dodge_timer > 0.0:
		_set_state(MovementStates.State.DODGE)
	elif not grounded:
		_set_state(MovementStates.State.RISE if velocity.y > 1.0 else MovementStates.State.FALL)
	elif _land_timer > 0.0:
		_set_state(MovementStates.State.LAND)
	elif input_dir.length_squared() > 0.0001:
		_set_state(_locomotion_state())
	else:
		_set_state(MovementStates.State.IDLE)

func _face_motion(delta: float, input_dir: Vector3) -> void:
	var desired := Vector3.ZERO
	if _dodge_timer > 0.0:
		desired = _dodge_dir
	else:
		var planar := Vector3(velocity.x, 0.0, velocity.z)
		if planar.length() > 0.6:
			desired = planar.normalized()
		elif input_dir.length_squared() > 0.0:
			desired = input_dir.normalized()
	if desired.is_zero_approx():
		return
	var target_yaw := atan2(-desired.x, -desired.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, minf(turn_speed * delta, 1.0))

func _planar_speed_ratio() -> float:
	return clampf(planar_speed() / maxf(run_speed, 0.001), 0.0, 1.5)

func _on_sensor_target_changed(target: Node3D) -> void:
	interaction_target_changed.emit(target)

func _set_state(next: int) -> void:
	if _state == next:
		return
	var previous := _state
	_state = next
	movement_state_changed.emit(previous, next)
