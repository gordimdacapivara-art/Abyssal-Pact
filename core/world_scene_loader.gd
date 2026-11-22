class_name WorldSceneLoader
extends RefCounted
## WorldSceneLoader — Carregador e descarregador de cenas e ambientes 3D de ABYSSAL PACT.
##
## Responsabilidade:
##   - Carregamento assíncrono (threaded) de recursos e cenas da Godot via ResourceLoader;
##   - Descarregamento estrito da região anterior para evitar acúmulo de ambientes 3D em memória;
##   - Resolução determinística de pontos de entrada (spawns) e posicionamento de pawns;
##   - Preservação integral do estado do jogador (personagem, inventário, equipamentos, progressão).

signal load_progress_updated(region_id: StringName, progress: float)
signal load_finished(region_id: StringName, packed_scene: PackedScene)
signal load_failed(region_id: StringName, error_code: int)

var _active_region_node: Node3D = null
var _active_region_id: StringName = &""
var _current_loading_path: String = ""
var _is_async_loading: bool = false

func active_region_node() -> Node3D:
	return _active_region_node

func active_region_id() -> StringName:
	return _active_region_id

## Registra a região e/ou nó 3D atualmente ativo.
func set_active_region(region_id: StringName, node: Node3D = null) -> void:
	_active_region_id = region_id
	_active_region_node = node

## Descarrega o ambiente 3D anterior da árvore de nós e libera a memória.
func unload_active_region() -> void:
	var prev_id := _active_region_id
	if _active_region_node != null and is_instance_valid(_active_region_node):
		if _active_region_node.get_parent() != null:
			_active_region_node.get_parent().remove_child(_active_region_node)
		_active_region_node.queue_free()
		_active_region_node = null
	_active_region_id = &""
	if not prev_id.is_empty():
		EventBus.region_unloaded.emit(prev_id)

## Carrega a cena da região. Suporta carregamento síncrono ou assíncrono.
func load_scene(scene_path: String, use_threads: bool = false, tree: SceneTree = null) -> PackedScene:
	if not ResourceLoader.exists(scene_path):
		push_error("WorldSceneLoader: cena não encontrada: %s" % scene_path)
		return null

	if use_threads and tree != null:
		var err := ResourceLoader.load_threaded_request(scene_path, "", true)
		if err == OK:
			var progress: Array = []
			while true:
				var status := ResourceLoader.load_threaded_get_status(scene_path, progress)
				if status == ResourceLoader.THREAD_LOAD_LOADED:
					return ResourceLoader.load_threaded_get(scene_path) as PackedScene
				elif status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
					var p: float = float(progress[0]) if progress.size() > 0 else 0.5
					load_progress_updated.emit(_active_region_id, p)
					await tree.process_frame
				else:
					push_warning("WorldSceneLoader: carregamento threaded falhou para %s; tentando síncrono." % scene_path)
					break

	# Fallback síncrono imediato (padrão em testes headless ou carga local direta)
	return load(scene_path) as PackedScene

## Instancia a cena carregada, descarrega a região anterior e anexa a nova ao container.
func instantiate_region(packed: PackedScene, target_parent: Node, region_id: StringName, params: Dictionary = {}) -> Node3D:
	if packed == null or target_parent == null:
		return null

	# Descarrega anterior antes de instanciar a nova (evita manter dois ambientes 3D simultâneos)
	unload_active_region()

	var new_instance := packed.instantiate() as Node3D
	if new_instance == null:
		push_error("WorldSceneLoader: raiz da cena de %s não herda de Node3D." % region_id)
		return null

	if new_instance.has_method("setup"):
		new_instance.call("setup", params)

	target_parent.add_child(new_instance)
	_active_region_node = new_instance
	_active_region_id = region_id

	return new_instance

## Resolve o ponto de entrada (spawn) na cena 3D a partir do identificador de spawn.
func resolve_spawn_transform(region_node: Node3D, spawn_marker: String = "default") -> Transform3D:
	if region_node == null:
		return Transform3D.IDENTITY

	if region_node.has_method("spawn_point"):
		var marker: Node3D = region_node.call("spawn_point", spawn_marker)
		if marker != null and is_instance_valid(marker):
			return marker.global_transform

		# Fallback para spawn default
		if spawn_marker != "default":
			var def_marker: Node3D = region_node.call("spawn_point", "default")
			if def_marker != null and is_instance_valid(def_marker):
				return def_marker.global_transform

	# Procura nós Marker3D em Spawns/
	var spawns_node := region_node.get_node_or_null("Spawns")
	if spawns_node != null:
		var specific := spawns_node.get_node_or_null("Spawn_" + spawn_marker)
		if specific is Marker3D:
			return (specific as Marker3D).global_transform
		var def := spawns_node.get_node_or_null("Spawn_default")
		if def is Marker3D:
			return (def as Marker3D).global_transform

	return region_node.global_transform

## Posiciona o pawn do jogador no ponto de spawn sem alterar o inventário, dados ou progressão.
func place_pawn_at_spawn(pawn: Node3D, region_node: Node3D, spawn_marker: String = "default") -> bool:
	if pawn == null or region_node == null:
		return false

	var target_tf := resolve_spawn_transform(region_node, spawn_marker)
	pawn.global_transform = target_tf
	return true
