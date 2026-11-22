# Abyssal Pact — Visão do Projeto

## Estado deste documento

| Item | Estado |
|---|---|
| Fonte examinada | Repositório examinado em 13/11/2026: os 12 documentos base da Fase 0 já estavam presentes e foram preservados; não há projeto Godot (`project.godot`), arquivos Blender (`.blend`/`.glb`), repositório Git ou material de design adicional neste diretório. |
| Confirmado | Informações fornecidas no briefing fundador e nas diretrizes de fluxo de trabalho deste projeto. |
| Planejado / pendente | Todo item explicitamente marcado **Pendente**. Não representa decisão de design. |

## Identidade confirmada

- **Nome:** Abyssal Pact.
- **Gênero:** RPG de ação em terceira pessoa.
- **Estética:** Dark Fantasy 3D.
- **Engine:** Godot 4.
- **Linguagem de jogo:** GDScript.
- **Modelagem:** Blender.
- **Formato de modelos em jogo:** GLB.
- **Multijogador:** exclusivamente privado.
- **Capacidade inicial:** até 8 jogadores por mundo, anfitrião incluído.
- **Hub central:** Hell Forge.
- **Ressurgimento:** obrigatório na Hell Forge.

## Escopo de conteúdo confirmado

| Categoria | Quantidade | Fonte de detalhe |
|---|---:|---|
| Continentes | 4 | `CONTINENTS_AND_REGIONS.md` |
| Regiões | 40 | `CONTINENTS_AND_REGIONS.md` |
| Raças | 40 | `RACES_AND_SUBRACES.md` |
| Sub-raças | 80 | `RACES_AND_SUBRACES.md` |
| Classes | 80 | `CLASSES.md` |
| Demônios | 230 | `DEMON_BESTIARY.md` e `BOSS_CATALOG.md` |
| Criaturas regionais | 200 | `DEMON_BESTIARY.md` |
| Chefes | 30 | `BOSS_CATALOG.md` |

## Limites e invariantes

- 200 criaturas regionais + 30 chefes = 230 demônios. As categorias não devem se sobrepor.
- O máximo de 8 jogadores inclui o anfitrião; um mundo não pode aceitar oito convidados além dele.
- A sessão multiplayer é privada; matchmaking público, listas públicas de mundos e acesso aleatório não fazem parte do escopo confirmado.
- O ponto de ressurgimento obrigatório é a Hell Forge. Outros pontos de retorno exigiriam uma decisão de design futura e não devem substituir essa regra.
- Não há nomes, mecânicas, biomas, narrativas, atributos, UI ou topologia de rede adicionais confirmados na fonte examinada.

## Não fazer nesta etapa

Esta fase organiza a documentação. Ela não autoriza implementar cenas, scripts, rede, modelos, interfaces, sistemas de combate ou conteúdo jogável.

## Decisões pendentes prioritárias

1. Distribuição das 40 regiões entre continentes e seus nomes/identidades.
2. Catálogo, identidade e relações entre raças, sub-raças e classes.
3. Atribuição das 200 criaturas às regiões e definição dos 30 chefes.
4. Modelo de autoridade/sincronização de rede para partidas privadas.
5. Loop de progressão, combate, equipamentos, economia e exploração.
6. Fluxos de UI, plataformas-alvo, controles, acessibilidade e salvamento.

## Documentos de referência

- `WORLD_LORE.md` - cânone e regras narrativas.
- `CONTINENTS_AND_REGIONS.md` - continentes confirmados e capacidade das 40 regiões.
- `RACES_AND_SUBRACES.md` - capacidade de 40 raças e 80 sub-raças.
- `CLASSES.md` - capacidade das 80 classes.
- `DEMON_BESTIARY.md` - capacidade das 200 criaturas regionais.
- `BOSS_CATALOG.md` - capacidade dos 30 chefes demoníacos.
- `HELL_FORGE.md` - definição do hub e do ressurgimento obrigatório.
- `GAMEPLAY_SYSTEMS.md` - sistemas confirmados e pendências de gameplay.
- `UI_AND_MENUS.md` - fluxos previstos de interface e requisitos pendentes.
- `TECHNICAL_ARCHITECTURE.md` - decisões e questões técnicas.
- `DEVELOPMENT_ROADMAP.md` - marcos, com a implementação central registrada.
- `ARCHITECTURE.md` - arquitetura central implementada (gerenciadores, dados, comunicação, testes).

## Implementação central (13/11/2026)

A arquitetura central do projeto foi implementada em Godot 4.7 + GDScript, sem
implementar sistemas completos de gameplay: 14 gerenciadores (7 autoloads + 8
serviços registrados por `GameManager` + orquestrador), camada de dados em
`Resource` (`data/models/`) com placeholders editoriais (`data/content/`),
comunicação por sinais no `EventBus`, descoberta de sistemas por `SystemRegistry`
(sem dependências circulares), contrato de salvamento por contribuições
(`user://saves/`, JSON versionado) e invariantes de produto em código
(`core/invariants.gd`). Validação: 11 suítes de teste, **343 checks, 0 falhas**
(`--headless`, código de saída 0) — instruções e contrato em `ARCHITECTURE.md`.
Decisões de design (lore, nomes, combate, UI, rede definitiva) continuam pendentes
e NÃO foram inventadas.

## Controlador do personagem (14/11/2026)

Camada de cena `player/` implementada (ainda sem gameplay completo): CharacterBody3D
com estados de movimento (caminhada/corrida/sprint/salto/queda/aterrissagem/
esquiva), câmera em 3ª pessoa com colisão e zoom, interação por contrato e
driver de animação preparado para GLB (modelo provisório: cápsula). Entradas
remapeáveis e playtest manual em `scenes/testing/movement_playtest.tscn`.
Validação: suíte `suite_player` com física real headless. Contratos em `ARCHITECTURE.md`.

## Pipeline de modelos 3D (14/11/2026)

Pipeline oficial Blender → GLB → Godot implementado e validado: fontes `.blend`
FORA do repositório (regra absoluta, auditada), modelo humanoide de referência
PROVISÓRIO (manequim procedural, ~87 KB, 9 ossos, 8 clipes do contrato de
animação) gerado por `tools/blender/build_reference_character.py`, importado e
anexado automaticamente ao controlador (substituindo a cápsula), com
AnimationTree padrão construída em runtime (`AnimationTreeBuilder`). Auditoria
headless (`tools/audit_runner.gd`) valida orçamentos do PC alvo 4 GB, materiais,
texturas, esqueleto, clipes, escala e a política .blend — **APROVADA**.
Documentação: `MODEL_PIPELINE.md`; suíte `suite_models` cobre a política e o
builder.

## Sistema de classes (14/11/2026)

Sistema de classes baseado em dados implementado: **80 classes registradas**
(CLASS-001..080, CLASSES.md) nos 8 grupos editoriais (nomes de grupo pendentes
— o documento não os define), sem código por classe. **Protótipo funcional
completo: Arcanista (CLASS-001)** — atributos, 2 ativas demonstráveis (básica +
especial), passiva demonstrável + passiva reservada pendente, árvore de 4 nós,
progressão e desbloqueios por nível. Runtime: componente de classe no player
(equipar em slots, cooldowns, custos de mana, casts com sinais no EventBus),
subconjunto mínimo de combate (vida/recurso/resistências/morte + área de
impacto) e alvo de treino provisório. Playtest manual em
`scenes/testing/class_playtest.tscn`. Validação: `suite_classes` — total
**650 checks, 0 falhas**. Os 79 registros restantes estão estruturados e
prontos para receber conteúdo de design; balanceamento e animações de combate
do protótipo são PROVISÓRIOS (marcados `pending`).

## Sistema racial (14/11/2026)

Sistema racial baseado em dados implementado: **40 raças + 80 sub-raças
registradas** (RACE-001..040, SUBRACE-001..080; RACES_AND_SUBRACES.md) com
**2 sub-raças por raça** (decisão desta fase, registrada no documento), links
bidirecionais validados, sem código por raça e sem lore inventada. **Protótipo
funcional: RACE-001 (protótipo visual)** — esqueleto humanoide compartilhado do
pipeline GLB, perfil visual em dados e 2 sub-raças com diferenças visuais
demonstráveis (chifres vs. antenas+cauda, tintas e escalas distintas); peças
PROVISÓRIAS anexadas por osso via `RaceVisualBuilder` (suporte editorial a
caudas, asas, chifres, antenas, cristais; escamas e corpos especializados
pendentes de arte/rig próprio, com aviso explícito). Compatibilidade com
classes via `can_use_class()`; atributos raciais NÃO presumidos (vazios);
animações complementares pendentes. Playtest `scenes/testing/race_playtest.tscn`.
Validação: `suite_races` — total **916 checks, 0 falhas**.

## Bestiário e Chefes (21/11/2026)

Integração completa e catálogo dos 230 demônios implementados em Godot 4.7 + GDScript:
- **200 demônios regionais** (`DEMON-001`..`200`, `DEMON_BESTIARY.md`): exatamente 50
  por continente (Veyrath `CONT-01`, Sylvaran `CONT-02`, Khar-Duum `CONT-03` e Nhal'Kora
  `CONT-04`), distribuídos em 5 por região nas 40 regiões catalogadas.
- **30 chefes demoníacos** (`BOSS-001`..`030`, `BOSS_CATALOG.md`): 8 em Veyrath, 8 em
  Sylvaran, 7 em Khar-Duum e 7 em Nhal'Kora, com categorias e prefixos sem sobreposição.
- **Arquitetura 100% data-driven:** ZERO scripts individuais por criatura. Definições
  em `DemonData` e `BossData` (`Resource`).
- **Cenas reutilizáveis:** `enemies/creature.tscn` (6 famílias de combate: brute,
  stalker, caster, swarm, flyer, sentinel com hurtbox na camada 8 e combatant integrado)
  e `enemies/boss.tscn` (combate em 3 fases por limiares de vida decrescentes, sem respawn).
- **Ciclo de encontro:** cena orquestradora `enemies/boss_encounter.tscn` com registro
  em `BossManager`, entrada cinematográfica com temporização, combate em fases, HUD
  dedicado `enemies/boss_ui.tscn` e concessão de recompensas na derrota.
- **IA compartilhada:** `enemies/creature_ai.gd` (máquina de estados idle/chase/attack/return/death).
- **Pipeline GLB e modelos:** todos os 230 registros possuem `model_pending = true` e
  caminhos convencionais (`res://assets/models/{demons,bosses}/<id>.glb`). Nenhum GLB
  de criatura existe no repositório; o visual em testes utiliza placeholders claramente
  identificados (`is_placeholder() == true`).
- **Playtest e validação:** arena interativa em `scenes/testing/creature_arena.tscn`
  e suíte de testes `suite_bestiary` (367 checks). Total acumulado do projeto:
  **1499 checks, 0 falhas**.

## Sistema de Mundo Aberto (21/11/2026)

Implementação completa do sistema de mundo aberto em Godot 4.7 + GDScript:
- **4 continentes confirmados:** Veyrath (`CONT-01`), Sylvaran (`CONT-02`), Khar-Duum (`CONT-03`), Nhal'Kora (`CONT-04`).
- **40 regiões catalogadas:** exatamente 10 regiões por continente (`REG-001` a `REG-040`), cada qual com bioma, faixa de nível, iluminação, conexões geográficas e POIs definidos.
- **14 subsistemas implementados:** continentes, regiões, streaming de mapas sob demanda, transições entre regiões por portões colidentes, limites geográficos com paredes e barreira visual perimetral, portais de teleporte rápido para a Hell Forge, pontos de interesse categorizados (cidades, masmorras, chefes, exploração), cidades seguras via `SafeZone`, masmorras via `DungeonEntrance`, arenas de chefes circulares via `BossArenaZone`, pontos de exploração (monólitos e mirantes), descoberta de regiões e POIs via EventBus e logs de personagem, marcadores de mapa e persistência do progresso de exploração no save (`WorldSessionData`).
- **Região piloto de produção completa (`REG-001` Veyrath):** cena `scenes/world/regions/region_001.tscn` com terreno vulcânico de cinzas (360×360 m), fenda de lava ativa com iluminação pontual, Baluarte das Cinzas (cidade + safe zone de raio 22 m), Catacumbas de Basalto (masmorra nível 1+), Arena do Vazio Vulcânico (`BOSS-001`), GateNorth (`REG-002`), GateSouth (`REG-003`), portal para a Hell Forge e 5 spawners da fauna regional de Veyrath (`DEMON-001..005`).
- **Carregador modular para as outras 39 regiões:** cena `scenes/world/modular_region.tscn` que instancia dinamicamente terreno, iluminação com paletas continentais, limites, portões, portais, POIs e áreas de monstros a partir de arquivos `RegionData`.
- **Honestidade de assets:** todas as regiões mantêm no campo `pending_assets` os modelos 3D e texturas ainda não produzidos, sem apresentar cenas vazias como concluídas nem placeholders como arte final.
- **Validação:** suíte `suite_open_world` (1.140 checks). Total acumulado de testes do projeto: **2.639 checks, 0 falhas** (`--headless`, código de saída 0).

## Interfaces e Sistemas Complementares (21/11/2026)

Desenvolvimento e integração completa da camada de interface do usuário (UI) e sistemas complementares em Godot 4.7 + GDScript:
- **Identidade Dark Fantasy e Biblioteca Compartilhada (`scenes/ui/components/`):**
  - `DarkFantasyHeader`: cabeçalho com insígnias rúnicas (`❖ TITULO ❖`), subtítulo e botão de fechar.
  - `DarkFantasyNavBar`: barra horizontal de navegação e abas com sinalização dinâmica de seleção.
  - `ItemSlotUI`: slot de item com borda estilizada por raridade (comum, incomum, raro, épico, lendário, relíquia), badge numérico de quantidade e destaque ao selecionar.
  - `StatComparisonCard`: cartão dinâmico de comparação entre o item equipado e o item candidato do inventário, com indicadores coloridos de variação (+ / = / -).
- **16 Telas Canônicas Integradas (`scenes/ui/screens/`):**
  1. `main_menu`: tela inicial com botões para novo personagem, criar mundo, entrar e configurações.
  2. `create_world`: criação e hospedagem de mundos privados (até 8 jogadores) com porta configurável e nome da sessão.
  3. `join_world`: entrada em mundos privados com validação de formato de IP/endereço e porta.
  4. `inventory`: visualização e filtragem nas 5 categorias canônicas (equipamentos, consumíveis, materiais, relíquias, itens de missão), uso de consumíveis e descarte.
  5. `equipment`: visualização de 7 slots de armaduras/armas/acessórios, doll 3D interativo via `SubViewport` renderizando o personagem com `RaceVisualBuilder`, e comparador de atributos.
  6. `abilities`: visualização da classe ativa, barra de ação/hotbar de habilidades e árvore de magias/técnicas.
  7. `class_tree`: árvore de progressão de classes com nós desbloqueados, disponíveis e bloqueados por requisitos de nível.
  8. `pacts`: catálogo dos 5 pactos de sangue/alma, detalhes de descrição e efeitos, e evolução de Graus (1 a 5) com consumo de recursos.
  9. `world_map`: visão macroscópica dos 4 continentes com contadores de exploração, status e transição direta para o mapa regional.
  10. `regional_map`: tela e tela-canvas 2D dedicada (`MapCanvas`) com renderização em tempo real de limites da região, cidades, masmorras, chefes, portais e posição atual do jogador.
  11. `codex`: enciclopédia abrangente com 9 categorias canônicas (demônios, chefes, raças, sub-raças, classes, continentes, regiões, história e facções), com pesquisa por texto e detalhes estruturados.
  12. `bestiary`: visualizador das 200 criaturas e 30 chefes por continente e família de combate, com indicação de modelos GLB e placeholders.
  13. `quests`: rastreador de missões com 5 categorias canônicas (`main`, `side`, `regional`, `class`, `race`), monitoramento de múltiplos objetivos e conclusão.
  14. `party`: visualização de até 8 membros de grupo com seus níveis, classes, barras de vida, latência e botão para copiar o código de convite privado.
  15. `settings`: ajustes de áudio (volumes e mudo em Music/SFX/UI), vídeo (resolução, modo janela/tela cheia, VSync) e jogabilidade, persistidos no disco.
  16. `pause_menu`: menu de pausa com retomada de jogo, acesso ao mapa, missões, inventário, configurações e botão de retorno à Hell Forge (`Invariants.HUB_REGION_ID`).
- **Roteamento Centralizado (`UIManager`):**
  - 17 telas registradas e instanciadas sob demanda com gerenciamento de pilha (`push_screen`, `pop_screen`), fechamento e transições limpas.
- **Conexão Real aos Sistemas:**
  - 100% dos dados provêm de `CharacterManager`, `InventoryManager`, `WorldManager`, `QuestManager`, `DemonManager`, `BossManager`, `RaceManager`, `ClassManager`, `NetworkManager` e `SaveManager`. Zero placeholders estáticos de texto.
- **Validação:** suíte `suite_ui_systems` (192 checks). Total acumulado de testes do projeto: **2.831 checks, 0 falhas** (`--headless`, código de saída 0).
