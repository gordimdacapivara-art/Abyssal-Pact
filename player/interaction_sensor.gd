class_name InteractionSensor
extends Area3D
## Sensor de interação do personagem.
##
## Acompanha os PlayerInteractable em alcance (camada 2), elege o MAIS
## PRÓXIMO como alvo e expõe prompt/execução. Sem lógica de gameplay: o
## que acontece na interação é responsabilidade do objeto interativo.
##
## Integração:
##   - Consumido por: PlayerController (tecla E → try_interact), HUD
##     (current_prompt) e sistemas futuros (target_changed).
##   - Interação com domínios (missões/itens/descobertas) pertence ao
##     interativo, não ao sensor.

## Alvo mais próximo mudou (null quando não há alvo em alcance).
signal target_changed(target: Node3D)

var _targets: Array[Node3D] = []
var _target: Node3D = null

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1 << (PlayerInteractable.INTERACTABLE_LAYER - 1)
	monitorable = false
	monitoring = true
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _physics_process(_delta: float) -> void:
	_refresh_target()

func current_target() -> Node3D:
	if _target != null and not is_instance_valid(_target):
		_target = null
	return _target

## Prompt do alvo corrente ("" quando não há alvo).
func current_prompt() -> String:
	var node := current_target()
	if node != null and node.has_method("interaction_prompt"):
		var value: Variant = node.call("interaction_prompt")
		return String(value)
	return ""

## Executa a interação no alvo corrente (respeitando can_interact).
func try_interact(player: Node3D) -> bool:
	var node := current_target()
	if node == null or not node.has_method("can_interact") or not node.has_method("interact"):
		return false
	var allowed: Variant = node.call("can_interact", player)
	if not bool(allowed):
		return false
	var done: Variant = node.call("interact", player)
	return bool(done)

# ------------------------------------------------------------------ INTERNO --

func _refresh_target() -> void:
	var best: Node3D = null
	var best_distance := INF
	for node in _targets:
		if not is_instance_valid(node):
			continue
		var distance := global_position.distance_squared_to(node.global_position)
		if distance < best_distance:
			best_distance = distance
			best = node
	if best != _target:
		_target = best
		target_changed.emit(_target)

func _on_area_entered(area: Area3D) -> void:
	if area is PlayerInteractable:
		_targets.append(area)

func _on_area_exited(area: Area3D) -> void:
	_targets.erase(area)
	if _target == area:
		_target = null
