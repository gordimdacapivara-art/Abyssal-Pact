class_name BossEncounter
extends Node3D
## Fluxo de encontro de chefe (reutilizável para os 30 chefes):
##   1. BossManager.begin_encounter (autoridade/registro do encontro);
##   2. instancia a cena compartilhada do chefe e aplica BossData;
##   3. entrada cinematográfica (boss_entrance_started + duração dos dados);
##   4. combate com fases por limiar de vida (boss_phase_changed);
##   5. derrota → recompensas especiais → BossManager.end_encounter.
##
## Nenhum chefe tem script próprio: cena + dados + este componente.
## A entrada é apenas temporização e HUD (sem câmera cinematográfica final).

signal entrance_started(boss_id: StringName)
signal fight_started(boss_id: StringName)
signal phase_changed(boss_id: StringName, phase_index: int, behavior: StringName)
signal encounter_finished(boss_id: StringName, victory: bool)

const BOSS_SCENE := preload("res://enemies/boss.tscn")
const BOSS_UI_SCENE := preload("res://enemies/boss_ui.tscn")

@export var boss_id: StringName = &"BOSS-001"
@export var boss_spawn_offset := Vector3.ZERO
@export var show_ui := true

var _boss: Boss = null
var _ui: BossUI = null
var _data: BossData = null
var _participants := PackedInt64Array()
var _started := false
var _fighting := false
var _finished := false
var _victory := false
var _rewards_granted := false

func _ready() -> void:
	EventBus.network_boss_phase_replicated.connect(_on_network_boss_phase)

func _on_network_boss_phase(net_boss_id: StringName, phase_index: int, behavior: StringName) -> void:
	if net_boss_id == boss_id and _ui != null:
		_ui.set_phase(phase_index, behavior)

## Inicia o encontro. `skip_entrance` existe para testes/automação; o fluxo
## normal respeita entrance.duration_seconds de BossData.
func start(participants: PackedInt64Array = PackedInt64Array(), skip_entrance := false) -> Error:
	if _started:
		return ERR_ALREADY_IN_USE
	var bosses := Game.get_system(SystemNames.BOSSES) as BossManager
	if bosses == null:
		return ERR_UNAVAILABLE
	if not bosses.has_boss(boss_id):
		return ERR_DOES_NOT_EXIST
	_data = bosses.get_boss(boss_id)
	if _data == null:
		return ERR_INVALID_DATA
	if participants.is_empty():
		participants = PackedInt64Array([Invariants.HOST_PEER_ID])
	var begin_error := bosses.begin_encounter(boss_id, participants)
	if begin_error != OK:
		return begin_error
	_participants = participants
	_started = true

	var packed: PackedScene = load(_data.placeholder_scene) as PackedScene
	if packed == null:
		packed = BOSS_SCENE
	_boss = packed.instantiate() as Boss
	if _boss == null:
		_abort_start(bosses)
		return ERR_FILE_CORRUPT
	_boss.name = "Boss_%s" % String(boss_id).replace("-", "_")
	_boss.position = boss_spawn_offset
	add_child(_boss)
	if not _boss.setup(_data):
		_abort_start(bosses)
		return ERR_INVALID_DATA
	_boss.boss_phase_changed.connect(_on_phase_changed)
	_boss.boss_defeated.connect(_on_boss_defeated)
	_boss.combatant().health_changed.connect(_on_boss_health_changed)
	_build_ui()

	var duration := float((_data.entrance as Dictionary).get("duration_seconds", 0.0))
	EventBus.boss_entrance_started.emit(boss_id, duration)
	entrance_started.emit(boss_id)
	if skip_entrance or duration <= 0.0:
		_begin_fight()
	else:
		get_tree().create_timer(duration).timeout.connect(_begin_fight)
	return OK

func _begin_fight() -> void:
	if not _started or _finished or _fighting:
		return
	_fighting = true
	if _boss != null:
		_boss.set_combat_active(true)
	if _ui != null:
		_ui.visible = true
	fight_started.emit(boss_id)

## Encerra sem vitória (saída da arena, teste, derrota do grupo).
func abort() -> void:
	if not _started or _finished:
		return
	var bosses := Game.get_system(SystemNames.BOSSES) as BossManager
	if bosses != null:
		bosses.end_encounter(boss_id, false)
	_finished = true
	_fighting = false
	encounter_finished.emit(boss_id, false)

func boss() -> Boss:
	return _boss

func ui() -> BossUI:
	return _ui

func boss_data() -> BossData:
	return _data

func is_started() -> bool:
	return _started

func is_fighting() -> bool:
	return _fighting

func is_finished() -> bool:
	return _finished

func rewards_granted() -> bool:
	return _rewards_granted

func _build_ui() -> void:
	if not show_ui:
		return
	var layer := CanvasLayer.new()
	layer.name = "BossUILayer"
	add_child(layer)
	_ui = BOSS_UI_SCENE.instantiate() as BossUI
	if _ui == null:
		return
	layer.add_child(_ui)
	_ui.setup(_data)
	_ui.visible = false

func _on_boss_health_changed(current: float, maximum: float) -> void:
	if _ui != null:
		_ui.update_health(current, maximum)

func _on_phase_changed(id: StringName, phase_index: int, behavior: StringName) -> void:
	if _ui != null:
		_ui.set_phase(phase_index, behavior)
	var net_mgr := Game.get_system(SystemNames.NET) as MultiplayerManager if Engine.has_singleton("Game") or get_tree().root.has_node("Net") else null
	if net_mgr != null and net_mgr.is_host():
		net_mgr.rpc_sync_boss_phase(id, phase_index, behavior)
	phase_changed.emit(id, phase_index, behavior)

func _on_boss_defeated(id: StringName, rewards: Dictionary) -> void:
	if _finished:
		return
	_finished = true
	_victory = true
	_fighting = false
	var xp := int(rewards.get("xp", 0))
	var gold := int(rewards.get("gold", 0))
	if not _rewards_granted:
		_rewards_granted = true
		EventBus.boss_rewards_granted.emit(id, xp, gold)
	if _ui != null:
		_ui.show_defeated()
	var bosses := Game.get_system(SystemNames.BOSSES) as BossManager
	if bosses != null:
		bosses.end_encounter(id, true)
	encounter_finished.emit(id, true)

func _abort_start(bosses: BossManager) -> void:
	_started = false
	if bosses != null:
		bosses.end_encounter(boss_id, false)
	if _boss != null:
		_boss.queue_free()
		_boss = null

func _exit_tree() -> void:
	if _started and not _finished:
		abort()
