class_name EquipmentLoadoutData
extends Resource
## Equipamento vestido por um personagem: { slot: item_id }.
## Consumo/dureza de itens NÃO é aplicado ainda (decisão pendente);
## equipar não retira o item do inventário nesta etapa.

var character_id: StringName = &""
var slots: Dictionary = {} # String(slot) -> String(item_id)

func equip(slot: StringName, item_id: StringName) -> void:
	slots[String(slot)] = String(item_id)

func unequip(slot: StringName) -> bool:
	return slots.erase(String(slot))

func item_in_slot(slot: StringName) -> StringName:
	return StringName(String(slots.get(String(slot), "")))

func to_dict() -> Dictionary:
	return {"character_id": String(character_id), "slots": slots}

func from_dict(data: Dictionary) -> bool:
	if not data.has("character_id"):
		return false
	character_id = StringName(String(data.get("character_id", "")))
	slots = data.get("slots", {})
	return true
