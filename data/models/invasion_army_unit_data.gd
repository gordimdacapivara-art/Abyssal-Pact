class_name InvasionArmyUnitData
extends Resource
## InvasionArmyUnitData — Unidade Militar Integrante do Exército de Azaroth (PROMPT 04).
##
## Hierarquia Militar:
##   - INFERIOR (Rank 0): Unidades comuns do exército de Azaroth.
##   - SUPERIOR (Rank 1): Unidades militares mais fortes com habilidades especiais e maior resistência (NÃO são chefes individuais).
##   - PRIMORDIAL (Rank 2): Criaturas especiais fortalecidas durante a invasão (atributos maciços e auras).
##
## Todas as unidades obrigatoriamente integram o exército de Azaroth (Invariants.AZAROTH_ARMY_FACTION).

enum MilitaryRank {
	INFERIOR = 0,
	SUPERIOR = 1,
	PRIMORDIAL = 2
}

@export var unit_id: StringName = &""
@export var display_name: String = ""
@export var base_demon_id: StringName = &""
@export var military_rank: MilitaryRank = MilitaryRank.INFERIOR
@export var army_faction: StringName = Invariants.AZAROTH_ARMY_FACTION
@export var region_id: StringName = &""

@export var max_health: float = 100.0
@export var current_health: float = 100.0
@export var attack_damage: float = 15.0
@export var defense: float = 5.0
@export var move_speed: float = 4.0
@export var special_abilities: PackedStringArray = PackedStringArray()
@export var aura_effects: Dictionary = {}
@export var visual_scale: float = 1.0

# Estado de emergência física do solo
var current_y_offset: float = 0.0
var is_emerging: bool = false
var emergence_elapsed: float = 0.0
const EMERGENCE_DURATION: float = 2.0

static func create_army_unit(
	p_unit_id: StringName,
	p_rank: int,
	p_reg_id: StringName,
	p_base_demon: DemonData = null
) -> Resource:
	var script: GDScript = load("res://data/models/invasion_army_unit_data.gd")
	var unit = script.new()
	unit.unit_id = p_unit_id
	unit.military_rank = p_rank as MilitaryRank
	unit.region_id = p_reg_id
	unit.army_faction = Invariants.AZAROTH_ARMY_FACTION

	var base_hp := 120.0
	var base_dmg := 18.0
	var base_def := 8.0
	var base_spd := 4.0
	var base_name := "Guerreiro Abissal"

	if p_base_demon != null:
		unit.base_demon_id = p_base_demon.id
		base_name = p_base_demon.display_name
		base_hp = p_base_demon.health()
		var d_stats: Dictionary = p_base_demon.stats
		base_dmg = float(d_stats.get("damage", base_dmg))
		base_def = float(d_stats.get("defense", base_def))
		base_spd = float(d_stats.get("move_speed", base_spd))

	match p_rank:
		MilitaryRank.INFERIOR:
			unit.display_name = "%s do Exército de Azaroth" % base_name
			unit.max_health = base_hp
			unit.attack_damage = base_dmg
			unit.defense = base_def
			unit.move_speed = base_spd
			unit.visual_scale = 1.0
			unit.special_abilities = PackedStringArray(["golpe_abissal"])

		MilitaryRank.SUPERIOR:
			unit.display_name = "Comandante %s de Azaroth" % base_name
			unit.max_health = base_hp * Invariants.SUPERIOR_DEMON_HP_MULT
			unit.attack_damage = base_dmg * Invariants.SUPERIOR_DEMON_DMG_MULT
			unit.defense = base_def * 1.3
			unit.move_speed = base_spd * 1.15
			unit.visual_scale = 1.25
			unit.special_abilities = PackedStringArray(["grito_de_guerra", "rajada_carmesim", "esmagar_abissal"])
			unit.aura_effects = {"command_radius": 15.0, "squad_buff": 1.2}

		MilitaryRank.PRIMORDIAL:
			unit.display_name = "Primordial %s de Azaroth" % base_name
			unit.max_health = base_hp * Invariants.PRIMORDIAL_DEMON_HP_MULT
			unit.attack_damage = base_dmg * Invariants.PRIMORDIAL_DEMON_DMG_MULT
			unit.defense = base_def * Invariants.PRIMORDIAL_DEMON_DEF_MULT
			unit.move_speed = base_spd * 1.1
			unit.visual_scale = 1.6
			unit.special_abilities = PackedStringArray(["furia_primordial", "onda_magmatica", "abismo_devorador", "pele_de_rocha"])
			unit.aura_effects = {"corruption_dps": 8.0, "radius": 10.0, "resistance_boost": 0.25}

	unit.current_health = unit.max_health
	return unit

## Inicia a emergência física da unidade subindo de -8.0m do solo
func start_emergence() -> void:
	is_emerging = true
	emergence_elapsed = 0.0
	current_y_offset = -8.0

## Atualiza a subida contínua da unidade emergindo do solo
func advance_emergence(delta: float) -> void:
	if not is_emerging:
		return
	emergence_elapsed += delta
	var progress := clampf(emergence_elapsed / EMERGENCE_DURATION, 0.0, 1.0)
	var smooth := sin(progress * PI * 0.5)
	current_y_offset = lerpf(-8.0, 0.0, smooth)
	if emergence_elapsed >= EMERGENCE_DURATION:
		is_emerging = false
		current_y_offset = 0.0

func is_inferior() -> bool:
	return military_rank == MilitaryRank.INFERIOR

func is_superior() -> bool:
	return military_rank == MilitaryRank.SUPERIOR

func is_primordial() -> bool:
	return military_rank == MilitaryRank.PRIMORDIAL

func to_dict() -> Dictionary:
	return {
		"unit_id": String(unit_id),
		"display_name": display_name,
		"base_demon_id": String(base_demon_id),
		"military_rank": int(military_rank),
		"army_faction": String(army_faction),
		"region_id": String(region_id),
		"max_health": max_health,
		"current_health": current_health,
		"attack_damage": attack_damage,
		"defense": defense,
		"move_speed": move_speed,
		"special_abilities": Array(special_abilities),
		"aura_effects": aura_effects,
		"visual_scale": visual_scale,
		"is_emerging": is_emerging,
		"current_y_offset": current_y_offset
	}
