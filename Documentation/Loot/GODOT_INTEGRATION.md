# MANUAL TÉCNICO DE INTEGRAÇÃO COM GODOT 4
**Projeto:** Abyssal Pact | **Arquitetura:** ManagerBase + Resources

---

## 1. COMPONENTES DO SISTEMA
- `LootEntryData` (`res://systems/loot/loot_entry.gd`): Resource de entrada única com ID, chance, min, max, raridade e categoria.
- `LootTableData` (`res://systems/loot/loot_table.gd`): Resource agregador de entradas por faixas de raridade.
- `LootGenerator` (`res://systems/loot/loot_generator.gd`): Motor de cálculo RNG determinístico e independente.
- `LootValidation` (`res://systems/loot/loot_validation.gd`): Validador referencial das 530 tabelas.
- `LootManager` (`res://systems/loot/loot_manager.gd`): Gerenciador oficial do jogo com integração ao `InventoryManager` e suporte multiplayer.

## 2. API DO LOOT MANAGER
```gdscript
# Gerar loot para um monstro ou demônio derrotado
var drops: Array = LootManager.roll_loot("DEMON-001", "CHAR-001")

# Adicionar diretamente ao inventário com sinal
for drop in drops:
    InventoryManager.add_item("CHAR-001", drop.item_id, drop.quantity)
```
