# RELATÓRIO OFICIAL DE PRODUÇÃO DE ARMAS — ABYSSAL PACT

> **Status:** Sistema Estruturado e Auditado | Lote Piloto Concluído no Blender 5.3  
> **Data:** 21 de Novembro de 2026  
> **Engine 3D:** Blender 5.3.0 Local via API `bpy` | **Motor de Jogo:** Godot 4.7.2 Forward+  
> **Total de Armas Catalogadas:** 100 Armas em 10 Categorias Oficiais  
> **Lote Piloto 3D:** 5 Armas de Categorias Diferentes com Geometria Real, PBR, Sockets e Renders  

---

## 1. AUDITORIA E INTEGRAÇÃO DO SISTEMA DE ARMAS

A auditoria completa de equipamentos examinou os itens previamente planejados no repositório (`data/content/equipment/`), preservando integralmente suas identidades e integrando-os ao catálogo expandido de 100 armas:

| ID no Sistema | ID do Inventário | Nome Canônico | Categoria | Raridade Original | Status de Produção |
|---|---|---|---|---|---|
| `WEP-001` | `EQ-001` | Espada das Cinzas | Espadas | Comum | **Modelado (Piloto Blender 5.3)** |
| `WEP-011` | `EQ-004` | Machado Rúnico de Basalto | Machados | Épico | **Modelado (Piloto Blender 5.3)** |
| `WEP-041` | `EQ-003` | Adaga de Obsidiana | Adagas e armas leves | Incomum | Ficha Técnica Concluída |
| `WEP-071` | `EQ-002` | Cajado do Vazio Vulcânico | Cajados e catalisadores | Raro | Ficha Técnica Concluída |

---

## 2. RESUMO DAS 10 CATEGORIAS OFICIAIS DE ARMAS

| Nº | Categoria Oficial | Quantidade | Faixa de IDs | Pasta no Projeto | Pasta 3D | Lote Piloto |
|---|---|---:|---|---|---|---|
| **01** | **Espadas** | 10 | `WEP-001`–`010` | `Weapons/Swords/` | `assets/3d/weapons/swords/` | `WEP-001` Concluído |
| **02** | **Machados** | 10 | `WEP-011`–`020` | `Weapons/Axes/` | `assets/3d/weapons/axes/` | `WEP-011` Concluído |
| **03** | **Martelos e maças** | 10 | `WEP-021`–`030` | `Weapons/Hammers_Maces/` | `assets/3d/weapons/hammers_maces/` | `WEP-021` Concluído |
| **04** | **Lanças e armas de haste** | 10 | `WEP-031`–`040` | `Weapons/Polearms/` | `assets/3d/weapons/polearms/` | `WEP-031` Concluído |
| **05** | **Adagas e armas leves** | 10 | `WEP-041`–`050` | `Weapons/Daggers/` | `assets/3d/weapons/daggers/` | Planejado Lote 2 |
| **06** | **Arcos e armas de distância** | 10 | `WEP-051`–`060` | `Weapons/Bows_Crossbows/` | `assets/3d/weapons/bows_crossbows/` | Planejado Lote 3 |
| **07** | **Armas de fogo fantásticas** | 10 | `WEP-061`–`070` | `Weapons/Firearms_Fantasy/` | `assets/3d/weapons/firearms_fantasy/` | Planejado Lote 4 |
| **08** | **Cajados e catalisadores** | 10 | `WEP-071`–`080` | `Weapons/Staves_Catalysts/` | `assets/3d/weapons/staves_catalysts/` | Planejado Lote 5 |
| **09** | **Armas especiais** | 10 | `WEP-081`–`090` | `Weapons/Special_Weapons/` | `assets/3d/weapons/special_weapons/` | Planejado Lote 6 |
| **10** | **Escudos e defensivos** | 10 | `WEP-091`–`100` | `Weapons/Shields/` | `assets/3d/weapons/shields/` | `WEP-091` Concluído |
| **TOTAL** | **10 Categorias** | **100** | `WEP-001`–`100` | `Weapons/` | `assets/3d/weapons/` | **5 Pilotos Validados** |

---

## 3. AUDITORIA TÉCNICA DAS 5 ARMAS-PILOTO NO BLENDER 5.3

Todos os 5 modelos foram criados procedurally no Blender 5.3, contendo malhas poligonais detalhadas, materiais PBR com emissão abissal, pontos de fixação (Sockets) e imagens de pré-visualização renderizadas:

| ID | Nome da Arma | Categoria | Vértices / Polígonos | Materiais PBR | Sockets de Personagem | Arquivo .blend | Arquivo .glb | Preview .png | Auditoria |
|---|---|---|---:|---|---|---|---|---|---|
| `WEP-001` | Espada das Cinzas | Espadas | 95 / 117 | 5 PBR (`#1E1C1A`, `#FF5500`) | `socket_hand_r`, `socket_back`, `socket_hip_l` | 103 KB | 19.7 KB | 391 KB | **100% Aprovado** |
| `WEP-011` | Machado Rúnico de Basalto | Machados | 147 / 99 | 4 PBR (`#181615`, `#FF4400`) | `socket_hand_r`, `socket_back` | 102 KB | 24.2 KB | 453 KB | **100% Aprovado** |
| `WEP-021` | Martelo Colossal da Forja | Martelos e maças | 77 / 51 | 4 PBR (`#323438`, `#FF7700`) | `socket_hand_r`, `socket_back` | 100 KB | 13.6 KB | 417 KB | **100% Aprovado** |
| `WEP-031` | Lança das Cinzas Abissais | Lanças e hastes | 90 / 64 | 4 PBR (`#0F1215`, `#FF6622`) | `socket_hand_r`, `socket_back` | 101 KB | 17.2 KB | 384 KB | **100% Aprovado** |
| `WEP-091` | Escudo Torre de Ferro Negro | Escudos e defensivos | 107 / 127 | 4 PBR (`#222428`, `#FF3300`) | `socket_hand_l`, `socket_back` | 102 KB | 21.7 KB | 531 KB | **100% Aprovado** |

---

## 4. PADRÕES DE RIGGING, SOCKETS E INTEGRAÇÃO COM PERSONAGEM

As armas foram projetadas para acoplamento dinâmico no esqueleto de personagem humanoide (`char_ref_humanoid.glb` / `player_character_master.blend`):

1. **Ponto de Empunhadura Principal (`socket_hand_r` / `socket_hand_l`):**
   - Localizado no centro exato da pegada de couro, com orientação Y+ alinhada com o cano/lâmina para empunhadura anatômica natural.
2. **Ponto de Bainha de Costas (`socket_back`):**
   - Translação e rotação pré-configuradas para descansar na diagonal das costas do jogador (ângulo de 35° a 45°).
3. **Ponto de Bainha de Cintura (`socket_hip_l` / `socket_hip_r`):**
   - Posição lateral paralela à coxa esquerda para espadas curtas, sabres e adagas.

---

## 5. CATÁLOGO COMPLETO DAS 100 ARMAS

| ID | Nome Oficial | Categoria | Subcategoria | Raridade | Dano | Peso (kg) | Alcance | Ficha Técnica |
|---|---|---|---|---|---:|---:|---:|---|
| `WEP-001` | Espada das Cinzas | Espadas | Espadas longas | Comum | 18 | 2.4 | 2.0m | [`WEP-001.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Swords/WEP-001.md) |
| `WEP-002` | Gládio de Ferro Negro | Espadas | Espadas curtas | Comum | 15 | 1.8 | 2.0m | [`WEP-002.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Swords/WEP-002.md) |
| `WEP-003` | Montante de Basalto Calcinado | Espadas | Espadões | Incomum | 34 | 5.8 | 2.0m | [`WEP-003.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Swords/WEP-003.md) |
| `WEP-004` | Lâmina Bastarda da Forja | Espadas | Espadas bastardas | Raro | 28 | 3.2 | 2.0m | [`WEP-004.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Swords/WEP-004.md) |
| `WEP-005` | Cimitarra das Dunas Negras | Espadas | Sabres / Espadas curvas | Incomum | 22 | 2.1 | 2.0m | [`WEP-005.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Swords/WEP-005.md) |
| `WEP-006` | Nodachi do Abismo Férreo | Espadas | Katanas / Lâminas longas | Raro | 30 | 2.9 | 2.0m | [`WEP-006.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Swords/WEP-006.md) |
| `WEP-007` | Lâmina Rúnica da Fenda | Espadas | Espadas mágicas | Épico | 38 | 2.7 | 2.0m | [`WEP-007.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Swords/WEP-007.md) |
| `WEP-008` | Ceifadora de Almas de Azaroth | Espadas | Espadas demoníacas | Lendário | 52 | 4.1 | 2.0m | [`WEP-008.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Swords/WEP-008.md) |
| `WEP-009` | Vorpal do Fogo Profundo | Espadas | Espadas lendárias | Lendário | 56 | 3.6 | 2.0m | [`WEP-009.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Swords/WEP-009.md) |
| `WEP-010` | Espada Quebrada do Primeiro Herói | Espadas | Espadas ancestrais | Abissal / Relíquia | 62 | 2.5 | 2.0m | [`WEP-010.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Swords/WEP-010.md) |
| `WEP-011` | Machado Rúnico de Basalto | Machados | Machados de guerra | Épico | 46 | 4.8 | 1.8m | [`WEP-011.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Axes/WEP-011.md) |
| `WEP-012` | Machadinha de Enxofre | Machados | Machados de uma mão | Comum | 20 | 2.1 | 1.8m | [`WEP-012.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Axes/WEP-012.md) |
| `WEP-013` | Rachador de Crânios Vulcânico | Machados | Machados de duas mãos | Incomum | 36 | 5.4 | 1.8m | [`WEP-013.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Axes/WEP-013.md) |
| `WEP-014` | Cutelo Duplo do Algoz | Machados | Machados duplos | Raro | 42 | 6.2 | 1.8m | [`WEP-014.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Axes/WEP-014.md) |
| `WEP-015` | Rompedor de Portões de Ferro | Machados | Machados pesados | Raro | 44 | 7.0 | 1.8m | [`WEP-015.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Axes/WEP-015.md) |
| `WEP-016` | Machado da Seiva Pútrida | Machados | Machados encantados | Épico | 48 | 4.5 | 1.8m | [`WEP-016.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Axes/WEP-016.md) |
| `WEP-017` | Foice-Machado das Marés Frias | Machados | Machados híbridos | Incomum | 32 | 3.8 | 1.8m | [`WEP-017.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Axes/WEP-017.md) |
| `WEP-018` | Machado Voraz do Devorador | Machados | Machados demoníacos | Lendário | 58 | 6.5 | 1.8m | [`WEP-018.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Axes/WEP-018.md) |
| `WEP-019` | Cutelo Gigante das Cinzas | Machados | Machados colossais | Lendário | 64 | 9.5 | 1.8m | [`WEP-019.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Axes/WEP-019.md) |
| `WEP-020` | Machado dos Titãs Antigos | Machados | Machados ancestrais | Abissal / Relíquia | 70 | 8.0 | 1.8m | [`WEP-020.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Axes/WEP-020.md) |
| `WEP-021` | Martelo Colossal da Forja | Martelos e maças | Martelos colossais | Lendário | 60 | 11.2 | 1.7m | [`WEP-021.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Hammers_Maces/WEP-021.md) |
| `WEP-022` | Maça Flangeada de Aço Escuro | Martelos e maças | Maças de combate | Comum | 19 | 2.6 | 1.7m | [`WEP-022.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Hammers_Maces/WEP-022.md) |
| `WEP-023` | Mangual de Espinhos Abissais | Martelos e maças | Maças com espinhos | Incomum | 26 | 3.4 | 1.7m | [`WEP-023.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Hammers_Maces/WEP-023.md) |
| `WEP-024` | Quebra-Muralhas de Basalto | Martelos e maças | Martelos pesados | Raro | 42 | 7.8 | 1.7m | [`WEP-024.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Hammers_Maces/WEP-024.md) |
| `WEP-025` | Martelo Sísmico de Veyrath | Martelos e maças | Martelos mágicos | Épico | 50 | 8.5 | 1.7m | [`WEP-025.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Hammers_Maces/WEP-025.md) |
| `WEP-026` | Clava Monolítica do Deserto | Martelos e maças | Martelos pesados | Incomum | 32 | 6.2 | 1.7m | [`WEP-026.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Hammers_Maces/WEP-026.md) |
| `WEP-027` | Maça da Estrela Noturna | Martelos e maças | Maças encantadas | Raro | 36 | 3.2 | 1.7m | [`WEP-027.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Hammers_Maces/WEP-027.md) |
| `WEP-028` | Martelo da Bigorna Primordial | Martelos e maças | Martelos ancestrais | Lendário | 66 | 12.0 | 1.7m | [`WEP-028.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Hammers_Maces/WEP-028.md) |
| `WEP-029` | Fustigador de Almas Encadeado | Martelos e maças | Maças demoníacas | Épico | 48 | 4.5 | 1.7m | [`WEP-029.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Hammers_Maces/WEP-029.md) |
| `WEP-030` | Quebra-Reinos de Khar-Duum | Martelos e maças | Martelos lendários | Abissal / Relíquia | 74 | 13.5 | 1.7m | [`WEP-030.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Hammers_Maces/WEP-030.md) |
| `WEP-031` | Lança das Cinzas Abissais | Lanças e armas de haste | Lanças / Glaives | Raro | 35 | 3.6 | 3.2m | [`WEP-031.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Polearms/WEP-031.md) |
| `WEP-032` | Pique de Guarnição de Basalto | Lanças e armas de haste | Piques | Comum | 22 | 4.2 | 3.2m | [`WEP-032.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Polearms/WEP-032.md) |
| `WEP-033` | Alabarda da Guarda Vulcânica | Lanças e armas de haste | Alabardas | Incomum | 30 | 4.8 | 3.2m | [`WEP-033.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Polearms/WEP-033.md) |
| `WEP-034` | Bardiche do Carrasco da Caldeira | Lanças e armas de haste | Bardiches | Raro | 38 | 5.2 | 3.2m | [`WEP-034.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Polearms/WEP-034.md) |
| `WEP-035` | Tridente do Recife Abissal | Lanças e armas de haste | Tridentes | Incomum | 26 | 3.4 | 3.2m | [`WEP-035.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Polearms/WEP-035.md) |
| `WEP-036` | Glaive Rúnica da Fenda Esmeralda | Lanças e armas de haste | Glaives | Épico | 44 | 3.8 | 3.2m | [`WEP-036.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Polearms/WEP-036.md) |
| `WEP-037` | Foice de Guerra dos Condenados | Lanças e armas de haste | Foices de guerra | Épico | 48 | 4.1 | 3.2m | [`WEP-037.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Polearms/WEP-037.md) |
| `WEP-038` | Lança de Presa de Dragão | Lanças e armas de haste | Lanças ancestrais | Lendário | 54 | 3.7 | 3.2m | [`WEP-038.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Polearms/WEP-038.md) |
| `WEP-039` | Haste Perfuradora do Leviatã | Lanças e armas de haste | Armas de haste mágicas | Lendário | 58 | 4.5 | 3.2m | [`WEP-039.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Polearms/WEP-039.md) |
| `WEP-040` | Lança Solar de Khar-Zul | Lanças e armas de haste | Lanças lendárias | Abissal / Relíquia | 68 | 4.0 | 3.2m | [`WEP-040.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Polearms/WEP-040.md) |
| `WEP-041` | Adaga de Obsidiana | Adagas e armas leves | Adagas | Incomum | 22 | 0.8 | 1.2m | [`WEP-041.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Daggers/WEP-041.md) |
| `WEP-042` | Punhal do Sacrifício Sangrento | Adagas e armas leves | Punhais | Comum | 14 | 0.6 | 1.2m | [`WEP-042.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Daggers/WEP-042.md) |
| `WEP-043` | Faca Cáustica das Fendas | Adagas e armas leves | Facas de combate | Comum | 16 | 0.7 | 1.2m | [`WEP-043.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Daggers/WEP-043.md) |
| `WEP-044` | Lâminas Gêmeas da Sombra | Adagas e armas leves | Lâminas duplas | Raro | 28 | 1.4 | 1.2m | [`WEP-044.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Daggers/WEP-044.md) |
| `WEP-045` | Garras do Espreitador Abissal | Adagas e armas leves | Garras equipáveis | Raro | 26 | 1.1 | 1.2m | [`WEP-045.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Daggers/WEP-045.md) |
| `WEP-046` | Kris de Coral Negro | Adagas e armas leves | Armas curvas leves | Incomum | 20 | 0.9 | 1.2m | [`WEP-046.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Daggers/WEP-046.md) |
| `WEP-047` | Adaga de Cristal de Miasma | Adagas e armas leves | Adagas mágicas | Épico | 34 | 0.7 | 1.2m | [`WEP-047.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Daggers/WEP-047.md) |
| `WEP-048` | Estilete Envenenado da Víbora | Adagas e armas leves | Estiletes perfurantes | Épico | 30 | 0.5 | 1.2m | [`WEP-048.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Daggers/WEP-048.md) |
| `WEP-049` | Garras de Sangue de Azaroth | Adagas e armas leves | Garras demoníacas | Lendário | 44 | 1.3 | 1.2m | [`WEP-049.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Daggers/WEP-049.md) |
| `WEP-050` | Dente do Vórtice Final | Adagas e armas leves | Adagas lendárias | Abissal / Relíquia | 52 | 0.6 | 1.2m | [`WEP-050.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Daggers/WEP-050.md) |
| `WEP-051` | Arco Curto das Cinzas | Arcos e armas de distância | Arcos curtos | Comum | 18 | 1.2 | 22.0m | [`WEP-051.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Bows_Crossbows/WEP-051.md) |
| `WEP-052` | Arco Longo de Madeira Petrificada | Arcos e armas de distância | Arcos longos | Incomum | 26 | 2.0 | 22.0m | [`WEP-052.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Bows_Crossbows/WEP-052.md) |
| `WEP-053` | Arco Composto de Chifre Demoníaco | Arcos e armas de distância | Arcos compostos | Raro | 34 | 1.7 | 22.0m | [`WEP-053.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Bows_Crossbows/WEP-053.md) |
| `WEP-054` | Besta de Repetição de Ferro Negro | Arcos e armas de distância | Bestas leves | Raro | 32 | 3.8 | 22.0m | [`WEP-054.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Bows_Crossbows/WEP-054.md) |
| `WEP-055` | Balista Portátil de Cerco | Arcos e armas de distância | Bestas pesadas | Épico | 50 | 7.5 | 22.0m | [`WEP-055.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Bows_Crossbows/WEP-055.md) |
| `WEP-056` | Arco Recurvo da Fenda Esmeralda | Arcos e armas de distância | Arcos encantados | Épico | 40 | 1.5 | 22.0m | [`WEP-056.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Bows_Crossbows/WEP-056.md) |
| `WEP-057` | Arco dos Salgueiros Negros | Arcos e armas de distância | Arcos mágicos | Raro | 36 | 1.8 | 22.0m | [`WEP-057.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Bows_Crossbows/WEP-057.md) |
| `WEP-058` | Besta Arcanum de Sílica | Arcos e armas de distância | Bestas arcanas | Épico | 46 | 4.2 | 22.0m | [`WEP-058.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Bows_Crossbows/WEP-058.md) |
| `WEP-059` | Disparador de Almas Condenadas | Arcos e armas de distância | Arcos demoníacos | Lendário | 58 | 2.2 | 22.0m | [`WEP-059.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Bows_Crossbows/WEP-059.md) |
| `WEP-060` | Arco do Zênite Solar de Khar-Duum | Arcos e armas de distância | Arcos lendários | Abissal / Relíquia | 68 | 1.9 | 22.0m | [`WEP-060.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Bows_Crossbows/WEP-060.md) |
| `WEP-061` | Canhão Portátil da Hell Forge | Armas de fogo fantásticas | Artefatos de ferro fundido | Raro | 48 | 9.2 | 18.0m | [`WEP-061.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Firearms_Fantasy/WEP-061.md) |
| `WEP-062` | Arcabuz de Fogo Grego e Enxofre | Armas de fogo fantásticas | Armas químicas arcaicas | Incomum | 36 | 5.6 | 18.0m | [`WEP-062.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Firearms_Fantasy/WEP-062.md) |
| `WEP-063` | Projetor de Plasma Magmático | Armas de fogo fantásticas | Artefatos de energia | Épico | 54 | 7.8 | 18.0m | [`WEP-063.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Firearms_Fantasy/WEP-063.md) |
| `WEP-064` | Pistola de Cristal Sísmico | Armas de fogo fantásticas | Armas de fragmentos arcanos | Incomum | 28 | 2.4 | 18.0m | [`WEP-064.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Firearms_Fantasy/WEP-064.md) |
| `WEP-065` | Lança-Chamas de Nafta Abissal | Armas de fogo fantásticas | Armas contínuas | Raro | 42 | 8.0 | 18.0m | [`WEP-065.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Firearms_Fantasy/WEP-065.md) |
| `WEP-066` | Mosquete Rúnico de Basalto | Armas de fogo fantásticas | Armas de dispersão | Raro | 44 | 6.2 | 18.0m | [`WEP-066.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Firearms_Fantasy/WEP-066.md) |
| `WEP-067` | Ejetor de Vapores Cáusticos | Armas de fogo fantásticas | Artefatos pressurizados | Épico | 46 | 6.8 | 18.0m | [`WEP-067.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Firearms_Fantasy/WEP-067.md) |
| `WEP-068` | Canhão de Mão do Titã de Chumbo | Armas de fogo fantásticas | Artefatos colossais | Lendário | 66 | 14.0 | 18.0m | [`WEP-068.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Firearms_Fantasy/WEP-068.md) |
| `WEP-069` | Colubrina Portátil de Maré Gélida | Armas de fogo fantásticas | Artefatos hidro-abissais | Épico | 50 | 8.5 | 18.0m | [`WEP-069.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Firearms_Fantasy/WEP-069.md) |
| `WEP-070` | Olho da Singularidade Abissal | Armas de fogo fantásticas | Artefatos cósmicos | Abissal / Relíquia | 76 | 10.5 | 18.0m | [`WEP-070.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Firearms_Fantasy/WEP-070.md) |
| `WEP-071` | Cajado do Vazio Vulcânico | Cajados e catalisadores | Cajados mágicos | Raro | 14 | 2.2 | 15.0m | [`WEP-071.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Staves_Catalysts/WEP-071.md) |
| `WEP-072` | Bastão Arcano de Obsidiana | Cajados e catalisadores | Bastões arcanos | Comum | 12 | 1.6 | 15.0m | [`WEP-072.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Staves_Catalysts/WEP-072.md) |
| `WEP-073` | Orbe das Marés Glaciais | Cajados e catalisadores | Orbes flutuantes | Incomum | 18 | 1.2 | 15.0m | [`WEP-073.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Staves_Catalysts/WEP-073.md) |
| `WEP-074` | Tomo das Chamas Proibidas | Cajados e catalisadores | Tomos de feitiçaria | Incomum | 20 | 2.0 | 15.0m | [`WEP-074.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Staves_Catalysts/WEP-074.md) |
| `WEP-075` | Grimório da Corrupção Abissal | Cajados e catalisadores | Grimórios profanos | Épico | 26 | 2.5 | 15.0m | [`WEP-075.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Staves_Catalysts/WEP-075.md) |
| `WEP-076` | Catalisador de Seiva Esmeralda | Cajados e catalisadores | Catalisadores naturais | Raro | 22 | 1.5 | 15.0m | [`WEP-076.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Staves_Catalysts/WEP-076.md) |
| `WEP-077` | Relíquia da Mente Fraturada | Cajados e catalisadores | Relíquias mágicas | Épico | 30 | 1.8 | 15.0m | [`WEP-077.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Staves_Catalysts/WEP-077.md) |
| `WEP-078` | Cetro do Lorde de Basalto | Cajados e catalisadores | Cetros cerimoniais | Épico | 28 | 2.8 | 15.0m | [`WEP-078.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Staves_Catalysts/WEP-078.md) |
| `WEP-079` | Báculo da Tempestade de Areia | Cajados e catalisadores | Cajados elementais | Lendário | 36 | 2.6 | 15.0m | [`WEP-079.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Staves_Catalysts/WEP-079.md) |
| `WEP-080` | Coroa de Miasma Primordial | Cajados e catalisadores | Catalisadores lendários | Abissal / Relíquia | 45 | 1.4 | 15.0m | [`WEP-080.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Staves_Catalysts/WEP-080.md) |
| `WEP-081` | Lâmina Viva de Carne Abissal | Armas especiais | Armas vivas | Épico | 45 | 2.8 | 2.5m | [`WEP-081.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Special_Weapons/WEP-081.md) |
| `WEP-082` | Cutelo da Praga Imortal | Armas especiais | Armas amaldiçoadas | Raro | 38 | 4.5 | 2.5m | [`WEP-082.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Special_Weapons/WEP-082.md) |
| `WEP-083` | Corrente de Espinhos de Azaroth | Armas especiais | Armas demoníacas | Lendário | 52 | 5.8 | 2.5m | [`WEP-083.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Special_Weapons/WEP-083.md) |
| `WEP-084` | Martelo da Primeira Fratura | Armas especiais | Armas ancestrais | Lendário | 62 | 10.5 | 2.5m | [`WEP-084.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Special_Weapons/WEP-084.md) |
| `WEP-085` | Cetro do Vórtice Final | Armas especiais | Armas primordiais | Abissal / Relíquia | 58 | 3.2 | 2.5m | [`WEP-085.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Special_Weapons/WEP-085.md) |
| `WEP-086` | Lâmina Transformável da Fenda | Armas especiais | Armas mecânicas | Épico | 44 | 3.9 | 2.5m | [`WEP-086.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Special_Weapons/WEP-086.md) |
| `WEP-087` | Chicote de Fogo Candente | Armas especiais | Armas de energia | Raro | 36 | 1.6 | 2.5m | [`WEP-087.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Special_Weapons/WEP-087.md) |
| `WEP-088` | Bastão de Ignis'Khar | Armas especiais | Armas de chefe (BOSS-001) | Lendário | 56 | 5.2 | 2.5m | [`WEP-088.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Special_Weapons/WEP-088.md) |
| `WEP-089` | Foice de Cruor'Zul | Armas especiais | Armas de chefe (BOSS-012) | Lendário | 60 | 4.8 | 2.5m | [`WEP-089.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Special_Weapons/WEP-089.md) |
| `WEP-090` | Devoradora de Mundos de Azaroth | Armas especiais | Arma suprema de World Boss | Abissal / Relíquia | 85 | 7.5 | 2.5m | [`WEP-090.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Special_Weapons/WEP-090.md) |
| `WEP-091` | Escudo Torre de Ferro Negro | Escudos e defensivos | Escudos torre | Raro | 8 | 8.4 | 1.0m | [`WEP-091.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Shields/WEP-091.md) |
| `WEP-092` | Broquel de Cinzas Endurecidas | Escudos e defensivos | Escudos pequenos | Comum | 5 | 1.8 | 1.0m | [`WEP-092.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Shields/WEP-092.md) |
| `WEP-093` | Escudo Gota de Bronze Vulcânico | Escudos e defensivos | Escudos médios | Incomum | 6 | 3.8 | 1.0m | [`WEP-093.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Shields/WEP-093.md) |
| `WEP-094` | Pavise dos Guardiões da Caldeira | Escudos e defensivos | Escudos grandes | Raro | 7 | 7.2 | 1.0m | [`WEP-094.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Shields/WEP-094.md) |
| `WEP-095` | Escudo Rúnico da Barreira de Basalto | Escudos e defensivos | Escudos mágicos | Épico | 10 | 6.5 | 1.0m | [`WEP-095.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Shields/WEP-095.md) |
| `WEP-096` | Carapaça Quitínica do Pântano | Escudos e defensivos | Escudos biológicos | Incomum | 6 | 2.2 | 1.0m | [`WEP-096.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Shields/WEP-096.md) |
| `WEP-097` | Escudo Espelhado de Obsidiana | Escudos e defensivos | Escudos refletores | Épico | 9 | 5.4 | 1.0m | [`WEP-097.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Shields/WEP-097.md) |
| `WEP-098` | Muralha da Forja Eterna | Escudos e defensivos | Escudos torre pesados | Lendário | 12 | 12.0 | 1.0m | [`WEP-098.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Shields/WEP-098.md) |
| `WEP-099` | Escudo do Crânio de Titã | Escudos e defensivos | Escudos demoníacos | Lendário | 15 | 9.0 | 1.0m | [`WEP-099.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Shields/WEP-099.md) |
| `WEP-100` | Égide Primordial das Profundezas | Escudos e defensivos | Escudos lendários | Abissal / Relíquia | 18 | 7.0 | 1.0m | [`WEP-100.md`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/Weapons/Shields/WEP-100.md) |
