# Abyssal Pact — Raças e Sub-raças

## Escopo confirmado

- 40 raças.
- 80 sub-raças.

O total não define a distribuição de sub-raças por raça. A média matemática é duas, mas **não** é uma decisão de design de que cada raça tenha exatamente duas sub-raças.

> **DECISÃO REGISTRADA (14/11/2026):** a distribuição de **exatamente 2 sub-raças por raça** foi definida nesta fase do desenvolvimento do sistema (por decisão do usuário do sistema). O parágrafo acima permanece como histórico: a média matemática originalmente NÃO era uma decisão de design; agora é.

## Registro de raças

| Registros | Nome e identidade | Sub-raças associadas |
|---|---|---|
| RACE-001–RACE-010 | Pendente | Pendente |
| RACE-011–RACE-020 | Pendente | Pendente |
| RACE-021–RACE-030 | Pendente | Pendente |
| RACE-031–RACE-040 | Pendente | Pendente |

**Contagem validada:** 40 registros de raça reservados.

## Registro de sub-raças

| Registros | Nome e identidade | Raça-mãe | Observações |
|---|---|---|---|
| SUBRACE-001–SUBRACE-020 | Pendente | Pendente | Pendente |
| SUBRACE-021–SUBRACE-040 | Pendente | Pendente | Pendente |
| SUBRACE-041–SUBRACE-060 | Pendente | Pendente | Pendente |
| SUBRACE-061–SUBRACE-080 | Pendente | Pendente | Pendente |

**Contagem validada:** 80 registros de sub-raça reservados.

## Informações ainda necessárias

- Nomes, aparência, culturas, origem, papel de jogador e disponibilidade de cada raça.
- Relação exata entre raça e sub-raça.
- Efeitos mecânicos, se existirem; não se presume que raça ou sub-raça conceda atributos.
- Relações com classes, regiões e lore.

Nenhum nome de raça ou sub-raça foi encontrado no material de projeto examinado.

## Estado do registro no sistema (14/11/2026)

- As **40 raças e 80 sub-raças estão registradas no catálogo de dados** (`data/content/races/race_001..040.tres`, `data/content/subraces/subrace_001..080.tres`) com IDs editoriais oficiais (RACE-001..RACE-040, SUBRACE-001..SUBRACE-080), **2 sub-raças por raça** (decisão desta fase) e vínculo bidirecional validado (`RaceManager._validate_catalog`).
- Os 39 registros de raça e 78 de sub-raça não-protótipo permanecem com nome editorial "(pendente de design)" e `pending_fields` declarados — NADA de lore foi inventado.
- **Protótipo funcional completo: RACE-001 (protótipo visual)** — esqueleto humanoide COMPARTILHADO do pipeline GLB (`char_ref_humanoid.glb`), perfil visual em dados (`visual_profile`) e 2 sub-raças com diferenças visuais demonstráveis via construtor modular:
  - SUBRACE-001: chifres no osso `head`, tinta de cabeça distinta, escala 1.06.
  - SUBRACE-002: antenas no `head` + cauda no `root`, tinta distinta, escala 0.94.
  - Peças anexadas por `BoneAttachment3D` e nomeadas como PROVISÓRIAS (nenhuma passa por definitiva).
- Suporte a estruturas registradas em dados: chifres, galhadas, antenas, caudas, asas, cristais (`RaceVisualBuilder.BONE_FOR_ACCESSORY`); escamas/estruturas especiais ficam como marcas editoriais em `special_structures` (sem mesh dedicada — pendentes de arte). Corpos incompatíveis com o esqueleto humanoide (`body_type="specialized"`) usam o manequim compartilhado como PROVISÓRIO com aviso explícito até existir rig próprio.
- Atributos raciais: **não presumidos** (vazios em todas — `racial_attributes: {}`).
- Compatibilidade com classes: `can_use_class()` — raça com `compatible_class_groups` vazio é compatível com todas (estado provisório; restrições oficiais pendentes de design).
- Animações complementares: pendentes em todas (`animation_extras: {}`).
- Validação: suíte `suite_races` (266 checks) — ver `ARCHITECTURE.md`. Playtest manual: `scenes/testing/race_playtest.tscn`.
