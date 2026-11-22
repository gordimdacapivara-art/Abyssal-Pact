class_name PlayerInputMap
extends RefCounted
## Ações de entrada do controlador do personagem (remapeáveis via InputMap).
##
## As ações são declaradas em project.godot (seção [input]) — aparecem no
## editor (Projeto → Mapa de Entrada) e aceitam remapeamento em runtime
## (teclado/mouse/gamepad; preparo para controles). O mouse é exceção por
## natureza: olhar da câmera e zoom da roda são eventos brutos tratados pelo
## rig da câmera, não ações do InputMap.
##
## Contrato de teste: `missing_actions()` deve retornar vazio.

const MOVE_FORWARD := "move_forward"
const MOVE_BACK := "move_back"
const MOVE_LEFT := "move_left"
const MOVE_RIGHT := "move_right"
const JUMP := "jump"
const SPRINT := "sprint"
const DODGE := "dodge"
const INTERACT := "interact"
const ABILITY_1 := "ability_1"
const ABILITY_2 := "ability_2"
const CAMERA_LEFT := "camera_left"
const CAMERA_RIGHT := "camera_right"
const CAMERA_UP := "camera_up"
const CAMERA_DOWN := "camera_down"

const MOVEMENT_ACTIONS: PackedStringArray = [
	MOVE_FORWARD, MOVE_BACK, MOVE_LEFT, MOVE_RIGHT,
]
const CAMERA_ACTIONS: PackedStringArray = [
	CAMERA_LEFT, CAMERA_RIGHT, CAMERA_UP, CAMERA_DOWN,
]
const ALL_ACTIONS: PackedStringArray = [
	MOVE_FORWARD, MOVE_BACK, MOVE_LEFT, MOVE_RIGHT,
	JUMP, SPRINT, DODGE, INTERACT, ABILITY_1, ABILITY_2,
	CAMERA_LEFT, CAMERA_RIGHT, CAMERA_UP, CAMERA_DOWN,
]

## Validação usada pelo suíte de testes e pelo playtest.
static func missing_actions() -> PackedStringArray:
	var missing := PackedStringArray()
	for action in ALL_ACTIONS:
		if not InputMap.has_action(action):
			missing.append(action)
	return missing

## Remapeamento em runtime (menu de opções futuro): descarta os eventos atuais
## da ação e atribui um novo evento (tecla, botão ou eixo). Cria a ação caso
## ela não exista.
static func remap_action(action: StringName, event: InputEvent) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
