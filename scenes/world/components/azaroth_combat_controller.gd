class_name AzarothCombatController
extends Node3D
## AzarothCombatController — Controlador de Combate Exclusivo de Azaroth (PROMPT 05).
##
## Responsabilidade:
##   1. Orquestrar a IA e máquina de estados de combate de Azaroth durante a fase ACTIVE.
##   2. Gerenciar os padrões de combate exclusivos de cada uma das 4 fases canônicas.
##   3. Coordenar as ordens táticas ao Exército de Azaroth (DemonicInvasionSystem).
##   4. Executar telegrafia no solo, tempos de canalização e aplicação de dano em área.
##   5. Conduzir as transições cinematográficas invulneráveis entre as fases (4.5s).
##   6. Conduzir o colapso e sequência de vitória cinematográfica (6.0s), expurgando o território.
##   7. Sincronizar todos os passos autoritativos para os clientes do mundo privado.

enum CombatState {
	IDLE = 0,
	APPROACHING = 1,
	TELEGRAPHING = 2,
	CASTING = 3,
	PHASE_TRANSITION = 4,
	COLLAPSING = 5,
	DEFEATED = 6
}

const WorldBossDataScript := preload("res://data/models/world_boss_data.gd")

signal combat_state_changed(previous_state: int, new_state: int)
signal ability_telegraphed(ability_id: StringName, ability_name: String, target_pos: Vector3, duration: float)
signal ability_cast_executed(ability_id: StringName, ability_name: String, origin_pos: Vector3, radius: float, damage: float)
signal phase_cinematic_begun(from_phase: int, to_phase: int, phase_name: String, duration: float)
signal phase_cinematic_finished(phase: int, phase_name: String)
signal victory_sequence_begun(defeated_id: StringName)
signal victory_sequence_finished()

var _boss_data: Resource = null
var _current_combat_state: CombatState = CombatState.IDLE
var _current_phase: int = 1
var _is_invulnerable: bool = false

var _state_timer: float = 0.0
var _attack_cooldown_timer: float = 0.0
var _active_telegraph_duration: float = 2.0
var _active_ability_id: StringName = &""
var _active_ability_name: String = ""
var _active_target_position: Vector3 = Vector3.ZERO
var _current_animation: String = "idle"

# Multiplicadores de fase vigentes
var _damage_multiplier: float = 1.0
var _speed_multiplier: float = 1.0
var _current_cooldown_threshold: float = 4.0

# Referências de suporte
var _invasion_system: Node = null
var _pending_phase_target: int = 1
var _pending_phase_name: String = ""
var _last_army_command_time: float = 0.0
var _army_command_interval: float = 18.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(true)

func setup(boss_data_res: Resource, invasion_sys: Node = null) -> void:
	_boss_data = boss_data_res
	_invasion_system = invasion_sys
	_is_invulnerable = false
	_current_combat_state = CombatState.IDLE
	_apply_phase_attributes(1)

func _safe_global_position() -> Vector3:
	return global_position if is_inside_tree() else position

func set_invasion_system(sys: Node) -> void:
	_invasion_system = sys

func get_current_combat_state() -> CombatState:
	return _current_combat_state

func get_current_phase() -> int:
	return _current_phase

func is_invulnerable() -> bool:
	return _is_invulnerable

func get_current_animation() -> String:
	return _current_animation

func get_active_ability_id() -> StringName:
	return _active_ability_id

func get_active_target_position() -> Vector3:
	return _active_target_position

func get_damage_multiplier() -> float:
	return _damage_multiplier

func get_speed_multiplier() -> float:
	return _speed_multiplier

# ------------------------------------------------------------- GAME LOOP --

func advance_combat(delta: float, player_positions: Array) -> void:
	_state_timer += delta
	_attack_cooldown_timer += delta
	_last_army_command_time += delta

	match _current_combat_state:
		CombatState.IDLE:
			if not player_positions.is_empty() and _attack_cooldown_timer >= _current_cooldown_threshold:
				_choose_and_telegraph_next_ability(player_positions)

		CombatState.TELEGRAPHING:
			if _state_timer >= _active_telegraph_duration:
				_execute_active_ability_cast(player_positions)

		CombatState.CASTING:
			# Duração de execução/animação da habilidade (1.0s padrão)
			if _state_timer >= 1.0:
				_set_combat_state(CombatState.IDLE)
				_attack_cooldown_timer = 0.0

		CombatState.PHASE_TRANSITION:
			if _state_timer >= Invariants.WORLD_BOSS_PHASE_TRANSITION_DURATION:
				_finish_phase_transition()

		CombatState.COLLAPSING:
			if _state_timer >= Invariants.WORLD_BOSS_VICTORY_COLLAPSE_DURATION:
				_finish_victory_sequence()

		CombatState.DEFEATED:
			pass

	# Coordenação periódica das ordens de batalha do exército
	if _current_combat_state == CombatState.IDLE or _current_combat_state == CombatState.CASTING:
		if _last_army_command_time >= _army_command_interval:
			_last_army_command_time = 0.0
			_dispatch_phase_army_order(player_positions)

func _set_combat_state(new_state: CombatState) -> void:
	if _current_combat_state == new_state:
		return
	var prev := _current_combat_state
	_current_combat_state = new_state
	_state_timer = 0.0
	combat_state_changed.emit(int(prev), int(new_state))

# ------------------------------------------------- SELEÇÃO DE HABILIDADES --

func _choose_and_telegraph_next_ability(player_positions: Array) -> void:
	var origin := _safe_global_position()
	var target_p := Vector3.ZERO
	if not player_positions.is_empty():
		target_p = player_positions[randi() % player_positions.size()]
	else:
		target_p = origin + Vector3(0.0, 0.0, -15.0)

	_active_target_position = target_p
	var dist := origin.distance_to(target_p)

	# Seleciona habilidade com base na fase ativa e distância
	match _current_phase:
		1: # Ascensão da Fenda (Despertar Tectônico)
			if dist <= 22.0:
				_active_ability_id = Invariants.ABIL_AZAROTH_TECTONIC_SLAM
			else:
				_active_ability_id = Invariants.ABIL_AZAROTH_ABYSSAL_RIFT

		2: # Fúria Vulcânica
			var roll := randf()
			if roll < 0.45:
				_active_ability_id = Invariants.ABIL_AZAROTH_MAGMA_RAIN
			elif roll < 0.80:
				_active_ability_id = Invariants.ABIL_AZAROTH_ABYSSAL_BEAM
			else:
				_active_ability_id = Invariants.ABIL_AZAROTH_TECTONIC_SLAM

		3: # Tempestade do Caos
			var roll := randf()
			if roll < 0.50:
				_active_ability_id = Invariants.ABIL_AZAROTH_CHAOS_VORTEX
			else:
				_active_ability_id = Invariants.ABIL_AZAROTH_VOID_NOVA

		4: # O Devorador Despertado (Enrage)
			var roll := randf()
			if roll < 0.40:
				_active_ability_id = Invariants.ABIL_AZAROTH_CATACLYSMIC_DEVOUR
			elif roll < 0.75:
				_active_ability_id = Invariants.ABIL_AZAROTH_APOCALYPTIC_BARRAGE
			else:
				_active_ability_id = Invariants.ABIL_AZAROTH_VOID_NOVA

	var meta: Dictionary = WorldBossDataScript.get_ability_metadata(_active_ability_id)
	_active_ability_name = String(meta.get("name", "Habilidade Abissal"))
	_active_telegraph_duration = float(meta.get("telegraph_time", 2.0))
	_current_animation = String(meta.get("animation", "attack"))

	_set_combat_state(CombatState.TELEGRAPHING)

	ability_telegraphed.emit(_active_ability_id, _active_ability_name, _active_target_position, _active_telegraph_duration)
	EventBus.azaroth_ability_telegraphed.emit(_active_ability_id, _active_ability_name, _active_target_position, _active_telegraph_duration)
	EventBus.notification_requested.emit("⚠️ AZAROTH TELEGRAFA: %s!" % _active_ability_name)

func _execute_active_ability_cast(player_positions: Array) -> float:
	var meta: Dictionary = WorldBossDataScript.get_ability_metadata(_active_ability_id)
	var base_dmg := float(meta.get("damage", 300.0))
	var radius := float(meta.get("radius", 15.0))
	var effective_damage := base_dmg * _damage_multiplier

	_set_combat_state(CombatState.CASTING)

	ability_cast_executed.emit(_active_ability_id, _active_ability_name, _active_target_position, radius, effective_damage)
	EventBus.azaroth_ability_cast.emit(_active_ability_id, _active_ability_name, _active_target_position, radius, effective_damage)

	# Aplica dano aos jogadores no raio
	var total_dealt := 0.0
	for p_pos in player_positions:
		var pos_v3: Vector3 = p_pos if p_pos is Vector3 else Vector3.ZERO
		if _active_target_position.distance_to(pos_v3) <= radius:
			total_dealt += effective_damage

	return total_dealt

# ---------------------------------------------------- TRANSIÇÃO DE FASES --

## Dispara transição cinematográfica invulnerável entre fases
func trigger_phase_transition(to_phase: int, phase_name: String) -> void:
	if _current_combat_state == CombatState.COLLAPSING or _current_combat_state == CombatState.DEFEATED:
		return
	if _current_phase == to_phase:
		return

	_pending_phase_target = to_phase
	_pending_phase_name = phase_name
	_is_invulnerable = true
	_current_animation = "phase_transition"

	_set_combat_state(CombatState.PHASE_TRANSITION)

	phase_cinematic_begun.emit(_current_phase, to_phase, phase_name, Invariants.WORLD_BOSS_PHASE_TRANSITION_DURATION)
	EventBus.azaroth_phase_cinematic_started.emit(_current_phase, to_phase, phase_name, Invariants.WORLD_BOSS_PHASE_TRANSITION_DURATION)
	EventBus.notification_requested.emit("⚡ TRANSIÇÃO CINEMATOGRÁFICA: Azaroth canaliza o Abismo! Fase %d: %s!" % [to_phase, phase_name])

func _finish_phase_transition() -> void:
	_current_phase = _pending_phase_target
	_is_invulnerable = false
	_apply_phase_attributes(_current_phase)

	_set_combat_state(CombatState.IDLE)
	_attack_cooldown_timer = 0.0 # Pronto para atacar na nova fase

	phase_cinematic_finished.emit(_current_phase, _pending_phase_name)
	EventBus.azaroth_phase_cinematic_ended.emit(_current_phase, _pending_phase_name)

func _apply_phase_attributes(phase_idx: int) -> void:
	_current_phase = phase_idx
	match phase_idx:
		1:
			_damage_multiplier = Invariants.AZAROTH_P1_DMG_MULT
			_speed_multiplier = Invariants.AZAROTH_P1_SPEED_MULT
			_current_cooldown_threshold = 4.0
			_current_animation = "idle"
		2:
			_damage_multiplier = Invariants.AZAROTH_P2_DMG_MULT
			_speed_multiplier = Invariants.AZAROTH_P2_SPEED_MULT
			_current_cooldown_threshold = 3.2
			_current_animation = "idle_flames"
		3:
			_damage_multiplier = Invariants.AZAROTH_P3_DMG_MULT
			_speed_multiplier = Invariants.AZAROTH_P3_SPEED_MULT
			_current_cooldown_threshold = 2.5
			_current_animation = "idle_vortex"
		4:
			_damage_multiplier = Invariants.AZAROTH_P4_DMG_MULT
			_speed_multiplier = Invariants.AZAROTH_P4_SPEED_MULT
			_current_cooldown_threshold = 1.8
			_current_animation = "idle_enrage"

	# Dispara ordem militar correspondente à entrada da fase
	_execute_army_order_for_phase(phase_idx)

# --------------------------------------------- PARTICIPAÇÃO DO EXÉRCITO --

func _execute_army_order_for_phase(phase_idx: int) -> void:
	if _invasion_system == null:
		return

	var origin := _safe_global_position()
	match phase_idx:
		1: # Ordem: patrulha e flanco de inferiores
			_invasion_system.call("trigger_ambush", origin, 4)
		2: # Ordem: convoca demônios superiores como guarda de honra
			_invasion_system.call("spawn_army_unit", 1, origin + Vector3(8, 0, 8))
			_invasion_system.call("spawn_army_unit", 1, origin + Vector3(-8, 0, -8))
		3: # Ordem: acelera surgimento de primordiais pelas fendas
			_invasion_system.call("spawn_army_unit", 2, origin + Vector3(14, 0, 0))
		4: # Ordem: frenesi abissal total — investida em pinça com cerco simultâneo
			_invasion_system.call("trigger_pincer_assault", origin, 4, 2)

func _dispatch_phase_army_order(player_positions: Array) -> void:
	if _invasion_system == null or player_positions.is_empty():
		return
	var p_target: Vector3 = player_positions[0] if player_positions[0] is Vector3 else _safe_global_position()
	match _current_phase:
		1:
			_invasion_system.call("trigger_ambush", p_target, 3)
		2:
			_invasion_system.call("trigger_ambush", p_target, 4)
		3:
			_invasion_system.call("trigger_pincer_assault", p_target, 3, 2)
		4:
			_invasion_system.call("trigger_pincer_assault", p_target, 4, 3)

# ------------------------------------------- VITÓRIA E COLAPSO DO TITÃ --

## Inicia a sequência cinematográfica de derrota e colapso de Azaroth
func trigger_victory_collapse(_winner_peers: PackedInt64Array = PackedInt64Array()) -> void:
	if _current_combat_state == CombatState.COLLAPSING or _current_combat_state == CombatState.DEFEATED:
		return

	_is_invulnerable = true
	_current_animation = "collapse_death"
	_set_combat_state(CombatState.COLLAPSING)

	victory_sequence_begun.emit(Invariants.WORLD_BOSS_ID)
	EventBus.azaroth_victory_cinematic_started.emit(Invariants.WORLD_BOSS_ID, _winner_peers)
	EventBus.notification_requested.emit("⚔️ QUEDA DO DEVORADOR: Azaroth cai de joelhos perante os guerreiros de Abyssal Pact!")

	# Expurga a invasão demoníaca e limpa as fendas do território
	if _invasion_system != null:
		_invasion_system.call("cleanse_invasion")

func _finish_victory_sequence() -> void:
	_set_combat_state(CombatState.DEFEATED)
	_current_animation = "defeated_statue"
	victory_sequence_finished.emit()

	var rewards: Dictionary = _boss_data.get("rewards") if _boss_data != null else {}
	EventBus.azaroth_victory_cinematic_ended.emit(rewards)
	EventBus.notification_requested.emit("👑 SELO RESTAURADO: As trevas foram expurgadas e as terras foram salvas!")
