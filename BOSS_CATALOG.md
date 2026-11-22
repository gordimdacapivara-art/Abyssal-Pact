# Abyssal Pact — Catálogo de Chefes

## Escopo confirmado

Há **30 chefes demoníacos**. Eles compõem a parcela de chefes dos 230 demônios totais e não podem ser contados novamente como criaturas regionais.

## Registro completo de capacidade

| Registros | Nome | Região / arena | Identidade / encontro | Estado |
|---|---|---|---|---|
| BOSS-001–BOSS-005 | Pendente | Pendente | Pendente | Não definido |
| BOSS-006–BOSS-010 | Pendente | Pendente | Pendente | Não definido |
| BOSS-011–BOSS-015 | Pendente | Pendente | Pendente | Não definido |
| BOSS-016–BOSS-020 | Pendente | Pendente | Pendente | Não definido |
| BOSS-021–BOSS-025 | Pendente | Pendente | Pendente | Não definido |
| BOSS-026–BOSS-030 | Pendente | Pendente | Pendente | Não definido |

**Contagem validada:** 30 registros de chefe reservados.

## Dados necessários por chefe

- Nome, lore, região, arena e relação com a progressão.
- Fases, padrões, telegrafia, condições de derrota e escalonamento de grupo.
- Recompensas e consequências de mundo, quando aprovadas.
- Lista de arte/animação/áudio e orçamento de performance.

Não foram definidos chefes nem alocação de chefes por continente.

## Estado do registro no sistema (21/11/2026)

- Os **30 chefes demoníacos estão catalogados e registrados** em dados (`data/content/bosses/boss_001.tres`..`boss_030.tres`) com IDs oficiais `BOSS-001` a `BOSS-030`.
- **Distribuição por continentes e regiões:**
  - **Veyrath (CONT-01):** 8 chefes (`BOSS-001` a `BOSS-008`), alocados nas regiões `REG-001` a `REG-008`.
  - **Sylvaran (CONT-02):** 8 chefes (`BOSS-009` a `BOSS-016`), alocados nas regiões `REG-011` a `REG-018`.
  - **Khar-Duum (CONT-03):** 7 chefes (`BOSS-017` a `BOSS-023`), alocados nas regiões `REG-021` a `REG-027`.
  - **Nhal'Kora (CONT-04):** 7 chefes (`BOSS-024` a `BOSS-030`), alocados nas regiões `REG-031` a `REG-037`.
- **Sem scripts individuais:** ZERO scripts específicos por chefe. Utiliza-se a classe de dados `BossData` (`Resource`), a cena compartilhada `enemies/boss.tscn` (`Boss`, herdada de `Creature`), o orquestrador `BossEncounter` e a interface `BossUI`.
- **Estrutura de dados por chefe:**
  - `id`: Identificador único (`BOSS-001`..`BOSS-030`).
  - `display_name`: Nome editorial com identificador e marcação `(editorial)`.
  - `description`: Descrição do encontro e papel no continente.
  - `narrative_identity`: Identidade narrativa declarada explicitamente como `PENDENTE de design (BOSS_CATALOG.md)` para resguardar o cânone.
  - `continent_id` e `region_id`: Vínculo geográfico validado sem divergências.
  - `arena`: Configuração da arena (`name`, `radius`, `hazards`, `entrance_marker`).
  - `category`: `boss` (invariante: estritamente separado do catálogo regional).
  - `rarity`: `boss`, `boss_elite`, `boss_final`.
  - `stats`: Atributos de chefe (`max_health`, `damage`, `defense`, `move_speed`, `attack_range`, `attack_cooldown`, `xp_reward`, `gold_reward`).
  - `resistances`: Resistências a tipos de dano (`physical`, `abyssal`, `fire`).
  - `ability_ids`: Catálogo completo de habilidades de combate.
  - `special_abilities`: Habilidades especiais utilizadas nas transições de fase (`ABIL-BOSS-SLAM`, `ABIL-BOSS-BEAM`, `ABIL-BOSS-HAZARD`, `ABIL-BOSS-SUMMON`, `ABIL-BOSS-ENRAGE`).
  - `phases`: 3 fases de combate por limiares de vida decrescentes (`1.0`, `0.66`, `0.33`), cada uma com comportamento (`ground_pressure`, `mixed_pressure`, `enraged`), habilidades desbloqueadas e animação dedicada.
  - `phase_count`: 3.
  - `exclusive_animations`: Mapeamento de clipes exclusivos (`entrance`, `phase_2`, `phase_3`, `cast`, `death`).
  - `boss_ui`: Configuração visual da interface de chefe (`bar_style`, `name_color`, `phase_markers`, `show_cast_bar`).
  - `entrance`: Sequência de entrada cinematográfica com temporização (`cinematic`, `duration_seconds`, `camera_move`, `title_card`).
  - `defeat_conditions`: Condições de encerramento (`health_zero`).
  - `rewards`: Recompensas especiais de encontro (`xp`, `gold`, `items`, `unlocks`).
  - `model_path`: Convenção `res://assets/models/bosses/<id>.glb`.
  - `model_pending`: Marcado como `true` para os 30 registros — nenhum GLB final de chefe existe no projeto.
  - `placeholder_scene`: Cena de teste `res://enemies/boss.tscn` (cápsula com escala 1.6x, silhueta provisória e Label3D de identificação).
  - `ai`: Configuração de IA para chefes com `respawn_enabled = false` e `phase_driven = true`.
- **Integração:** Carregamento e ciclo de encontro gerenciados por `BossManager` (`SystemNames.BOSSES`) via `begin_encounter` (limite máximo de 8 jogadores do produto) e `end_encounter`.
- **Interface de chefe:** Componente reutilizável `BossUI` em `enemies/boss_ui.tscn` com barra de vida segmentada, marcadores de fase, barra de conjuração e cor configurável.
- **Validação:** Suíte de testes `suite_bestiary` (testes de catálogo, limiares de fase por dano letal/parcial, emissão de sinais de evento, concessão de recompensas e encerramento) e arena interativa em `scenes/testing/creature_arena.tscn`.
