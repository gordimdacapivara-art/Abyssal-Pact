# Abyssal Pact — Arquitetura Implementada

## Estado deste documento

| Item | Estado |
|---|---|
| Escopo | Arquitetura central implementada (interfaces, dados, comunicação e testes). Sistemas completos de gameplay NÃO estão implementados — ver Pendências ao final. |
| Validação | Suíte de testes de arquitetura: **11 suítes, 343 checks, 0 falhas** (`Godot 4.7.2 --headless`, código de saída 0). |
| Fontes | Os 12 documentos da Fase 0 na raiz; decisões confirmadas no briefing fundador. |

## Visão geral das camadas

```
autoloads (7)          serviços (8, filhos do Game)      dados                    cenas                    testes
EventBus  ─ sinais     World      Character              data/models/*.gd         scenes/boot              tests/test_host.gd
Scenes (SceneManager)  Race       Class                  (Resources,              scenes/world/hub_*       tests/test_case.gd
UI (UIManager)         Demons     Bosses                  to_dict/from_dict)      scenes/ui/screens/*      tests/suites/* (11)
Audio (AudioManager)   Inventory  Quests                 data/content/**/*.tres                            tests/run_tests.tscn
Net (MultiplayerManager)
Save (SaveManager)
Game (GameManager) ── compõe e orquestra tudo acima via SystemRegistry
core/ ── event_bus.gd · system_registry.gd · system_names.gd · invariants.gd · game_states.gd · manager_base.gd
```

Regra de autoload mínimo: apenas 7 autoloads. Os 8 serviços de domínio são instanciados
e registrados pelo GameManager como filhos — não são autoload.

## Composição dos sistemas

| Sistema | Camada | Chave (`SystemNames`) | Responsabilidade | Salva? |
|---|---|---|---|---|
| GameManager | autoload `Game` | `Game` | Boot (ordem, registro, verificação), máquina de estados global, invariantes de produto | Não (estado global pendente) |
| SceneManager | autoload `Scenes` | `Scenes` | Transição de cena + entrega de `setup(params)` | Não |
| UIManager | autoload `UI` (cena) | `UI` | Camadas de UI persistentes (Screens/Overlay/Hud) + router de telas | Não |
| AudioManager | autoload `Audio` (cena) | `Audio` | Buses Music/SFX/UI + players persistentes; pedidos por id | Não |
| MultiplayerManager | autoload `Net` | `Net` | Sessões privadas (transporte provisório ENet), roster ≤ 8, código de convite (não validado) | Não |
| SaveManager | autoload `Save` | `Save` | Persistência por slot em `user://saves/` (JSON versionado) | Não |
| WorldManager | serviço | `World` | Catálogos de continentes/regiões + sessão do mundo privado + ressurgimento → Hell Forge | Sim |
| CharacterManager | serviço | `Character` | Perfis, seleção, progressão mínima, log de descobertas | Sim |
| RaceManager | serviço | `Race` | Catálogo de raças/sub-raças + vínculo sub-raça→raça | Não (conteúdo) |
| ClassManager | serviço | `Class` | Catálogo de classes/habilidades + vínculos | Não (conteúdo) |
| DemonManager | serviço | `Demons` | Catálogo regional (DEMON-*, sem chefes), descobertas (delega a Character), pedido de spawn (stub) | Não (conteúdo) |
| BossManager | serviço | `Bosses` | Catálogo de chefes (BOSS-*) + início/fim de encontro (stub, cap 8) | Não (conteúdo) |
| InventoryManager | serviço | `Inventory` | Catálogo de itens + inventários/loadouts por personagem | Sim |
| QuestManager | serviço | `Quests` | Catálogo de missões + diário por personagem (aceitar/progredir/concluir/abandonar) | Sim |

## Regras de dependência e comunicação

1. **Zero dependência circular de classes.** Gerenciadores nunca se tipam entre si:
   resolvem outros sistemas por `get_system(SystemNames.X)` (service locator
   `core/system_registry.gd`, chaves em `core/system_names.gd`).
2. **EventBus para domínio cruzado.** Eventos que interessam a mais de um domínio são
   emitidos no autoload `EventBus` (`core/event_bus.gd`, apenas sinais — sem estado/lógica).
   Sinais locais de um gerenciador existem somente para ouvintes diretos.
3. **Registro unilateral.** Somente o GameManager registra sistemas (`register()`), uma
   única vez no boot. Leituras (`get_system`/`has_system`) nunca criam sistemas.
4. **Dados separados de lógica.** Dados configuráveis são `Resource` em `data/`; lógica
   vive nos gerenciadores; estado serializável vive em modelos de dados com
   `to_dict()/from_dict()`.
5. **Cenas reutilizáveis com contratos.** Telas implementam `ScreenBase`
   (`open(params)`/`close()`); cenas de mundo expõem `setup(params)`.

## Ordem de boot (`Game._ready()` → `boot()`)

1. `EventBus.boot_started`.
2. Criação do `SystemRegistry` e registro dos 6 autoloads de infraestrutura
   (Game registra a si mesmo; EventBus é público por definição).
3. Instanciação e registro dos 8 serviços (scripts `managers/*.gd`).
4. `initialize()` do próprio Game, depois de cada sistema em `SystemNames.INIT_ORDER`
   (Scenes → UI → Audio → Race → Class → Demons → Bosses → Inventory → Quests →
   Character → World → Net → Save; **Game não está na lista**: o orquestrador
   inicializa a si mesmo antes).
5. `post_initialize()` de cada sistema (integrações que exigem todos vivos).
6. `verify_all()` + `_verify_product_invariants()` (limite de 8, Hell Forge,
   sobreposição DEMON-/BOSS-).
7. Estado → `MENU` (UIManager abre a tela principal), `connect_state_watchers()`,
   `EventBus.boot_completed(sucesso)`.

## Ciclo de vida dos gerenciadores (`core/manager_base.gd`)

`setup(registry)` → `initialize()` → `post_initialize()` → `verify()` (retorna
`PackedStringArray`; vazio = ok) → `collect_save_data()/apply_save_data()`.

Observações de GDScript 4.7 registradas durante a implementação: constantes não são
sobrescritíveis (cada gerenciador declara seu `const KEY` e sobrescreve
`system_key()`); `Object.get_class()` não pode ser sobrescrito; o enum `Error` não
possui `ERR_NOT_FOUND` (usar `ERR_DOES_NOT_EXIST`); inferência `:=` de valores
`Variant` é erro (`inference_on_variant`) — anotar tipos explícitos.

## Contrato de salvamento

- Cada gerenciador decide se participa: `collect_save_data()` retorna `{}` quando não
  participa. Categorias cobertas: **mundo privado** (World), **personagens +
  seleção + progressão + descobertas** (Character), **equipamentos + inventário**
  (Inventory), **missões** (Quests).
- `Save.save_slot(n)` monta o snapshot, valida que é JSON-safe, grava
  `user://saves/slot_n.json`; `Save.load_slot(n)` aplica cada contribuição via
  `apply_save_data()` (implementações limpam o estado antigo antes — idempotentes).
- Formato: `format: "abyssal_pact_save"`, `format_version: 1` (`Invariants`),
  `slot`, `saved_at`, `contributions: { system_key: payload }`.
- Sinais: `save_started/completed/failed`, `load_started/completed/failed`.

## Invariantes de produto (`core/invariants.gd`)

| Invariante | Valor | Fonte |
|---|---|---|
| `MAX_PARTICIPANTS` | 8, anfitrião incluído (cliente ENet: máx. 7 conexões) | PROJECT_OVERVIEW / GAMEPLAY_SYSTEMS |
| `HUB_REGION_ID` | `hell_forge` — destino OBRIGATÓRIO de ressurgimento | HELL_FORGE |
| `DEMON_ID_PREFIX` / `BOSS_ID_PREFIX` | `DEMON-` / `BOSS-` — categorias sem sobreposição (verificado no boot) | PROJECT_OVERVIEW / BOSS_CATALOG |
| `REGION_ID_PREFIX` | `REG-` (REG-001..REG-040) | CONTINENTS_AND_REGIONS |
| `RACE_ID_PREFIX` / `SUBRACE_ID_PREFIX` | `RACE-` (40) / `SUBRACE-` (80) | RACES_AND_SUBRACES |
| `CLASS_ID_PREFIX` | `CLASS-` (80) | CLASSES |
| `SAVE_FORMAT_ID` / `SAVE_FORMAT_VERSION` | `abyssal_pact_save` / 1 | este documento |

IDs editoriais (RACE-001, DEMON-001…) são placeholders de capacidade — não são nomes
de lore e não devem ser renomeados sem decisão de design.

## Camada de dados

- `data/models/*.gd` — classes `Resource` com `to_dict()/from_dict()`: Continent, Region,
  Race, Subrace, Class, Ability, Demon, Boss, Equipment, Quest, Pact (estrutura pronta,
  sem gerenciador — design pendente) e estado de execução: Character, Progression,
  DiscoveryLog, Inventory(+Slot), EquipmentLoadout, WorldSession, QuestLog(+Entry).
- `data/content/**` — placeholders `.tres` carregados por catálogo: 4 continentes
  canônicos (Veyrath, Sylvaran, Khar-Duum, Nhal'Kora) + 1 registro por categoria.
  Catálogos emitem `catalog_loaded` / `catalog_invalid`.
- **Classes: 80 registros** (`class_001..080.tres`) nos 8 grupos editoriais
  (`CLASS-GROUP-01..08`, nomes pendentes). Protótipo funcional completo:
  CLASS-001 "Arcanista" (atributos, 2 ativas + 2 passivas, árvore, progressão).
  As demais 79 são estruturais, com `pending_fields` declarados.

## Sistema de classes (data-driven, protótipo Arcanista)

Nenhuma classe tem código próprio: tudo vem de `ClassData`/`AbilityData`
(`data/models/`). Papéis:

| Arquivo | Responsabilidade |
|---|---|
| `managers/class_manager.gd` | Catálogo 80/8 grupos, validação estrutural (ids contíguos, grupos de 10, protótipo completo), árvores/desbloqueios por nível e regras de equipamento (`can_equip`: pertence à classe, tipo casa com o slot, desbloqueado) |
| `data/models/class_data.gd` | Grupo, identidade, atributos iniciais, ativas/passivas, especializações (pendentes), árvore, progressão, desbloqueios, `pending_fields` (honestidade do catálogo) |
| `data/models/ability_data.gd` | kind (active/special/passive), cooldown, custo+recurso, dano+tipo, alcance, modo de alvo, animação (pendente), VFX, efeitos de passiva, `pending` |
| `player/player_class_component.gd` | Camada de cena: vincula classe do catálogo, aplica atributos ao Combatant, equipa em slots (2 ativas + 1 passiva) e executa casts — cooldowns, custos, sinais no EventBus, área de impacto |
| `combat/combatant.gd` | Vida/recurso/resistências/morte (subconjunto mínimo de combate; sistema completo é o próximo passo) |
| `combat/ability_burst.gd` | Área de impacto gerada da AbilityData (VFX placeholder neutro) |
| `combat/training_dummy.tscn` | Alvo provisório: hurtbox + resistência de prova + morte/ressurgimento |
| `scenes/testing/class_playtest.tscn` | Playtest: Arcanista vinculado, HUD (atributos/loadout/cooldowns/recurso/eventos), teclas 1/2 cast, R troca especial, P troca passiva, T mata o alvo |

Sinais novos no EventBus: `ability_cast_started/failed/resolved`,
`target_damaged`, `target_died`, `class_loadout_changed`.
Validação: `suite_classes` (160 checks) + atualizações em `suite_catalogs`.

## Sistema racial (data-driven, protótipo visual RACE-001)

40 raças + 80 sub-raças (2 por raça — decisão registrada em
`RACES_AND_SUBRACES.md`), sem código por raça e sem lore inventada.

| Arquivo | Responsabilidade |
|---|---|
| `managers/race_manager.gd` | Catálogo 40/80 (ids contíguos, 2 sub-raças por raça, links bidirecionais), `visual_profile_of()` (mescla raça + overrides da sub-raça, sem mutação), `animation_extras_of()`, `can_use_class()` (compatibilidade via ClassManager), `completeness_report()` |
| `data/models/race_data.gd` | `visual_profile` (body_type humanoid_shared/specialized, model_glb, tintas, acessórios, escala, special_structures), `animation_extras` (pendente), `compatible_class_groups` (vazio = compatível com todas), `racial_attributes` (não presumidos), `pending_fields` |
| `data/models/subrace_data.gd` | `visual_overrides` (diferenças sobre a raça-mãe), `animation_extras`, `is_prototype` |
| `race/race_visual_builder.gd` | Construtor visual modular: esqueleto COMPARTILHADO `char_ref_humanoid.glb` + peças PROVISÓRIAS via BoneAttachment3D (horn/antler/antenna/crystal→head, tail→root, wing→chest); tintas por material duplicado; `body_type != humanoid_shared` → aviso explícito de PROVISÓRIO |
| `scenes/testing/race_playtest.tscn` | Playtest: preview do construtor + HUD (raça/sub-raça, corpo, acessórios, estruturas, compatibilidade, modelo); teclas 1/2 trocam sub-raça, R reconstrói, T alterna o player |

Anatomias incompatíveis com o esqueleto humanoide (quadrúpedes/especiais)
terão rigs próprios (`body_type="specialized"`) — nenhum GLB especializado
existe ainda; recebem aviso e usam o manequim compartilhado como PROVISÓRIO.
Validação: `suite_races` (266 checks).

## Sistema de Bestiário e Chefes (data-driven, 200 regionais + 30 chefes)

200 demônios regionais (50 por continente, 5 por região) + 30 chefes demoníacos
(sem sobreposição com regionais), sem código individual por criatura e sem lore inventada.

| Arquivo | Responsabilidade |
|---|---|
| `managers/demon_manager.gd` | Catálogo dos 200 demônios regionais (`DEMON-001`..`200`), consultas por continente (`count_by_continent`), região e família de combate, representantes das 6 famílias, integração de descobertas com `CharacterManager` e emissão de `demon_spawn_requested` |
| `managers/boss_manager.gd` | Catálogo dos 30 chefes (`BOSS-001`..`030`), ciclo de encontro com limite de participantes (`begin_encounter`/`end_encounter`), consultas por continente/região e emissão de `boss_encounter_started`/`ended` |
| `data/models/demon_data.gd` | `Resource` de criatura regional: id, display_name, description, continent_id, region_id, family (`brute`, `stalker`, `caster`, `swarm`, `flyer`, `sentinel`), category (`regional`), rarity (`common`/`uncommon`/`rare`/`elite`), stats, resistances, ability_ids, rewards, model_path, model_pending (`true`), placeholder_scene, animations, ai |
| `data/models/boss_data.gd` | `Resource` de chefe: narrative_identity (`PENDENTE`), arena (`name`, `radius`, `hazards`), category (`boss`), rarity (`boss`/`boss_elite`/`boss_final`), stats, resistances, special_abilities, phases (3 fases por limiar de vida), phase_count, exclusive_animations, boss_ui, entrance cinematográfica, defeat_conditions, rewards especiais |
| `enemies/creature.gd` / `enemies/creature.tscn` | Cena e componente de criatura compartilhada: leitura de dados (`setup`), silhueta provisória dimensionada por família, hurtbox (layer 8), combatant com vida/resistências, animação de dano, morte/respawn configurável e emissão de sinais |
| `enemies/boss.gd` / `enemies/boss.tscn` | Chefe demoníaco (herda de `Creature`): controle de início de combate pós-entrada cinematográfica, transição automática de 3 fases ao atingir limiares de vida e fluxo exclusivo de derrota sem respawn |
| `enemies/creature_ai.gd` | IA desacoplada data-driven compartilhada: máquina de estados (`idle`, `chase`, `attack`, `return`, `death`), leitura de parâmetros (`aggro_radius`, `deaggro_radius`, `attack_range`, `chase_speed`, `attack_cooldown`) e aplicação de dano no Combatant do alvo |
| `enemies/boss_encounter.gd` / `enemies/boss_encounter.tscn` | Orquestrador de encontro de chefe: coordena BossManager, temporização da entrada cinematográfica, combate em fases, HUD de chefe, concessão de recompensas e encerramento |
| `enemies/boss_ui.gd` / `enemies/boss_ui.tscn` | Interface de chefe orientada a dados: barra de vida com cores por fase, marcadores, nome e barra de conjuração |
| `scenes/testing/creature_arena.tscn` | Arena de playtest: 6 famílias ativas simultâneas, chefe com ciclo de 3 fases, HUD com estado em tempo real e atalhos de teste (1/2 habilidades, F dano, K abate) |

Validação: `suite_bestiary` (367 checks cobrindo os 200 demônios, 30 chefes, runtime das 6 famílias, IA e encontro de chefe).

## Cenas reutilizáveis

- `scenes/boot/boot.tscn` — primeira cena; apenas reporta o resultado do boot.
- `scenes/ui/screens/main_menu_screen.tscn` — placeholder arquitetural
  (contrato `ScreenBase`; emite `ui_action_requested`, sem fluxo implementado).
- `scenes/world/hub_placeholder.tscn` — Hell Forge placeholder (contrato `setup(params)`,
  `spawn_point()`); destino concreto da regra de ressurgimento.
- `player/player.tscn` — controlador do personagem em 3ª pessoa (cena
  reutilizável; ver seção própria abaixo). Modelo visual PROVISÓRIO (cápsula)
  substituído automaticamente pelo GLB do pipeline (auto-attach).
- `scenes/testing/movement_playtest.tscn` — playground neutro (sem lore) para
  testes manuais do controlador: parede, degraus/plataforma, pilar, bloco de
  colisão de câmera, interativo de prova (TEST-INT-001) e HUD de estados.
- `enemies/creature.tscn` — criatura demoníaca reutilizável compartilhada pelas
  6 famílias regionais (brute/stalker/caster/swarm/flyer/sentinel); lê DemonData,
  possui Hurtbox (camada 8), Combatant e visual placeholder claramente identificado.
- `enemies/boss.tscn` — chefe demoníaco reutilizável (herda de Creature); transição
  de 3 fases por limiares de vida em dados e controle de hurtbox pós-cinemática.
- `enemies/boss_encounter.tscn` — orquestrador de ciclo de encontro de chefe: registro
  em BossManager, entrada cinematográfica com temporização, combate em fases, UI
  dedicada, concessão de recompensas e encerramento.
- `enemies/boss_ui.tscn` — interface de chefe com barra de vida segmentada,
  marcadores de fase e barra de conjuração orientada a dados.
- `scenes/testing/creature_arena.tscn` — arena de validação interativa com as
  6 famílias simultâneas, ciclo de chefe, HUD de estado e controles de teste.
- `autoload/ui_manager.tscn` / `autoload/audio_manager.tscn` — camadas persistentes.

## Sistema de Mundo Aberto (4 Continentes, 40 Regiões, REG-001 Veyrath)

Arquitetura data-driven desacoplada de streaming e modularidade regional: nenhum
continente é instanciado em uma única cena gigantesca; cada região é carregada sob demanda.

| Arquivo / Componente | Responsabilidade |
|---|---|
| `managers/world_manager.gd` | Catálogos de continentes (4) e regiões (40; 10 por continente), `load_region()`, `transition_to_region()`, `discover_region()`, `discover_poi()`, `activate_portal()`, `get_region_markers()`, coleta e aplicação de save (`WorldSessionData`) |
| `data/models/continent_data.gd` | Recurso de continente: capital, clima, tema visual, 10 regiões vinculadas, registro de assets pendentes |
| `data/models/region_data.gd` | Recurso de região: bioma, nível, conexões geográficas, limites, iluminação, POIs, portões, portais, 5 zonas de inimigos regionais, arena de chefe, cena associada e assets pendentes |
| `scenes/world/regions/region_001.tscn` | Cena de produção dedicada para Veyrath (`REG-001`): terreno cinzento, fenda de lava ativa, Baluarte das Cinzas (cidade + SafeZone), Catacumbas de Basalto (masmorra), Arena do Vazio Vulcânico (`BOSS-001`), GateNorth (`REG-002`), GateSouth (`REG-003`), Portal para Hell Forge e spawners dos demônios `DEMON-001..005` |
| `scenes/world/modular_region.tscn` | Cena modular reutilizável para o staging dinâmico das outras 39 regiões: constrói terreno, paletas por continente, iluminação, limites, portões, portais, POIs e áreas de inimigos/chefes com base no `RegionData` |
| `scenes/world/components/*` | Componentes 3D compartilhados: `region_gate.gd` (transições), `world_portal.gd` (teleporte), `world_boundary.gd` (limites perimetrais), `point_of_interest.gd` (POIs com XP), `safe_zone.gd` (cidades seguras), `dungeon_entrance.gd` (masmorras), `boss_arena_zone.gd` (arena circular de chefe), `exploration_spot.gd` (monólitos e mirantes), `enemy_spawner_zone.gd` (spawners de demônios do DemonManager) |
| `tests/suites/suite_open_world.gd` | Suíte com 1.140 verificações abrangendo continentes, regiões, transições, limites, POIs, masmorras, chefes, exploração e persistência de save |

## Camada de Interface e Sistemas Complementares (UI)

A interface de usuário de **ABYSSAL PACT** é regida pela identidade estética **Dark Fantasy** e arquitetada sobre o router persistente do `UIManager` (`autoload/ui_manager.gd`), com preloading estático de todas as 16 telas canônicas e criação de personagem. Os dados apresentados fluem exclusivamente dos sistemas de jogo e catálogos vivos, sem mockups estáticos de texto.

| Módulo / Componente | Localização | Responsabilidade |
|---|---|---|
| `DarkFantasyTheme` | `scenes/ui/theme/dark_fantasy_theme.gd` | Definição programática do tema visual: superfícies de pedra vulcânica, bordas metálicas envelhecidas e dourado pálido, botões rúnicos e contraste balanceado. |
| `DarkFantasyHeader` | `scenes/ui/components/dark_fantasy_header.gd` | Cabeçalho compartilhado com runas `❖ TITULO ❖`, subtítulo e botão fechar (`close_requested`). |
| `DarkFantasyNavBar` | `scenes/ui/components/dark_fantasy_nav_bar.gd` | Barra horizontal de abas para navegação entre categorias e subsistemas. |
| `ItemSlotUI` | `scenes/ui/components/item_slot_ui.gd` | Célula de inventário com bordas por raridade (`common`, `uncommon`, `rare`, `epic`, `legendary`), badge de quantidade e seleção. |
| `StatComparisonCard` | `scenes/ui/components/stat_comparison_card.gd` | Comparador dinâmico de atributos entre item equipado e candidato com indicadores coloridos de delta (+/-). |
| `PactCatalog` | `core/pact_catalog.gd` | Catálogo e provedor estático dos 5 Pactos Abissais canônicos (`PACT-001..005`). |
| `CodexLore` | `data/content/lore/codex_lore.gd` | Provedor canônico dos registros de História Antiga e Facções do mundo. |
| 16 Telas Canônicas | `scenes/ui/screens/*` | Telas: `main_menu`, `create_world`, `join_world`, `inventory`, `equipment`, `abilities`, `class_tree`, `pacts`, `world_map`, `regional_map`, `codex`, `bestiary`, `quests`, `party`, `settings`, `pause_menu`. |

## Camada de cena — controlador do personagem (`player/`)

Cena de gameplay, NÃO é gerenciador: não se registra no SystemRegistry e NÃO
emite eventos de domínio cruzado. Comunicação com o resto do jogo por sinais
LOCAIS (`movement_state_changed`, `dodged`, `landed`, `interaction_target_changed`);
quando interação tocar missões/itens/descobertas, quem emitir no EventBus será
o sistema de domínio acionado pelo objeto interativo.

| Arquivo | Responsabilidade |
|---|---|
| `player_controller.gd` | CharacterBody3D: máquina de estados (IDLE/WALK/RUN/SPRINT/RISE/FALL/LAND/DODGE), movimento relativo à câmera, salto com buffer+coyote, gravidade assimétrica, esquiva com cooldown, aterrissagem com trava curta, rotação suave, interação |
| `player_camera_rig.gd` | Órbita (mouse/gamepad) com pitch clampado, colisão via SpringArm3D, distância por roda do mouse + API (`set_distance`), exclusão do próprio corpo |
| `interaction_sensor.gd` | Varre a camada 2 (interativos), elege o mais próximo, expõe prompt e executa `interact(player)` |
| `player_interactable.gd` | Contrato dos objetos interativos (camada de colisão 2; sobrescrever `interact`) |
| `player_animator.gd` | Driver de animação: contrato de nomes de clipes (idle/walk/run/sprint/jump/fall/land/dodge); com modelo GLB anexado, opera AnimationTree PADRÃO do pipeline (prioridade sobre o contrato estático da cena); sem clipes, avisa uma vez e não quebra |
| `animation_tree_builder.gd` | Construtor runtime da AnimationTree padrão sobre a biblioteca do AnimationPlayer do GLB (biblioteca compartilhada): máquina de estados all-pairs IMMEDIATE (xfade 0,18 s) + auto-loop AT_END (0,12 s) em idle/walk/run/sprint/fall; API estática `start/travel/current_node/has_state` |
| `player_model_loader.gd` | Anexa GLB do pipeline ao `ModelRoot` do player, oculta o placeholder e liga o animator ao mixer importado |
| `input_map.gd` | Nomes canônicos das ações, validação do InputMap e remapeamento em runtime |
| `movement_states.gd` | Enum de estados + classificadores (ar/chão/locomoção) |

Ações de entrada (project.godot → `[input]`, remapeáveis no editor):
`move_forward/back/left/right` (WASD + analógico), `jump` (Espaço/A),
`sprint` (Shift/L3), `dodge` (Ctrl/X), `interact` (E/Y), `camera_left/right/up/down`
(alavanca direita). Mouse: olhar e zoom da roda são eventos brutos do rig
(exceção documentada — o menu de opções futuro pode expor `set_distance`).

Regras de velocidade: WASD = caminhada; Shift = corrida; Shift mantido em
movimento por `sprint_hold_time` = sprint (auto-sprint). Esquiva apenas no
chão (decisão provisória). `land_impact_threshold` separa degraus pequenos
(sem trava) de aterrissagens reais (trava curta + sinal `landed`).

## Testes de arquitetura

Execução (console, fora do editor):

```
Godot_v4.7.2_console.exe --headless --path "<projeto>" res://tests/run_tests.tscn
```

Códigos de saída: `0` = passou; `1` = falhas; `2` = watchdog (suíte travada).
O TestHost é anexado direto à root (sobrevive a trocas de cena) e exige ≥ 40 checks.

| Suíte | O que valida |
|---|---|
| `suite_core` | EventBus (conexão/emit), SystemRegistry (registro/duplicatas/chaves), invariantes e INIT_ORDER |
| `suite_boot` | Boot completo, 14 sistemas registrados, serviços como filhos do Game, `verify_all()` limpo |
| `suite_catalogs` | Raças/sub-raças/vínculo, classes/habilidades, demônios sem chefes, encontros (cap 8), continentes canônicos |
| `suite_character` | Criação validada por catálogo, recusas, seleção, progressão, descobertas, exclusão — com sinais |
| `suite_inventory` | Inventário sob demanda, adicionar/remover (guarda de estoque), equipar/desequipar com sinais |
| `suite_world` | Mundo privado, roster 8 (anfitrião incluído) com recusa do 9º, região corrente, ressurgimento → Hell Forge |
| `suite_quest` | Aceitar (duplicidade), abandono, progresso clampado, conclusão, guardas de objetivo |
| `suite_save` | Ciclo ponto a ponto entre 4 gerenciadores: coleta → JSON → mutação → carga restauradora; falhas documentadas |
| `suite_scene_ui` | Transição de cena + `setup(params)`; router de telas (abrir/fechar/registro) com sinais |
| `suite_net` | Invariantes de rede, roster via gancho de teste, hospedagem ENet real (loopback), recusas, saída encerrando o mundo espelhado |
| `suite_integration` | Cadeia completa: personagem → mundo → missão → itens → ressurgimento → save → limpeza, com sinais em cada etapa |
| `suite_player` | Controlador do personagem com física real (headless): mapa de entrada, contratos da cena, caminhada/corrida/sprint, salto/queda/aterrissagem, esquiva+cooldown, colisão de corpo, órbita/clampes/zoom/colisão de câmera, ciclo de interação e contrato do driver de animação (com modelo do pipeline anexado) |
| `suite_models` | Pipeline GLB: política .blend (zero fontes no repositório), auditoria completa do modelo de referência (orçamentos, esqueleto, clipes, escala) e unit tests do AnimationTreeBuilder (has_state/start/travel/current_node, auto-loop, recusa de estado inexistente) |
| `suite_classes` | Catálogo das 80 classes (ids contíguos, 8 grupos de 10), protótipo Arcanista (atributos, ativas/passivas, árvore, progressão), regras de equipar (slots/tipo/desbloqueio), runtime (cooldowns, recurso, sinais) e impacto no alvo de treino (dano + resistência + morte) |
| `suite_races` | Catálogo 40 raças / 80 sub-raças (2 por raça, links bidirecionais), protótipo RACE-001 (perfil visual, diferenças das 2 sub-raças, atributos não presumidos), compatibilidade com classes e RaceVisualBuilder (esqueleto compartilhado, ossos do contrato, peças PROVISÓRIAS nomeadas, recusa de vínculo inválido) |
| `suite_bestiary` | Catálogo completo dos 230 demônios: 200 regionais (50 por continente, 5 por região), 30 chefes (sem sobreposição, fases 1..3, arena, UI, entrada, recompensas), runtime das 6 famílias via cena compartilhada, IA data-driven com aggro/ataque e ciclo completo de encontro de chefe |
| `suite_open_world` | Mundo aberto completo: 4 continentes, 40 regiões (exatamente 10 por continente), validação de identidades, biomas, conexões e POIs; runtime da região piloto REG-001 Veyrath e do carregador modular das outras 39 regiões; limites geográficos, portões de transição, portais arcanos, cidades seguras, masmorras, arenas de chefes e persistência do progresso de exploração no save |
| `suite_ui_systems` | Interfaces e sistemas complementares: registro dos 16 menus/telas Dark Fantasy no router do UIManager, 5 categorias de inventário e uso de consumíveis, equipamentos com doll 3D e StatComparisonCard, habilidades e árvore de classes, pactos abissais e evolução até Grau 5, códice com 9 categorias canônicas, bestiário com filtragem continental e chefes, missões nas 5 categorias, marcadores de mapa e menu de pausa com retorno à Hell Forge |

Padrão de captura de sinais: como Godot 4.7 exige `await` na chamada de corrotinas, as
suítes usam **captura síncrona** — `capture(EventBus.sinal)` conecta um recorder ANTES da
ação; como os eventos são emitidos na mesma pilha, os argumentos são lidos depois com
`captura.first()` (Array de argumentos; `[0]` para sinais de 1 argumento) ou
`captura.count()`. Para eventos assíncronos (conclusão de transição de cena), a suíte
aguarda frames com `await wait_frames(n)` antes de ler a captura.

## Decisões provisórias e pendências (não implementar sem decisão)

- **Transporte de rede:** ENetMultiplayerPeer é PROVISÓRIO, isolado nas fábricas
  `_create_server_peer/_create_client_peer` do MultiplayerManager.
- **Código de convite:** gerado (`AP-XXXX`) e aceito, mas NÃO validado.
- **Modelo do personagem:** cápsula provisória em `player/player.tscn`,
  substituída em runtime pelo GLB do pipeline (auto-attach via
  `PlayerModelLoader`; placeholder oculto quando o modelo entra). Fonte
  `.blend` FORA do repositório; ver `MODEL_PIPELINE.md`.
- **Pipelines GLB/Blender de demônios e chefes:** campos `model_path` seguem
  convenção provisória (`res://assets/models/{demons,bosses}/<id>.glb`); nenhum
  modelo GLB de criatura existe ainda no repositório (`model_pending = true` em
  todos os 230 registros). As cenas de criatura e chefe usam placeholders
  identificados (`is_placeholder() == true`).
- **Navegação avançada e patrulha de IA:** IA implementa máquina de estados
  `idle`, `chase`, `attack`, `return` e `death`; navmesh e desvio de obstáculos
  continuam pendentes de design e biomas aprovados.
- **Consumo de itens ao equipar:** não consome (decisão pendente).
- **Sinal de "sem estoque":** retorna `FAILED` (não há código no enum `Error`).
- **Mundos simultâneos por processo:** um por instância (host dedicado pendente).
- **Estado global de save (idioma, opções):** não persistido ainda.
- **UI/áudio canônicos:** telas e streams atuais são placeholders.
- **Esquiva apenas no chão / auto-sprint por Shift mantido:** decisões de
  gameplay provisórias do controlador (parâmetros exportados, ajustáveis).
- **Zoom da câmera por roda do mouse:** evento bruto no rig (não é ação do
  InputMap); remapeamento futuro via menu de opções/API `set_distance`.
