extends TestCase
## Suite LOOT — Sistema de Loot de Abyssal Pact (300 Monstros + 230 Demônios).
##
## Valida:
## 1. Carga integral das 530 tabelas de loot (300 monstros + 230 demônios).
## 2. Catálogo central de itens.
## 3. Os 7 drops exclusivos obrigatórios de cada um dos 10 Primordiais.
## 4. Mecânica de rolagens independentes e integridade de quantidades.
## 5. Prevenção de duplicação em eventos de morte e suporte a mundos privados (até 8 participantes).
## 6. Integração com InventoryManager.

const LootManagerScript := preload("res://systems/loot/loot_manager.gd")
const LootValidationScript := preload("res://systems/loot/loot_validation.gd")
const LootGeneratorScript := preload("res://systems/loot/loot_generator.gd")

func system_label() -> String:
	return "loot"

func execute() -> void:
	await _test_loot_catalog_integrity()
	await _test_loot_roll_mechanics()
	await _test_primordial_exclusives()
	await _test_multiplayer_and_anti_duplication()
	await _test_inventory_integration()

# ------------------------------------------------------------- 1. Integridade --

func _test_loot_catalog_integrity() -> void:
	section("LootManager: 530 tabelas de loot, ausência de duplicatas e integridade referencial")
	var mgr = LootManagerScript.new()
	check_true(mgr.is_loaded(), "LootManager deve inicializar e carregar todos os dados")
	check_eq(mgr.count(), 530, "catálogo deve conter exatamente 530 tabelas de loot (300 monstros + 230 demônios)")
	
	var val_result: Dictionary = LootValidationScript.validate_all(mgr)
	var issues: PackedStringArray = val_result.get("issues", [])
	check_true(val_result.get("success", false), "validação referencial das 530 tabelas deve passar sem erros: %s" % "; ".join(issues.slice(0, 5)))
	check_eq(issues.size(), 0, "nenhum conflito referencial, probabilidade negativa ou min > max detectado")
	check_eq(val_result.get("monster_count", 0), 300, "exatamente 300 monstros catalogados")
	check_eq(val_result.get("demon_count", 0), 230, "exatamente 230 demônios catalogados")

# -------------------------------------------------------------- 2. Mecânicas --

func _test_loot_roll_mechanics() -> void:
	section("LootGenerator: rolagens independentes, drops garantidos e sorteio uniforme de quantidade")
	var mgr = LootManagerScript.new()
	var table: Resource = mgr.get_table(&"DEMON-001")
	check_not_null(table, "tabela de DEMON-001 deve existir")
	if table == null:
		return
		
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	
	var drops: Array[Dictionary] = LootGeneratorScript.generate_loot(table, rng)
	check_true(drops.size() > 0, "rolagem de DEMON-001 deve gerar drops")
	
	# Verifica se os drops garantidos estão presentes
	var dropped_ids: Array[StringName] = []
	for d in drops:
		dropped_ids.append(StringName(String(d.get("item_id", ""))))
		var qty: int = int(d.get("quantity", 0))
		check_true(qty >= 1, "quantidade dropada de '%s' deve ser >= 1 (obtido: %d)" % [d.get("item_id"), qty])
		
	for g in table.guaranteed:
		check_true(dropped_ids.has(g.item_id), "drop garantido '%s' deve estar presente no resultado" % String(g.item_id))

# ------------------------------------------------------------ 3. Primordiais --

func _test_primordial_exclusives() -> void:
	section("Demônios Primordiais: verificação dos 7 componentes exclusivos em DEMON-191 a DEMON-200")
	var mgr = LootManagerScript.new()
	for i in range(191, 201):
		var p_id := StringName("DEMON-%d" % i)
		check_true(mgr.has_table(p_id), "Primordial %s deve existir" % String(p_id))
		var p_table: Resource = mgr.get_table(p_id)
		if p_table != null:
			check_true(p_table.exclusive.size() >= 7,
				"Primordial %s deve possuir pelo menos 7 drops exclusivos (possui: %d)" % [String(p_id), p_table.exclusive.size()])
			check_eq(p_table.subcategory, &"primordial", "categoria deve ser primordial")

# ----------------------------------------------------------- 4. Multiplayer --

func _test_multiplayer_and_anti_duplication() -> void:
	section("Multiplayer: prevenção de duplicação por morte repetida e distribuição em mundos privados")
	var mgr = LootManagerScript.new()
	var death_event := &"DEATH-EVT-999"
	var participants: Array = ["CHAR-001", "CHAR-002", "CHAR-003"]
	
	# Primeiro processamento da morte do inimigo
	var res1: Dictionary = mgr.process_enemy_death(death_event, &"BOSS-001", participants)
	check_true(res1.get("success", false), "primeiro processamento do evento de morte deve ser aprovado")
	var results_dict: Dictionary = res1.get("results", {})
	check_eq(results_dict.size(), 3, "distribuição deve contemplar os 3 participantes do mundo privado")
	
	# Segundo processamento do mesmo evento (tentativa de duplicação / exploit)
	var res2: Dictionary = mgr.process_enemy_death(death_event, &"BOSS-001", participants)
	check_false(res2.get("success", true), "segundo processamento com mesmo death_event_id DEVE ser rejeitado")
	check_eq(res2.get("reason", ""), "already_processed", "motivo de rejeição deve ser already_processed")

# ------------------------------------------------------------ 5. Inventário --

func _test_inventory_integration() -> void:
	section("Integração com InventoryManager: entrega direta de drops e compatibilidade de tipos")
	var inventory_service = system(SystemNames.INVENTORY)
	check_not_null(inventory_service, "InventoryManager deve estar ativo no SystemRegistry")
	if inventory_service == null:
		return
		
	var character_service = system(SystemNames.CHARACTER)
	var char_data = character_service.call("create_character", "Caçador de Loot", &"RACE-001", &"SUBRACE-001", &"CLASS-001") as CharacterData
	check_not_null(char_data, "personagem de teste criado")
	var char_id: StringName = char_data.id
	
	# Registra um item de teste do catálogo de loot
	var test_item_id := &"mat_beast_leather"
	inventory_service.call("register_item_raw", test_item_id, "Couro Flexível de Fera", &"material", &"uncommon")
	
	var initial_count: int = inventory_service.call("count_item", char_id, test_item_id)
	check_eq(initial_count, 0, "inventário inicia sem o item")
	
	var mgr = LootManagerScript.new()
	var drops: Array = [
		{"item_id": test_item_id, "quantity": 3, "rarity": "uncommon"}
	]
	var err: int = mgr.deliver_to_inventory(char_id, drops, inventory_service)
	check_eq(err, OK, "entrega de drops ao inventário deve retornar OK")
	
	var final_count: int = inventory_service.call("count_item", char_id, test_item_id)
	check_eq(final_count, 3, "inventário deve conter 3 unidades do item após entrega")
	
	character_service.call("delete_character", char_id)
