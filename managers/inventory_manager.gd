class_name InventoryManager
extends ManagerBase
## InventoryManager â€” catÃ¡logo de itens/equipamentos + inventÃ¡rios vivos.
##
## Responsabilidade: catÃ¡logo EquipmentData (data/content/equipment);
## inventÃ¡rios por personagem (InventoryData) e loadout de equipamento
## (EquipmentLoadoutData). Economia, raridade e consumo de itens PENDENTES:
## equipar NÃƒO consome o item nesta etapa (decisÃ£o pendente documentada).
##
## IntegraÃ§Ã£o:
##   - Emite (EventBus): catalog_loaded / catalog_invalid, item_added,
##     item_removed, equipment_changed.
##   - Consome (registry): nenhum (inventÃ¡rio Ã© criado sob demanda por id).
##   - Save (contrato ManagerBase): inventÃ¡rios + loadouts por personagem.
## ServiÃ§o: registro "Inventory" (criado por GameManager).

const KEY: StringName = SystemNames.INVENTORY

## Expõe a chave constante (constantes não são sobrescíveis em GDScript).
func system_key() -> StringName:
	return KEY

const EQUIPMENT_DIR := "res://data/content/equipment"

var _items: Dictionary = {} # String(id) -> EquipmentData
var _inventories: Dictionary = {} # String(character_id) -> InventoryData
var _loadouts: Dictionary = {} # String(character_id) -> EquipmentLoadoutData

func initialize() -> void:
	super()
	load_catalog()

# ------------------------------------------------------------------ CATÃLOGO --

func load_catalog() -> bool:
	_items.clear()
	var issues := PackedStringArray()
	if not DirAccess.dir_exists_absolute(EQUIPMENT_DIR):
		issues.append("diretÃ³rio ausente: %s" % EQUIPMENT_DIR)
	else:
		for file_name in DirAccess.get_files_at(EQUIPMENT_DIR):
			if not file_name.ends_with(".tres"):
				continue
			var resource := load(EQUIPMENT_DIR + "/" + file_name) as EquipmentData
			if resource == null:
				issues.append("recurso invÃ¡lido (esperado EquipmentData): %s" % file_name)
				continue
			var data_id := String(resource.id)
			if data_id.is_empty():
				issues.append("id vazio em %s" % file_name)
				continue
			if String(resource.slot) == "":
				issues.append("item '%s' sem slot definido" % data_id)
				continue
			if _items.has(data_id):
				issues.append("item duplicado: %s" % data_id)
				continue
			_items[data_id] = resource

	if issues.is_empty():
		log_info("CatÃ¡logo de itens carregado: %d itens." % _items.size())
		EventBus.catalog_loaded.emit(&"equipment", _items.size())
		return true
	EventBus.catalog_invalid.emit(&"equipment", issues)
	return false

func has_item(item_id: StringName) -> bool:
	return _items.has(String(item_id))

func register_item(item: EquipmentData) -> bool:
	if item == null:
		return false
	var key := String(item.id)
	if key.is_empty():
		return false
	_items[key] = item
	return true

func register_item_raw(p_id: StringName, p_name: String, p_category: StringName = &"material", p_rarity: StringName = &"common") -> bool:
	var item := EquipmentData.new()
	item.id = p_id
	item.display_name = p_name
	item.category = p_category
	item.slot = &"none"
	item.rarity = p_rarity
	return register_item(item)

func get_item(item_id: StringName) -> EquipmentData:
	return _items.get(String(item_id)) as EquipmentData

func items() -> Array[EquipmentData]:
	var result: Array[EquipmentData] = []
	for value in _items.values():
		result.append(value as EquipmentData)
	return result

func items_of_category(p_category: StringName) -> Array[EquipmentData]:
	var result: Array[EquipmentData] = []
	for item in items():
		if item.category == p_category:
			result.append(item)
	return result

func use_item(character_id: StringName, item_id: StringName) -> Error:
	var item := get_item(item_id)
	if item == null:
		return ERR_DOES_NOT_EXIST
	if item.category != &"consumable":
		return ERR_INVALID_PARAMETER
	if count_item(character_id, item_id) <= 0:
		return FAILED
	var err := remove_item(character_id, item_id, 1)
	if err == OK:
		EventBus.ui_action_requested.emit(&"item_used")
	return err

# ---------------------------------------------------------------- INVENTÃRIO --

func inventory_of(character_id: StringName) -> InventoryData:
	var key := String(character_id)
	if key.is_empty():
		return null
	if not _inventories.has(key):
		var inventory := InventoryData.new()
		inventory.character_id = character_id
		_inventories[key] = inventory
	return _inventories[key] as InventoryData

func loadout_of(character_id: StringName) -> EquipmentLoadoutData:
	var key := String(character_id)
	if key.is_empty():
		return null
	if not _loadouts.has(key):
		var loadout := EquipmentLoadoutData.new()
		loadout.character_id = character_id
		_loadouts[key] = loadout
	return _loadouts[key] as EquipmentLoadoutData

func add_item(character_id: StringName, item_id: StringName, quantity: int = 1) -> Error:
	if not has_item(item_id):
		return ERR_DOES_NOT_EXIST
	if quantity <= 0:
		return ERR_INVALID_PARAMETER
	var inventory := inventory_of(character_id)
	if inventory == null:
		return ERR_INVALID_PARAMETER
	var slot := inventory.find_slot(item_id)
	if slot == null:
		slot = InventorySlotData.new(item_id, 0)
		inventory.slots.append(slot)
	slot.quantity += quantity
	EventBus.item_added.emit(character_id, item_id, slot.quantity)
	return OK

func remove_item(character_id: StringName, item_id: StringName, quantity: int = 1) -> Error:
	if quantity <= 0:
		return ERR_INVALID_PARAMETER
	var inventory := inventory_of(character_id)
	if inventory == null:
		return ERR_INVALID_PARAMETER
	var slot := inventory.find_slot(item_id)
	if slot == null or slot.quantity < quantity:
		return FAILED # Sem estoque suficiente (nÃ£o hÃ¡ cÃ³digo especÃ­fico na Godot).
	slot.quantity -= quantity
	if slot.quantity == 0:
		inventory.slots.erase(slot)
	EventBus.item_removed.emit(character_id, item_id, inventory.total_of(item_id))
	return OK

func count_item(character_id: StringName, item_id: StringName) -> int:
	var inventory := inventory_of(character_id)
	return inventory.total_of(item_id) if inventory != null else 0

## Equipa item de um slot de equipamento. NÃƒO consome do inventÃ¡rio
## (decisÃ£o de consumo pendente). Valida que o slot informado Ã© o slot do item.
func equip_item(character_id: StringName, slot: StringName, item_id: StringName) -> Error:
	var item := get_item(item_id)
	if item == null:
		return ERR_DOES_NOT_EXIST
	if item.slot != slot:
		return ERR_INVALID_PARAMETER
	if count_item(character_id, item_id) < 1:
		return FAILED
	var loadout := loadout_of(character_id)
	if loadout == null:
		return ERR_INVALID_PARAMETER
	loadout.equip(slot, item_id)
	log_info("Equipado: %s em %s (personagem %s)." % [item_id, slot, character_id])
	EventBus.equipment_changed.emit(character_id, slot, item_id)
	return OK

func unequip_slot(character_id: StringName, slot: StringName) -> Error:
	var loadout := loadout_of(character_id)
	if loadout == null or String(loadout.item_in_slot(slot)) == "":
		return ERR_DOES_NOT_EXIST
	loadout.unequip(slot)
	EventBus.equipment_changed.emit(character_id, slot, &"")
	return OK

# ---------------------------------------------------------------------- SAVE --

func collect_save_data() -> Dictionary:
	var inventories: Dictionary = {}
	for key in _inventories.keys():
		inventories[key] = (_inventories[key] as InventoryData).to_dict()
	var loadouts: Dictionary = {}
	for key in _loadouts.keys():
		loadouts[key] = (_loadouts[key] as EquipmentLoadoutData).to_dict()
	return {"inventories": inventories, "loadouts": loadouts}

func apply_save_data(data: Dictionary) -> bool:
	_inventories.clear()
	_loadouts.clear()
	for key: String in (data.get("inventories", {}) as Dictionary).keys():
		var inventory := InventoryData.new()
		if not inventory.from_dict(data["inventories"][key]):
			return false
		_inventories[key] = inventory
	for key: String in (data.get("loadouts", {}) as Dictionary).keys():
		var loadout := EquipmentLoadoutData.new()
		if not loadout.from_dict(data["loadouts"][key]):
			return false
		_loadouts[key] = loadout
	return true

func verify() -> PackedStringArray:
	var issues := super()
	if _items.is_empty():
		issues.append("catÃ¡logo de itens vazio")
	for key in _inventories.keys():
		var inventory := _inventories[key] as InventoryData
		for slot in inventory.slots:
			if slot.quantity < 0:
				issues.append("quantidade negativa no inventÃ¡rio de '%s' (item %s)" % [key, slot.item_id])
			elif not has_item(slot.item_id):
				issues.append("item fora do catÃ¡logo no inventÃ¡rio de '%s': %s" % [key, slot.item_id])
	return issues
