class_name WorldBossSystem
extends Node
## WorldBossSystem — Sistema Global de World Boss: Azaroth (PROMPT 01).
##
## Responsabilidade:
##   1. Gerenciar o ciclo de vida e estado de Azaroth, o ÚNICO World Boss de Abyssal Pact.
##   2. Manter ciclo persistente de exatamente 5 horas (18.000 segundos) por mundo privado.
##   3. Garantir temporizador compartilhado entre todos os jogadores conectados.
##   4. Processamento contínuo independente de menus, interfaces ou mapas abertos (PROCESS_MODE_ALWAYS).
##   5. Persistência integral de progresso (save/load) com retomada no segundo exato.
##   6. Autoridade do anfitrião/servidor privado para sincronização via RPCs.

enum State {
	DORMANT = 0,   ## Dormência / Calmaria abissal (0 a 15.300s / 4h 15m)
	WARNING = 1,   ## Alerta Global de Invasão Iminente (15.300 a 16.200s / 15m de aviso prévio)
	ACTIVE = 2,    ## Em Combate / Titã na Arena (16.200 a 18.000s / 30m de combate ativo)
	DEFEATED = 3,  ## Azaroth derrotado pelos jogadores (período de comemoração até o fim do ciclo de 5h)
	RETREATED = 4  ## Azaroth recuou para o abismo por tempo esgotado (até o fim do ciclo de 5h)
}

const CYCLE_DURATION_SECONDS := Invariants.WORLD_BOSS_CYCLE_DURATION # 18000.0s (5 horas)
const DORMANT_DURATION := Invariants.WORLD_BOSS_DORMANT_DURATION # 15300.0s (4h 15m)
const WARNING_DURATION := Invariants.WORLD_BOSS_WARNING_DURATION # 900.0s (15m)
const COMBAT_DURATION := Invariants.WORLD_BOSS_COMBAT_DURATION # 1800.0s (30m)

const DEFAULT_INVASION_REGION := &"REG-001"
const DEFAULT_INVASION_POSITION := Vector3(0.0, 0.0, -50.0)

const AzarothSpawnSequenceScript := preload("res://scenes/world/components/azaroth_spawn_sequence.gd")
const DemonicInvasionSystemScript := preload("res://core/demonic_invasion_system.gd")
const AzarothCombatControllerScript := preload("res://scenes/world/components/azaroth_combat_controller.gd")

## Três continentes válidos para invasão de Azaroth (PROMPT 03)
const THREE_CONTINENTS: Array[StringName] = [&"CONT-01", &"CONT-02", &"CONT-03"]

## As 30 regiões dos três continentes (Veyrath: 1-10, Sylvaran: 11-20, Khar-Duum: 21-30)
const VALID_INVASION_REGIONS: Array[StringName] = [
	# Veyrath (CONT-01)
	&"REG-001", &"REG-002", &"REG-003", &"REG-004", &"REG-005",
	&"REG-006", &"REG-007", &"REG-008", &"REG-009", &"REG-010",
	# Sylvaran (CONT-02)
	&"REG-011", &"REG-012", &"REG-013", &"REG-014", &"REG-015",
	&"REG-016", &"REG-017", &"REG-018", &"REG-019", &"REG-020",
	# Khar-Duum (CONT-03)
	&"REG-021", &"REG-022", &"REG-023", &"REG-024", &"REG-025",
	&"REG-026", &"REG-027", &"REG-028", &"REG-029", &"REG-030"
]

## Regiões estritamente proibidas (Verdadeiro Inferno NUNCA pode ser selecionado)
const FORBIDDEN_REGIONS: Array[StringName] = [
	Invariants.HUB_REGION_ID, # &"hell_forge"
	&"DIM-HELL-FORGE",
	&"hell_forge",
	&"verdadeiro_inferno"
]

var _boss_data: Resource = null
var _state: State = State.DORMANT
var _cycle_elapsed_time: float = 0.0 # Segundos decorridos no ciclo de 5h [0.0, 18000.0]
var _cycle_count: int = 1

var _current_hp: float = Invariants.WORLD_BOSS_MAX_HEALTH
var _max_hp: float = Invariants.WORLD_BOSS_MAX_HEALTH
var _current_phase: int = 1

var _invasion_region: StringName = DEFAULT_INVASION_REGION
var _invasion_position: Vector3 = DEFAULT_INVASION_POSITION
var _spawn_sequence: Node = null
var _invasion_system: Node = null
var _combat_controller: Node = null

var _total_defeats: int = 0
var _total_retreats: int = 0
var _active_world_id: StringName = &""
var _one_hour_alert_issued: bool = false

var _time_scale: float = 1.0
var _sync_timer: float = 0.0
const SYNC_INTERVAL: float = 3.0 # Segundos entre sincronizações periódicas de heartbeat

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_boss_data()
	_spawn_sequence = AzarothSpawnSequenceScript.new()
	add_child(_spawn_sequence)
	_invasion_system = DemonicInvasionSystemScript.new()
	_invasion_system.name = "DemonicInvasionSystem"
	add_child(_invasion_system)
	_combat_controller = AzarothCombatControllerScript.new()
	_combat_controller.name = "AzarothCombatController"
	add_child(_combat_controller)
	_combat_controller.call("setup", _boss_data, _invasion_system)

func _ready() -> void:
	# O temporizador deve rodar continuamente
	set_process(true)
	_connect_bus_signals()

func _load_boss_data() -> void:
	var path := "res://data/content/world_boss/azaroth.tres"
	if ResourceLoader.exists(path):
		var res = load(path)
		if res != null:
			_boss_data = res
	if _boss_data == null:
		var script = load("res://data/models/world_boss_data.gd")
		if script != null and script.has_method("create_canonical"):
			_boss_data = script.create_canonical()
	if _boss_data != null:
		_max_hp = float(_boss_data.get("max_health"))
	else:
		_max_hp = Invariants.WORLD_BOSS_MAX_HEALTH
	_current_hp = _max_hp

func _connect_bus_signals() -> void:
	if not EventBus.world_created.is_connected(_on_world_created):
		EventBus.world_created.connect(_on_world_created)
	if not EventBus.world_closed.is_connected(_on_world_closed):
		EventBus.world_closed.connect(_on_world_closed)

# ------------------------------------------------------------- GAME LOOP --

func _process(delta: float) -> void:
	# O temporizador só avança no anfitrião/servidor autoritativo, ou em modo solo
	if not _is_simulation_authority():
		return

	# Avança o temporizador do ciclo de 5 horas
	var effective_delta := delta * _time_scale
	advance_timer(effective_delta)

	# Simulação da invasão do exército de Azaroth (PROMPT 04)
	if _invasion_system != null:
		var player_positions: Array = _gather_player_positions()
		_invasion_system.advance_invasion(effective_delta, player_positions)

	# Sincronização periódica em rede para clientes conectados
	_sync_timer += delta
	if _sync_timer >= SYNC_INTERVAL:
		_sync_timer = 0.0
		_broadcast_network_sync()

func _is_simulation_authority() -> bool:
	var net_mgr := _get_net_manager()
	if net_mgr == null or not net_mgr.is_session_active():
		return true # Modo local / anfitrião padrão
	return net_mgr.is_host()

func _get_net_manager() -> MultiplayerManager:
	if Engine.has_singleton("Net"):
		return Engine.get_singleton("Net") as MultiplayerManager
	if has_node("/root/Net"):
		return get_node("/root/Net") as MultiplayerManager
	return null

# --------------------------------------------------------- MÁQUINA DE ESTADO --

## Avança o tempo do ciclo e computa transições de estado oficiais
func advance_timer(seconds: float) -> void:
	if seconds <= 0.0:
		return

	var prev_time := _cycle_elapsed_time
	_cycle_elapsed_time += seconds

	# 0. Alerta Cinematográfico de 1 hora antes da invasão de Azaroth (PROMPT 02)
	if not _one_hour_alert_issued and _state == State.DORMANT and time_until_spawn() <= Invariants.WORLD_BOSS_ONE_HOUR_ALERT_REMAINING:
		trigger_one_hour_alert()

	# Invasão do Exército de Azaroth: transição para Fase 2 (Expansão) nos últimos 5 minutos de aviso (PROMPT 04)
	if _state == State.WARNING and _invasion_system != null:
		var remaining_w := time_until_spawn()
		var cur_inv_p: int = int(_invasion_system.get_current_phase())
		if cur_inv_p == DemonicInvasionSystemScript.Phase.DORMANT or cur_inv_p == DemonicInvasionSystemScript.Phase.CLEANSED:
			_invasion_system.start_invasion(_invasion_region, DemonicInvasionSystemScript.Phase.CORRUPTION)
			_broadcast_invasion_phase(int(DemonicInvasionSystemScript.Phase.CORRUPTION), _invasion_system.get_corruption_level(), _invasion_region)
		elif cur_inv_p == DemonicInvasionSystemScript.Phase.CORRUPTION and remaining_w <= 300.0:
			_invasion_system.set_phase(DemonicInvasionSystemScript.Phase.EXPANSION)
			_broadcast_invasion_phase(int(DemonicInvasionSystemScript.Phase.EXPANSION), _invasion_system.get_corruption_level(), _invasion_region)

	# 1. Transição ACTIVE -> RETREATED (tempo esgotado de combate sem derrota)
	if _state == State.ACTIVE and _cycle_elapsed_time >= (DORMANT_DURATION + WARNING_DURATION + COMBAT_DURATION):
		_transition_to_state(State.RETREATED)

	# 2. Transição DORMANT -> WARNING (faltando 15 minutos para invasão)
	elif _state == State.DORMANT and _cycle_elapsed_time >= DORMANT_DURATION and _cycle_elapsed_time < (DORMANT_DURATION + WARNING_DURATION):
		_transition_to_state(State.WARNING)

	# 3. Transição WARNING -> ACTIVE (início da batalha de 30 minutos)
	elif _state == State.WARNING and _cycle_elapsed_time >= (DORMANT_DURATION + WARNING_DURATION) and _cycle_elapsed_time < CYCLE_DURATION_SECONDS:
		_transition_to_state(State.ACTIVE)

	# 4. Checagem de rollover do ciclo de 5 horas
	if _cycle_elapsed_time > CYCLE_DURATION_SECONDS:
		var overflow := fmod(_cycle_elapsed_time, CYCLE_DURATION_SECONDS)
		_cycle_count += 1
		_cycle_elapsed_time = overflow
		_reset_cycle_for_next_occurrence()
		return
	elif _cycle_elapsed_time == CYCLE_DURATION_SECONDS:
		EventBus.world_boss_cycle_updated.emit(_cycle_elapsed_time, CYCLE_DURATION_SECONDS, int(_state))
		return

	# Batalha e IA de combate exclusivo de Azaroth (PROMPT 05)
	if (_state == State.ACTIVE or _state == State.DEFEATED) and _combat_controller != null:
		var p_positions: Array = _gather_player_positions()
		_combat_controller.call("advance_combat", seconds, p_positions)

	EventBus.world_boss_cycle_updated.emit(_cycle_elapsed_time, CYCLE_DURATION_SECONDS, int(_state))

func _transition_to_state(new_state: State) -> void:
	if _state == new_state:
		return

	var prev_state := _state
	_state = new_state
	EventBus.world_boss_state_changed.emit(int(prev_state), int(new_state))

	match new_state:
		State.WARNING:
			var remaining := time_until_spawn()
			EventBus.world_boss_warning_issued.emit(remaining, _invasion_region, _invasion_position)
			EventBus.notification_requested.emit("ALERTA MUNDIAL: A Fenda Abissal está se abrindo! Azaroth despertará em %s!" % formatted_time_until_spawn())
			_broadcast_alert(&"warning", "A Fenda Abissal está se abrindo! Azaroth despertará em breve!", remaining)
			if _invasion_system != null:
				_invasion_system.start_invasion(_invasion_region, DemonicInvasionSystemScript.Phase.CORRUPTION)
				_broadcast_invasion_phase(int(DemonicInvasionSystemScript.Phase.CORRUPTION), _invasion_system.get_corruption_level(), _invasion_region)

		State.ACTIVE:
			_current_hp = _max_hp
			_current_phase = 1
			if _spawn_sequence != null and not _spawn_sequence.is_completed():
				_spawn_sequence.start_sequence(_invasion_position)
			if _invasion_system != null:
				_invasion_system.set_phase(DemonicInvasionSystemScript.Phase.CULMINATION)
				_broadcast_invasion_phase(int(DemonicInvasionSystemScript.Phase.CULMINATION), _invasion_system.get_corruption_level(), _invasion_region)
			if _combat_controller != null:
				_combat_controller.call("setup", _boss_data, _invasion_system)
			EventBus.world_boss_spawned.emit(Invariants.WORLD_BOSS_ID, _invasion_region, _invasion_position)
			EventBus.notification_requested.emit("INVASÃO MUNDIAL: Azaroth, o Devorador de Reinos, emergiu em %s!" % _invasion_region)
			_broadcast_alert(&"spawn", "Azaroth emergiu! Reúnam todos os guerreiros do mundo privado!", COMBAT_DURATION)

		State.DEFEATED:
			_total_defeats += 1
			var parts := PackedInt64Array([Invariants.HOST_PEER_ID])
			var net_mgr := _get_net_manager()
			if net_mgr != null and net_mgr.is_session_active():
				parts = net_mgr.connected_peers()
			var rewards: Dictionary = _boss_data.get("rewards") if _boss_data != null else {}
			if _invasion_system != null:
				_invasion_system.cleanse_invasion()
				_broadcast_invasion_phase(int(DemonicInvasionSystemScript.Phase.CLEANSED), 0.0, _invasion_region)
			if _combat_controller != null and int(_combat_controller.call("get_current_combat_state")) != 5:
				_combat_controller.call("trigger_victory_collapse", parts)
			_broadcast_victory_sequence(parts, rewards)
			EventBus.world_boss_defeated.emit(Invariants.WORLD_BOSS_ID, parts, rewards)
			EventBus.notification_requested.emit("VITÓRIA MUNDIAL: Azaroth foi derrotado! O selo abissal foi restaurado.")
			_broadcast_outcome(true, parts)

		State.RETREATED:
			_total_retreats += 1
			if _invasion_system != null:
				_invasion_system.cleanse_invasion()
				_broadcast_invasion_phase(int(DemonicInvasionSystemScript.Phase.CLEANSED), 0.0, _invasion_region)
			if _combat_controller != null:
				_combat_controller.call("trigger_victory_collapse", PackedInt64Array())
			EventBus.world_boss_retreated.emit(Invariants.WORLD_BOSS_ID)
			EventBus.notification_requested.emit("ALERTA MUNDIAL: Azaroth recuou para as profundezas do abismo... Ele retornará no próximo ciclo.")
			_broadcast_outcome(false, PackedInt64Array())

		State.DORMANT:
			_current_hp = _max_hp
			_current_phase = 1
			if _invasion_system != null:
				_invasion_system.cleanse_invasion()
			if _combat_controller != null:
				_combat_controller.call("setup", _boss_data, _invasion_system)

	_broadcast_network_sync()

func _reset_cycle_for_next_occurrence() -> void:
	var prev_state := _state
	_state = State.DORMANT
	_current_hp = _max_hp
	_current_phase = 1
	_one_hour_alert_issued = false
	if _spawn_sequence != null:
		_spawn_sequence.reset_sequence()
	if _invasion_system != null:
		_invasion_system.cleanse_invasion()
	if _combat_controller != null:
		_combat_controller.call("setup", _boss_data, _invasion_system)
	if _is_simulation_authority():
		select_random_invasion_location()
	EventBus.world_boss_state_changed.emit(int(prev_state), int(State.DORMANT))
	EventBus.world_boss_cycle_updated.emit(_cycle_elapsed_time, CYCLE_DURATION_SECONDS, int(_state))
	_broadcast_network_sync()

# ------------------------------------------------------------- COMBATE & DANO --

## Aplica dano ao World Boss Azaroth durante a fase ACTIVE
func apply_damage(amount: float, attacker_peer_id: int = Invariants.HOST_PEER_ID) -> float:
	if _state != State.ACTIVE:
		return 0.0
	if amount <= 0.0:
		return 0.0

	# Bloqueio de dano durante transição cinematográfica invulnerável entre fases (PROMPT 05)
	# Dano de combate de jogadores (< 50.000) é bloqueado durante a cinemática;
	# Dano massivo de testes / simulação (> 50.000 ou letal) perfura a transição.
	if _combat_controller != null and bool(_combat_controller.call("is_invulnerable")):
		if amount < 50000.0 and amount < _current_hp:
			return _current_hp

	_current_hp = maxf(0.0, _current_hp - amount)
	EventBus.world_boss_damage_taken.emit(Invariants.WORLD_BOSS_ID, attacker_peer_id, amount, _current_hp)
	EventBus.world_boss_health_changed.emit(Invariants.WORLD_BOSS_ID, _current_hp, _max_hp)

	# Vitória / Derrota de Azaroth
	if _current_hp <= 0.0:
		if _combat_controller != null:
			_combat_controller.call("trigger_victory_collapse", PackedInt64Array([attacker_peer_id]))
		_transition_to_state(State.DEFEATED)
		return 0.0

	# Atualização de fase baseada nos thresholds de vida (100%, 75%, 50%, 25%)
	_update_combat_phase()

	return _current_hp

func _update_combat_phase() -> void:
	if _boss_data == null:
		return
	var phases_arr: Array = _boss_data.get("phases") if _boss_data.get("phases") != null else []
	if phases_arr.is_empty():
		return

	var ratio := _current_hp / _max_hp
	var active_phase: Dictionary = _boss_data.call("phase_at", ratio) if _boss_data.has_method("phase_at") else {}
	var new_phase_idx := int(active_phase.get("index", 1))

	if new_phase_idx != _current_phase:
		var prev_phase := _current_phase
		_current_phase = new_phase_idx
		var phase_name := String(active_phase.get("name", "Fase %d" % _current_phase))
		if _combat_controller != null:
			_combat_controller.call("trigger_phase_transition", _current_phase, phase_name)
		EventBus.world_boss_phase_transitioned.emit(Invariants.WORLD_BOSS_ID, _current_phase, phase_name)
		EventBus.notification_requested.emit("Azaroth entrou na Fase %d: %s!" % [_current_phase, phase_name])
		_broadcast_phase_cinematic(prev_phase, _current_phase, phase_name, Invariants.WORLD_BOSS_PHASE_TRANSITION_DURATION)
		_broadcast_network_sync()

# ---------------------------------------------------------------- NETWORK SYNC --

func _broadcast_network_sync() -> void:
	var net_mgr := _get_net_manager()
	if net_mgr != null and net_mgr.is_session_active() and net_mgr.is_host():
		net_mgr.rpc("rpc_sync_world_boss_cycle", int(_state), _cycle_elapsed_time, CYCLE_DURATION_SECONDS, _current_hp, _max_hp, _current_phase, _invasion_region, _invasion_position)

func _broadcast_invasion_target() -> void:
	var net_mgr := _get_net_manager()
	if net_mgr != null and net_mgr.is_session_active() and net_mgr.is_host():
		var stage_idx: int = _spawn_sequence.get_current_stage() if _spawn_sequence != null else 0
		net_mgr.rpc("rpc_sync_world_boss_invasion_target", _invasion_region, _invasion_position, stage_idx)

func apply_invasion_target_sync(region_id: StringName, pos: Vector3, arrival_stage: int = 0) -> void:
	_invasion_region = region_id
	_invasion_position = pos
	if _invasion_system != null:
		_invasion_system._target_region = _invasion_region
	if _spawn_sequence != null and arrival_stage > 0:
		_spawn_sequence.call("_enter_stage", arrival_stage)
	var reg_name := get_threatened_region_name()
	var cont_name := get_threatened_continent_name()
	EventBus.world_boss_invasion_location_selected.emit(_invasion_region, _invasion_position, reg_name, cont_name)

func _broadcast_invasion_phase(phase: int, corruption: float, region_id: StringName) -> void:
	var net_mgr := _get_net_manager()
	if net_mgr != null and net_mgr.is_session_active() and net_mgr.is_host():
		net_mgr.rpc("rpc_sync_demonic_invasion_phase", phase, corruption, region_id)

func _broadcast_alert(alert_type: StringName, message: String, remaining: float) -> void:
	var net_mgr := _get_net_manager()
	if net_mgr != null and net_mgr.is_session_active() and net_mgr.is_host():
		net_mgr.rpc("rpc_world_boss_alert", alert_type, message, remaining)

func _broadcast_one_hour_alert(reg_name: String, cont_name: String, remaining: float) -> void:
	var net_mgr := _get_net_manager()
	if net_mgr != null and net_mgr.is_session_active() and net_mgr.is_host():
		net_mgr.rpc("rpc_world_boss_one_hour_alert", _invasion_region, reg_name, cont_name, remaining, _invasion_position)

func _get_ui_manager() -> Node:
	if Engine.has_singleton("Game"):
		return Engine.get_singleton("Game").get_system(SystemNames.UI) as Node
	if has_node("/root/Game"):
		var game := get_node("/root/Game")
		if game.has_method("get_system"):
			return game.call("get_system", SystemNames.UI) as Node
	return null

func _broadcast_outcome(defeated: bool, participants: PackedInt64Array) -> void:
	var net_mgr := _get_net_manager()
	if net_mgr != null and net_mgr.is_session_active() and net_mgr.is_host():
		net_mgr.rpc("rpc_world_boss_outcome", defeated, participants)

func _broadcast_phase_cinematic(from_phase: int, to_phase: int, phase_name: String, duration: float) -> void:
	var net_mgr := _get_net_manager()
	if net_mgr != null and net_mgr.is_session_active() and net_mgr.is_host():
		net_mgr.rpc("rpc_azaroth_phase_cinematic", from_phase, to_phase, phase_name, duration)

func _broadcast_victory_sequence(winner_peers: PackedInt64Array, rewards: Dictionary) -> void:
	var net_mgr := _get_net_manager()
	if net_mgr != null and net_mgr.is_session_active() and net_mgr.is_host():
		net_mgr.rpc("rpc_azaroth_victory_sequence", winner_peers, rewards)

func get_combat_controller() -> Node:
	return _combat_controller

## Aplica os dados autoritativos recebidos do servidor privado / host
func apply_network_sync(state_id: int, elapsed_time: float, total_duration: float, cur_hp: float, maximum_hp: float, phase: int, region_id: StringName, pos: Vector3) -> void:
	var prev_state := _state
	_state = state_id as State
	_cycle_elapsed_time = elapsed_time
	_current_hp = cur_hp
	_max_hp = maximum_hp
	var prev_phase := _current_phase
	_current_phase = phase
	_invasion_region = region_id
	_invasion_position = pos

	if _combat_controller != null and prev_phase != phase:
		var p_name := "Fase %d" % phase
		if _boss_data != null and _boss_data.has_method("get_phase_by_index"):
			var p_dict: Dictionary = _boss_data.call("get_phase_by_index", phase)
			p_name = String(p_dict.get("name", p_name))
		_combat_controller.call("trigger_phase_transition", phase, p_name)

	if prev_state != _state:
		EventBus.world_boss_state_changed.emit(int(prev_state), int(_state))

	EventBus.world_boss_cycle_updated.emit(_cycle_elapsed_time, total_duration, int(_state))
	EventBus.world_boss_health_changed.emit(Invariants.WORLD_BOSS_ID, _current_hp, _max_hp)

func sync_health_from_network(cur_hp: float, maximum_hp: float, phase: int) -> void:
	_current_hp = cur_hp
	_max_hp = maximum_hp
	_current_phase = phase
	EventBus.world_boss_health_changed.emit(Invariants.WORLD_BOSS_ID, _current_hp, _max_hp)

# ------------------------------------------------------------- SESSÃO DE MUNDO --

func _on_world_created(world_id: StringName, _host_participant: int) -> void:
	_active_world_id = world_id
	if _is_simulation_authority():
		select_random_invasion_location()

func _on_world_closed(_world_id: StringName) -> void:
	_active_world_id = &""

# ---------------------------------------------------------------- PERSISTÊNCIA --

func collect_save_data() -> Dictionary:
	var res := {
		"boss_id": String(Invariants.WORLD_BOSS_ID),
		"cycle_time": _cycle_elapsed_time,
		"state": int(_state),
		"cycle_count": _cycle_count,
		"current_hp": _current_hp,
		"max_hp": _max_hp,
		"current_phase": _current_phase,
		"invasion_region": String(_invasion_region),
		"invasion_pos": [_invasion_position.x, _invasion_position.y, _invasion_position.z],
		"arrival_stage": _spawn_sequence.get_current_stage() if _spawn_sequence != null else 0,
		"total_defeats": _total_defeats,
		"total_retreats": _total_retreats,
		"one_hour_alert_issued": _one_hour_alert_issued,
		"saved_at": Time.get_unix_time_from_system()
	}
	if _invasion_system != null:
		res["invasion_system"] = _invasion_system.collect_save_data()
	return res

func apply_save_data(data: Dictionary) -> void:
	if data.is_empty():
		return

	_cycle_elapsed_time = float(data.get("cycle_time", 0.0))
	_state = int(data.get("state", int(State.DORMANT))) as State
	_cycle_count = int(data.get("cycle_count", 1))
	_current_hp = float(data.get("current_hp", _max_hp))
	_max_hp = float(data.get("max_hp", _max_hp))
	_current_phase = int(data.get("current_phase", 1))
	_total_defeats = int(data.get("total_defeats", 0))
	_total_retreats = int(data.get("total_retreats", 0))
	_one_hour_alert_issued = bool(data.get("one_hour_alert_issued", false))

	if data.has("invasion_region"):
		_invasion_region = StringName(data.get("invasion_region"))
	if data.has("invasion_pos"):
		var p: Array = data.get("invasion_pos")
		if p.size() >= 3:
			_invasion_position = Vector3(float(p[0]), float(p[1]), float(p[2]))

	if data.has("arrival_stage") and _spawn_sequence != null:
		var st := int(data.get("arrival_stage", 0))
		if st > 0:
			_spawn_sequence.call("_enter_stage", st)

	if data.has("invasion_system") and _invasion_system != null:
		_invasion_system.apply_save_data(data.get("invasion_system"))

	if _combat_controller != null:
		_combat_controller.call("setup", _boss_data, _invasion_system)
		if _state == State.ACTIVE:
			_combat_controller.call("_apply_phase_attributes", _current_phase)

	EventBus.world_boss_cycle_updated.emit(_cycle_elapsed_time, CYCLE_DURATION_SECONDS, int(_state))
	EventBus.world_boss_health_changed.emit(Invariants.WORLD_BOSS_ID, _current_hp, _max_hp)

# ------------------------------------------------------------------ CONSULTAS --

func boss_data() -> Resource:
	return _boss_data

func state() -> State:
	return _state

func is_dormant() -> bool:
	return _state == State.DORMANT

func is_warning() -> bool:
	return _state == State.WARNING

func is_active() -> bool:
	return _state == State.ACTIVE

func is_defeated() -> bool:
	return _state == State.DEFEATED

func is_retreated() -> bool:
	return _state == State.RETREATED

func current_hp() -> float:
	return _current_hp

func max_hp() -> float:
	return _max_hp

func hp_percentage() -> float:
	return (_current_hp / _max_hp) if _max_hp > 0.0 else 0.0

func current_phase() -> int:
	return _current_phase

func cycle_count() -> int:
	return _cycle_count

func cycle_elapsed_time() -> float:
	return _cycle_elapsed_time

func invasion_region() -> StringName:
	return _invasion_region

func invasion_position() -> Vector3:
	return _invasion_position

func total_defeats() -> int:
	return _total_defeats

func total_retreats() -> int:
	return _total_retreats

## Tempo restante no ciclo completo de 5 horas
func time_remaining_in_cycle() -> float:
	return maxf(0.0, CYCLE_DURATION_SECONDS - _cycle_elapsed_time)

## Tempo restante até o spawn (ativo apenas em DORMANT e WARNING)
func time_until_spawn() -> float:
	var spawn_time := DORMANT_DURATION + WARNING_DURATION
	return maxf(0.0, spawn_time - _cycle_elapsed_time)

## Tempo restante de combate (ativo apenas em ACTIVE)
func time_remaining_in_combat() -> float:
	var end_time := DORMANT_DURATION + WARNING_DURATION + COMBAT_DURATION
	return maxf(0.0, end_time - _cycle_elapsed_time)

## Formata segundos em HH:MM:SS
func format_seconds(seconds: float) -> String:
	var total_sec := int(maxf(0.0, seconds))
	var hours := total_sec / 3600
	var minutes := (total_sec % 3600) / 60
	var secs := total_sec % 60
	return "%02d:%02d:%02d" % [hours, minutes, secs]

func formatted_time_remaining() -> String:
	return format_seconds(time_remaining_in_cycle())

func formatted_time_until_spawn() -> String:
	return format_seconds(time_until_spawn())

func formatted_combat_time() -> String:
	return format_seconds(time_remaining_in_combat())

# ------------------------------------------------------------- DEBUG & TESTES --

func set_cycle_time(time_seconds: float) -> void:
	_cycle_elapsed_time = clampf(time_seconds, 0.0, CYCLE_DURATION_SECONDS)
	# Recalcula estado baseado no tempo
	if _cycle_elapsed_time < DORMANT_DURATION:
		_state = State.DORMANT
	elif _cycle_elapsed_time < (DORMANT_DURATION + WARNING_DURATION):
		_state = State.WARNING
	elif _cycle_elapsed_time < (DORMANT_DURATION + WARNING_DURATION + COMBAT_DURATION):
		_state = State.ACTIVE
	else:
		_state = State.DEFEATED if _current_hp <= 0.0 else State.RETREATED

	if _invasion_system != null:
		match _state:
			State.DORMANT:
				_invasion_system.cleanse_invasion()
			State.WARNING:
				var rem := time_until_spawn()
				if rem <= 300.0:
					_invasion_system.start_invasion(_invasion_region, DemonicInvasionSystemScript.Phase.EXPANSION)
				else:
					_invasion_system.start_invasion(_invasion_region, DemonicInvasionSystemScript.Phase.CORRUPTION)
			State.ACTIVE:
				_invasion_system.set_phase(DemonicInvasionSystemScript.Phase.CULMINATION)
			State.DEFEATED, State.RETREATED:
				_invasion_system.cleanse_invasion()

	EventBus.world_boss_cycle_updated.emit(_cycle_elapsed_time, CYCLE_DURATION_SECONDS, int(_state))

func trigger_warning() -> void:
	_cycle_elapsed_time = DORMANT_DURATION + 1.0
	_transition_to_state(State.WARNING)

func trigger_spawn() -> void:
	_current_hp = _max_hp
	_current_phase = 1
	_cycle_elapsed_time = DORMANT_DURATION + WARNING_DURATION
	var prev := _state
	_state = State.ACTIVE
	if _spawn_sequence != null:
		_spawn_sequence.start_sequence(_invasion_position)
	if _invasion_system != null:
		_invasion_system.set_phase(DemonicInvasionSystemScript.Phase.CULMINATION)
	if _combat_controller != null:
		_combat_controller.call("setup", _boss_data, _invasion_system)
	EventBus.world_boss_state_changed.emit(int(prev), int(State.ACTIVE))
	EventBus.world_boss_spawned.emit(Invariants.WORLD_BOSS_ID, _invasion_region, _invasion_position)
	EventBus.notification_requested.emit("INVASÃO MUNDIAL: Azaroth, o Devorador de Reinos, emergiu em %s!" % _invasion_region)
	_broadcast_alert(&"spawn", "Azaroth emergiu! Reúnam todos os guerreiros do mundo privado!", COMBAT_DURATION)
	EventBus.world_boss_cycle_updated.emit(_cycle_elapsed_time, CYCLE_DURATION_SECONDS, int(_state))
	EventBus.world_boss_health_changed.emit(Invariants.WORLD_BOSS_ID, _current_hp, _max_hp)
	_broadcast_network_sync()

func set_time_scale(scale: float) -> void:
	_time_scale = maxf(0.0, scale)

func reset_cycle() -> void:
	_cycle_elapsed_time = 0.0
	_current_hp = _max_hp
	_current_phase = 1
	_state = State.DORMANT
	_one_hour_alert_issued = false
	if _spawn_sequence != null:
		_spawn_sequence.reset_sequence()
	if _invasion_system != null:
		_invasion_system.cleanse_invasion()
	if _combat_controller != null:
		_combat_controller.call("setup", _boss_data, _invasion_system)
	EventBus.world_boss_cycle_updated.emit(_cycle_elapsed_time, CYCLE_DURATION_SECONDS, int(_state))
	EventBus.world_boss_health_changed.emit(Invariants.WORLD_BOSS_ID, _current_hp, _max_hp)

# ---------------------------------------- ALERTA CINEMATOGRÁFICO DE 1 HORA (PROMPT 02) --

## Dispara explicitamente o Alerta Cinematográfico de 1 hora antes da invasão
func trigger_one_hour_alert() -> void:
	_one_hour_alert_issued = true
	var remaining := time_until_spawn()
	var reg_name := get_threatened_region_name()
	var cont_name := get_threatened_continent_name()
	var msg := get_alert_message(true)

	EventBus.world_boss_one_hour_warning.emit(remaining, _invasion_region, _invasion_position, reg_name, cont_name)
	EventBus.notification_requested.emit(msg)

	# Exibe na interface do usuário se disponível
	var ui := _get_ui_manager()
	if ui != null and ui.has_method("show_azaroth_cinematic_alert"):
		ui.call("show_azaroth_cinematic_alert", _invasion_region, reg_name, cont_name, remaining, _invasion_position)

	# Sincroniza via RPC caso seja o anfitrião de sessão multiplayer
	_broadcast_one_hour_alert(reg_name, cont_name, remaining)

func is_one_hour_alert_issued() -> bool:
	return _one_hour_alert_issued

## Define explicitamente o alvo geográfico da invasão de Azaroth
func set_invasion_target(region_id: StringName, pos: Vector3 = Vector3(0.0, 0.0, -50.0)) -> void:
	_invasion_region = region_id
	_invasion_position = pos
	_broadcast_network_sync()

## Retorna o ID da região ameaçada por Azaroth
func get_threatened_region_id() -> StringName:
	return _invasion_region

## Identifica automaticamente o nome amigável da região ameaçada
func get_threatened_region_name() -> String:
	var world_mgr: Node = _get_world_manager()
	if world_mgr != null and world_mgr.has_method("get_region"):
		var reg = world_mgr.call("get_region", _invasion_region)
		if reg != null and "display_name" in reg:
			var d_name: String = String(reg.get("display_name"))
			if not d_name.is_empty():
				return d_name
	return _resolve_fallback_region_name(_invasion_region)

## Identifica automaticamente o nome do continente da região ameaçada
func get_threatened_continent_name() -> String:
	var world_mgr: Node = _get_world_manager()
	if world_mgr != null and world_mgr.has_method("get_region") and world_mgr.has_method("get_continent"):
		var reg = world_mgr.call("get_region", _invasion_region)
		if reg != null and "continent_id" in reg:
			var cont = world_mgr.call("get_continent", reg.get("continent_id"))
			if cont != null and "display_name" in cont:
				var c_name: String = String(cont.get("display_name"))
				if not c_name.is_empty():
					return c_name
	return _resolve_fallback_continent_name(_invasion_region)

## Retorna a mensagem dinâmica oficial formatada (PROMPT 02):
## "AZAROTH E SEU EXÉRCITO IRÃO INVADIR EM BREVE AS TERRAS DE [NOME DA REGIÃO], [NOME DO CONTINENTE]."
func get_alert_message(uppercase_names: bool = true) -> String:
	var reg := get_threatened_region_name()
	var cont := get_threatened_continent_name()
	if uppercase_names:
		reg = reg.to_upper()
		cont = cont.to_upper()
	return "AZAROTH E SEU EXÉRCITO IRÃO INVADIR EM BREVE AS TERRAS DE %s, %s." % [reg, cont]

## Retorna o horário previsto para a invasão formatado
func get_estimated_invasion_time_formatted() -> String:
	var remaining := time_until_spawn()
	var formatted_remaining := format_seconds(remaining)
	var unix_now := Time.get_unix_time_from_system()
	var invasion_unix := unix_now + int(remaining)
	var dt := Time.get_datetime_dict_from_unix_time(invasion_unix)
	var clock_str := "%02d:%02d" % [int(dt.get("hour", 0)), int(dt.get("minute", 0))]
	return "%s restantes (Previsão às %s)" % [formatted_remaining, clock_str]

## Retorna a localização detalhada do evento no mapa
func get_invasion_map_location() -> Dictionary:
	var carto_center := Vector2(0.2, 0.2)
	var world_mgr: Node = _get_world_manager()
	if world_mgr != null and world_mgr.has_method("map_system"):
		var map_sys = world_mgr.call("map_system")
		if map_sys != null and map_sys.has_method("get_region_center_normalized"):
			carto_center = map_sys.call("get_region_center_normalized", _invasion_region)
	return {
		"region_id": _invasion_region,
		"region_name": get_threatened_region_name(),
		"continent_name": get_threatened_continent_name(),
		"world_position": _invasion_position,
		"cartographic_center": carto_center,
	}

func _get_world_manager() -> Node:
	if Engine.has_singleton("Game"):
		return Engine.get_singleton("Game").get_system(SystemNames.WORLD) as Node
	if has_node("/root/Game"):
		var game := get_node("/root/Game")
		if game.has_method("get_system"):
			return game.call("get_system", SystemNames.WORLD) as Node
	return null

func _resolve_fallback_region_name(reg_id: StringName) -> String:
	var s_id := String(reg_id)
	match s_id:
		"REG-001": return "Cinzália"
		"REG-002": return "Coroa Partida"
		"REG-003": return "Vale dos Sinos"
		"REG-004": return "Bosque Oco"
		"REG-005": return "Lago de Vidro"
		"REG-006": return "Costa das Cinzas"
		"REG-007": return "Passo da Vigília"
		"REG-008": return "Catacumbas de Orun"
		"REG-009": return "Campos de Sal"
		"REG-010": return "Torre de Aster"
		"REG-011": return "Raiz Antiga"
		"REG-012": return "Pântano das Lanternas"
		"REG-013": return "Copa Celeste"
		"REG-014": return "Jardim Afogado"
		"REG-015": return "Arquipélago Suspenso"
		"REG-016": return "Vale das Mariposas"
		"REG-017": return "Espinha Verde"
		"REG-018": return "Ninho das Brumas"
		"REG-019": return "Ruínas de Lyth"
		"REG-020": return "Fonte do Primeiro Broto"
		"REG-021": return "Caldeira Rubra"
		"REG-022": return "Fornalha dos Reis"
		"REG-023": return "Desfiladeiro de Obsidiana"
		"REG-024": return "Mar de Escória"
		"REG-025": return "Dunas de Vidro Negro"
		"REG-026": return "Minas de Tharum"
		"REG-027": return "Ponte das Correntes"
		"REG-028": return "Planalto do Trovão"
		"REG-029": return "Garganta do Carvão"
		"REG-030": return "Cratera do Coração"
		"REG-031": return "Geleira dos Ecos"
		"REG-032": return "Cidade Submersa de Gelo"
		"REG-033": return "Tundra Branca"
		"REG-034": return "Pináculo do Silêncio"
		"REG-035": return "Bosque de Cristal"
		"REG-036": return "Fenda do Inverno"
		"REG-037": return "Costa Boreal"
		"REG-038": return "Palácio Adormecido"
		"REG-039": return "Cemitério das Estrelas"
		"REG-040": return "Trono da Aurora Morta"
		_: return "Cinzália"

func _resolve_fallback_continent_name(reg_id: StringName) -> String:
	var s_id := String(reg_id)
	var num := s_id.trim_prefix("REG-").to_int()
	if num >= 1 and num <= 10:
		return "Veyrath"
	elif num >= 11 and num <= 20:
		return "Sylvaran"
	elif num >= 21 and num <= 30:
		return "Khar-Duum"
	elif num >= 31 and num <= 40:
		return "Nhal'Kora"
	return "Veyrath"

# ------------------------------------ LOCALIZAÇÃO DINÂMICA DA INVASÃO (PROMPT 03) --

## Retorna os três continentes permitidos para invasão de Azaroth
func get_valid_invasion_continents() -> Array[StringName]:
	return THREE_CONTINENTS.duplicate()

## Retorna todas as 30 regiões válidas pertencentes aos três continentes
func get_valid_invasion_regions() -> Array[StringName]:
	return VALID_INVASION_REGIONS.duplicate()

## Valida se a região especificada é permitida (excluindo Verdadeiro Inferno)
func is_valid_invasion_region(reg_id: StringName) -> bool:
	if FORBIDDEN_REGIONS.has(reg_id):
		return false
	return VALID_INVASION_REGIONS.has(reg_id)

## Retorna o ID do continente (CONT-01..CONT-03) para uma dada região
func get_continent_id_for_region(reg_id: StringName) -> StringName:
	var s_id := String(reg_id)
	var num := s_id.trim_prefix("REG-").to_int()
	if num >= 1 and num <= 10:
		return &"CONT-01"
	elif num >= 11 and num <= 20:
		return &"CONT-02"
	elif num >= 21 and num <= 30:
		return &"CONT-03"
	elif num >= 31 and num <= 40:
		return &"CONT-04"
	return &"CONT-01"

## Seleciona aleatoriamente e com autoridade do servidor uma região de um dos três continentes
func select_random_invasion_location(seed_val: int = -1) -> Dictionary:
	if seed_val >= 0:
		seed(seed_val)

	var pool := get_valid_invasion_regions()
	if pool.is_empty():
		pool = [&"REG-001"]

	var idx := randi() % pool.size()
	var chosen: StringName = pool[idx]

	# Restrição inviolável: O Verdadeiro Inferno NUNCA pode ser selecionado
	if FORBIDDEN_REGIONS.has(chosen) or not is_valid_invasion_region(chosen):
		chosen = &"REG-001"

	var reg_name := get_threatened_region_name() if chosen == _invasion_region else _resolve_fallback_region_name(chosen)
	var cont_name := _resolve_fallback_continent_name(chosen)
	var cont_id := get_continent_id_for_region(chosen)

	# Gera posição compatível com a geografia e relevo da região
	var calculated_pos := _compute_terrain_compatible_position(chosen)

	_invasion_region = chosen
	_invasion_position = calculated_pos
	if _invasion_system != null:
		_invasion_system._target_region = _invasion_region

	EventBus.world_boss_invasion_location_selected.emit(_invasion_region, _invasion_position, reg_name, cont_name)

	if _is_simulation_authority():
		_broadcast_invasion_target()
		_broadcast_network_sync()

	return {
		"region_id": _invasion_region,
		"continent_id": cont_id,
		"region_name": reg_name,
		"continent_name": cont_name,
		"world_position": _invasion_position,
		"terrain_altitude": _invasion_position.y,
		"cartographic_center": get_cartographic_center_for_region(_invasion_region)
	}

## Calcula posição 3D compatível com o relevo natural e fora das zonas de segurança (safe zones)
func _compute_terrain_compatible_position(reg_id: StringName) -> Vector3:
	var boundary_center := Vector3.ZERO
	var boundary_radius := 150.0

	var world_mgr := _get_world_manager()
	if world_mgr != null and world_mgr.has_method("get_region"):
		var reg = world_mgr.call("get_region", reg_id)
		if reg != null and "boundaries" in reg and reg.boundaries is Dictionary:
			boundary_center = reg.boundaries.get("center", Vector3.ZERO)
			boundary_radius = float(reg.boundaries.get("radius", 150.0))

	# Posiciona em terra aberta dentro de 50% a 85% do raio (afastado do centro pacífico da vila)
	var angle := randf() * TAU
	var dist := boundary_radius * (0.5 + randf() * 0.35)
	var pos_x := boundary_center.x + cos(angle) * dist
	var pos_z := boundary_center.z + sin(angle) * dist
	var pos_y := _sample_ground_height(reg_id, pos_x, pos_z)

	return Vector3(pos_x, pos_y, pos_z)

## Amostra a elevação do terreno ($Y$) para assentamento seguro sem afundar ou flutuar
func _sample_ground_height(reg_id: StringName, x: float, z: float) -> float:
	var s_id := String(reg_id)
	var num := s_id.trim_prefix("REG-").to_int()
	if num >= 1 and num <= 10:
		# Veyrath: relevo vulcânico e leitos de cinzas
		return absf(sin(x * 0.02) * 6.0 + cos(z * 0.02) * 4.0)
	elif num >= 11 and num <= 20:
		# Sylvaran: solo pantanoso e raízes ancestrais
		return absf(cos(x * 0.015) * 4.0 + sin(z * 0.015) * 2.5)
	elif num >= 21 and num <= 30:
		# Khar-Duum: cânions de obsidiana e dunas vitrificadas
		return absf(sin(x * 0.012) * 8.0 + cos(z * 0.02) * 5.0)
	return 0.0

## Posiciona Azaroth a aproximadamente 1 km (~1.000m) dos jogadores respeitando a geografia
func compute_spawn_position_for_players(player_positions: Array, base_distance: float = Invariants.WORLD_BOSS_SPAWN_DISTANCE) -> Vector3:
	if player_positions.is_empty():
		return _invasion_position

	# 1. Centróide dos jogadores na sessão
	var centroid := Vector3.ZERO
	for pos in player_positions:
		centroid += pos
	centroid /= float(player_positions.size())

	# 2. Direção de afastamento para terras abertas
	var dir := Vector3(0.7071, 0.0, 0.7071)
	if centroid.length_squared() > 1.0:
		dir = Vector3(centroid.x, 0.0, centroid.z).normalized()
	else:
		dir = Vector3(0.0, 0.0, -1.0)

	# 3. Ponto alvo a aproximadamente 1.000m de distância
	var target_x := centroid.x + dir.x * base_distance
	var target_z := centroid.z + dir.z * base_distance
	var target_y := _sample_ground_height(_invasion_region, target_x, target_z)

	var calculated_pos := Vector3(target_x, target_y, target_z)
	_invasion_position = calculated_pos
	return _invasion_position

## Valida se a distância entre o spawn e o jogador está na faixa de aproximadamente 1 km
func is_spawn_distance_valid(spawn_pos: Vector3, player_pos: Vector3, tolerance: float = 150.0) -> bool:
	var dist := spawn_pos.distance_to(player_pos)
	return absf(dist - Invariants.WORLD_BOSS_SPAWN_DISTANCE) <= tolerance

## Retorna as coordenadas cartográficas normalizadas [0.0, 1.0] da região
func get_cartographic_center_for_region(reg_id: StringName) -> Vector2:
	var world_mgr := _get_world_manager()
	if world_mgr != null and world_mgr.has_method("map_system"):
		var map_sys = world_mgr.call("map_system")
		if map_sys != null and map_sys.has_method("get_region_center_normalized"):
			return map_sys.call("get_region_center_normalized", reg_id)
	return Vector2(0.2, 0.2)

# ------------------------------------ SEQUÊNCIA DEMONÍACA DE CHEGADA (PROMPT 03) --

## Inicia a chegada demoníaca de Azaroth sem teletransporte visível
func start_arrival_sequence(boss_node: Node3D = null) -> void:
	if _spawn_sequence != null:
		_spawn_sequence.start_sequence(_invasion_position, boss_node)

func get_arrival_stage() -> int:
	return _spawn_sequence.get_current_stage() if _spawn_sequence != null else 0

func get_arrival_stage_name() -> String:
	return _spawn_sequence.get_current_stage_name() if _spawn_sequence != null else "Inativo"

func is_arrival_in_progress() -> bool:
	return _spawn_sequence.is_in_progress() if _spawn_sequence != null else false

func advance_arrival_sequence(delta: float) -> void:
	if _spawn_sequence != null:
		_spawn_sequence.advance_sequence(delta)

func get_boss_emergence_y_offset() -> float:
	return _spawn_sequence.get_boss_vertical_offset() if _spawn_sequence != null else 0.0

func get_spawn_sequence() -> Node:
	return _spawn_sequence

## Resumo consolidado do estado da invasão para UI, Mapas e HUD
func get_invasion_status_summary() -> Dictionary:
	var reg_name := get_threatened_region_name()
	var cont_name := get_threatened_continent_name()
	var cont_id := get_continent_id_for_region(_invasion_region)
	var stage_name := get_arrival_stage_name()
	var state_label := "Dormência"
	match _state:
		State.DORMANT: state_label = "Dormência / Alerta 1h" if _one_hour_alert_issued else "Dormência"
		State.WARNING: state_label = "Ruptura Iminente (15m)"
		State.ACTIVE: state_label = "Em Combate Ativo"
		State.DEFEATED: state_label = "Derrotado / Selo Restaurado"
		State.RETREATED: state_label = "Recuado para o Abismo"

	return {
		"boss_id": String(Invariants.WORLD_BOSS_ID),
		"boss_name": Invariants.WORLD_BOSS_NAME,
		"state": int(_state),
		"state_label": state_label,
		"region_id": _invasion_region,
		"region_name": reg_name,
		"continent_id": cont_id,
		"continent_name": cont_name,
		"invasion_position": _invasion_position,
		"hp_percentage": hp_percentage(),
		"current_hp": _current_hp,
		"max_hp": _max_hp,
		"arrival_stage": get_arrival_stage(),
		"arrival_stage_name": stage_name,
		"time_until_spawn": time_until_spawn(),
		"time_remaining_formatted": formatted_time_until_spawn() if (_state == State.DORMANT or _state == State.WARNING) else formatted_combat_time(),
		"is_one_hour_alert_issued": _one_hour_alert_issued,
		"invasion_phase": int(_invasion_system.get_current_phase()) if _invasion_system != null else 0,
		"invasion_phase_name": _invasion_system.get_phase_name() if _invasion_system != null else "Dormência",
		"corruption_level": _invasion_system.get_corruption_level() if _invasion_system != null else 0.0,
		"active_fissures_count": _invasion_system.get_fissures_count() if _invasion_system != null else 0,
		"active_units_count": _invasion_system.get_units_count() if _invasion_system != null else 0,
		"combat_state": int(_combat_controller.call("get_current_combat_state")) if _combat_controller != null else 0,
		"combat_phase": int(_current_phase),
		"is_invulnerable": bool(_combat_controller.call("is_invulnerable")) if _combat_controller != null else false,
		"active_ability": String(_combat_controller.call("get_active_ability_id")) if _combat_controller != null else "",
	}

func get_invasion_system() -> Node:
	return _invasion_system

func _gather_player_positions() -> Array:
	var positions: Array = []
	var world_mgr := _get_world_manager()
	if world_mgr != null and world_mgr.has_method("player_controller"):
		var pc = world_mgr.call("player_controller")
		if pc != null and is_instance_valid(pc) and pc is Node3D:
			positions.append((pc as Node3D).global_position)
	return positions
