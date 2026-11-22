class_name LootManager
extends ManagerBase
## LootManager — Gerenciador Oficial do Sistema de Loot de Abyssal Pact.
##
## Responsabilidade:
## 1. Carregar as 530 tabelas de loot (300 monstros + 230 demônios).
## 2. Carregar o catálogo central de itens e materiais.
## 3. Sortear recompensas via LootGenerator de forma independente.
## 4. Distribuir itens aos personagens via InventoryManager.
## 5. Controlar autoridade em multiplayer (Host) e evitar duplicação por morte repetida.

const KEY: StringName = &"Loot"

func system_key() -> StringName:
	return KEY

const MASTER_DB_PATH := "res://data/loot/loot_tables/master_loot_database.json"
const ITEM_CATALOG_PATH := "res://data/loot/items/item_catalog.json"

const LootTableScript := preload("res://systems/loot/loot_table.gd")
const LootGeneratorScript := preload("res://systems/loot/loot_generator.gd")

var _tables: Dictionary = {} # String(enemy_id) -> LootTableData
var _item_catalog: Dictionary = {} # String(item_id) -> Dictionary
var _processed_deaths: Dictionary = {} # String(death_event_id) -> bool
var _is_loaded: bool = false

signal loot_dropped(enemy_id: StringName, character_id: StringName, items: Array)

func _init() -> void:
	load_all_data()

func initialize() -> void:
	super()
	load_all_data()

func load_all_data() -> bool:
	if _is_loaded:
		return true
		
	var s1 := load_item_catalog()
	var s2 := load_loot_database()
	_is_loaded = s1 and s2
	return _is_loaded

func load_item_catalog(p_path: String = ITEM_CATALOG_PATH) -> bool:
	_item_catalog.clear()
	if not FileAccess.file_exists(p_path):
		push_warning("LootManager: Catálogo de itens não encontrado em %s" % p_path)
		return false
		
	var file := FileAccess.open(p_path, FileAccess.READ)
	if file == null:
		push_error("LootManager: Falha ao abrir %s" % p_path)
		return false
		
	var json_str := file.get_as_text()
	var parser := JSON.new()
	var err := parser.parse(json_str)
	if err != OK:
		push_error("LootManager: Erro ao parsear %s: %s" % [p_path, parser.get_error_message()])
		return false
		
	var data: Dictionary = parser.data
	_item_catalog = data.get("items", {})
	return true

func load_loot_database(p_path: String = MASTER_DB_PATH) -> bool:
	_tables.clear()
	if not FileAccess.file_exists(p_path):
		push_warning("LootManager: Banco mestre de loot não encontrado em %s" % p_path)
		return false
		
	var file := FileAccess.open(p_path, FileAccess.READ)
	if file == null:
		push_error("LootManager: Falha ao abrir %s" % p_path)
		return false
		
	var json_str := file.get_as_text()
	var parser := JSON.new()
	var err := parser.parse(json_str)
	if err != OK:
		push_error("LootManager: Erro ao parsear %s: %s" % [p_path, parser.get_error_message()])
		return false
		
	var data: Dictionary = parser.data
	var enemies_dict: Dictionary = data.get("enemies", {})
	
	for enemy_id in enemies_dict.keys():
		var t_dict: Dictionary = enemies_dict[enemy_id]
		var table = LootTableScript.new()
		if table.from_dict(t_dict):
			_tables[enemy_id] = table
			
	log_info("LootManager: %d tabelas de loot carregadas." % _tables.size())
	return true

func is_loaded() -> bool:
	return _is_loaded

func count() -> int:
	return _tables.size()

func has_table(enemy_id: StringName) -> bool:
	return _tables.has(String(enemy_id))

func get_table(enemy_id: StringName) -> Resource:
	return _tables.get(String(enemy_id), null)

func get_all_tables() -> Array:
	return _tables.values()

func get_item_catalog() -> Dictionary:
	return _item_catalog

## Sorteia as recompensas de um inimigo.
func roll_loot(enemy_id: StringName, character_id: StringName = &"", rng: RandomNumberGenerator = null) -> Array[Dictionary]:
	var table: Resource = get_table(enemy_id)
	if table == null:
		push_warning("LootManager: Tabela não encontrada para %s" % String(enemy_id))
		return []
		
	var drops: Array[Dictionary] = LootGeneratorScript.generate_loot(table, rng)
	if not String(character_id).is_empty():
		loot_dropped.emit(enemy_id, character_id, drops)
		deliver_to_inventory(character_id, drops)
	return drops

## Entrega a lista de itens ao inventário via InventoryManager
func deliver_to_inventory(character_id: StringName, drops: Array, p_inv_manager = null) -> Error:
	if String(character_id).is_empty():
		return OK
		
	var inv_manager = p_inv_manager
	if inv_manager == null:
		if _registry != null and _registry.has_system(SystemNames.INVENTORY):
			inv_manager = _registry.get_system(SystemNames.INVENTORY)
		elif is_inside_tree() and has_node("/root/Game"):
			var game_node := get_node("/root/Game")
			if game_node != null and game_node.has_method("get_system"):
				inv_manager = game_node.call("get_system", SystemNames.INVENTORY)
		
	if inv_manager != null:
		for drop in drops:
			var i_id: StringName = StringName(drop.get("item_id", ""))
			var qty: int = int(drop.get("quantity", 1))
			if inv_manager.has_item(i_id):
				inv_manager.add_item(character_id, i_id, qty)
	return OK

## Processa evento de morte com autoridade de rede e prevenção de duplicação.
func process_enemy_death(death_event_id: StringName, enemy_id: StringName, participants: Array = []) -> Dictionary:
	var event_key := String(death_event_id)
	if _processed_deaths.has(event_key):
		log_warn("LootManager: Evento de morte duplicado descartado: %s" % event_key)
		return {"success": false, "reason": "already_processed"}
		
	_processed_deaths[event_key] = true
	
	var table: Resource = get_table(enemy_id)
	if table == null:
		return {"success": false, "reason": "unknown_enemy"}
		
	var results: Dictionary = {}
	if participants.is_empty():
		var single_roll: Array[Dictionary] = roll_loot(enemy_id)
		results["shared"] = single_roll
	else:
		# Distribuição por participante em mundo privado (até 8 jogadores)
		for char_id in participants:
			var p_id: StringName = StringName(char_id)
			var p_roll: Array[Dictionary] = roll_loot(enemy_id, p_id)
			results[String(p_id)] = p_roll
			
	return {
		"success": true,
		"enemy_id": String(enemy_id),
		"results": results
	}
