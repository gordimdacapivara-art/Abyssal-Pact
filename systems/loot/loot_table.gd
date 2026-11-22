class_name LootTableData
extends Resource
## LootTableData — Estrutura de dados contendo todas as entradas de loot de um inimigo.
##
## Agrupa drops garantidos, comuns, incomuns, raros, épicos, lendários, equipamentos
## e exclusivos.

const LootEntryScript := preload("res://systems/loot/loot_entry.gd")

@export var enemy_id: StringName = &""
@export var enemy_name: String = ""
@export var category: StringName = &"monster"
@export var subcategory: StringName = &""
@export var family: StringName = &""
@export var continent: String = ""
@export var region: String = ""
@export var biome: String = ""
@export var difficulty: StringName = &"common"
@export var encounter_type: String = ""

@export var guaranteed: Array = []
@export var common: Array = []
@export var uncommon: Array = []
@export var rare: Array = []
@export var epic: Array = []
@export var legendary: Array = []
@export var equipment: Array = []
@export var exclusive: Array = []

func get_all_entries() -> Array:
	var result: Array = []
	result.append_array(guaranteed)
	result.append_array(common)
	result.append_array(uncommon)
	result.append_array(rare)
	result.append_array(epic)
	result.append_array(legendary)
	result.append_array(equipment)
	result.append_array(exclusive)
	return result

func to_dict() -> Dictionary:
	var g_list: Array = []
	for e in guaranteed: g_list.append(e.to_dict())
	var c_list: Array = []
	for e in common: c_list.append(e.to_dict())
	var u_list: Array = []
	for e in uncommon: u_list.append(e.to_dict())
	var r_list: Array = []
	for e in rare: r_list.append(e.to_dict())
	var ep_list: Array = []
	for e in epic: ep_list.append(e.to_dict())
	var l_list: Array = []
	for e in legendary: l_list.append(e.to_dict())
	var eq_list: Array = []
	for e in equipment: eq_list.append(e.to_dict())
	var ex_list: Array = []
	for e in exclusive: ex_list.append(e.to_dict())
	
	return {
		"enemy_id": String(enemy_id),
		"enemy_name": enemy_name,
		"category": String(category),
		"subcategory": String(subcategory),
		"family": String(family),
		"continent": continent,
		"region": region,
		"biome": biome,
		"difficulty": String(difficulty),
		"encounter_type": encounter_type,
		"guaranteed": g_list,
		"common": c_list,
		"uncommon": u_list,
		"rare": r_list,
		"epic": ep_list,
		"legendary": l_list,
		"equipment": eq_list,
		"exclusive": ex_list
	}

func from_dict(data: Dictionary) -> bool:
	if not data.has("enemy_id"):
		return false
	enemy_id = StringName(String(data.get("enemy_id", "")))
	enemy_name = String(data.get("enemy_name", ""))
	category = StringName(String(data.get("category", "monster")))
	subcategory = StringName(String(data.get("subcategory", "")))
	family = StringName(String(data.get("family", "")))
	continent = String(data.get("continent", ""))
	region = String(data.get("region", ""))
	biome = String(data.get("biome", ""))
	difficulty = StringName(String(data.get("difficulty", "common")))
	encounter_type = String(data.get("encounter_type", ""))
	
	guaranteed.clear()
	for item_dict in data.get("guaranteed", []):
		var entry = LootEntryScript.new()
		if entry.from_dict(item_dict):
			guaranteed.append(entry)
			
	common.clear()
	for item_dict in data.get("common", []):
		var entry = LootEntryScript.new()
		if entry.from_dict(item_dict):
			common.append(entry)
			
	uncommon.clear()
	for item_dict in data.get("uncommon", []):
		var entry = LootEntryScript.new()
		if entry.from_dict(item_dict):
			uncommon.append(entry)
			
	rare.clear()
	for item_dict in data.get("rare", []):
		var entry = LootEntryScript.new()
		if entry.from_dict(item_dict):
			rare.append(entry)
			
	epic.clear()
	for item_dict in data.get("epic", []):
		var entry = LootEntryScript.new()
		if entry.from_dict(item_dict):
			epic.append(entry)
			
	legendary.clear()
	for item_dict in data.get("legendary", []):
		var entry = LootEntryScript.new()
		if entry.from_dict(item_dict):
			legendary.append(entry)
			
	equipment.clear()
	for item_dict in data.get("equipment", []):
		var entry = LootEntryScript.new()
		if entry.from_dict(item_dict):
			equipment.append(entry)
			
	exclusive.clear()
	var raw_excl = data.get("exclusive", [])
	if raw_excl is Array:
		for item_dict in raw_excl:
			var entry = LootEntryScript.new()
			if entry.from_dict(item_dict):
				exclusive.append(entry)
	elif raw_excl is Dictionary:
		if raw_excl.has("items"):
			for item_dict in raw_excl.get("items", []):
				var entry = LootEntryScript.new()
				if entry.from_dict(item_dict):
					exclusive.append(entry)
		elif raw_excl.has("item_id"):
			var entry = LootEntryScript.new()
			if entry.from_dict(raw_excl):
				exclusive.append(entry)
				
	return true
