extends Node3D
## Arena de teste do bestiário: UM representante de cada uma das 6 famílias
## regionais + UM encontro de chefe completo (entrada → fases → recompensas).
##
## Tudo vem dos catálogos (DemonManager/BossManager) e das cenas compartilhadas
## (enemies/creature.tscn, enemies/boss_encounter.tscn). Nenhum script por
## criatura. O visual é PLACEHOLDER identificado (nenhum GLB de criatura existe).
##
## Controles de teste:
##   1 / 2 — habilidades do Arcanista (AbilityBurst atinge hurtboxes layer 8)
##   F     — aplica dano de teste na criatura viva mais próxima
##   K     — derruba o chefe (valida fases/recompensas do encontro)
##   WASD + mouse — movimentação/câmera do jogador

const CREATURE_SCENE := preload("res://enemies/creature.tscn")
const ENCOUNTER_SCENE := preload("res://enemies/boss_encounter.tscn")
const TEST_DAMAGE := 40.0

@onready var _player: PlayerController = get_node("Player") as PlayerController
@onready var _hud: Label = get_node("HUD/Status") as Label

var _class_component: PlayerClassComponent = null
var _creatures: Array[Creature] = []
var _encounter: BossEncounter = null
var _boss_id: StringName = &"BOSS-001"
var _events: Dictionary = {}

func _ready() -> void:
	_bind_player_class()
	_spawn_representatives()
	_spawn_boss()
	_connect_events()

func _bind_player_class() -> void:
	var component := PlayerClassComponent.new()
	component.name = "ClassComponent"
	_player.add_child(component)
	_class_component = component
	if not _class_component.bind_class(&"CLASS-001"):
		push_error("creature_arena: CLASS-001 (Arcanista) não carregou")

func _spawn_representatives() -> void:
	var demons := Game.get_system(SystemNames.DEMONS) as DemonManager
	if demons == null:
		push_error("creature_arena: DemonManager indisponível")
		return
	var representatives := demons.representatives()
	var index := 0
	for demon in representatives:
		var creature := CREATURE_SCENE.instantiate() as Creature
		creature.name = "Creature_%s" % String(demon.family)
		add_child(creature)
		creature.position = Vector3(-7.5 + index * 3.0, 0.0, 2.0)
		if not creature.setup(demon):
			push_warning("creature_arena: falha ao configurar %s" % demon.id)
			continue
		var ai := CreatureAI.new()
		ai.name = "AI"
		creature.add_child(ai)
		ai.setup(creature, _player)
		_creatures.append(creature)
		index += 1

func _spawn_boss() -> void:
	var bosses := Game.get_system(SystemNames.BOSSES) as BossManager
	if bosses == null:
		push_error("creature_arena: BossManager indisponível")
		return
	var ids := bosses.all_ids()
	ids.sort()
	if not ids.is_empty():
		_boss_id = StringName(ids[0])
	_encounter = ENCOUNTER_SCENE.instantiate() as BossEncounter
	_encounter.name = "BossEncounter"
	_encounter.boss_id = _boss_id
	_encounter.position = Vector3(0.0, 0.0, -9.0)
	add_child(_encounter)
	var error := _encounter.start()
	if error != OK:
		push_error("creature_arena: encontro de chefe não iniciou (erro %d)" % error)

func _connect_events() -> void:
	EventBus.creature_defeated.connect(func(demon_id: StringName, _instance: int, _xp: int, _gold: int) -> void: _events["derrotado:" + String(demon_id)] = true)
	EventBus.creature_respawned.connect(func(demon_id: StringName, _instance: int) -> void: _events["ressurgiu:" + String(demon_id)] = true)
	EventBus.boss_phase_changed.connect(func(boss_id: StringName, phase: int, behavior: StringName) -> void: _events["fase %d %s (%s)" % [phase, boss_id, behavior]] = true)
	EventBus.boss_rewards_granted.connect(func(boss_id: StringName, xp: int, gold: int) -> void: _events["recompensa %s (+%d xp/+%d gold)" % [boss_id, xp, gold]] = true)
	EventBus.boss_encounter_ended.connect(func(boss_id: StringName, defeated: bool) -> void: _events["fim %s (%s)" % [boss_id, "vitória" if defeated else "abortado"]] = true)

func _unhandled_input(event: InputEvent) -> void:
	if _class_component != null and event.is_action_pressed(PlayerInputMap.ABILITY_1):
		_class_component.try_cast(0)
		return
	if _class_component != null and event.is_action_pressed(PlayerInputMap.ABILITY_2):
		_class_component.try_cast(1)
		return
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		match (event as InputEventKey).physical_keycode:
			KEY_F:
				_damage_nearest()
			KEY_K:
				_kill_boss()

func _damage_nearest() -> void:
	var nearest: Creature = null
	var best_distance := INF
	for creature in _creatures:
		if not is_instance_valid(creature) or creature.is_dead():
			continue
		var distance := creature.global_position.distance_to(_player.global_position)
		if distance < best_distance:
			best_distance = distance
			nearest = creature
	if nearest != null:
		nearest.combatant().take_damage(TEST_DAMAGE, &"physical")

func _kill_boss() -> void:
	if _encounter == null or _encounter.boss() == null:
		return
	var combatant := _encounter.boss().combatant()
	combatant.take_damage(combatant.health + 1.0, &"abyssal")

func _process(_delta: float) -> void:
	if _hud == null:
		return
	var lines := PackedStringArray()
	lines.append("ABYSSAL PACT — ARENA DO BESTIÁRIO (placeholders identificados)")
	lines.append("Catálogo: %d regionais | 6 famílias representadas | chefe %s" % [_creatures.size(), _boss_id])
	var alive := 0
	var family_lines := PackedStringArray()
	for creature in _creatures:
		if not is_instance_valid(creature):
			continue
		if not creature.is_dead():
			alive += 1
		var demon := creature.demon_data()
		family_lines.append("%s:%s%s" % [
			String(demon.family),
			"vivo" if not creature.is_dead() else "morto",
			" (PLACEHOLDER)" if creature.is_placeholder() else ""])
	lines.append("Famílias — %s" % " | ".join(family_lines))
	lines.append("Vivos: %d/%d" % [alive, _creatures.size()])
	if _encounter != null:
		var status := "encerrado" if _encounter.is_finished() else ("em combate" if _encounter.is_fighting() else "entrada/aguardando")
		var phase := 0
		if _encounter.boss() != null:
			phase = _encounter.boss().current_phase_index()
		lines.append("Chefe %s — %s | fase %d/%d" % [_boss_id, status, phase, _encounter.boss_data().phase_count if _encounter.boss_data() != null else 0])
	lines.append("Eventos: %s" % (", ".join(PackedStringArray(_events.keys())) if not _events.is_empty() else "—"))
	lines.append("1/2 = habilidades | F = dano na criatura mais próxima | K = derrubar chefe | WASD + mouse")
	_hud.text = "\n".join(lines)
