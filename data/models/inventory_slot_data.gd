class_name InventorySlotData
extends Resource
## Uma pilha de item: item_id + quantidade. Estrutura leve para inventário.

var item_id: StringName = &""
var quantity: int = 0

func _init(p_item_id: StringName = &"", p_quantity: int = 0) -> void:
	item_id = p_item_id
	quantity = p_quantity

func to_dict() -> Dictionary:
	return {"item_id": String(item_id), "quantity": quantity}

func from_dict(data: Dictionary) -> bool:
	if not data.has("item_id"):
		return false
	item_id = StringName(String(data.get("item_id", "")))
	quantity = int(data.get("quantity", 0))
	return true
