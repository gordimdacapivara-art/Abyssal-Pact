class_name LootGenerator
extends RefCounted
## LootGenerator — Motor de cálculo e rolagem probabilística independente.
##
## Implementa as regras matemáticas do Game Design Document:
## 1. Cada item possui rolagem individual (as chances NÃO somam 100%).
## 2. Drops garantidos (100%) sempre são entregues.
## 3. Quantidades são sorteadas uniformemente no intervalo [min, max].
## 4. Suporte a RNG com semente para sincronização multiplayer e testes Monte Carlo.

static func generate_loot(table: Resource, rng: RandomNumberGenerator = null) -> Array[Dictionary]:
	if table == null:
		return []
		
	var active_rng := rng
	if active_rng == null:
		active_rng = RandomNumberGenerator.new()
		active_rng.randomize()
		
	var dropped_items: Array[Dictionary] = []
	var all_entries: Array = table.call("get_all_entries")
	
	for entry in all_entries:
		if entry == null:
			continue
		var i_id: StringName = entry.item_id
		if i_id == &"":
			continue
			
		var success := false
		var ch: float = entry.chance
		if ch >= 100.0:
			success = true
		elif ch <= 0.0:
			success = false
		else:
			var roll := active_rng.randf_range(0.0, 100.0)
			if roll <= ch:
				success = true
				
		if success:
			var min_q: int = entry.min_quantity
			var max_q: int = entry.max_quantity
			if min_q <= 0:
				min_q = 1
			if max_q < min_q:
				max_q = min_q
				
			var quantity := active_rng.randi_range(min_q, max_q)
			dropped_items.append({
				"item_id": entry.item_id,
				"name": entry.name,
				"quantity": quantity,
				"rarity": entry.rarity,
				"category": entry.category,
				"is_exclusive": entry.is_exclusive,
				"purpose": entry.purpose
			})
			
	return dropped_items
