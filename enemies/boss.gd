class_name Boss
extends Creature
## Chefe demoníaco (BOSS-001..BOSS-030) — MESMO componente de criatura, com
## fases por limiar de vida. Nenhum script por chefe: fases, habilidades,
## animações exclusivas, arena, interface e recompensas vêm de BossData.
##
## Diferenças em relação a Creature:
##   - combate só começa após a entrada cinematográfica (set_combat_active);
##   - mudança de fase emite boss_phase_changed (EventBus + sinal local);
##   - não ressuscita e não emite creature_defeated (chefe tem fluxo próprio,
##     tratado por BossEncounter).
##
## Animações exclusivas são NOMES de clipe (dados). Nenhum GLB de chefe existe
## no projeto: o visual é o placeholder identificado herdado de Creature.

signal boss_phase_changed(boss_id: StringName, phase_index: int, behavior: StringName)
signal boss_defeated(boss_id: StringName, rewards: Dictionary)

var _combat_active := false
var _phase_index := 1
var _phase_behavior: StringName = &""

func setup(data: Resource) -> bool:
	var ok := super(data)
	if not ok or boss_data() == null:
		return false
	_combat_active = false
	_phase_index = 1
	_phase_behavior = _behavior_for(1)
	_set_hurtbox_active(false)
	return true

func boss_id() -> StringName:
	return entity_id()

func current_phase_index() -> int:
	return _phase_index

func current_phase_behavior() -> StringName:
	return _phase_behavior

## Fase ativa como dicionário de dados ({} quando não há BossData).
func current_phase() -> Dictionary:
	if boss_data() == null:
		return {}
	for phase: Dictionary in boss_data().phases:
		if int(phase.get("index", -1)) == _phase_index:
			return phase
	return {}

## Liga/desliga a hurtbox até o fim da entrada cinematográfica.
func set_combat_active(active: bool) -> void:
	_combat_active = active
	_set_hurtbox_active(active)

func is_combat_active() -> bool:
	return _combat_active

## Override: reage a mudanças de vida emitindo a transição de fase.
func _on_health_changed(current: float, maximum: float) -> void:
	if boss_data() == null or maximum <= 0.0:
		return
	var phase := boss_data().phase_at(current / maximum)
	var next_index := int(phase.get("index", _phase_index))
	if next_index <= _phase_index:
		return
	_phase_index = next_index
	_phase_behavior = StringName(String(phase.get("behavior", "")))
	EventBus.boss_phase_changed.emit(entity_id(), _phase_index, _phase_behavior)
	boss_phase_changed.emit(entity_id(), _phase_index, _phase_behavior)

## Override: chefe não ressuscita e tem fluxo de recompensa próprio.
func _on_died() -> void:
	if _dead:
		return
	_dead = true
	_set_hurtbox_active(false)
	if _visual != null:
		_visual.visible = false
	var payload := rewards()
	EventBus.creature_defeated.emit(entity_id(), get_instance_id(), int(payload.get("xp", 0)), int(payload.get("gold", 0)))
	boss_defeated.emit(entity_id(), payload)
	defeated.emit(entity_id(), payload)

func _behavior_for(index: int) -> StringName:
	if boss_data() == null:
		return &""
	for phase: Dictionary in boss_data().phases:
		if int(phase.get("index", -1)) == index:
			return StringName(String(phase.get("behavior", "")))
	return &""

func _set_hurtbox_active(active: bool) -> void:
	if _hurtbox != null:
		_hurtbox.set_deferred("monitorable", active)
