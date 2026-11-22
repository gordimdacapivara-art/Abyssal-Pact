# Abyssal Pact — Bestiário de Demônios Regionais

## Escopo confirmado

- 200 demônios são criaturas regionais.
- Esses 200 não incluem os 30 chefes, catalogados separadamente em `BOSS_CATALOG.md`.

Não há nomes, aparências, regiões, comportamento, narrativa ou estatísticas confirmadas para as criaturas regionais.

## Registro completo de capacidade

| Registros | Nome | Região | Identidade / combate | Estado |
|---|---|---|---|---|
| DEMON-001–DEMON-025 | Pendente | Pendente | Pendente | Não definido |
| DEMON-026–DEMON-050 | Pendente | Pendente | Pendente | Não definido |
| DEMON-051–DEMON-075 | Pendente | Pendente | Pendente | Não definido |
| DEMON-076–DEMON-100 | Pendente | Pendente | Pendente | Não definido |
| DEMON-101–DEMON-125 | Pendente | Pendente | Pendente | Não definido |
| DEMON-126–DEMON-150 | Pendente | Pendente | Pendente | Não definido |
| DEMON-151–DEMON-175 | Pendente | Pendente | Pendente | Não definido |
| DEMON-176–DEMON-200 | Pendente | Pendente | Pendente | Não definido |

**Contagem validada:** 200 registros de criatura regional reservados.

## Estado do registro no sistema (21/11/2026)

- Os **200 demônios regionais estão catalogados e registrados** em dados (`data/content/demons/demon_001.tres`..`demon_200.tres`) com IDs oficiais `DEMON-001` a `DEMON-200`.
- **Distribuição geográfica obrigatória:**
  - **Veyrath (CONT-01):** 50 criaturas (`DEMON-001`..`DEMON-050`), distribuídas nas regiões `REG-001` a `REG-010` (exatamente 5 por região).
  - **Sylvaran (CONT-02):** 50 criaturas (`DEMON-051`..`DEMON-100`), distribuídas nas regiões `REG-011` a `REG-020` (exatamente 5 por região).
  - **Khar-Duum (CONT-03):** 50 criaturas (`DEMON-101`..`DEMON-150`), distribuídas nas regiões `REG-021` a `REG-030` (exatamente 5 por região).
  - **Nhal'Kora (CONT-04):** 50 criaturas (`DEMON-151`..`DEMON-200`), distribuídas nas regiões `REG-031` a `REG-040` (exatamente 5 por região).
- **Sem scripts individuais:** ZERO scripts específicos de criatura. Utiliza-se a classe `DemonData` (`Resource`), a cena compartilhada `enemies/creature.tscn` (`Creature`) e a IA desacoplada `CreatureAI`.
- **6 Famílias de combate:** `brute` (tanque pesado), `stalker` (ágil e flanqueador), `caster` (conjurador à distância), `swarm` (enxame rápido e frágil), `flyer` (aéreo veloz), `sentinel` (sentinela defensivo). Cada família define parâmetros de combate, silhueta e paleta visual no placeholder.
- **Campos estruturados para cada criatura:**
  - `id`: Identificador canônico único (`DEMON-001`..`DEMON-200`).
  - `display_name`: Nome editorial identificado explicitamente com `(editorial)`.
  - `description`: Descrição do papel de combate, família e vínculo com continente/região.
  - `continent_id`: ID do continente (`CONT-01`..`CONT-04`).
  - `region_id`: ID da região (`REG-001`..`REG-040`).
  - `category`: Categoria `regional` (sem sobreposição com chefes).
  - `rarity`: Distribuição equilibrada: `common` (120), `uncommon` (40), `rare` (20), `elite` (20).
  - `stats`: Atributos de combate escalonados por raridade e família (`max_health`, `damage`, `defense`, `move_speed`, `attack_range`, `attack_cooldown`, `xp_reward`, `gold_reward`).
  - `resistances`: Resistências elementais e físicas (`physical`, `abyssal`, `fire`).
  - `ability_ids`: Habilidades associadas via `AbilityData` (ex.: `ABIL-DEM-BRUTE`, `ABIL-DEM-STALKER`, `ABIL-DEM-CASTER`, etc.).
  - `rewards`: Recompensas concedidas na derrota (`xp`, `gold`, `items`).
  - `model_path`: Caminho convencional padronizado `res://assets/models/demons/<id>.glb`.
  - `model_pending`: Marcado como `true` para todos os registros — nenhum GLB final de criatura existe no repositório.
  - `placeholder_scene`: Cena de teste `res://enemies/creature.tscn`, identificada visualmente com `PLACEHOLDER` em mesh, nó e Label3D billboard.
  - `animations`: Contrato de animações padrão (`idle`, `walk`, `attack`, `hurt`, `death`).
  - `ai`: Configurações de IA data-driven (`perception_radius`, `aggro_radius`, `deaggro_radius`, `leash_radius`, `patrol_radius`, `chase_speed`, `attack_range`, `attack_cooldown`, `respawn_seconds`, `respawn_enabled`, `return_speed`, `states`).
- **Integração:** Carregamento, validação e gerenciamento completo via `DemonManager` (`SystemNames.DEMONS`), com consultas por continente, região, família, representantes e requisição de spawn via `EventBus`.
- **Validação:** Suíte de testes automatizados `suite_bestiary` (200 registros validados, zero falhas) e arena interativa em `scenes/testing/creature_arena.tscn`.

## Campos obrigatórios antes de implementação

- Nome canônico, silhueta, origem e região de ocorrência.
- Papel de encontro e comportamento em solo/grupo.
- Recompensas, progressão e variantes, caso aprovadas.
- Requisitos de modelo GLB, rig, animação, VFX, áudio e orçamento técnico.
- Regra de autoridade de rede para dano, morte e recompensas.
