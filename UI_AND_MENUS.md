# Abyssal Pact — Interfaces, Telas e Sistemas Complementares

Este documento define a arquitetura, biblioteca de componentes e implementação dos 16 menus e telas complementares de **ABYSSAL PACT**, regidos pela identidade visual **Dark Fantasy** e alimentados dinamicamente pelos sistemas de dados do jogo.

---

## 1. Identidade Visual Dark Fantasy

Todas as telas seguem a direção de arte sombria, metálica e rúnica estabelecida no tema dinâmico `DarkFantasyTheme` (`res://scenes/ui/theme/dark_fantasy_theme.gd`):
- **Paleta de Cores:** Fundo de pedra escura vulcânica (`#0a0910`, `#141218`), bordas metálicas envelhecidas e dourado pálido (`#594c38`, `#b39461`), runas avermelhadas e destaques abissais (`#e6c073`, `#46d973`, `#ff4033`).
- **Ornamento Rúnico Canônico:** Padrão `❖ TITULO DA TELA ❖`.
- **Hierarquia:** Telas instanciadas como filhas da camada `Screens` do autoload `UI` (`UIManager`), sobrepondo o mundo 3D com modais centralizados ou dashboards de tela inteira.

---

## 2. Biblioteca Compartilhada de Componentes (`res://scenes/ui/components/`)

Para garantir reutilização, coerência visual e modularidade:

1. **`DarkFantasyHeader` (`dark_fantasy_header.gd`):**
   - Cabeçalho padronizado com ornamentos rúnicos laterais, subtítulo temático e botão de fechar (`✖`).
   - Emite o sinal `close_requested`.
2. **`DarkFantasyNavBar` (`dark_fantasy_nav_bar.gd`):**
   - Barra de navegação em abas rúnicas (`tabs: Array[Dictionary]`).
   - Suporta seleção visual ativa, badges e emissão do sinal `tab_selected(tab_id: StringName)`.
3. **`ItemSlotUI` (`item_slot_ui.gd`):**
   - Célula de inventário com moldura baseada na raridade do item (`common`, `uncommon`, `rare`, `epic`, `legendary`).
   - Exibição de badge com quantidade de pilha, ícone provisório e destaque de foco/seleção.
   - Emite o sinal `slot_clicked(slot: ItemSlotUI)`.
4. **`StatComparisonCard` (`stat_comparison_card.gd`):**
   - Painel comparativo em tempo real entre o item equipado e o item candidato do inventário.
   - Apresenta deltas coloridos (+ verde para ganho, - vermelho para perda, cinza para neutro) em atributos como ataque, defesa, poder mágico, vida e velocidade.

---

## 3. Catálogo dos 16 Menus e Telas Implementadas

Todos os menus herdam de `ScreenBase` (`res://scenes/ui/screens/screen_base.gd`), possuem cenas pré-carregadas no router do `UIManager` e contam com botões e interações 100% funcionais.

| # | ID da Tela (`StringName`) | Arquivo GDScript | Arquivo Cena (.tscn) | Propósito & Integração com Sistemas |
|---|---|---|---|---|
| 1 | `main_menu` | `main_menu_screen.gd` | `main_menu_screen.tscn` | Tela de entrada, novo jogo (`character_creation`), continuar, criar mundo privado, entrar em mundo privado, configurações e saída. |
| 2 | `create_world` | `create_world_screen.gd` | `create_world_screen.tscn` | Criação de sessões privadas (`MultiplayerManager.host_private_world`), seleção de mapa inicial e porta de rede. |
| 3 | `join_world` | `join_world_screen.gd` | `join_world_screen.tscn` | Entrada em mundos privados via código de convite ou IP/porta (`MultiplayerManager.join_private_world`). |
| 4 | `inventory` | `inventory_screen.gd` | `inventory_screen.tscn` | Grade de 40 slots, filtros pelas 5 categorias canônicas (Equipamentos, Consumíveis, Materiais, Relíquias, Missão), descarte e uso de consumíveis. |
| 5 | `equipment` | `equipment_screen.gd` | `equipment_screen.tscn` | Doll de slots (arma, armaduras, acessórios), boneco 3D instanciado via `RaceVisualBuilder`, inspeção de estatísticas e comparador de atributos. |
| 6 | `abilities` | `abilities_screen.gd` | `abilities_screen.tscn` | Grade de habilidades da classe, árvore de ativação e loadout de combate (slots 1 a 4). |
| 7 | `class_tree` | `class_tree_screen.gd` | `class_tree_screen.tscn` | Visualizador da árvore de especialização da classe ativa, atributos base, desbloqueios por nível e progressão. |
| 8 | `pacts` | `pacts_screen.gd` | `pacts_screen.tscn` | Seleção dos 5 Pactos Abissais canônicos, vínculo ao personagem, evolução até Grau 5 com custos de almas e materiais, e escalonamento de atributos. |
| 9 | `world_map` | `world_map_screen.gd` | `world_map_screen.tscn` | Mapa dos 4 continentes (Veyrath, Sylvaran, Khar-Duum, Nhal'Kora), seleção das 40 regiões, teleporte e status de descoberta. |
| 10 | `regional_map` | `regional_map_screen.gd` | `regional_map_screen.tscn` | Mapa topográfico 2D da região ativa, radar com marcadores de cidades, masmorras, chefes, portais e exploração. |
| 11 | `codex` | `codex_screen.gd` | `codex_screen.tscn` | Grande enciclopédia de conhecimento nas 9 categorias canônicas: 200 demônios, 30 chefes, 40 raças, 80 sub-raças, 80 classes, 4 continentes, 40 regiões, história e facções. |
| 12 | `bestiary` | `bestiary_screen.gd` | `bestiary_screen.tscn` | Bestiário com filtragem por continente (50 criaturas por continente) e 30 chefes especiais, exibindo fraquezas, drops, modelo GLB e status de encontro. |
| 13 | `quests` | `quests_screen.gd` | `quests_screen.tscn` | Diário de missões nas 5 categorias (Principais, Secundárias, Regionais, Classe, Raça), aceitação, abandono, rastreamento de objetivos e recompensas. |
| 14 | `party` | `party_screen.gd` | `party_screen.tscn` | Interface de grupo até 8 jogadores, classes, níveis, barras de vida, ping de rede e geração/cópia do código de convite privado. |
| 15 | `settings` | `settings_screen.gd` | `settings_screen.tscn` | Painel de ajustes: Áudio (Master, Música, Efeitos, UI), Gráficos (Modo de Janela, V-Sync, Escala de Resolução) e Jogabilidade (Sensibilidade, Inversão, Vibração de Tela). |
| 16 | `pause_menu` | `pause_menu_screen.gd` | `pause_menu_screen.tscn` | Modal de pausa centralizado, dados do personagem ativo, grade de atalhos rápidos para as outras 15 telas, retorno à Hell Forge (`Invariants.HUB_REGION_ID`) e saída. |

---

## 4. Integração Dinâmica com Sistemas de Jogo

Nenhuma tela utiliza dados fictícios ou textos codificados estaticamente nos nós visuais:
- **Inventário e Equipamentos:** Consultam diretamente `InventoryManager`, `CharacterManager` e os 21 recursos canônicos de `EquipmentData` (`EQ-001` a `EQ-021`).
- **Pactos Abissais:** Consultam `PactCatalog` (`PACT-001` a `PACT-005`), gerenciam o vínculo em `CharacterData.active_pact_id` e a progressão em `CharacterData.pact_tiers`.
- **Códice e Bestiário:** Consultam dinamicamente `DemonsManager` (200 demônios), `BossManager` (30 chefes), `RaceManager` (40 raças, 80 sub-raças), `ClassManager` (80 classes), `WorldManager` (4 continentes, 40 regiões) e `CodexLore` (entradas históricas e facções canônicas).
- **Missões:** Consultam `QuestManager` com suporte a 5 categorias via `quests_of_category()` e sincronização com `QuestLogData`.
- **Mapas:** Consultam `WorldManager.get_region_markers()` e as geometrias de exploração de `ModularRegion`.
- **Grupo:** Consulta `MultiplayerManager.participants()` e metadados de jogadores em rede.
