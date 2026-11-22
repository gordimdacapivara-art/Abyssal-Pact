class_name PlayerClassComponent
extends Node
## Componente de classe do jogador — camada de cena, 100% data-driven.
##
## Carrega a ClassData do catálogo (ClassManager), aplica atributos iniciais ao
## Combatant, equipa habilidades em slots (2 ativas + 1 passiva) com validação
## de pertencimento/tipo/desbloqueio e executa casts: cooldowns, custos de
## recurso, emissão de sinais no EventBus e área de impacto (protótipo).
## NENHUMA habilidade tem código próprio — tudo vem de AbilityData.
##
## Slots: active[0] = ataque básico; active[1] = ataque especial;
## passive[0] = passiva equipada.

const ACTIVE_SLOTS := 2
const PASSIVE_SLOTS := 1
const SLOT_ACTIVE := &"active"
const SLOT_PASSIVE := &"passive"

signal class_bound(class_id: StringName)
signal loadout_changed()
signal cast_performed(ability_id: StringName)

@export var default_class_id: StringName = &"CLASS-001"
## Nível de protótipo (desbloqueios da árvore; save integrará depois).
@export var prototype_level: int = 1
@export var target_layer := AbilityBurst.DEFAULT_TARGET_LAYER

var class_id: StringName = &""
var _class_data: ClassData = null
var _class_manager: ClassManager = null
var _combatant: Combatant = null
## Arrays indexados: _active_slots[2], _passive_slots[1] ("" = vazio).
var _active_slots: PackedStringArray = PackedStringArray(["", ""])
var _passive_slots: PackedStringArray = PackedStringArray([""])
var _cooldowns: Dictionary = {} # String(ability_id) -> segundos restantes

func _ready() -> void:
	_class_manager = Game.registry().get_system(SystemNames.CLASS) as ClassManager
	if _class_manager == null:
		push_warning("PlayerClassComponent: ClassManager indisponível")
		return
	if class_id == &"":
		bind_class(default_class_id)

func _process(delta: float) -> void:
	if _cooldowns.is_empty():
		return
	var expired := PackedStringArray()
	for ability_id: String in _cooldowns:
		var remaining := float(_cooldowns[ability_id]) - delta
		if remaining <= 0.0:
			expired.append(ability_id)
		else:
			_cooldowns[ability_id] = remaining
	for ability_id in expired:
		_cooldowns.erase(ability_id)

# --------------------------------------------------------------------- API --

## Vincula uma classe do catálogo: aplica atributos e loadout padrão
## (primeira ativa e primeira passiva desbloqueadas).
func bind_class(new_class_id: StringName) -> bool:
	if _class_manager == null or not _class_manager.has_class(new_class_id):
		push_warning("PlayerClassComponent: classe ausente no catálogo: %s" % new_class_id)
		return false
	class_id = new_class_id
	_class_data = _class_manager.get_class_data(new_class_id)
	_apply_attributes()
	_cooldowns.clear()
	_auto_loadout()
	class_bound.emit(class_id)
	EventBus.class_loadout_changed.emit(get_instance_id(), class_id)
	return true

func class_data() -> ClassData:
	return _class_data

func combatant() -> Combatant:
	return _combatant

## Conecta o componente de vida (pode ser do player ou de um alvo de teste).
func bind_combatant(new_combatant: Combatant) -> void:
	_combatant = new_combatant
	if _combatant != null and _class_data != null:
		_apply_attributes()

## Equipa `ability_id` no slot `slot_kind`/índice. Retorna OK ou erro:
## ERR_DOES_NOT_EXIST, ERR_INVALID_DATA (regras), ERR_UNAVAILABLE (bloqueado).
func equip_ability(slot_kind: StringName, slot_index: int, ability_id: StringName, level: int = prototype_level) -> Error:
	if _class_data == null:
		return ERR_DOES_NOT_EXIST
	var slots := _active_slots if slot_kind == SLOT_ACTIVE else _passive_slots
	if slot_kind != SLOT_ACTIVE and slot_kind != SLOT_PASSIVE:
		return ERR_INVALID_PARAMETER
	if slot_index < 0 or slot_index >= slots.size():
		return ERR_PARAMETER_RANGE_ERROR
	if not _class_manager.can_equip(class_id, ability_id, slot_kind, level):
		return ERR_UNAVAILABLE
	slots[slot_index] = String(ability_id)
	if slot_kind == SLOT_PASSIVE:
		_apply_passive(ability_id)
	loadout_changed.emit()
	EventBus.class_loadout_changed.emit(get_instance_id(), class_id)
	return OK

## ID equipado no slot ("" = vazio).
func equipped(slot_kind: StringName, slot_index: int) -> String:
	if slot_kind == SLOT_ACTIVE:
		return _active_slots[slot_index] if slot_index >= 0 and slot_index < _active_slots.size() else ""
	return _passive_slots[slot_index] if slot_index >= 0 and slot_index < _passive_slots.size() else ""

## Cooldown restante de uma habilidade (0.0 = pronta).
func cooldown_remaining(ability_id: String) -> float:
	return float(_cooldowns.get(ability_id, 0.0))

## Executa o cast do slot ativo `slot_index`. Sinais no EventBus:
## ability_cast_started (aceito) ou ability_cast_failed (recusado).
func try_cast(slot_index: int) -> bool:
	if _class_data == null or _class_manager == null:
		EventBus.ability_cast_failed.emit(get_instance_id(), &"", &"no_class")
		return false
	var ability_id := equipped(SLOT_ACTIVE, slot_index)
	var ability := _class_manager.get_ability(StringName(ability_id)) if not ability_id.is_empty() else null
	if ability == null or not ability.is_active():
		EventBus.ability_cast_failed.emit(get_instance_id(), StringName(ability_id), &"empty_slot")
		return false
	if cooldown_remaining(ability_id) > 0.0:
		EventBus.ability_cast_failed.emit(get_instance_id(), ability.id, &"cooldown")
		return false
	if _combatant == null or not _combatant.spend_resource(ability.cost, ability.cost_resource):
		EventBus.ability_cast_failed.emit(get_instance_id(), ability.id, &"resource")
		return false
	_cooldowns[ability_id] = ability.cooldown
	EventBus.ability_cast_started.emit(get_instance_id(), ability.id)
	var caster := _owner_node()
	if caster is Node3D:
		AbilityBurst.spawn(caster as Node3D, ability, target_layer)
	else:
		# Sem corpo 3D: cast resolve direto (útil em testes headless).
		EventBus.ability_cast_resolved.emit(get_instance_id(), ability.id)
	cast_performed.emit(ability.id)
	return true

# ------------------------------------------------------------------ INTERNO --

func _owner_node() -> Node:
	return get_parent() if get_parent() != null else self

func _apply_attributes() -> void:
	if _class_data == null:
		return
	var target := _combatant
	if target == null:
		target = Combatant.new()
		target.name = "ClassCombatant"
		add_child(target)
		_combatant = target
	target.max_health = float(_class_data.base_attributes.get("health", 100.0))
	target.max_resource = float(_class_data.base_attributes.get("mana", 100.0))
	target.health = target.max_health
	target.resource = target.max_resource
	target.resource_regeneration = float(_class_data.base_attributes.get("resource_regeneration", 4.0))

## Loadout padrão: primeira ativa e primeira passiva desbloqueadas.
func _auto_loadout() -> void:
	var unlocked := _class_manager.unlocked_abilities(class_id, prototype_level)
	_active_slots = PackedStringArray(["", ""])
	_passive_slots = PackedStringArray([""])
	for ability_id in _class_data.active_ability_ids:
		if not unlocked.has(String(ability_id)):
			continue
		var slot := 0 if _active_slots[0].is_empty() else 1
		if _active_slots[slot].is_empty():
			_active_slots[slot] = String(ability_id)
		if not _active_slots[1].is_empty() and not _active_slots[0].is_empty():
			break
	for ability_id in _class_data.passive_ability_ids:
		if unlocked.has(String(ability_id)) and _passive_slots[0].is_empty():
			_passive_slots[0] = String(ability_id)
			_apply_passive(String(ability_id))

func _apply_passive(ability_id: String) -> void:
	var ability := _class_manager.get_ability(StringName(ability_id))
	if ability == null or _combatant == null:
		return
	# Efeitos de passiva aplicados de forma data-driven ao combatante.
	if ability.passive_effects.has("resource_regeneration_bonus"):
		_combatant.resource_regeneration_bonus = float(ability.passive_effects["resource_regeneration_bonus"])
