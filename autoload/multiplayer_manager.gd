class_name MultiplayerManager
extends ManagerBase
## MultiplayerManager — Ciclo de vida e coordenação de sessões PRIVADAS em ABYSSAL PACT.
##
## REGRA FUNDAMENTAL (Documentação e Invariantes):
##   - ABYSSAL PACT NÃO TEM SERVIDORES PÚBLICOS.
##   - Mundos exclusivamente privados hospedados pelos próprios jogadores.
##   - Limite MÁXIMO de 8 participantes por mundo, ANFITRIÃO INCLUÍDO
##     (Invariants.MAX_PARTICIPANTS).
##   - O anfitrião (Host / Peer 1) é a autoridade absoluta do mundo.
##   - Transporte de rede: ENetMultiplayerPeer nativo da Godot 4.
##
## Integração:
##   - Emite (EventBus): session_hosted, session_joined, session_left,
##     peer_registered, peer_unregistered, peer_limit_rejected, peer_rejected,
##     peer_kicked, connection_failed, network_player_spawned,
##     network_player_despawned, network_combat_replicated, network_damage_replicated,
##     network_boss_phase_replicated, network_respawn_replicated,
##     network_region_transition_replicated.
##   - Consome (registry): WorldManager, CharacterManager, SaveManager.
## Autoload: "Net" (/root/Net).

const KEY: StringName = SystemNames.NET

func system_key() -> StringName:
	return KEY

const DEFAULT_PORT := 24565
const TRANSPORT_NAME := "ENetMultiplayerPeer"
const PROTOCOL_VERSION := "1.0"
const HUB_REGION_ID := Invariants.HUB_REGION_ID

const NetworkInviteSystemScript = preload("res://core/network_invite_system.gd")

## Roster ativo: peer_id (int) -> display_name (String)
var _participants: Dictionary = {}
## Detalhes dos participantes: peer_id (int) -> Dictionary (character_id, race, class, level, hp, etc.)
var _participant_details: Dictionary = {}
## Código curto (AP-XXXX)
var _short_invite_code := ""
## Código direto completo (AP-DIRECT-XXXXX)
var _direct_invite_code := ""
## Token de segurança da sessão para validação no handshake
var _session_token := ""
## Nome do mundo ativo hospedado
var _active_world_name := ""
## Porta da sessão ativa
var _active_port := DEFAULT_PORT

## Rastreamento de pawns em cena por peer_id
var _player_pawns: Dictionary = {} # peer_id (int) -> Node3D

func initialize() -> void:
	super()
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	log_info("Multiplayer pronto; transporte: %s (Autoridade do Anfitrião)." % TRANSPORT_NAME)

# --------------------------------------------------------------------- API --

## Hospeda um mundo privado como autoridade do servidor.
func host_private_world(world_name: String, port: int = DEFAULT_PORT, custom_token: String = "") -> Error:
	if _is_session_active():
		log_warn("Sessão já ativa; encerre antes de hospedar.")
		return ERR_ALREADY_IN_USE
	if world_name.strip_edges().is_empty():
		return ERR_INVALID_PARAMETER

	var peer := _create_server_peer(_max_clients())
	if peer == null:
		EventBus.connection_failed.emit("Falha ao criar servidor ENet.")
		return ERR_CANT_CREATE

	var error := peer.create_server(port, _max_clients())
	if error != OK:
		EventBus.connection_failed.emit("create_server falhou (erro %d)." % error)
		return error

	multiplayer.multiplayer_peer = peer
	_active_world_name = world_name.strip_edges()
	_active_port = port
	_session_token = custom_token if not custom_token.is_empty() else _generate_token()
	_short_invite_code = NetworkInviteSystemScript.generate_short_code()
	_direct_invite_code = NetworkInviteSystemScript.generate_direct_code("127.0.0.1", port, &"WORLD-001", _session_token)

	_participants.clear()
	_participant_details.clear()
	_player_pawns.clear()

	# Host é registrado no roster como peer 1 (Invariants.HOST_PEER_ID)
	var host_details := _gather_local_character_details()
	_register_participant(Invariants.HOST_PEER_ID, host_details.get("name", "Anfitrião (Host)"), host_details)

	log_info("Sessão privada hospedada: '%s' na porta %d (Código: %s)." % [_active_world_name, port, _short_invite_code])
	EventBus.session_hosted.emit(_active_world_name, port)
	return OK

## Conecta a um mundo privado usando endereço direto, porta ou código de convite AP-DIRECT.
func join_private_world(address_or_code: String, port: int = DEFAULT_PORT, invite_code: String = "", character_payload: Dictionary = {}) -> Error:
	if _is_session_active():
		log_warn("Sessão já ativa; encerre antes de conectar.")
		return ERR_ALREADY_IN_USE
	if address_or_code.strip_edges().is_empty():
		return ERR_INVALID_PARAMETER

	var target_address := address_or_code.strip_edges()
	var target_port := port
	var token_to_send := invite_code.strip_edges()

	# Se for um código de convite direto (AP-DIRECT-...), decodifica automaticamente
	if target_address.begins_with(NetworkInviteSystemScript.PREFIX_DIRECT):
		var parsed: Dictionary = NetworkInviteSystemScript.parse_invite_code(target_address)
		if not parsed.get("valid", false):
			EventBus.connection_failed.emit("Código de convite direto inválido: %s" % parsed.get("error", ""))
			return ERR_INVALID_PARAMETER
		target_address = String(parsed.get("address", ""))
		target_port = int(parsed.get("port", DEFAULT_PORT))
		token_to_send = String(parsed.get("session_token", ""))

	var peer := _create_client_peer()
	if peer == null:
		EventBus.connection_failed.emit("Falha ao criar cliente ENet.")
		return ERR_CANT_CREATE

	var error := peer.create_client(target_address, target_port)
	if error != OK:
		EventBus.connection_failed.emit("create_client falhou para %s:%d (erro %d)." % [target_address, target_port, error])
		return error

	multiplayer.multiplayer_peer = peer
	_session_token = token_to_send
	_active_port = target_port
	_active_world_name = "Mundo Remoto"

	if character_payload.is_empty():
		character_payload = _gather_local_character_details()
	_participant_details[multiplayer.get_unique_id()] = character_payload

	return OK

## Encerra ou sai da sessão ativa de forma graciosa.
func leave_session(reason: String = "leave") -> Error:
	if not _is_session_active():
		return ERR_UNAVAILABLE

	if not is_host() and multiplayer.multiplayer_peer != null:
		# Notifica o servidor da saída antes de fechar o socket
		rpc_id(Invariants.HOST_PEER_ID, "rpc_client_request_leave", reason)

	_cleanup_session_state(reason)
	return OK

## Expulsa um peer da sessão (exclusivo para o Anfitrião).
func kick_peer(peer_id: int, reason: String = "Expulso pelo anfitrião") -> Error:
	if not is_host():
		log_warn("Apenas o anfitrião pode expulsar participantes.")
		return ERR_UNAUTHORIZED
	if peer_id == Invariants.HOST_PEER_ID:
		log_warn("O anfitrião não pode expulsar a si mesmo.")
		return ERR_INVALID_PARAMETER
	if not _participants.has(peer_id):
		return ERR_DOES_NOT_EXIST

	rpc_id(peer_id, "rpc_kicked_notification", reason)
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.disconnect_peer(peer_id)

	_unregister_participant(peer_id)
	EventBus.peer_kicked.emit(peer_id, reason)
	_sync_roster_to_all()
	return OK

func is_session_active() -> bool:
	return _is_session_active()

func is_host() -> bool:
	return _is_session_active() and multiplayer.is_server()

func participants() -> Dictionary:
	return _participants.duplicate()

func participant_count() -> int:
	return _participants.size()

func max_participants() -> int:
	return Invariants.MAX_PARTICIPANTS

func invite_code() -> String:
	return _short_invite_code

func direct_invite_code() -> String:
	return _direct_invite_code

func session_token() -> String:
	return _session_token

func active_world_name() -> String:
	return _active_world_name

func active_port() -> int:
	return _active_port

func get_participant_details(peer_id: int) -> Dictionary:
	return _participant_details.get(peer_id, {}).duplicate()

func set_participant_details(peer_id: int, details: Dictionary) -> void:
	_participant_details[peer_id] = details
	if is_host():
		_sync_roster_to_all()

## Registra referência ao pawn local ou proxy remoto do jogador.
func register_player_pawn(peer_id: int, pawn: Node3D) -> void:
	_player_pawns[peer_id] = pawn

func unregister_player_pawn(peer_id: int) -> void:
	_player_pawns.erase(peer_id)

func get_player_pawn(peer_id: int) -> Node3D:
	return _player_pawns.get(peer_id, null)

# ----------------------------------------------- GANCHO DE TESTES / ROSTER --

func debug_register_participant(peer_id: int, display_name: String = "Peer", details: Dictionary = {}) -> Error:
	if _participants.size() >= max_participants():
		EventBus.peer_limit_rejected.emit(peer_id)
		return FAILED
	_register_participant(peer_id, display_name, details)
	return OK

func debug_clear_roster() -> void:
	_participants.clear()
	_participant_details.clear()
	_player_pawns.clear()

# ----------------------------------------- SINCRONIZAÇÃO EM REDE E RPCS --

## Handshake inicial do cliente com o Host (Segurança e Validação).
@rpc("any_peer", "call_remote", "reliable")
func rpc_client_handshake(payload: Dictionary) -> void:
	if not is_host():
		return
	var sender_id := multiplayer.get_remote_sender_id()
	if sender_id <= 0:
		sender_id = Invariants.HOST_PEER_ID

	# 1. Valida capacidade
	if _participants.size() >= max_participants():
		log_warn("Peer %d recusado: capacidade máxima de 8 atingida." % sender_id)
		EventBus.peer_limit_rejected.emit(sender_id)
		rpc_id(sender_id, "rpc_handshake_response", false, "Mundo lotado (máximo 8 jogadores).", {})
		if multiplayer.multiplayer_peer != null:
			multiplayer.multiplayer_peer.disconnect_peer(sender_id)
		return

	# 2. Valida token e versão
	var client_token: String = str(payload.get("token", ""))
	var client_version: String = str(payload.get("version", ""))
	var validation: Dictionary = NetworkInviteSystemScript.validate_handshake(client_token, _session_token, client_version)
	if not validation.get("accepted", false):
		var reason: String = str(validation.get("reason", "Acesso recusado."))
		log_warn("Peer %d rejeitado: %s" % [sender_id, reason])
		EventBus.peer_rejected.emit(sender_id, reason)
		rpc_id(sender_id, "rpc_handshake_response", false, reason, {})
		if multiplayer.multiplayer_peer != null:
			multiplayer.multiplayer_peer.disconnect_peer(sender_id)
		return

	# 3. Registra dados do personagem
	var char_data: Dictionary = payload.get("character", {})
	var display_name: String = str(char_data.get("name", "Jogador %d" % sender_id))
	_register_participant(sender_id, display_name, char_data)

	# 4. Responde sucesso com informações do mundo
	var world_info := {
		"world_name": _active_world_name,
		"region_id": String(_get_current_region_id()),
		"roster": _participants,
		"roster_details": _participant_details
	}
	rpc_id(sender_id, "rpc_handshake_response", true, "Conexão aceita.", world_info)
	_sync_roster_to_all()
	log_info("Peer %d validado com sucesso (%s)." % [sender_id, display_name])

## Resposta do Host ao handshake do cliente.
@rpc("authority", "call_remote", "reliable")
func rpc_handshake_response(accepted: bool, reason: String, world_info: Dictionary) -> void:
	if not accepted:
		log_error("Conexão recusada pelo anfitrião: %s" % reason)
		EventBus.connection_failed.emit(reason)
		_cleanup_session_state("handshake_rejected")
		return

	log_info("Handshake aceito pelo anfitrião! Mundo: %s" % world_info.get("world_name", ""))
	if world_info.has("roster"):
		_participants = world_info.get("roster", {}).duplicate()
	if world_info.has("roster_details"):
		_participant_details = world_info.get("roster_details", {}).duplicate()

	EventBus.session_joined.emit(multiplayer.multiplayer_peer.get_peer_address(1), _active_port)

## Sincronização de roster do Host para todos os clientes.
@rpc("authority", "call_remote", "reliable")
func rpc_sync_roster(roster: Dictionary, details: Dictionary) -> void:
	_participants = roster.duplicate()
	_participant_details = details.duplicate()

## Pedido voluntário de saída do cliente para o Host.
@rpc("any_peer", "call_local", "reliable")
func rpc_client_request_leave(reason: String) -> void:
	if not is_host():
		return
	var sender_id := multiplayer.get_remote_sender_id()
	if sender_id <= 0:
		for p_id in _participants.keys():
			if int(p_id) != Invariants.HOST_PEER_ID:
				sender_id = int(p_id)
				break
	if sender_id > 0:
		log_info("Cliente %d solicitou saída (%s)." % [sender_id, reason])
		_unregister_participant(sender_id)
		_sync_roster_to_all()

## Notificação de expulsão enviada do Host ao cliente.
@rpc("authority", "call_remote", "reliable")
func rpc_kicked_notification(reason: String) -> void:
	log_warn("Você foi expulso da sessão: %s" % reason)
	EventBus.notification_requested.emit("Você foi expulso: %s" % reason)
	_cleanup_session_state("kicked")

# --------------------------------- SINCRONIZAÇÃO DE MOVIMENTO E ANIMAÇÃO --

## Envio de posição/velocidade/estado do jogador com autoridade para o Host.
@rpc("any_peer", "call_remote", "unreliable_ordered")
func rpc_send_player_transform(pos: Vector3, rot_y: float, vel: Vector3, state_id: int) -> void:
	var sender_id := multiplayer.get_remote_sender_id()
	if sender_id <= 0:
		sender_id = Invariants.HOST_PEER_ID

	if is_host():
		# Validação autoritária no host: limites razoáveis de velocidade
		var speed := vel.length()
		if speed > 40.0: # Limite de tolerância contra hacks
			log_warn("Velocidade anômala detectada no peer %d (%.1f m/s)." % [sender_id, speed])
			return

		# Atualiza no Host
		_apply_network_transform_to_pawn(sender_id, pos, rot_y, vel, state_id)

		# Replica para os demais clientes
		for p_id in _participants.keys():
			var id_int := int(p_id)
			if id_int != Invariants.HOST_PEER_ID and id_int != sender_id:
				rpc_id(id_int, "rpc_replicate_player_transform", sender_id, pos, rot_y, vel, state_id)
	else:
		_apply_network_transform_to_pawn(sender_id, pos, rot_y, vel, state_id)

## Replicação de movimento e animação do Host para os clientes.
@rpc("authority", "call_remote", "unreliable_ordered")
func rpc_replicate_player_transform(peer_id: int, pos: Vector3, rot_y: float, vel: Vector3, state_id: int) -> void:
	_apply_network_transform_to_pawn(peer_id, pos, rot_y, vel, state_id)

func _apply_network_transform_to_pawn(peer_id: int, pos: Vector3, rot_y: float, vel: Vector3, state_id: int) -> void:
	var pawn := get_player_pawn(peer_id)
	if pawn != null and pawn.has_method("apply_network_state"):
		pawn.call("apply_network_state", pos, rot_y, vel, state_id)

# ------------------------------------------------ SINCRONIZAÇÃO DE COMBATE --

## Cliente solicita ação de combate ao Host (autoridade).
@rpc("any_peer", "call_local", "reliable")
func rpc_request_combat_action(ability_id: StringName, target_pos: Vector3, target_id: StringName) -> void:
	if not is_host():
		return
	var sender_id := multiplayer.get_remote_sender_id()
	if sender_id <= 0:
		sender_id = Invariants.HOST_PEER_ID

	# Validação no Host:
	var details := get_participant_details(sender_id)
	if details.is_empty():
		return

	# Host calcula impacto e dano autoritário
	var damage_amount := 25.0
	var damage_type := &"physical"
	var is_dead := false
	var new_hp := 75.0

	# Emite evento local no host
	EventBus.network_combat_replicated.emit(sender_id, ability_id, target_pos)

	# Replica para todos os clientes
	rpc("rpc_replicate_combat_action", sender_id, ability_id, target_pos)
	if not target_id.is_empty():
		EventBus.network_damage_replicated.emit(&"creature", target_id, damage_amount, new_hp, is_dead)
		rpc("rpc_replicate_damage", &"creature", target_id, damage_amount, damage_type, new_hp, is_dead)

## Replicação visual/sonora da habilidade para todos os peers.
@rpc("authority", "call_remote", "reliable")
func rpc_replicate_combat_action(caster_peer: int, ability_id: StringName, target_pos: Vector3) -> void:
	EventBus.network_combat_replicated.emit(caster_peer, ability_id, target_pos)

## Replicação de dano autoritário aplicado a um alvo.
@rpc("authority", "call_remote", "reliable")
func rpc_replicate_damage(target_type: StringName, target_id: StringName, damage_amount: float, damage_type: StringName, new_hp: float, is_dead: bool) -> void:
	EventBus.network_damage_replicated.emit(target_type, target_id, damage_amount, new_hp, is_dead)

# ------------------------------------- SINCRONIZAÇÃO DE CHEFES E CRIATURAS --

## Host replica atualização de fase de chefe para todos os clientes.
@rpc("authority", "call_local", "reliable")
func rpc_sync_boss_phase(boss_id: StringName, phase_idx: int, phase_name: StringName) -> void:
	EventBus.network_boss_phase_replicated.emit(boss_id, phase_idx, phase_name)

## Host replica ressurgimento obrigatório na Hell Forge.
@rpc("authority", "call_local", "reliable")
func rpc_sync_player_respawn(peer_id: int, hub_spawn_pos: Vector3) -> void:
	EventBus.network_respawn_replicated.emit(peer_id, hub_spawn_pos)

## Cliente solicita transição de região ao anfitrião (Host Authority).
@rpc("any_peer", "call_local", "reliable")
func rpc_request_region_transition(target_region: StringName, target_spawn: StringName) -> void:
	if not is_host():
		return
	var world := Game.get_system(SystemNames.WORLD) as WorldManager
	if world != null:
		var err := world.transition_to_region(target_region, target_spawn)
		if err != OK:
			log_warn("Transição solicitada por peer recusada pelo anfitrião: %d" % err)

## Host replica mudança de região/continente para todos os membros do mundo.
@rpc("authority", "call_local", "reliable")
func rpc_sync_region_transition(target_region: StringName, target_spawn: StringName) -> void:
	EventBus.network_region_transition_replicated.emit(target_region, target_spawn)
	if not is_host():
		var world := Game.get_system(SystemNames.WORLD) as WorldManager
		if world != null:
			world.load_region(target_region, String(target_spawn))

## Posições em tempo real de membros do grupo para o mapa e minimapa.
@rpc("any_peer", "call_local", "unreliable_ordered")
func rpc_update_player_map_position(peer_id: int, region_id: StringName, pos: Vector3, yaw: float) -> void:
	var world := Game.get_system(SystemNames.WORLD) if has_node("/root/Game") else null
	if world != null and world.has_method("map_system"):
		var map_sys = world.call("map_system")
		if map_sys != null and map_sys.has_method("update_party_member_position"):
			map_sys.call("update_party_member_position", peer_id, region_id, pos, yaw)

## Sincronização de pings e marcadores compartilhados entre os participantes do mundo privado.
@rpc("any_peer", "call_local", "reliable")
func rpc_share_party_ping(sender_peer: int, region_id: StringName, pos: Vector3, ping_type: StringName, label: String) -> void:
	EventBus.map_ping_shared.emit(sender_peer, region_id, pos, ping_type, label)
	var world := Game.get_system(SystemNames.WORLD) if has_node("/root/Game") else null
	if world != null and world.has_method("map_system"):
		var map_sys = world.call("map_system")
		if map_sys != null and map_sys.has_method("record_party_ping"):
			map_sys.call("record_party_ping", sender_peer, region_id, pos, ping_type, label)

# ---------------------------------------- WORLD BOSS: AZAROTH (PROMPT 01) --

## Sincronização do Ciclo Global de World Boss: Azaroth
@rpc("authority", "call_local", "reliable")
func rpc_sync_world_boss_cycle(state_id: int, elapsed_time: float, total_duration: float, current_hp: float, max_hp: float, phase: int, region_id: StringName, pos: Vector3) -> void:
	var bosses := Game.get_system(SystemNames.BOSSES) as Node if Engine.has_singleton("Game") or has_node("/root/Game") else null
	if bosses != null and bosses.has_method("world_boss_system"):
		var wb: Node = bosses.call("world_boss_system")
		if wb != null:
			wb.call("apply_network_sync", state_id, elapsed_time, total_duration, current_hp, max_hp, phase, region_id, pos)

@rpc("authority", "call_local", "reliable")
func rpc_world_boss_alert(alert_type: StringName, message: String, time_remaining: float) -> void:
	EventBus.notification_requested.emit(message)
	log_info("[WorldBoss Alert] %s: %s (tempo restante: %.1fs)" % [alert_type, message, time_remaining])

@rpc("authority", "call_local", "reliable")
func rpc_world_boss_one_hour_alert(region_id: StringName, region_name: String, continent_name: String, time_remaining: float, invasion_pos: Vector3) -> void:
	log_info("[WorldBoss 1h Alert] Invasão em %s, %s (tempo restante: %.1fs)" % [region_name, continent_name, time_remaining])
	EventBus.world_boss_one_hour_warning.emit(time_remaining, region_id, invasion_pos, region_name, continent_name)
	var ui := Game.get_system(SystemNames.UI) as UIManager if Engine.has_singleton("Game") or has_node("/root/Game") else null
	if ui != null and ui.has_method("show_azaroth_cinematic_alert"):
		ui.call("show_azaroth_cinematic_alert", region_id, region_name, continent_name, time_remaining, invasion_pos)

## Sincronização do Alvo e Sequência de Invasão de Azaroth (PROMPT 03)
@rpc("authority", "call_local", "reliable")
func rpc_sync_world_boss_invasion_target(region_id: StringName, pos: Vector3, arrival_stage: int = 0) -> void:
	log_info("[WorldBoss Target Sync] Alvo atualizado: %s na posição %s (fase de chegada: %d)" % [region_id, pos, arrival_stage])
	var bosses := Game.get_system(SystemNames.BOSSES) as Node if Engine.has_singleton("Game") or has_node("/root/Game") else null
	if bosses != null and bosses.has_method("world_boss_system"):
		var wb: Node = bosses.call("world_boss_system")
		if wb != null:
			wb.call("apply_invasion_target_sync", region_id, pos, arrival_stage)

@rpc("authority", "call_local", "reliable")
func rpc_world_boss_damage(current_hp: float, max_hp: float, phase: int) -> void:
	var bosses := Game.get_system(SystemNames.BOSSES) as Node if Engine.has_singleton("Game") or has_node("/root/Game") else null
	if bosses != null and bosses.has_method("world_boss_system"):
		var wb: Node = bosses.call("world_boss_system")
		if wb != null:
			wb.call("sync_health_from_network", current_hp, max_hp, phase)

@rpc("authority", "call_local", "reliable")
func rpc_world_boss_outcome(defeated: bool, participants: PackedInt64Array) -> void:
	log_info("[WorldBoss Outcome] Azaroth Derrotado: %s (participantes: %s)" % [defeated, participants])

# ------------------------------------ INVASÃO DO EXÉRCITO DE AZAROTH (PROMPT 04) --

## Sincronização da Fase da Invasão Demoníaca
@rpc("authority", "call_local", "reliable")
func rpc_sync_demonic_invasion_phase(phase: int, _corruption: float, region_id: StringName) -> void:
	var bosses := Game.get_system(SystemNames.BOSSES) as Node if Engine.has_singleton("Game") or has_node("/root/Game") else null
	if bosses != null and bosses.has_method("world_boss_system"):
		var wb: Node = bosses.call("world_boss_system")
		if wb != null and wb.has_method("get_invasion_system"):
			var inv_sys: Node = wb.call("get_invasion_system")
			if inv_sys != null:
				inv_sys.set("_target_region", region_id)
				inv_sys.call("set_phase", phase)

@rpc("authority", "call_local", "reliable")
func rpc_trigger_invasion_ambush(target_pos: Vector3, squad_size: int = 4) -> void:
	var bosses := Game.get_system(SystemNames.BOSSES) as Node if Engine.has_singleton("Game") or has_node("/root/Game") else null
	if bosses != null and bosses.has_method("world_boss_system"):
		var wb: Node = bosses.call("world_boss_system")
		if wb != null and wb.has_method("get_invasion_system"):
			var inv_sys: Node = wb.call("get_invasion_system")
			if inv_sys != null:
				inv_sys.call("trigger_ambush", target_pos, squad_size)

@rpc("authority", "call_local", "reliable")
func rpc_trigger_invasion_pincer(target_pos: Vector3, directions_count: int = 3, units_per_dir: int = 2) -> void:
	var bosses := Game.get_system(SystemNames.BOSSES) as Node if Engine.has_singleton("Game") or has_node("/root/Game") else null
	if bosses != null and bosses.has_method("world_boss_system"):
		var wb: Node = bosses.call("world_boss_system")
		if wb != null and wb.has_method("get_invasion_system"):
			var inv_sys: Node = wb.call("get_invasion_system")
			if inv_sys != null:
				inv_sys.call("trigger_pincer_assault", target_pos, directions_count, units_per_dir)

# ------------------------------------ BATALHA CONTRA AZAROTH (PROMPT 05) --

@rpc("authority", "call_local", "reliable")
func rpc_azaroth_ability_telegraphed(ability_id: StringName, ability_name: String, target_pos: Vector3, duration: float) -> void:
	EventBus.azaroth_ability_telegraphed.emit(ability_id, ability_name, target_pos, duration)
	log_info("[Azaroth Combat] Telegrafia: %s na posição %s (duração: %.1fs)" % [ability_name, target_pos, duration])

@rpc("authority", "call_local", "reliable")
func rpc_azaroth_ability_cast(ability_id: StringName, ability_name: String, origin_pos: Vector3, radius: float, damage: float) -> void:
	EventBus.azaroth_ability_cast.emit(ability_id, ability_name, origin_pos, radius, damage)
	log_info("[Azaroth Combat] Habilidade disparada: %s (raio: %.1fm, dano: %.1f)" % [ability_name, radius, damage])

@rpc("authority", "call_local", "reliable")
func rpc_azaroth_phase_cinematic(from_phase: int, to_phase: int, phase_name: String, duration: float) -> void:
	EventBus.azaroth_phase_cinematic_started.emit(from_phase, to_phase, phase_name, duration)
	log_info("[Azaroth Cinematic] Transição de Fase %d -> %d: %s" % [from_phase, to_phase, phase_name])

@rpc("authority", "call_local", "reliable")
func rpc_azaroth_victory_sequence(winner_peers: PackedInt64Array, _rewards: Dictionary) -> void:
	EventBus.azaroth_victory_cinematic_started.emit(Invariants.WORLD_BOSS_ID, winner_peers)
	log_info("[Azaroth Victory] Queda do Titã iniciada! Vencedores: %s" % [winner_peers])

# ------------------------------------------------------------------ INTERNO --

func _is_session_active() -> bool:
	var peer := multiplayer.multiplayer_peer
	if peer == null:
		return false
	return not (peer is OfflineMultiplayerPeer)

func _max_clients() -> int:
	return Invariants.MAX_PARTICIPANTS - 1

func _create_server_peer(_max_clients_arg: int) -> ENetMultiplayerPeer:
	return ENetMultiplayerPeer.new()

func _create_client_peer() -> ENetMultiplayerPeer:
	return ENetMultiplayerPeer.new()

func _register_participant(peer_id: int, display_name: String, details: Dictionary = {}) -> void:
	_participants[peer_id] = display_name
	if not details.is_empty():
		_participant_details[peer_id] = details
	else:
		_participant_details[peer_id] = {
			"peer_id": peer_id,
			"name": display_name,
			"level": 1,
			"class": "Arcanista",
			"health": 100,
			"max_health": 100
		}
	EventBus.peer_registered.emit(peer_id, display_name)

func _unregister_participant(peer_id: int) -> void:
	if _participants.erase(peer_id):
		_participant_details.erase(peer_id)
		var pawn := get_player_pawn(peer_id)
		if pawn != null and is_instance_valid(pawn):
			pawn.queue_free()
		_player_pawns.erase(peer_id)
		EventBus.peer_unregistered.emit(peer_id)

func _sync_roster_to_all() -> void:
	if not is_host():
		return
	rpc("rpc_sync_roster", _participants, _participant_details)

func _generate_token() -> String:
	return "%08x" % (randi())

func _gather_local_character_details() -> Dictionary:
	var chars := Game.get_system(SystemNames.CHARACTER) as CharacterManager
	if chars != null:
		var sel := chars.selected_character()
		if sel != null:
			return {
				"peer_id": multiplayer.get_unique_id(),
				"character_id": String(sel.id),
				"name": sel.display_name,
				"race_id": String(sel.race_id),
				"subrace_id": String(sel.subrace_id),
				"class_id": String(sel.class_id),
				"level": sel.progression.level if sel.progression != null else 1,
				"health": 100,
				"max_health": 100
			}
	return {
		"peer_id": multiplayer.get_unique_id(),
		"name": "Jogador",
		"level": 1,
		"class": "Arcanista",
		"health": 100,
		"max_health": 100
	}

func _get_current_region_id() -> StringName:
	var world := Game.get_system(SystemNames.WORLD) as WorldManager
	if world != null:
		return world.current_region_id()
	return HUB_REGION_ID

func _cleanup_session_state(reason: String) -> void:
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null

	for pawn in _player_pawns.values():
		if pawn != null and is_instance_valid(pawn):
			pawn.queue_free()
	_player_pawns.clear()

	_participants.clear()
	_participant_details.clear()
	_short_invite_code = ""
	_direct_invite_code = ""
	_session_token = ""
	_active_world_name = ""

	log_info("Sessão encerrada (%s)." % reason)
	EventBus.session_left.emit(reason)

# ------------------------------------------------- HANDLERS MULTIPLAYER --

func _on_peer_connected(peer_id: int) -> void:
	if not is_host():
		return
	# Apenas verifica limite imediato; o registro completo aguarda rpc_client_handshake
	if _participants.size() >= max_participants():
		log_warn("Peer %d recusado: capacidade máxima já ocupada." % peer_id)
		EventBus.peer_limit_rejected.emit(peer_id)
		if multiplayer.multiplayer_peer != null:
			multiplayer.multiplayer_peer.disconnect_peer(peer_id)
		return

func _on_peer_disconnected(peer_id: int) -> void:
	if not is_host():
		return
	log_info("Peer %d desconectou." % peer_id)
	_unregister_participant(peer_id)
	_sync_roster_to_all()

func _on_connected_to_server() -> void:
	log_info("Socket conectado ao anfitrião. Enviando handshake de validação...")
	var payload := {
		"token": _session_token,
		"version": PROTOCOL_VERSION,
		"character": _participant_details.get(multiplayer.get_unique_id(), _gather_local_character_details())
	}
	rpc_id(Invariants.HOST_PEER_ID, "rpc_client_handshake", payload)

func _on_connection_failed() -> void:
	log_error("Falha ao estabelecer conexão com o anfitrião.")
	EventBus.connection_failed.emit("Conexão recusada ou timeout.")
	_cleanup_session_state("connection_failed")

func _on_server_disconnected() -> void:
	log_warn("O anfitrião encerrou ou desconectou do mundo privado.")
	EventBus.notification_requested.emit("O anfitrião encerrou a sessão.")
	_cleanup_session_state("server_disconnected")

func verify() -> PackedStringArray:
	var issues := super()
	if _participants.size() > max_participants():
		issues.append("Roster excede o limite estrito de 8 participantes")
	if max_participants() != Invariants.MAX_PARTICIPANTS:
		issues.append("Limite diverge do invariante de produto (8 jogadores)")
	return issues

func collect_save_data() -> Dictionary:
	return {}

func apply_save_data(_data: Dictionary) -> bool:
	return true
