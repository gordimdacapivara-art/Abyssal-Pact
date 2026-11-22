class_name InventoryData
extends Resource
## Inventário de um personagem: pilhas ordenadas. Propriedade do
## InventoryManager; referenciado por id de personagem.

var character_id: StringName = &""
var slots: Array[InventorySlotData] = []

func find_slot(item_id: StringName) -> InventorySlotData:
	for slot in slots:
		if slot.item_id == item_id:
			return slot
	return null

func total_of(item_id: StringName) -> int:
	var slot := find_slot(item_id)
	return slot.quantity if slot != null else 0

func to_dict() -> Dictionary:
	var data_slots: Array = []
	for slot in slots:
		data_slots.append(slot.to_dict())
	return {"character_id": String(character_id), "slots": data_slots}

func from_dict(data: Dictionary) -> bool:
	if not data.has("character_id"):
		return false
	character_id = StringName(String(data.get("character_id", "")))
	slots.clear()
	for slot_data: Dictionary in data.get("slots", []):
		var slot := InventorySlotData.new()
		if not slot.from_dict(slot_data):
			return false
		slots.append(slot)
	return true
