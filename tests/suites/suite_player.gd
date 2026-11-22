extends TestCase
## Suíte PLAYER — controlador do personagem (movimentação/câmera/interação).
##
## Simula FÍSICA REAL em headless: monta um mundo de prova em código, instan-
## cia player.tscn e dirige o Input via Input.action_press/release. As esperas
## usam physics_frame (delta fixo 1/60 por passo de física) e Engine.max_fps=60
## mantém process e física 1:1 para o watchdog do TestHost continuar válido.
##
## Valida: mapa de entrada remapeável, contratos da cena, caminhada/corrida/
## sprint, salto/queda/aterrissagem, esquiva com cooldown, colisão de corpo
## contra obstáculo, órbita/clampes/zoom/colisão de câmera, ciclo de interação
## e contrato do driver de animação.

const PLAYER_SCENE_PATH := "res://player/player.tscn"
const SETTLE_FRAMES := 45

var _world: Node3D = null
var _player: PlayerController = null
var _rig: PlayerCameraRig = null
var _animator: PlayerAnimator = null
var _states_seen: Array[int] = []
var _land_events: Array[float] = []
var _dodge_events: int = 0
var _target_events: int = 0
var _state_handler: Callable = Callable()
var _land_handler: Callable = Callable()
var _dodge_handler: Callable = Callable()
var _target_handler: Callable = Callable()

func system_label() -> String:
	return "player"

## Mundo de prova do suíte: chão, parede frontal, bloco atrás do spawn
## (colisão de câmera) e interativo de teste.
class StubInteractable:
	extends PlayerInteractable

	var uses := 0

	func interact(_player: Node3D) -> bool:
		uses += 1
		return true

func execute() -> void:
	Engine.max_fps = 60 # física 1:1 com frames de processo (watchdog válido)
	await _test_input_map()
	await _build_world()
	await _test_scene_contracts()
	await _test_settle()
	await _test_walk()
	await _test_run_and_sprint()
	await _test_jump_fall_land()
	await _test_free_fall()
	await _test_dodge()
	await _test_body_collision()
	await _test_camera_rig()
	await _test_interaction()
	await _test_animator_contract()
	await _teardown()

# ------------------------------------------------------------------ HELPERS --

func wait_physics(frames: int) -> void:
	for i in frames:
		await host.get_tree().physics_frame
	host.call("heartbeat")

func press(action: StringName) -> void:
	Input.action_press(action)

func release(action: StringName) -> void:
	Input.action_release(action)

func release_all() -> void:
	for action in PlayerInputMap.ALL_ACTIONS:
		Input.action_release(action)

func tap(action: StringName) -> void:
	press(action)
	await wait_physics(2)
	release(action)

func reset_body(position: Vector3, yaw: float = 0.0) -> void:
	release_all()
	_player.rotation.y = yaw
	_player.teleport_to(position)
	await wait_physics(3)

func wait_grounded(max_frames: int) -> bool:
	for i in max_frames:
		if _player.is_on_floor():
			return true
		await wait_physics(1)
	return _player.is_on_floor()

func wait_state(wanted: int, max_frames: int) -> bool:
	for i in max_frames:
		if _player.state() == wanted:
			return true
		await wait_physics(1)
	return _player.state() == wanted

# ------------------------------------------------------------------ TESTES --

func _test_input_map() -> void:
	section("mapa de entrada: ações remapeáveis presentes")
	var missing := PlayerInputMap.missing_actions()
	check_true(missing.is_empty(), "nenhuma ação pode faltar no InputMap (faltou: %s)" % ", ".join(missing))
	for action in PlayerInputMap.ALL_ACTIONS:
		check_true(InputMap.has_action(action), "ação '%s' deve existir no InputMap" % action)
	section("remapeamento em runtime")
	var originals := InputMap.action_get_events(&"camera_down")
	check_true(originals.size() > 0, "camera_down deve ter evento padrão")
	var replacement := InputEventKey.new()
	replacement.physical_keycode = KEY_F12
	PlayerInputMap.remap_action(&"camera_down", replacement)
	var after := InputMap.action_get_events(&"camera_down")
	check_eq(after.size(), 1, "remapeamento deve substituir eventos anteriores")
	check_true(after[0] is InputEventKey, "evento remapeado deve ser de teclado")
	InputMap.action_erase_events(&"camera_down")
	for original in originals:
		InputMap.action_add_event(&"camera_down", original)
	check_eq(InputMap.action_get_events(&"camera_down").size(), originals.size(), "restauração deve recolocar os eventos originais")

func _build_world() -> void:
	section("montagem do mundo de prova")
	_world = Node3D.new()
	_world.name = "PlayerTestWorld"
	host.get_tree().root.add_child(_world)

	_world.add_child(_make_block(Vector3(40, 1, 40), Vector3(0, -0.5, 0))) # chão
	_world.add_child(_make_block(Vector3(8, 3, 0.7), Vector3(0, 1.5, -9))) # parede frontal
	_world.add_child(_make_block(Vector3(2, 3, 2), Vector3(0, 1.5, 10.5))) # colisão de câmera (atrás)

	var stone := StubInteractable.new()
	stone.name = "TestStone"
	stone.prompt = "Examinar pedra de prova (TEST-INT-001)"
	var stone_shape := CollisionShape3D.new()
	var stone_box := BoxShape3D.new()
	stone_box.size = Vector3(0.6, 1.2, 0.6)
	stone_shape.shape = stone_box
	stone.add_child(stone_shape)
	stone.position = Vector3(0, 0.7, 4.2)
	_world.add_child(stone)

	var packed: PackedScene = load(PLAYER_SCENE_PATH) as PackedScene
	check_not_null(packed, "player.tscn deve carregar")
	var instance := packed.instantiate()
	_player = instance as PlayerController
	check_not_null(_player, "raiz do player.tscn deve ser PlayerController")
	_world.add_child(_player)
	_player.position = Vector3(0, 0.05, 6)
	_rig = _player.get_node("CameraRig") as PlayerCameraRig
	_animator = _player.get_node("Animator") as PlayerAnimator

	_state_handler = func(_previous: int, current: int) -> void:
		_states_seen.append(current)
	_land_handler = func(impact: float) -> void:
		_land_events.append(impact)
	_dodge_handler = func(_dir: Vector3) -> void:
		_dodge_events += 1
	_target_handler = func(_target: Node3D) -> void:
		_target_events += 1
	_player.movement_state_changed.connect(_state_handler)
	_player.landed.connect(_land_handler)
	_player.dodged.connect(_dodge_handler)
	_player.interaction_target_changed.connect(_target_handler)
	await wait_physics(SETTLE_FRAMES)

func _make_block(size: Vector3, at: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	body.position = at
	return body

func _test_scene_contracts() -> void:
	section("cena: nós e camadas de colisão")
	check_eq(_player.collision_layer, 2, "corpo do player deve usar a camada 2 (atores)")
	check_eq(_player.collision_mask, 1, "corpo do player deve colidir com o cenário (camada 1)")
	check_not_null(_player.get_node_or_null("InteractionSensor"), "sensor de interação deve existir")
	check_not_null(_player.get_node_or_null("Animator"), "driver de animação deve existir")
	check_not_null(_player.get_node_or_null("AnimationPlayer"), "AnimationPlayer deve existir (alvo do GLB)")
	check_not_null(_player.get_node_or_null("AnimationTree"), "AnimationTree deve existir (alvo do GLB)")
	check_not_null(_rig, "rig de câmera deve existir")
	check_not_null(_rig.camera(), "câmera do rig deve existir")
	check_true(_rig.camera().current, "câmera do rig deve estar ativa")
	var arm := _rig.get_node("SpringArm3D") as SpringArm3D
	check_eq(arm.collision_mask, 1, "braço da câmera deve colidir apenas com o cenário")
	var sensor := _player.get_node("InteractionSensor") as InteractionSensor
	check_eq(sensor.collision_mask, 2, "sensor deve varrer a camada de interativos (2)")
	check_true(PlayerController.MODEL_IS_PLACEHOLDER, "modelo provisório deve estar sinalizado até o GLB entrar")

func _test_settle() -> void:
	section("assentamento no chão")
	check_true(_player.is_on_floor(), "player deve assentar no chão após o spawn")
	check_true(_player.state() == MovementStates.State.IDLE, "estado inicial deve ser IDLE")
	check_true(absf(_player.global_position.y) < 0.05, "pés do player devem ficar no nível do chão")

func _test_walk() -> void:
	section("caminhada (WASD relativo à câmera)")
	await reset_body(Vector3(0, 0.05, 6), 0.0)
	var start := _player.global_position
	press(&"move_forward")
	await wait_physics(60)
	var moved := start.z - _player.global_position.z
	check_true(moved > 2.2, "caminhada deve avançar em -Z (avançou %.2f m)" % moved)
	check_eq(_player.state(), MovementStates.State.WALK, "estado deve ser WALK sem Shift")
	check_true(absf(_player.rotation.y) < 0.2, "corpo deve girar suavemente para a direção de movimento")
	release(&"move_forward")
	await wait_physics(20)
	check_eq(_player.state(), MovementStates.State.IDLE, "soltar o input deve voltar a IDLE")

func _test_run_and_sprint() -> void:
	section("corrida (Shift) e sprint (Shift mantido)")
	await reset_body(Vector3(0, 0.05, 6), 0.0)
	var start := _player.global_position
	press(&"move_forward")
	press(&"sprint")
	await wait_physics(30)
	check_eq(_player.state(), MovementStates.State.RUN, "Shift recém-pressionado deve ser RUN")
	check_true(_player.planar_speed() > 4.5, "velocidade de corrida deve superar a caminhada (%.1f m/s)" % _player.planar_speed())
	await wait_physics(40)
	check_eq(_player.state(), MovementStates.State.SPRINT, "Shift mantido deve evoluir para SPRINT")
	check_true(_player.planar_speed() > 7.0, "sprint deve ser mais rápido que a corrida (%.1f m/s)" % _player.planar_speed())
	var sprint_moved := start.z - _player.global_position.z
	check_true(sprint_moved > 5.5, "distância de sprint deve ser bem maior que a de caminhada (%.2f m)" % sprint_moved)
	release(&"sprint")
	await wait_physics(6)
	check_eq(_player.state(), MovementStates.State.WALK, "soltar Shift deve voltar a WALK")
	release(&"move_forward")
	await wait_physics(10)

func _test_jump_fall_land() -> void:
	section("salto: subida, queda e aterrissagem")
	await reset_body(Vector3(0, 0.05, 6), 0.0)
	var base_y := _player.global_position.y
	await tap(&"jump")
	await wait_physics(8)
	check_false(_player.is_on_floor(), "pular deve deixar o chão")
	check_eq(_player.state(), MovementStates.State.RISE, "subida deve ser RISE")
	check_true(_player.global_position.y > base_y + 0.2, "salto deve elevar o personagem")
	var reached_fall: bool = await wait_state(MovementStates.State.FALL, 60)
	check_true(reached_fall, "após o ápice deve entrar em FALL")
	var landed_ok: bool = await wait_grounded(180)
	check_true(landed_ok, "deve aterrissar")
	check_true(absf(_player.global_position.y - base_y) < 0.05, "aterrissagem deve ocorrer no nível de partida")
	check_true(_land_events.size() >= 1, "sinal landed deve ser emitido na aterrissagem")
	check_true(_states_seen.has(MovementStates.State.LAND), "estado LAND deve ocorrer na aterrissagem")
	await wait_physics(20)
	check_eq(_player.state(), MovementStates.State.IDLE, "após aterrissar deve voltar a IDLE")

func _test_free_fall() -> void:
	section("queda livre e detecção de chão")
	await reset_body(Vector3(0, 5, 6), 0.0)
	await wait_physics(3)
	check_eq(_player.state(), MovementStates.State.FALL, "soltar de altura deve ser FALL")
	var fell_ok: bool = await wait_grounded(180)
	check_true(fell_ok, "queda deve terminar no chão")
	check_true(absf(_player.global_position.y) < 0.05, "queda deve assentar no nível do chão")

func _test_dodge() -> void:
	section("esquiva (Ctrl): impulso, retorno e cooldown")
	await reset_body(Vector3(0, 0.05, 6), 0.0)
	var start_z := _player.global_position.z
	await tap(&"dodge")
	var dodge_started: bool = await wait_state(MovementStates.State.DODGE, 5)
	check_true(dodge_started, "esquiva deve entrar em DODGE")
	check_true(_dodge_events >= 1, "sinal dodged deve ser emitido")
	await wait_physics(30)
	var dodge_moved := start_z - _player.global_position.z
	check_true(dodge_moved > 2.5, "esquiva deve impulsionar à frente (%.2f m)" % dodge_moved)
	check_eq(_player.state(), MovementStates.State.IDLE, "após a esquiva deve voltar a IDLE (sem input)")
	await tap(&"dodge")
	await wait_physics(4)
	check_false(_player.state() == MovementStates.State.DODGE, "esquiva em cooldown deve ser recusada")
	await wait_physics(45)
	await tap(&"dodge")
	var dodge_again: bool = await wait_state(MovementStates.State.DODGE, 5)
	check_true(dodge_again, "após o cooldown a esquiva volta a funcionar")
	release_all()
	await wait_physics(70) # agota esquiva + cooldown antes das próximas seções

func _test_body_collision() -> void:
	section("colisão de corpo: parede bloqueia sem atravessar")
	await reset_body(Vector3(0, 0.05, -6), 0.0)
	press(&"move_forward")
	await wait_physics(90)
	var z := _player.global_position.z
	check_true(z > -8.45, "parede deve impedir travessia (z final %.2f; face em -8,65)" % z)
	check_true(_player.is_on_wall(), "encostado na parede deve reportar colisão lateral")
	check_true(_player.planar_speed() < 1.0, "empurrando contra a parede a velocidade horizontal deve cair")
	release(&"move_forward")
	await wait_physics(10)

func _test_camera_rig() -> void:
	section("câmera: pitch com clamp e yaw")
	_rig.rotation = Vector3.ZERO
	_rig.apply_look(Vector2(0, -1000))
	check_true(absf(_rig.rotation.x - deg_to_rad(62.0)) < 0.01, "olhar para cima deve travar no clamp máximo")
	_rig.apply_look(Vector2(0, 1000))
	check_true(absf(_rig.rotation.x - deg_to_rad(-72.0)) < 0.01, "olhar para baixo deve travar no clamp mínimo")
	var yaw_before := _rig.rotation.y
	_rig.apply_look(Vector2(5, 0))
	check_true(_rig.rotation.y < yaw_before, "mouse à direita deve girar a câmera à direita")
	_rig.rotation = Vector3.ZERO

	section("câmera: colisão com cenário (recuo ao encostar)")
	await reset_body(Vector3(0, 0.05, 6), 0.0)
	await wait_physics(10)
	var blocked := _rig.hit_length()
	check_true(blocked < 4.0, "bloco atrás do spawn deve recuar a câmera (hit %.2f)" % blocked)
	check_true(blocked > 0.5, "recuo não deve colapsar sobre o próprio corpo (exclusão ativa)")
	press(&"move_forward")
	await wait_physics(45)
	release(&"move_forward")
	check_true(absf(_rig.hit_length() - 4.2) < 0.2, "longe do obstáculo a câmera deve voltar à distância cheia")

	section("câmera: distância (roda + API) com clampes")
	_rig.set_distance(50.0)
	check_true(absf(_rig.target_distance() - 6.0) < 0.001, "distância deve travar no máximo")
	_rig.set_distance(0.05)
	check_true(absf(_rig.target_distance() - 1.8) < 0.001, "distância deve travar no mínimo")
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
	wheel.pressed = true
	_rig._unhandled_input(wheel)
	await wait_physics(3)
	check_true(absf(_rig.target_distance() - 2.15) < 0.001, "roda para baixo deve afastar a câmera")
	await wait_physics(35)
	check_true(absf(_rig.distance() - _rig.target_distance()) < 0.4, "distância real deve convergir ao alvo")

func _test_interaction() -> void:
	section("interação: detecção, prompt e execução")
	await reset_body(Vector3(0, 0.05, 6), 0.0)
	await wait_physics(15)
	var stone := _world.get_node("TestStone") as StubInteractable
	check_not_null(stone, "interativo de prova deve existir no mundo")
	var target := _player.interaction_target()
	check_eq(target, stone, "alvo mais próximo deve ser o interativo de prova")
	check_true(_target_events >= 1, "sinal interaction_target_changed deve ser emitido")
	check_true(stone.interaction_prompt().contains("TEST-INT-001"), "prompt deve expor o id editorial")
	check_true(_player.request_interact(), "interação deve executar no alvo")
	check_eq(stone.uses, 1, "interação deve chegar ao objeto uma vez")
	stone.enabled = false
	check_false(_player.request_interact(), "interativo desabilitado deve recusar")
	check_eq(stone.uses, 1, "interação recusada não deve chegar ao objeto")
	stone.enabled = true

func _test_animator_contract() -> void:
	section("animação: contrato de nomes e modelo do pipeline anexado")
	# O controlador vivo reafirma IDLE a cada frame de física; para validar a
	# máquina diretamente, ele fica pausado durante este teste.
	_player.set_physics_process(false)
	_player.set_process(false)
	check_true(_animator.has_clip("idle"), "clipe idle deve existir (modelo GLB do pipeline auto-anexado)")
	check_true(_animator.has_clip("dodge"), "clipe dodge deve existir (modelo GLB do pipeline auto-anexado)")
	check_true(_animator.uses_tree(), "AnimationTree do modelo deve estar em comando")
	for state_value in MovementStates.State.values():
		var expected := String(PlayerAnimator.ANIM.get(state_value, ""))
		if expected.is_empty():
			continue
		# Simula o controlador: update a cada frame até a máquina chegar
		# (travel emitido durante crossfade é reemitido pelo animator).
		for i in 40:
			_animator.update(state_value)
			await wait_frames(1)
			if _animator.current_node() == expected:
				break
		check_eq(_animator.current_node(), expected, "estado %d deve viajar para '%s'" % [state_value, expected])
		check_true(_animator.current_clip().is_empty(), "via AnimationTree, current_clip fica vazio (estado %d)" % state_value)
	_player.set_process(true)
	_player.set_physics_process(true)
	check_eq(String(PlayerAnimator.ANIM[MovementStates.State.IDLE]), "idle", "âncora IDLE deve ser 'idle'")
	check_eq(String(PlayerAnimator.ANIM[MovementStates.State.DODGE]), "dodge", "âncora DODGE deve ser 'dodge'")
	check_eq(PlayerAnimator.ANIM.size(), 8, "contrato deve cobrir os 8 estados de movimento")

# ---------------------------------------------------------------- LIMPEZA ---

func _teardown() -> void:
	release_all()
	if _state_handler.is_valid() and _player != null and is_instance_valid(_player):
		_player.movement_state_changed.disconnect(_state_handler)
		_player.landed.disconnect(_land_handler)
		_player.dodged.disconnect(_dodge_handler)
		_player.interaction_target_changed.disconnect(_target_handler)
		_player.queue_free()
	if _world != null and is_instance_valid(_world):
		_world.queue_free()
	Engine.max_fps = 0
	await wait_frames(3)
