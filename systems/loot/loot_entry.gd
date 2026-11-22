class_name LootEntryData
extends Resource
## LootEntryData — Definição de uma entrada individual de drop.
##
## Armazena item_id, chance percentual (0.0 a 100.0), quantidades mínima e máxima,
## raridade, categoria e metadados de exibição.

@export var item_id: StringName = &""
@export var name: String = ""
@export var chance: float = 100.0
@export var min_quantity: int = 1
@export var max_quantity: int = 1
@export var rarity: StringName = &"common"
@export var category: StringName = &"material"
@export var is_exclusive: bool = false
@export var purpose: String = ""

func _init(
	p_id: StringName = &"",
	p_name: String = "",
	p_chance: float = 100.0,
	p_min: int = 1,
	p_max: int = 1,
	p_rarity: StringName = &"common",
	p_category: StringName = &"material",
	p_exclusive: bool = false,
	p_purpose: String = ""
) -> void:
	item_id = p_id
	name = p_name
	chance = p_chance
	min_quantity = p_min
	max_quantity = p_max
	rarity = p_rarity
	category = p_category
	is_exclusive = p_exclusive
	purpose = p_purpose

func to_dict() -> Dictionary:
	return {
		"item_id": String(item_id),
		"name": name,
		"chance": chance,
		"min_quantity": min_quantity,
		"max_quantity": max_quantity,
		"rarity": String(rarity),
		"category": String(category),
		"is_exclusive": is_exclusive,
		"purpose": purpose
	}

func from_dict(data: Dictionary) -> bool:
	if not data.has("item_id"):
		return false
	item_id = StringName(String(data.get("item_id", "")))
	name = String(data.get("name", ""))
	chance = float(data.get("chance", 100.0))
	min_quantity = int(data.get("min_quantity", 1))
	max_quantity = int(data.get("max_quantity", 1))
	rarity = StringName(String(data.get("rarity", "common")))
	category = StringName(String(data.get("category", "material")))
	is_exclusive = bool(data.get("is_exclusive", false))
	purpose = String(data.get("purpose", data.get("usage", data.get("description", ""))))
	return true
