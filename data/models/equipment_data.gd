class_name EquipmentData
extends Resource
## Dados de item/equipamento. Catálogo carregado pelo InventoryManager.
## Suporta as 5 categorias de inventário: equipamentos, consumíveis,
## materiais, relíquias e itens de missão.

@export var id: StringName = &""
@export var display_name: String = ""
@export var description: String = ""
## Categoria: equipment, consumable, material, relic, quest
@export var category: StringName = &"equipment"
## Slot de equipamento: weapon, head, chest, legs, boots, amulet, ring, ring2, none
@export var slot: StringName = &""
## Subtipo de equipamento: weapon, armor_head, armor_chest, armor_legs, armor_boots, accessory_amulet, accessory_ring
@export var equipment_type: StringName = &"weapon"
## Raridade: common, uncommon, rare, epic, legendary, abyssal
@export var rarity: StringName = &"common"
## Estatísticas de combate (ex: {"attack": 15, "defense": 10, "health": 50})
@export var stats: Dictionary = {}
## Efeito de uso (para consumíveis: ex: {"type": "heal", "value": 100})
@export var use_effect: Dictionary = {}
## Valor em moedas/almas
@export var value: int = 10
## Quantidade máxima por pilha no inventário
@export var max_stack: int = 99

func to_dict() -> Dictionary:
	return {
		"id": String(id),
		"display_name": display_name,
		"description": description,
		"category": String(category),
		"slot": String(slot),
		"equipment_type": String(equipment_type),
		"rarity": String(rarity),
		"stats": stats,
		"use_effect": use_effect,
		"value": value,
		"max_stack": max_stack,
	}

func from_dict(data: Dictionary) -> bool:
	if not data.has("id"):
		return false
	id = StringName(String(data.get("id", "")))
	display_name = String(data.get("display_name", ""))
	description = String(data.get("description", ""))
	category = StringName(String(data.get("category", "equipment")))
	slot = StringName(String(data.get("slot", "")))
	equipment_type = StringName(String(data.get("equipment_type", "weapon")))
	rarity = StringName(String(data.get("rarity", "common")))
	stats = data.get("stats", {})
	use_effect = data.get("use_effect", {})
	value = int(data.get("value", 10))
	max_stack = int(data.get("max_stack", 99))
	return true
