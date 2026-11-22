class_name WorldTransitionSystem
extends RefCounted
## WorldTransitionSystem — Sistema de transições e validação de trânsito em ABYSSAL PACT.
##
## Responsabilidade:
##   - Validação de rotas terrestres, marítimas e conduítes dimensionais via WorldConnectionGraph;
##   - Garantia da autoridade do anfitrião em sessões multiplayer de mundos privados;
##   - Emissão determinística de eventos de transição no EventBus;
##   - Salvamento da última região visitada e spawn de chegada para persistência;
##   - Tratamento de falhas e recuperação segura em caso de erros de carregamento.

var _graph: WorldConnectionGraph = null
var _loader: WorldSceneLoader = null
var _world_ref: WeakRef = null
var _is_transitioning: bool = false

func _init(graph: WorldConnectionGraph, loader: WorldSceneLoader, world_manager: Object = null) -> void:
	_graph = graph
	_loader = loader
	if world_manager != null:
		_world_ref = weakref(world_manager)

func is_transitioning() -> bool:
	return _is_transitioning

## Valida se uma transição de from_region para to_region pode ocorrer.
func validate_transition(from_region: StringName, to_region: StringName, player_level: int = 1) -> Dictionary:
	if _graph == null:
		return {"allowed": true, "reason": "Grafo não carregado, validação permissiva."}
	return _graph.can_travel(from_region, to_region, player_level)

## Executa uma transição completa entre regiões ou para a Hell Forge.
func execute_transition(from_region: StringName, to_region: StringName, target_spawn: StringName = &"default", player_level: int = 1) -> Error:
	if _is_transitioning:
		push_warning("WorldTransitionSystem: transição já em andamento de '%s' para '%s'." % [from_region, to_region])
		return ERR_BUSY

	var world := _get_world()
	if world == null:
		return ERR_UNAVAILABLE

	# 1. Validação de rota
	var check := validate_transition(from_region, to_region, player_level)
	if not bool(check.get("allowed", false)):
		var reason: String = String(check.get("reason", "Trânsito não autorizado."))
		push_warning("WorldTransitionSystem: transição recusada: %s" % reason)
		EventBus.region_transition_failed.emit(from_region, to_region, ERR_UNAUTHORIZED)
		return ERR_UNAUTHORIZED

	# 2. Validação de destino
	if not world.call("has_region", to_region):
		push_error("WorldTransitionSystem: região destino '%s' não existe." % to_region)
		EventBus.region_transition_failed.emit(from_region, to_region, ERR_DOES_NOT_EXIST)
		return ERR_DOES_NOT_EXIST

	# 3. Autoridade multiplayer
	var net_mgr: MultiplayerManager = null
	if world != null and world.has_method("get_system"):
		net_mgr = world.get_system(SystemNames.NET) as MultiplayerManager
	if net_mgr == null and world is Node and (world as Node).has_node("/root/Net"):
		net_mgr = (world as Node).get_node("/root/Net") as MultiplayerManager
	if net_mgr != null and net_mgr.is_session_active():
		if not net_mgr.is_host():
			# Cliente solicita transição ao anfitrião
			net_mgr.rpc_id(Invariants.HOST_PEER_ID, "rpc_request_region_transition", to_region, target_spawn)
			return OK
		else:
			# Anfitrião replica a transição para todos os participantes
			net_mgr.rpc_sync_region_transition(to_region, target_spawn)

	# 4. Início do ciclo de vida da transição
	_is_transitioning = true
	EventBus.region_transition_requested.emit(from_region, to_region, target_spawn)
	EventBus.region_transition_started.emit(from_region, to_region)

	# 5. Execução do carregamento e descarregamento via WorldManager
	var load_err: Error = world.call("load_region", to_region, String(target_spawn))
	if load_err != OK:
		_is_transitioning = false
		EventBus.region_transition_failed.emit(from_region, to_region, load_err)
		return load_err

	_is_transitioning = false
	EventBus.region_transition_completed.emit(from_region, to_region)
	return OK

func _get_world() -> Object:
	return _world_ref.get_ref() if _world_ref != null else null
