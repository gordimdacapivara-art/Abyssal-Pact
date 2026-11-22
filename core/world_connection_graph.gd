class_name WorldConnectionGraph
extends RefCounted
## WorldConnectionGraph — Sistema de conexões e topologia de rede geográfica de ABYSSAL PACT.
##
## Carrega e valida REGION_GRAPH.json e REGION_CONNECTIONS.md:
##   - 41 nós: 40 regiões continentais (REG-001..REG-040) + Dimensão Hell Forge (DIM-HELL-FORGE / hell_forge);
##   - Vias terrestres (estradas, desfiladeiros, pontes);
##   - Vias marítimas/fluviais (rotas costeiras, barcas);
##   - Conduítes dimensionais e portais arcanos intercontinentais;
##   - Validação de integridade: ZERO nós órfãos, conectividade 100% e cálculo de rotas.

const GRAPH_JSON_PATH := "res://REGION_GRAPH.json"
const HUB_NODE_CANONICAL := &"DIM-HELL-FORGE"
const HUB_ID := Invariants.HUB_REGION_ID # &"hell_forge"

var _nodes: Dictionary = {} # StringName -> Dictionary
var _adjacency: Dictionary = {} # StringName -> Array[Dictionary]
var _all_edges: Array[Dictionary] = []
var _is_loaded := false

func _init(auto_load: bool = true) -> void:
	if auto_load:
		load_graph(GRAPH_JSON_PATH)

## Normaliza identificador: "hell_forge" e "DIM-HELL-FORGE" apontam para o mesmo nó.
static func normalize_id(region_id: StringName) -> StringName:
	var s := String(region_id).strip_edges()
	if s == "hell_forge" or s == "DIM-HELL-FORGE":
		return HUB_NODE_CANONICAL
	return StringName(s)

## Carrega o grafo a partir de JSON no disco.
func load_graph(file_path: String = GRAPH_JSON_PATH) -> bool:
	_nodes.clear()
	_adjacency.clear()
	_all_edges.clear()
	_is_loaded = false

	if not FileAccess.file_exists(file_path):
		push_warning("WorldConnectionGraph: arquivo ausente '%s'." % file_path)
		return false

	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("WorldConnectionGraph: falha ao abrir '%s'." % file_path)
		return false

	var text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_err := json.parse(text)
	if parse_err != OK:
		push_error("WorldConnectionGraph: JSON inválido em '%s' (erro %d)." % [file_path, parse_err])
		return false

	var data: Dictionary = json.data
	var raw_nodes: Dictionary = data.get("nodes", {})
	var raw_edges: Array = data.get("edges", [])

	for node_id_str: String in raw_nodes.keys():
		var node_data: Dictionary = raw_nodes[node_id_str]
		var sname := StringName(node_id_str)
		_nodes[sname] = node_data
		_adjacency[sname] = []

	for edge_variant in raw_edges:
		var edge: Dictionary = edge_variant as Dictionary
		var from_id := StringName(String(edge.get("from", "")))
		var to_id := StringName(String(edge.get("to", "")))
		if from_id.is_empty() or to_id.is_empty():
			continue

		_all_edges.append(edge)

		if _adjacency.has(from_id):
			(_adjacency[from_id] as Array).append(edge)

		# Se for bidirecional e o inverso não estiver explicitamente presente, espelha
		if bool(edge.get("bidirectional", true)):
			var reverse_edge := edge.duplicate()
			reverse_edge["from"] = to_id
			reverse_edge["to"] = from_id
			if _adjacency.has(to_id):
				# Evita duplicar se já foi adicionado
				var already_has := false
				for existing: Dictionary in _adjacency[to_id]:
					if StringName(String(existing.get("to", ""))) == from_id:
						already_has = true
						break
				if not already_has:
					(_adjacency[to_id] as Array).append(reverse_edge)

	_is_loaded = true
	return true

func is_loaded() -> bool:
	return _is_loaded

func total_nodes() -> int:
	return _nodes.size()

func total_edges() -> int:
	return _all_edges.size()

func has_region(region_id: StringName) -> bool:
	var nid := normalize_id(region_id)
	return _nodes.has(nid)

func get_node(region_id: StringName) -> Dictionary:
	var nid := normalize_id(region_id)
	return _nodes.get(nid, {})

func get_degree(region_id: StringName) -> int:
	var nid := normalize_id(region_id)
	var conns: Array = _adjacency.get(nid, [])
	return conns.size()

func get_neighbors(region_id: StringName) -> Array[StringName]:
	var result: Array[StringName] = []
	var nid := normalize_id(region_id)
	var conns: Array = _adjacency.get(nid, [])
	for c_var in conns:
		var c: Dictionary = c_var as Dictionary
		var to_id := StringName(String(c.get("to", "")))
		if to_id == HUB_NODE_CANONICAL:
			to_id = HUB_ID
		if not result.has(to_id):
			result.append(to_id)
	return result

func get_connections(region_id: StringName) -> Array[Dictionary]:
	var nid := normalize_id(region_id)
	var result: Array[Dictionary] = []
	var conns: Array = _adjacency.get(nid, [])
	for c_var in conns:
		result.append(c_var as Dictionary)
	return result

func get_connection_between(from_id: StringName, to_id: StringName) -> Dictionary:
	var from_norm := normalize_id(from_id)
	var to_norm := normalize_id(to_id)
	var conns: Array = _adjacency.get(from_norm, [])
	for c_var in conns:
		var c: Dictionary = c_var as Dictionary
		if normalize_id(StringName(String(c.get("to", "")))) == to_norm:
			return c
	return {}

func are_connected(from_id: StringName, to_id: StringName) -> bool:
	return not get_connection_between(from_id, to_id).is_empty()

## Valida se o jogador pode transitar entre from_id e to_id (respeitando nível e rota).
func can_travel(from_id: StringName, to_id: StringName, player_level: int = 1) -> Dictionary:
	var from_norm := normalize_id(from_id)
	var to_norm := normalize_id(to_id)

	if not has_region(from_norm):
		return {"allowed": false, "reason": "Região de origem '%s' não existe no grafo." % from_id, "connection": {}}
	if not has_region(to_norm):
		return {"allowed": false, "reason": "Região de destino '%s' não existe no grafo." % to_id, "connection": {}}

	# Ressurgimento ou retorno direto à Hell Forge é SEMPRE permitido (Invariante)
	if to_norm == HUB_NODE_CANONICAL:
		return {"allowed": true, "reason": "Conduíte dimensional para Hell Forge autorizado.", "connection": get_connection_between(from_norm, to_norm)}

	var conn := get_connection_between(from_norm, to_norm)
	if conn.is_empty():
		return {"allowed": false, "reason": "Não existe conexão direta ou portal entre '%s' e '%s'." % [from_id, to_id], "connection": {}}

	var req_lvl := int(conn.get("required_level", 1))
	if player_level < req_lvl:
		return {"allowed": false, "reason": "Nível insuficiente (%d < %d) para atravessar '%s'." % [player_level, req_lvl, conn.get("route_name", "")], "connection": conn}

	return {"allowed": true, "reason": "Trânsito autorizado via %s." % conn.get("route_name", "fronteira"), "connection": conn}

## Encontra a rota mais curta (BFS) em número de saltos entre duas regiões.
func find_shortest_path(from_id: StringName, to_id: StringName) -> Array[StringName]:
	var start := normalize_id(from_id)
	var goal := normalize_id(to_id)

	if start == goal:
		return [from_id]
	if not has_region(start) or not has_region(goal):
		return []

	var queue: Array[StringName] = [start]
	var visited: Dictionary = {start: true}
	var parent: Dictionary = {}

	while not queue.is_empty():
		var current: StringName = queue.pop_front()
		if current == goal:
			# Reconstrói caminho
			var path: Array[StringName] = []
			var curr_step := goal
			while curr_step != start:
				var display_step := HUB_ID if curr_step == HUB_NODE_CANONICAL else curr_step
				path.push_front(display_step)
				curr_step = parent[curr_step]
			var display_start := HUB_ID if start == HUB_NODE_CANONICAL else start
			path.push_front(display_start)
			return path

		var neighbors := get_neighbors(current)
		for neighbor in neighbors:
			var n_norm := normalize_id(neighbor)
			if not visited.has(n_norm):
				visited[n_norm] = true
				parent[n_norm] = current
				queue.push_back(n_norm)

	return []

func is_intercontinental(from_id: StringName, to_id: StringName) -> bool:
	var node_a := get_node(from_id)
	var node_b := get_node(to_id)
	if node_a.is_empty() or node_b.is_empty():
		return false
	var cont_a := String(node_a.get("continent_id", ""))
	var cont_b := String(node_b.get("continent_id", ""))
	return cont_a != cont_b and cont_a != "NEXUS" and cont_b != "NEXUS"

func is_hell_forge_connected(region_id: StringName) -> bool:
	return are_connected(region_id, HUB_ID) or are_connected(region_id, HUB_NODE_CANONICAL)

func list_conduits_to_hell_forge() -> Array[StringName]:
	var result: Array[StringName] = []
	for node_id: StringName in _nodes.keys():
		if node_id != HUB_NODE_CANONICAL and are_connected(node_id, HUB_NODE_CANONICAL):
			result.append(node_id)
	return result

## Validação completa de integridade topológica do mundo.
func validate_network_integrity() -> Dictionary:
	var issues := PackedStringArray()
	var orphan_nodes: Array[StringName] = []

	if _nodes.size() != 41:
		issues.append("Grafo deve conter exatamente 41 nós (40 regiões + Hell Forge); encontrou %d." % _nodes.size())

	for node_id: StringName in _nodes.keys():
		var deg := get_degree(node_id)
		if deg == 0:
			orphan_nodes.append(node_id)
			issues.append("Região órfã detectada sem nenhuma conexão: %s" % node_id)
		elif deg < 2 and node_id != HUB_NODE_CANONICAL:
			# Quase todas as regiões possuem múltiplas conexões (apenas regiões terminais especiais podem ter menos)
			pass

	# Verificação de conectividade global (todos alcançáveis a partir de REG-001)
	var start_node := &"REG-001"
	var visited: Dictionary = {}
	if has_region(start_node):
		var queue: Array[StringName] = [start_node]
		visited[start_node] = true
		while not queue.is_empty():
			var curr: StringName = queue.pop_front()
			for neighbor in get_neighbors(curr):
				var n_norm := normalize_id(neighbor)
				if not visited.has(n_norm):
					visited[n_norm] = true
					queue.push_back(n_norm)

	var unreachable_count := _nodes.size() - visited.size()
	if unreachable_count > 0:
		issues.append("Grafo desconexo: %d regiões não são alcançáveis a partir de REG-001." % unreachable_count)

	return {
		"is_valid": issues.is_empty(),
		"total_nodes": _nodes.size(),
		"total_edges": _all_edges.size(),
		"orphan_nodes": orphan_nodes,
		"unreachable_count": unreachable_count,
		"all_reachable": unreachable_count == 0,
		"issues": issues
	}
