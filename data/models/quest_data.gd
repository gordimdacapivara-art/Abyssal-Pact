class_name QuestData
extends Resource
## Dados de missão. Estrutura de objetivos via dicionário para manter o
## .tres serializável manualmente; estado de execução vive em QuestLogData.
## Suporta as 5 categorias de missão: principais, secundárias, regionais, de classe e de raça.

@export var id: StringName = &""
@export var display_name: String = ""
@export var description: String = ""
## Categoria: main, side, regional, class, race
@export var category: StringName = &"main"
@export var level_requirement: int = 1
@export var region_id: StringName = &"REG-001"
@export var class_id: StringName = &""
@export var race_id: StringName = &""
## Recompensas: {"xp": int, "souls": int, "items": Array[Dictionary]}
@export var rewards: Dictionary = {}
## Objetivos: { objetivo_id: { "required": int, "description": String } }
@export var objectives: Dictionary = {}

func get_objective_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for objective_id: String in objectives.keys():
		ids.append(objective_id)
	return ids

func get_objective_required(objective_id: StringName) -> int:
	var entry: Dictionary = objectives.get(String(objective_id), {})
	return int(entry.get("required", 0))

func get_objective_description(objective_id: StringName) -> String:
	var entry: Dictionary = objectives.get(String(objective_id), {})
	return String(entry.get("description", "Objetivo"))

func to_dict() -> Dictionary:
	return {
		"id": String(id),
		"display_name": display_name,
		"description": description,
		"category": String(category),
		"level_requirement": level_requirement,
		"region_id": String(region_id),
		"class_id": String(class_id),
		"race_id": String(race_id),
		"rewards": rewards,
		"objectives": objectives,
	}

func from_dict(data: Dictionary) -> bool:
	if not data.has("id"):
		return false
	id = StringName(String(data.get("id", "")))
	display_name = String(data.get("display_name", ""))
	description = String(data.get("description", ""))
	category = StringName(String(data.get("category", "main")))
	level_requirement = int(data.get("level_requirement", 1))
	region_id = StringName(String(data.get("region_id", "REG-001")))
	class_id = StringName(String(data.get("class_id", "")))
	race_id = StringName(String(data.get("race_id", "")))
	rewards = data.get("rewards", {})
	objectives = data.get("objectives", {})
	return true
