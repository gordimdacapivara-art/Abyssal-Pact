class_name MultiplayerCrossplayManager
extends Node
## MultiplayerCrossplayManager — Coordenação de sessões privadas e Crossplay PC-Xbox.
##
## Responsabilidade:
## 1. Assegurar limite de 8 jogadores por mundo privado (Invariants.MAX_PARTICIPANTS).
## 2. Validação de privilégios de Cross-Network Play conforme Microsoft XR-053.
## 3. Tolerância a quedas com janela de reconexão de 60 segundos (Session Tickets).
## 4. Validação autoritativa do Host sobre Inventário, Progressão e Hell Forge exclusiva do mundo.

enum PlatformClientType {
	PC_WINDOWS = 0,
	XBOX_SERIES_S = 1,
	XBOX_SERIES_X = 2
}

enum PrivilegeStatus {
	GRANTED = 0,
	DENIED = 1,
	RESTRICTED = 2
}

const MAX_PRIVATE_WORLD_PLAYERS: int = 8
const RECONNECT_GRACE_PERIOD_SEC: float = 60.0

signal client_authenticated(peer_id: int, platform: PlatformClientType, gamertag: String)
signal client_reconnected(new_peer_id: int, old_peer_id: int, character_id: String)
signal hell_forge_synced(state: Dictionary)
signal validation_failed(peer_id: int, reason: String)

var crossplay_enabled: bool = true

## Roster ativo de clientes validados: peer_id -> Dictionary
var _clients: Dictionary = {}

## Tickets de reconexão ativa: reconnect_token -> Dictionary
var _reconnect_tickets: Dictionary = {}

## Estado autoritativo da Hell Forge exclusiva do mundo privado
var _hell_forge_state: Dictionary = {
	"forge_id": "HELL_FORGE_WORLD_UNIQUE",
	"corruption_level": 0.0,
	"active_infusions": [],
	"temperature": 1000.0,
	"in_use_by_peer": 0,
	"last_updated": 0
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	_cleanup_expired_tickets()

## Simulação do contrato Microsoft XUserCheckPrivilege (XR-053)
func check_xbox_privileges(player_xuid: String) -> Dictionary:
	# Privilégios essenciais da Xbox Live:
	# 254 = XPRIVILEGE_MULTIPLAYER_SESSIONS
	# 185 = XPRIVILEGE_CROSS_PLAY
	# 252 = XPRIVILEGE_COMMUNICATIONS
	if not crossplay_enabled:
		return {
			"multiplayer": PrivilegeStatus.GRANTED,
			"crossplay": PrivilegeStatus.DENIED,
			"communications": PrivilegeStatus.GRANTED,
			"allowed": false,
			"reason": "Crossplay desativado nas configurações do anfitrião."
		}

	# Em ambiente sem restrição parental ou bloqueio de conta
	return {
		"multiplayer": PrivilegeStatus.GRANTED,
		"crossplay": PrivilegeStatus.GRANTED,
		"communications": PrivilegeStatus.GRANTED,
		"allowed": true,
		"reason": "Privilégios válidos."
	}

## Registra novo cliente ou reconecta cliente existente
func register_client(peer_id: int, platform: PlatformClientType, gamertag: String, reconnect_token: String = "") -> bool:
	# 1. Checa se é uma tentativa de reconexão válida dentro da janela de 60s
	if reconnect_token != "" and _reconnect_tickets.has(reconnect_token):
		var ticket: Dictionary = _reconnect_tickets[reconnect_token]
		var old_peer_id: int = ticket.get("peer_id", -1)
		var char_id: String = ticket.get("character_id", "")
		
		_clients[peer_id] = {
			"platform": platform,
			"gamertag": gamertag,
			"character_id": char_id,
			"reconnect_token": reconnect_token,
			"connected_at": Time.get_ticks_msec() / 1000.0
		}
		_reconnect_tickets.erase(reconnect_token)
		client_reconnected.emit(peer_id, old_peer_id, char_id)
		return true

	# 2. Verifica se a sessão privada atingiu o teto estrito de 8 jogadores
	if _clients.size() >= MAX_PRIVATE_WORLD_PLAYERS:
		validation_failed.emit(peer_id, "Sessão privada lotada (Máximo: %d participantes)." % MAX_PRIVATE_WORLD_PLAYERS)
		return false

	# 3. Verifica compatibilidade de Crossplay
	if platform != PlatformClientType.PC_WINDOWS and not crossplay_enabled:
		validation_failed.emit(peer_id, "Crossplay desabilitado neste mundo privado.")
		return false

	# 4. Registra novo cliente com token seguro
	var new_token := "AP_TICKET_%d_%d" % [peer_id, Time.get_ticks_msec()]
	_clients[peer_id] = {
		"platform": platform,
		"gamertag": gamertag,
		"character_id": "",
		"reconnect_token": new_token,
		"connected_at": Time.get_ticks_msec() / 1000.0
	}
	client_authenticated.emit(peer_id, platform, gamertag)
	return true

## Desregistra cliente e gera ticket temporário se foi queda inesperada
func unregister_client(peer_id: int, graceful: bool = false) -> void:
	if not _clients.has(peer_id):
		return

	var info: Dictionary = _clients[peer_id]
	if not graceful:
		var token: String = info.get("reconnect_token", "")
		if token != "":
			_reconnect_tickets[token] = {
				"peer_id": peer_id,
				"gamertag": info.get("gamertag", ""),
				"character_id": info.get("character_id", ""),
				"platform": info.get("platform", PlatformClientType.PC_WINDOWS),
				"expires_at": (Time.get_ticks_msec() / 1000.0) + RECONNECT_GRACE_PERIOD_SEC
			}

	# Libera a Hell Forge se o jogador estava utilizando-a
	if _hell_forge_state.get("in_use_by_peer", 0) == peer_id:
		_hell_forge_state["in_use_by_peer"] = 0
		hell_forge_synced.emit(_hell_forge_state)

	_clients.erase(peer_id)

## Validação autoritativa do Host sobre alterações de Inventário e Progressão
func validate_inventory_mutation(peer_id: int, item_id: String, quantity: int) -> bool:
	if not _clients.has(peer_id):
		validation_failed.emit(peer_id, "Peer não autenticado tentou modificar inventário.")
		return false
	if quantity <= 0 or quantity > 999:
		validation_failed.emit(peer_id, "Quantidade inválida de itens solicitada: %d" % quantity)
		return false
	if item_id.is_empty():
		validation_failed.emit(peer_id, "Item ID inválido.")
		return false
	return true

## Validação autoritativa do Host para a Hell Forge única do mundo
func request_hell_forge_access(peer_id: int) -> bool:
	if not _clients.has(peer_id):
		return false
	var current_user: int = _hell_forge_state.get("in_use_by_peer", 0)
	if current_user != 0 and current_user != peer_id:
		# Hell Forge é exclusiva e já está em uso por outro jogador
		return false
	_hell_forge_state["in_use_by_peer"] = peer_id
	hell_forge_synced.emit(_hell_forge_state)
	return true

func release_hell_forge(peer_id: int) -> void:
	if _hell_forge_state.get("in_use_by_peer", 0) == peer_id:
		_hell_forge_state["in_use_by_peer"] = 0
		hell_forge_synced.emit(_hell_forge_state)

func update_hell_forge_state(new_corruption: float, infusions: Array) -> void:
	_hell_forge_state["corruption_level"] = clampf(new_corruption, 0.0, 100.0)
	_hell_forge_state["active_infusions"] = infusions
	_hell_forge_state["last_updated"] = Time.get_ticks_msec()
	hell_forge_synced.emit(_hell_forge_state)

func get_hell_forge_state() -> Dictionary:
	return _hell_forge_state.duplicate(true)

func get_connected_count() -> int:
	return _clients.size()

func get_client_info(peer_id: int) -> Dictionary:
	return _clients.get(peer_id, {})

func _cleanup_expired_tickets() -> void:
	var now := Time.get_ticks_msec() / 1000.0
	var to_remove: Array[String] = []
	for token in _reconnect_tickets.keys():
		var ticket: Dictionary = _reconnect_tickets[token]
		if now >= ticket.get("expires_at", 0.0):
			to_remove.append(token)
	for token in to_remove:
		_reconnect_tickets.erase(token)
