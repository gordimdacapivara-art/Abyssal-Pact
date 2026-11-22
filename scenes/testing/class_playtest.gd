extends Node3D
## Playtest do protótipo de classes (CLASS-001 Arcanista) — playground neutro.
##
## O jogador entra já com o Arcanista vinculado, HUD mostra atributos,
## loadout equipado, cooldowns e recurso. Controles de protótipo:
##   1 — cast do slot ativo 1 (Estilhaço Abissal)
##   2 — cast do slot ativo 2 (Onda do Pacto)
##   R — cicla o equipamento do slot ativo 2 (valida o sistema de equipar)
##   P — cicla a passiva equipada (valida efeito de passiva)
##   T — derruba/ressuscita o alvo de treino manualmente (prova de morte)

const DUMMY_RESPAWN_HINT := "alvo morto — aguardando ressurgimento"

@onready var _player: PlayerController = get_node("Player") as PlayerController
@onready var _dummy: TrainingDummy = get_node("Dummy") as TrainingDummy
@onready var _hud: Label = get_node("HUD/Status") as Label

var _class_component: PlayerClassComponent = null
var _actives: PackedStringArray = PackedStringArray()
var _passives: PackedStringArray = PackedStringArray()
var _active_cycle := 0
var _passive_cycle := 0
var _events_seen: Dictionary = {}

func _ready() -> void:
	var class_manager := Game.registry().get_system(SystemNames.CLASS) as ClassManager
	var component := PlayerClassComponent.new()
	component.name = "ClassComponent"
	_player.add_child(component)
	_class_component = component
	if not _class_component.bind_class(&"CLASS-001"):
		push_error("class_playtest: CLASS-001 (Arcanista) não carregou")
		return
	for ability in class_manager.abilities_of(&"CLASS-001"):
		if ability.is_active():
			_actives.append(String(ability.id))
		elif ability.kind == &"passive":
			_passives.append(String(ability.id))
	EventBus.ability_cast_started.connect(func(_caster: int, _ability: StringName) -> void: _events_seen["cast_started"] = true)
	EventBus.ability_cast_failed.connect(func(_caster: int, _ability: StringName, reason: StringName) -> void: _events_seen["cast_failed_" + String(reason)] = true)
	EventBus.ability_cast_resolved.connect(func(_caster: int, _ability: StringName) -> void: _events_seen["cast_resolved"] = true)
	EventBus.target_damaged.connect(func(_target: int, _amount: float, _source: int, _ability: StringName) -> void: _events_seen["target_damaged"] = true)
	EventBus.target_died.connect(func(_target: int) -> void: _events_seen["target_died"] = true)
	EventBus.class_loadout_changed.connect(func(_participant: int, _class_id: StringName) -> void: _events_seen["loadout_changed"] = true)

func _unhandled_input(event: InputEvent) -> void:
	if _class_component == null:
		return
	if event.is_action_pressed(PlayerInputMap.ABILITY_1):
		_class_component.try_cast(0)
	elif event.is_action_pressed(PlayerInputMap.ABILITY_2):
		_class_component.try_cast(1)
	elif event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		var key := (event as InputEventKey).physical_keycode
		if key == KEY_R:
			_cycle_active_slot(1)
		elif key == KEY_P:
			_cycle_passive()
		elif key == KEY_T:
			_toggle_dummy()

func _cycle_active_slot(slot: int) -> void:
	if _actives.size() < 2:
		return
	_active_cycle = (_active_cycle + 1) % _actives.size()
	var ability_id := _actives[_active_cycle]
	var error := _class_component.equip_ability(PlayerClassComponent.SLOT_ACTIVE, slot, StringName(ability_id))
	if error != OK:
		push_warning("class_playtest: equip recusado (%s): %d" % [ability_id, error])

func _cycle_passive() -> void:
	if _passives.is_empty():
		return
	_passive_cycle = (_passive_cycle + 1) % _passives.size()
	var ability_id := _passives[_passive_cycle]
	var error := _class_component.equip_ability(PlayerClassComponent.SLOT_PASSIVE, 0, StringName(ability_id))
	if error != OK:
		push_warning("class_playtest: equip recusado (%s): %d" % [ability_id, error])

func _toggle_dummy() -> void:
	if _dummy.is_dead():
		_dummy._respawn()
	else:
		_dummy._combatant.take_damage(_dummy._combatant.health, &"physical")

func _process(_delta: float) -> void:
	if _class_component == null or _hud == null:
		return
	var data := _class_component.class_data()
	var combatant := _class_component.combatant()
	var lines := PackedStringArray()
	lines.append("[Classe] %s (%s) — protótipo" % [data.display_name, String(data.id)])
	var attributes := PackedStringArray()
	for attribute_key in data.base_attributes:
		attributes.append("%s=%.0f" % [attribute_key, float(data.base_attributes[attribute_key])])
	lines.append("[Atributos] %s" % " | ".join(attributes))
	var life := "HP %.0f/%.0f  MANA %.0f/%.0f  regen %.1f (+bônus %.1f)" % [
		combatant.health, combatant.max_health,
		combatant.resource, combatant.max_resource,
		combatant.resource_regeneration, combatant.resource_regeneration_bonus]
	lines.append("[Vida/Recurso] %s" % life)
	for slot in 2:
		var ability_id := _class_component.equipped(PlayerClassComponent.SLOT_ACTIVE, slot)
		var ability := Game.registry().get_system(SystemNames.CLASS).call("get_ability", StringName(ability_id)) as AbilityData
		var cd := _class_component.cooldown_remaining(ability_id)
		var state := "PRONTA" if cd <= 0.0 else "cooldown %.1fs" % cd
		lines.append("[Slot ativo %d] %s — %s" % [slot + 1, ability.display_name if ability != null else "(vazio)", state])
	var passive_id := _class_component.equipped(PlayerClassComponent.SLOT_PASSIVE, 0)
	lines.append("[Passiva] %s" % (passive_id if not passive_id.is_empty() else "(vazio)"))
	lines.append("[Alvo] %s | eventos: %s" % [
		DUMMY_RESPAWN_HINT if _dummy.is_dead() else "vivo",
		", ".join(PackedStringArray(_events_seen.keys())) if _events_seen.size() > 0 else "—"])
	lines.append("1/2 = cast | R = trocar especial | P = trocar passiva | T = matar alvo")
	_hud.text = "\n".join(lines)
