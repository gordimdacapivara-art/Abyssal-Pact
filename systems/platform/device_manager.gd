class_name DeviceManager
extends Node
## DeviceManager — Gerenciador de dispositivos de entrada e interface adaptativa.
##
## Responsabilidade:
## 1. Detectar chaveamento em tempo real entre Teclado/Mouse e Controle Xbox.
## 2. Fornecer glifos e prompts adaptativos na interface.
## 3. Garantir navegação 100% por controle via focus neighbors automáticos (XR-051).
## 4. Gerenciar remapeamento de botões no InputMap do Godot.

enum DeviceType {
	KEYBOARD_MOUSE,
	XBOX_CONTROLLER
}

signal device_changed(new_device: DeviceType)
signal remapped_action(action: StringName, event: InputEvent)

var active_device: DeviceType = DeviceType.KEYBOARD_MOUSE
var _vibration_enabled: bool = true
var _deadzone_left_stick: float = 0.2
var _deadzone_right_stick: float = 0.25

# Mapeamento oficial de botões do controle Xbox para glifos visuais
const XBOX_GLYPHS = {
	JOY_BUTTON_A: "[A]",
	JOY_BUTTON_B: "[B]",
	JOY_BUTTON_X: "[X]",
	JOY_BUTTON_Y: "[Y]",
	JOY_BUTTON_LEFT_SHOULDER: "[LB]",
	JOY_BUTTON_RIGHT_SHOULDER: "[RB]",
	JOY_BUTTON_LEFT_STICK: "[LS]",
	JOY_BUTTON_RIGHT_STICK: "[RS]",
	JOY_BUTTON_START: "[Menu]",
	JOY_BUTTON_BACK: "[View]",
	JOY_BUTTON_DPAD_UP: "[D-Pad Cima]",
	JOY_BUTTON_DPAD_DOWN: "[D-Pad Baixo]",
	JOY_BUTTON_DPAD_LEFT: "[D-Pad Esquerda]",
	JOY_BUTTON_DPAD_RIGHT: "[D-Pad Direita]",
}

const XBOX_AXIS_GLYPHS = {
	JOY_AXIS_TRIGGER_LEFT: "[LT]",
	JOY_AXIS_TRIGGER_RIGHT: "[RT]",
	JOY_AXIS_LEFT_X: "[LS Horizontal]",
	JOY_AXIS_LEFT_Y: "[LS Vertical]",
	JOY_AXIS_RIGHT_X: "[RS Horizontal]",
	JOY_AXIS_RIGHT_Y: "[RS Vertical]",
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouse:
		if active_device != DeviceType.KEYBOARD_MOUSE:
			active_device = DeviceType.KEYBOARD_MOUSE
			device_changed.emit(active_device)
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		# Ignora micro-movimentos de ruído analógico
		if event is InputEventJoypadMotion:
			if absf(event.axis_value) < 0.2:
				return
		if active_device != DeviceType.XBOX_CONTROLLER:
			active_device = DeviceType.XBOX_CONTROLLER
			device_changed.emit(active_device)

## Retorna a representação textual do botão ou tecla atribuída à ação.
func get_action_prompt(action: StringName) -> String:
	if not InputMap.has_action(action):
		return "[?]"
		
	var events := InputMap.action_get_events(action)
	if active_device == DeviceType.XBOX_CONTROLLER:
		for ev in events:
			if ev is InputEventJoypadButton:
				var btn_idx: int = ev.button_index
				return XBOX_GLYPHS.get(btn_idx, "[Btn %d]" % btn_idx)
			elif ev is InputEventJoypadMotion:
				var axis_idx: int = ev.axis
				return XBOX_AXIS_GLYPHS.get(axis_idx, "[Eixo %d]" % axis_idx)
		# Fallback se a ação não tiver botão de controle mapeado
		return "[Controle]"
	else:
		for ev in events:
			if ev is InputEventKey:
				var key_text: String = OS.get_keycode_string(ev.physical_keycode)
				if key_text.is_empty():
					key_text = OS.get_keycode_string(ev.keycode)
				return "[%s]" % key_text
			elif ev is InputEventMouseButton:
				match ev.button_index:
					MOUSE_BUTTON_LEFT: return "[Mouse Esq]"
					MOUSE_BUTTON_RIGHT: return "[Mouse Dir]"
					MOUSE_BUTTON_MIDDLE: return "[Mouse Meio]"
					_: return "[Mouse]"
		return "[Teclado]"

## Configura recursivamente a árvore de foco para navegação fluida via controle (D-Pad / Analógico).
func setup_focus_tree(parent: Control) -> void:
	if parent == null:
		return
		
	var focusable_nodes: Array[Control] = []
	_gather_focusable_controls(parent, focusable_nodes)
	
	if focusable_nodes.is_empty():
		return
		
	for i in range(focusable_nodes.size()):
		var current := focusable_nodes[i]
		var prev := focusable_nodes[i - 1] if i > 0 else focusable_nodes[focusable_nodes.size() - 1]
		var next := focusable_nodes[i + 1] if i < focusable_nodes.size() - 1 else focusable_nodes[0]
		
		# Define foco automático vertical
		if current.focus_neighbor_top.is_empty():
			current.focus_neighbor_top = prev.get_path()
		if current.focus_neighbor_bottom.is_empty():
			current.focus_neighbor_bottom = next.get_path()
			
	# Dá foco ao primeiro elemento caso nenhum esteja focado
	if active_device == DeviceType.XBOX_CONTROLLER:
		focusable_nodes[0].grab_focus()

func _gather_focusable_controls(node: Node, list: Array[Control]) -> void:
	if node is Control and node.visible:
		var c := node as Control
		if c.focus_mode == Control.FOCUS_ALL:
			list.append(c)
	for child in node.get_children():
		_gather_focusable_controls(child, list)

## Remapeia uma ação em tempo de execução para um evento de entrada.
func remap_action(action: StringName, event: InputEvent) -> void:
	PlayerInputMap.remap_action(action, event)
	remapped_action.emit(action, event)

## Dispara vibração tátil no controle Xbox.
func trigger_haptic(weak_magnitude: float, strong_magnitude: float, duration_seconds: float) -> void:
	if not _vibration_enabled:
		return
	Input.start_joy_vibration(0, clampf(weak_magnitude, 0.0, 1.0), clampf(strong_magnitude, 0.0, 1.0), duration_seconds)
