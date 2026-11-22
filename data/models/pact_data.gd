class_name PactData
extends Resource
## Dados de Pacto Abissal.
## Suporta seleção, descrição, efeitos passivos e ativos, evolução em tiers e requisitos de desbloqueio.

@export var id: StringName = &""
@export var display_name: String = ""
@export var description: String = ""
@export var lore: String = ""
@export var tier: int = 1
@export var max_tier: int = 5
@export var unlocked: bool = false
@export var unlock_level: int = 1
## Habilidade ativa concedida pelo pacto
@export var active_ability_id: StringName = &""
## Descrições dos efeitos passivos
@export var passive_descriptions: PackedStringArray = PackedStringArray()
## Modificadores de atributos por nível de tier (ex: {"dark_power": 10, "max_health": 40})
@export var stat_modifiers: Dictionary = {}
## Requisitos para evolução: {"souls_cost": int, "required_item_id": String, "item_quantity": int}
@export var evolution_requirements: Dictionary = {}
## Dicionário genérico de efeitos legados
@export var effects: Dictionary = {}

func get_stat_modifier(stat_key: String) -> float:
	var base_val := float(stat_modifiers.get(stat_key, 0.0))
	# Escala linear com o tier
	return base_val * float(tier)

func can_evolve() -> bool:
	return tier < max_tier and unlocked

func evolve() -> bool:
	if not can_evolve():
		return false
	tier += 1
	return true

func to_dict() -> Dictionary:
	return {
		"id": String(id),
		"display_name": display_name,
		"description": description,
		"lore": lore,
		"tier": tier,
		"max_tier": max_tier,
		"unlocked": unlocked,
		"unlock_level": unlock_level,
		"active_ability_id": String(active_ability_id),
		"passive_descriptions": Array(passive_descriptions),
		"stat_modifiers": stat_modifiers,
		"evolution_requirements": evolution_requirements,
		"effects": effects,
	}

func from_dict(data: Dictionary) -> bool:
	if not data.has("id"):
		return false
	id = StringName(String(data.get("id", "")))
	display_name = String(data.get("display_name", ""))
	description = String(data.get("description", ""))
	lore = String(data.get("lore", ""))
	tier = int(data.get("tier", 1))
	max_tier = int(data.get("max_tier", 5))
	unlocked = bool(data.get("unlocked", false))
	unlock_level = int(data.get("unlock_level", 1))
	active_ability_id = StringName(String(data.get("active_ability_id", "")))
	passive_descriptions = PackedStringArray(data.get("passive_descriptions", []))
	stat_modifiers = data.get("stat_modifiers", {})
	evolution_requirements = data.get("evolution_requirements", {})
	effects = data.get("effects", {})
	return true
