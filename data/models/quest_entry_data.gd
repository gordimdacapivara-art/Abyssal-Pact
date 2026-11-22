class_name QuestEntryData
extends Resource
## Entrada do diário de missões de um personagem: estado + progresso.

var quest_id: StringName = &""
## Estados: &"active", &"completed", &"abandoned".
var state: StringName = &"active"
## Progresso por objetivo: String(objective_id) -> int.
var progress: Dictionary = {}

func is_objective_complete(quest: QuestData, objective_id: StringName) -> bool:
	var required := quest.get_objective_required(objective_id)
	return int(progress.get(String(objective_id), 0)) >= required

func all_objectives_complete(quest: QuestData) -> bool:
	for objective_id in quest.get_objective_ids():
		if not is_objective_complete(quest, objective_id):
			return false
	return true

func to_dict() -> Dictionary:
	return {
		"quest_id": String(quest_id),
		"state": String(state),
		"progress": progress,
	}

func from_dict(data: Dictionary) -> bool:
	if not data.has("quest_id"):
		return false
	quest_id = StringName(String(data.get("quest_id", "")))
	state = StringName(String(data.get("state", "active")))
	progress = data.get("progress", {})
	return true
