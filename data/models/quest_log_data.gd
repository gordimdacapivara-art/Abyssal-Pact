class_name QuestLogData
extends Resource
## Diário de missões por personagem. Propriedade do QuestManager; o estado
## é serializado pelo contrato de save do próprio QuestManager.

var character_id: StringName = &""
var entries: Array[QuestEntryData] = []

func find_entry(quest_id: StringName) -> QuestEntryData:
	for entry in entries:
		if entry.quest_id == quest_id:
			return entry
	return null

func entries_in_state(state: StringName) -> Array[QuestEntryData]:
	var result: Array[QuestEntryData] = []
	for entry in entries:
		if entry.state == state:
			result.append(entry)
	return result

func to_dict() -> Dictionary:
	var data_entries: Array = []
	for entry in entries:
		data_entries.append(entry.to_dict())
	return {"character_id": String(character_id), "entries": data_entries}

func from_dict(data: Dictionary) -> bool:
	if not data.has("character_id"):
		return false
	character_id = StringName(String(data.get("character_id", "")))
	entries.clear()
	for entry_data: Dictionary in data.get("entries", []):
		var entry := QuestEntryData.new()
		if not entry.from_dict(entry_data):
			return false
		entries.append(entry)
	return true
