extends TestCase
## Suite INVENTORY — catálogo de itens, inventários, equipamento e sinais.

func system_label() -> String:
	return "inventory"

func execute() -> void:
	var character := system(SystemNames.CHARACTER).call("create_character", "Portador de Itens", &"RACE-001", &"SUBRACE-001", &"CLASS-001") as CharacterData
	check_not_null(character, "personagem de suporte criado")
	var char_id: StringName = character.id

	section("Inventário sob demanda")
	var inventory_service := system(SystemNames.INVENTORY)
	var inventory: Resource = inventory_service.call("inventory_of", char_id)
	check_not_null(inventory, "inventário é criado sob demanda")
	var again: Resource = inventory_service.call("inventory_of", char_id)
	check_eq(again, inventory, "inventário é reutilizado por id")

	section("Adição de itens com sinal")
	var waiter_added := capture(EventBus.item_added)
	check_err(inventory_service.call("add_item", char_id, &"EQ-001", 2), OK, "item do catálogo é aceito")
	var added_args: Array = waiter_added.first()
	check_eq(int(added_args[2]), 2, "evento reporta o total após adicionar")
	check_eq(inventory_service.call("count_item", char_id, &"EQ-001"), 2, "quantidade acumulada")
	check_err(inventory_service.call("add_item", char_id, &"EQ-999", 1), ERR_DOES_NOT_EXIST, "item fora do catálogo")
	check_err(inventory_service.call("add_item", char_id, &"EQ-001", 0), ERR_INVALID_PARAMETER, "quantidade ≤ 0")

	section("Remoção com guarda de estoque")
	var waiter_removed := capture(EventBus.item_removed)
	check_err(inventory_service.call("remove_item", char_id, &"EQ-001", 1), OK, "remoção parcial")
	var removed_args: Array = waiter_removed.first()
	check_eq(int(removed_args[2]), 1, "evento reporta o total restante")
	check_err(inventory_service.call("remove_item", char_id, &"EQ-001", 5), FAILED,
		"remover mais do que existe falha")
	check_eq(inventory_service.call("count_item", char_id, &"EQ-001"), 1, "estoque preservado após falha")

	section("Equipamento: slot do item é validado")
	var waiter_equipped := capture(EventBus.equipment_changed)
	check_err(inventory_service.call("equip_item", char_id, &"weapon", &"EQ-001"), OK, "equipar em slot compatível")
	var equipped_args: Array = waiter_equipped.first()
	check_eq(StringName(equipped_args[1]), &"weapon", "evento carrega o slot")
	var loadout: Resource = inventory_service.call("loadout_of", char_id)
	check_eq(loadout.item_in_slot(&"weapon"), &"EQ-001", "loadout preserva o item")
	check_err(inventory_service.call("equip_item", char_id, &"head", &"EQ-001"), ERR_INVALID_PARAMETER,
		"slot divergente do item recusa")
	check_err(inventory_service.call("equip_item", char_id, &"weapon", &"EQ-999"), ERR_DOES_NOT_EXIST,
		"item inexistente recusa")

	section("Desequipar limpa o slot com sinal")
	var waiter_unequipped := capture(EventBus.equipment_changed)
	check_err(inventory_service.call("unequip_slot", char_id, &"weapon"), OK, "desequipar slot ocupado")
	var unequipped_args: Array = waiter_unequipped.first()
	check_eq(StringName(unequipped_args[2]), &"", "evento indica slot liberado")
	check_err(inventory_service.call("unequip_slot", char_id, &"weapon"), ERR_DOES_NOT_EXIST, "slot vazio recusa")

	section("Remoção até zerar some com a pilha")
	check_err(inventory_service.call("remove_item", char_id, &"EQ-001", 1), OK, "remoção final")
	check_eq(inventory_service.call("count_item", char_id, &"EQ-001"), 0, "inventário vazio")

	check_true(system(SystemNames.CHARACTER).call("delete_character", char_id), "limpeza do personagem de suporte")
