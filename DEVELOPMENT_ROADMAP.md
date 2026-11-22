# Abyssal Pact — Roadmap de Desenvolvimento

## Estado atual

**Fase 0 — Fundação documental:** concluída com os 12 documentos base, preservados na raiz.

**Fase 2 (parcial) — Arquitetura central implementada (13/11/2026):** sem aprovação da
Fase 1 e conforme o escopo solicitado, a espinha dorsal técnica do projeto foi
implementada em Godot 4.7 + GDScript: 14 gerenciadores com responsabilidades e
verificações próprias, camada de dados em `Resource`, comunicação por sinais
(`EventBus`), descoberta de sistemas por `SystemRegistry` (sem dependências
circulares), contrato de salvamento por contribuições, cenas reutilizáveis com
contratos e 11 suítes de teste (343 checks, 0 falhas, `--headless`, saída 0).
Sistemas completos de gameplay continuam NÃO implementados; ver `ARCHITECTURE.md`.

**Fase 2 (parcial) — Controlador do personagem (14/11/2026):** camada de cena
`player/` implementada em Godot 4.7 + GDScript: CharacterBody3D com máquina de
estados de movimento (IDLE/WALK/RUN/SPRINT/RISE/FALL/LAND/DODGE), locomoção
relativa à câmera, salto (buffer + coyote), queda/aterrissagem, esquiva com
cooldown, câmera em 3ª pessoa com colisão e zoom, interação por contrato
(`PlayerInteractable`) e driver de animação com âncoras para o GLB futuro
(cápsula provisória na cena). Ações de entrada remapeáveis
(`project.godot` + `PlayerInputMap`), playtest manual em
`scenes/testing/movement_playtest.tscn` e suíte `suite_player` com física real
headless. Combate/progressão/rede continuam fora do escopo; ver `ARCHITECTURE.md`.

**Fase 2 (parcial) — Pipeline de modelos 3D (14/11/2026):** pipeline oficial
Blender → GLB → Godot implementado: gerador canônico
(`tools/blender/build_reference_character.py`, Blender 5.3 headless), fontes
`.blend` FORA do repositório (regra absoluta, auditada), modelo humanoide de
referência PROVISÓRIO importado e anexado automaticamente ao controlador
(`PlayerModelLoader` + auto-attach), AnimationTree padrão construída em runtime
(`AnimationTreeBuilder`: máquina de estados com crossfade e auto-loop),
auditoria headless (`tools/audit_runner.gd` → `tools/model_audit.gd`: orçamentos
de 4 GB, esqueleto, clipes, escala, política .blend) e suíte `suite_models`.
Auditoria APROVADA: 87 KB, 384 triângulos, 9 ossos, 1,79 m, origem nos pés,
8 clipes do contrato. Detalhes em `MODEL_PIPELINE.md`.

**Fase 2 (parcial) — Sistema de classes (14/11/2026):** 80 classes registradas
em dados (CLASS-001..080; CLASSES.md) nos 8 grupos editoriais (nomes pendentes),
sem código por classe; protótipo funcional completo do Arcanista (CLASS-001)
com habilidades demonstráveis, árvore, progressão e desbloqueios; componente de
classe no player (equipar/casts/cooldowns/recursos), subconjunto mínimo de
combate (vida/recurso/resistências/morte, área de impacto) e alvo de treino
provisório; playtest `scenes/testing/class_playtest.tscn`; suíte `suite_classes`.
Total de testes: 650 checks, 0 falhas. Especializações, nomes canônicos das 79
classes restantes, balanceamento e animações de combate: pendentes de design
(campos `pending` declarados nos dados).

**Fase 2 (parcial) — Sistema racial (14/11/2026):** 40 raças + 80 sub-raças
registradas em dados (RACES_AND_SUBRACES.md) com 2 sub-raças por raça (decisão
desta fase) e links bidirecionais validados; protótipo visual RACE-001 com
esqueleto humanoide compartilhado do pipeline GLB e 2 sub-raças com diferenças
visuais demonstráveis (chifres vs. antenas+cauda, tintas, escalas); construtor
visual modular (`race/race_visual_builder.gd`) com peças PROVISÓRIAS anexadas
por osso (chifres/antenas/caudas/asas/cristais; escamas e corpos especializados
como registro editorial pendente de arte); compatibilidade com classes
(`can_use_class`); atributos raciais não presumidos (vazios); animações
complementares pendentes; playtest `scenes/testing/race_playtest.tscn`; suíte
`suite_races`. Total de testes: 916 checks, 0 falhas. Nomes, identidades,
modelos definitivos, restrições de classe e balanceamento racial: pendentes de
design (`pending_fields` declarados nos dados).

**Fase 2 (parcial) — Bestiário e chefes (21/11/2026):** catálogo completo e
integração dos 230 demônios em Godot 4.7 + GDScript: 200 demônios regionais
(exatamente 50 por continente em Veyrath, Sylvaran, Khar-Duum e Nhal'Kora,
com 5 por região nas 40 regiões) + 30 chefes demoníacos (8 em Veyrath, 8 em
Sylvaran, 7 em Khar-Duum e 7 em Nhal'Kora, sem sobreposição com regionais).
Zero scripts por criatura: arquitetura 100% data-driven em `DemonData` e
`BossData` (`Resource`). Cenas compartilhadas `enemies/creature.tscn` (6
famílias de combate: brute, stalker, caster, swarm, flyer, sentinel com
hurtbox layer 8 e combatant integrado) e `enemies/boss.tscn` (3 fases de
combate disparadas por vida decrescente, controle pós-cinemática e derrota
sem respawn). Ciclo de encontro reutilizável orquestrado por `BossEncounter`
com temporização de entrada cinematográfica, HUD dedicado `BossUI` e concessão
de recompensas. IA compartilhada `CreatureAI` (idle/chase/attack/return/death).
Pipeline GLB: `model_pending = true` em todos os 230 registros e visual em
placeholder identificado provisório (mesh, material e Label3D billboard).
Playtest manual em `scenes/testing/creature_arena.tscn`. Validação por suíte
dedicada `suite_bestiary` (367 checks). Total acumulado de testes do projeto:
**1499 checks, 0 falhas** (`--headless`, saída 0).

**Fase 2 (parcial) — Sistema de mundo aberto (21/11/2026):** arquitetura completa de
mundo aberto em Godot 4.7 + GDScript: 4 continentes confirmados (`CONT-01` a `CONT-04`),
40 regiões mapeadas (exatamente 10 por continente, `REG-001` a `REG-040`), 14 subsistemas
integrados (continentes, regiões, streaming sob demanda, transições de fronteira,
limites com barreiras visuais, portais arcanos para Hell Forge, pontos de interesse
com notificações e XP, cidades com SafeZones, masmorras com requisitos de nível, arenas
circulares de chefes integradas a `BossEncounter`, pontos de exploração, descobertas
regionais no Character/WorldSession, marcadores de mapa e salvamento de exploração).
Região piloto completa: `scenes/world/regions/region_001.tscn` (Veyrath, `REG-001`) com
terreno estruturado, fenda de lava ativa, Baluarte das Cinzas, Catacumbas de Basalto,
Arena do Vazio (`BOSS-001`), GateNorth (`REG-002`), GateSouth (`REG-003`), portal para
Hell Forge e 5 zonas de inimigos vinculadas a `DEMON-001..005`. As demais 39 regiões
operam sob carregador modular (`scenes/world/modular_region.tscn`) com paletas por
continente e registro transparente de assets 3D pendentes (`pending_assets`).
Validação por suíte dedicada `suite_open_world` (1140 checks). Total acumulado de testes
do projeto: **2639 checks, 0 falhas** (`--headless`, saída 0).

**Fase 2 (parcial) — Interfaces e sistemas complementares (21/11/2026):** desenvolvimento e
integração de todos os 16 menus/telas Dark Fantasy com biblioteca compartilhada de componentes
(`scenes/ui/components/`: `DarkFantasyHeader`, `DarkFantasyNavBar`, `ItemSlotUI`, `StatComparisonCard`)
e roteador de telas dinâmico (`UIManager`, 17 telas registradas).
Integração completa dos sistemas complementares:
1. **Inventário:** 5 categorias canônicas (`equipment`, `consumable`, `material`, `relic`, `quest`), capacidade de slots, uso de consumíveis e descarte.
2. **Equipamentos:** 7 slots (`weapon`, `helmet`, `chest`, `legs`, `boots`, `ring`, `amulet`), doll 3D interativo com `RaceVisualBuilder` e comparação de atributos em tempo real (`StatComparisonCard`).
3. **Pactos:** 5 pactos canônicos com 5 graus de evolução (`core/pact_catalog.gd`), escalonamento de multiplicadores, requisitos e custos de almas/itens.
4. **Códice:** 9 categorias canônicas (200 demônios, 30 chefes, 40 raças, 80 sub-raças, 80 classes, 4 continentes, 40 regiões, história antiga e facções), com busca em tempo real.
5. **Bestiário:** visualizador regional/famílias com filtros de continentes e modelos GLB.
6. **Missões:** 5 categorias canônicas (`main`, `side`, `regional`, `class`, `race`), aceitar, rastrear e concluir.
7. **Mapa:** Mundial e Regional interativo (`MapCanvas`) com marcadores dinâmicos (cidades, masmorras, chefes, portais e pontos de exploração).
8. **Grupo:** 8 jogadores (anfitrião + 7 convidados), classes, níveis, vida e código de convite privado.
9. **Telas de sistema:** Tela inicial, Criação de mundo privado, Conexão com código, Configurações com persistência e Menu de Pausa com retorno à Hell Forge (`Invariants.HUB_REGION_ID`).
Zero textos estáticos simulados: 100% dos dados provêm dos gerenciadores e catálogos do jogo.
Validação por suíte dedicada `suite_ui_systems` (192 checks). Total acumulado do projeto:
**2831 checks, 0 falhas** (`--headless`, saída 0).

## Marcos condicionais

| Fase | Resultado | Condição de entrada | Condição de saída |
|---|---|---|---|
| 0. Fundação documental | Fonte única de verdade e registro de lacunas. | Briefing fundador. | Os 12 documentos existem, as contagens fecham e pendências são visíveis. |
| 1. Direção de design | Cânone, regiões, catálogo de personagens e pilares de gameplay aprovados. | Aprovação da documentação. | Lacunas prioritárias resolvidas por decisões versionadas. |
| 2. Pré-produção técnica | Arquitetura, pipeline GLB e estratégia de rede validados em plano. | Fase 1 suficiente. | Critérios de protótipo e orçamentos definidos. |
| 3. Protótipo vertical | Futuro escopo de implementação, não iniciado aqui. | Fases 1–2 aprovadas. | Critérios a definir. |
| 4. Produção de conteúdo | Regiões, personagens e bestiário produzidos em lotes. | Pipeline e catálogos aprovados. | Critérios a definir. |
| 5. Alpha/Beta/Lançamento | Marcos futuros. | Plano de QA, plataformas e operações definidos. | Critérios a definir. |

## Ordem recomendada de decisões

1. Fechar premissa/lore da Hell Forge e identidades dos continentes.
2. Nomear e distribuir as 40 regiões.
3. Definir pilares de combate, progressão e criação de personagem.
4. Fechar modelo de rede privada, persistência e plataformas.
5. Nomear/estruturar raças, sub-raças, classes e bestiário de acordo com os pilares aprovados.
6. Criar especificações de UI e pipeline de produção antes de qualquer produção em massa.

## Registro de bloqueios atuais

- ~~O diretório não possui projeto Godot~~ **Resolvido (13/11/2026):** projeto Godot 4.7
  inicializado na raiz, com arquitetura central implementada e validada por testes
  (ver `ARCHITECTURE.md`).
- Conteúdo nomeado além dos quatro continentes e Hell Forge não foi fornecido: os
  IDs editoriais (RACE-001, DEMON-001, REG-001…) permanecem placeholders de capacidade.
- Sistemas de gameplay completos (combate, spawning, UI canônica, fluxo de partida
  privada) aguardam as decisões bloqueadoras antes de qualquer implementação.
- Transporte de rede: ENet provisório atrás de fábricas isoladas; código de convite
  aceito mas não validado.

## Métricas documentais de conclusão da Fase 0

- 12 documentos requisitados presentes.
- 4 continentes, 40 regiões, 40 raças, 80 sub-raças, 80 classes, 200 criaturas regionais e 30 chefes registrados sem inventar identidades.
- Todos os fatos foram classificados como confirmados ou pendentes/propostos.
- Nenhuma contradição interna conhecida permanece sem registro.
