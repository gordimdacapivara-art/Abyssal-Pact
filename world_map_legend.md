# Abyssal Pact — Legenda Oficial do Mapa-Múndi (World Map Legend)

> **Documento Oficial de Referência Cartográfica e Índice Territorial**  
> **Autoridade:** Cartógrafo Principal de ABYSSAL PACT  
> **Status:** Cânone Cartográfico Consolidado  
> **Versão:** 2.0.0 (Data-Driven / Visual Map Coherent)  
> **Arquivos Associados:** [world_map.svg](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/world_map.svg), [world_map.png](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/world_map.png), [world_map_layout.md](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/world_map_layout.md), [WORLD_MAP_DATA.json](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/WORLD_MAP_DATA.json), [REGION_GRAPH.json](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/REGION_GRAPH.json)

---

## 1. Visão Geral da Cartografia Visual

O **Mapa-Múndi Oficial de ABYSSAL PACT** foi projetado no estilo clássico **Dark Fantasy Medieval Cartography**, combinando o aspecto de pergaminho antigo envelhecido, relevo pictórico isométrico desenhado à mão (montanhas sombreadas, maciços florestais, dunas de areia negra, fissuras magmáticas e geleiras boreais), rosa dos ventos heráldica, graticulado de rumos náuticos e um sistema de indexação numérica que identifica todas as **40 regiões canônicas** sem comprometer a legibilidade artística do território.

```
+------------------------------------------------------------------------------------------------------+
|  ABYSSAL PACT — CHARTA TERRARUM ET PROFUNDI               [ HELL FORGE: DIMENSÃO INDEPENDENTE ]      |
+--------------------------------------------------------------------------------+---------------------+
|                                                                                | ÍNDICE DAS 40       |
|   [ CONT-01: VEYRATH (NW) ]                   [ CONT-02: SYLVARAN (NE) ]       | REGIÕES             |
|   Regiões 01 a 10                             Regiões 11 a 20                  |                     |
|   • Vulcânico, Imperial & Cinzas              • Floresta Ancestral & Ilhas     | • Veyrath (01-10)   |
|   • Picos de Obsidiana, Caldeira               • Raízes, Pântanos & Brumas     | • Sylvaran (11-20)  |
|                                                                                | • Khar-Duum (21-30) |
|                         ~~~~~~~~~~~~~~~~~~~~~~~~                               | • Nhal'Kora (31-40) |
|                         ~~~ MAR DA CICATRIZ ~~~                                |                     |
|                         ~~~ (Oceano Central) ~~~                               |                     |
|                         ~~~~~~~~~~~~~~~~~~~~~~~~                               | SIMBOLOGIA          |
|                                                                                | 🏙️ Cidade Segura   |
|   [ CONT-03: KHAR-DUUM (SW) ]                 [ CONT-04: NHAL'KORA (SE) ]      | 🏰 Masmorra         |
|   Regiões 21 a 30                             Regiões 31 a 40                  | ⚔️ Chefe Demoníaco  |
|   • Cânions Áridos & Dunas Negras             • Litoral Glacial & Fiordes      | 🌀 Portal Hell Forge|
|   • Cidadelas Subterrâneas & Sal              • Gelo Negro & Fossas Abissais   | ⚓ Rota Náutica     |
|                                                                                |                     |
|   [ROSA DOS VENTOS]     [ESCALA EM LÉGUAS]                                     | SELO CARTOGRÁFICO   |
+--------------------------------------------------------------------------------+---------------------+
```

---

## 2. Índice Completo das 40 Regiões (Identificadores 01 a 40)

Cada região representada visualmente em `world_map.svg` e `world_map.png` exibe um escudo heráldico circular com seu número cardinal de 01 a 40, sua etiqueta nominal e seu marcador de capital/cidade segura:

### Continente VEYRATH (`CONT-01`) — Noroeste (Escudos Vermelho-Ferrugem 01 a 10)

| Nº | ID | Nome Canônico | Bioma | Nível | Cidade / Posto Seguro | Masmorra Vinculada | Chefe Associado | Centro Cartográfico $(X, Y)$ | Pixel $(Px, Py)$ |
|---|---|---|---|---|---|---|---|---|---|
| **01** | `REG-001` | Planície Cinzenta de Veyrath | `ash_plains` | 1–5 | Baluarte das Cinzas | Catacumbas de Basalto | `BOSS-001` | $(0.24, 0.36)$ | $(666, 862)$ |
| **02** | `REG-002` | Fendas de Enxofre | `sulfur_crags` | 3–7 | Posto de Enxofre | Minas de Pirita | `BOSS-002` | $(0.36, 0.34)$ | $(950, 826)$ |
| **03** | `REG-003` | Desfiladeiro de Magma | `magma_gorge` | 5–10 | Acampamento da Forja | Cavernas Candentes | `BOSS-003` | $(0.18, 0.42)$ | $(525, 973)$ |
| **04** | `REG-004` | Pântano de Cinzas | `ash_mire` | 8–12 | Aldeia Queimada | Fosso Lamacento | `BOSS-004` | $(0.28, 0.24)$ | $(761, 642)$ |
| **05** | `REG-005` | Picos de Obsidiana | `obsidian_peaks` | 10–15 | Posto das Agulhas | Câmara das Lâminas | `BOSS-005` | $(0.11, 0.28)$ | $(360, 715)$ |
| **06** | `REG-006` | Deserto Fuliginoso | `soot_desert` | 13–17 | Refúgio de Sílica | Túmulo dos Ventos | `BOSS-006` | $(0.14, 0.15)$ | $(430, 476)$ |
| **07** | `REG-007` | Cratera Abissal de Ferro | `iron_crater` | 15–20 | Guarnição de Chumbo | Complexo de Ferro Profundo | `BOSS-007` | $(0.26, 0.14)$ | $(714, 458)$ |
| **08** | `REG-008` | Terra Férrea | `scorched_earth` | 18–22 | Fortim de Ferro | Mina dos Condenados | `BOSS-008` | $(0.38, 0.18)$ | $(997, 531)$ |
| **09** | `REG-009` | Garganta Calcinada | `burnt_canyon` | 20–25 | Posto do Abismo | Cripta dos Condenados | — | $(0.24, 0.07)$ | $(666, 329)$ |
| **10** | `REG-010` | Voo de Cinzas | `caldera_edge` | 23–28 | Santuário da Cinza | Santuário do Fogo Profundo | — | $(0.36, 0.08)$ | $(950, 347)$ |

---

### Continente SYLVARAN (`CONT-02`) — Nordeste (Escudos Verde-Esmeralda 11 a 20)

| Nº | ID | Nome Canônico | Bioma | Nível | Cidade / Posto Seguro | Masmorra Vinculada | Chefe Associado | Centro Cartográfico $(X, Y)$ | Pixel $(Px, Py)$ |
|---|---|---|---|---|---|---|---|---|---|
| **11** | `REG-011` | Bosque Sussurrante | `whispering_woods` | 1–6 | Bosque das Almas | Raízes Esquecidas | `BOSS-009` | $(0.64, 0.36)$ | $(1610, 862)$ |
| **12** | `REG-012` | Pântano Espectral | `spectral_fen` | 4–8 | Refúgio da Bruma | Galeria dos Afogados | `BOSS-010` | $(0.76, 0.38)$ | $(1894, 899)$ |
| **13** | `REG-013` | Clareira das Runas | `rune_glade` | 6–10 | Posto Rúnico | Cripta dos Símbolos | `BOSS-011` | $(0.66, 0.25)$ | $(1658, 660)$ |
| **14** | `REG-014` | Raízes Antigas | `ancient_roots` | 9–13 | Vila do Tronco Oco | Labirinto das Raízes | `BOSS-012` | $(0.78, 0.26)$ | $(1941, 678)$ |
| **15** | `REG-015` | Vale dos Salgueiros Negros | `black_willows` | 12–16 | Acampamento Fúnebre | Túmulo das Lágrimas | `BOSS-013` | $(0.88, 0.32)$ | $(2177, 789)$ |
| **16** | `REG-016` | Cume das Névoas | `misty_ridge` | 14–18 | Mirante das Brumas | Salão Enevoado | `BOSS-014` | $(0.58, 0.18)$ | $(1469, 531)$ |
| **17** | `REG-017` | Pântano de Sangue | `blood_mire` | 17–21 | Fortaleza Rubra | Fosso dos Sacrifícios | `BOSS-015` | $(0.88, 0.18)$ | $(2177, 531)$ |
| **18** | `REG-018` | Selva das Sombras | `shadow_jungle` | 19–23 | Posto do Dossel | Antro das Vinhas Negras | `BOSS-016` | $(0.77, 0.14)$ | $(1917, 458)$ |
| **19** | `REG-019` | Fenda Esmeralda | `emerald_fissure` | 22–26 | Vila Esmeralda | Cavernas dos Cristais Verdes | — | $(0.65, 0.10)$ | $(1634, 384)$ |
| **20** | `REG-020` | Coração da Floresta Abissal | `abyssal_heart` | 25–30 | Santuário da Seiva | Santuário Corrompido | — | $(0.78, 0.07)$ | $(1941, 329)$ |

---

### Continente KHAR-DUUM (`CONT-03`) — Sudoeste (Escudos Ocre-Dourado 21 a 30)

| Nº | ID | Nome Canônico | Bioma | Nível | Cidade / Posto Seguro | Masmorra Vinculada | Chefe Associado | Centro Cartográfico $(X, Y)$ | Pixel $(Px, Py)$ |
|---|---|---|---|---|---|---|---|---|---|
| **21** | `REG-021` | Dunas de Areia Negra | `black_sand_dunes` | 1–6 | Fortaleza de Basalto | Templo Soterrado | `BOSS-017` | $(0.36, 0.64)$ | $(950, 1378)$ |
| **22** | `REG-022` | Cânion dos Ventos Áridos | `dry_canyon` | 4–8 | Posto das Gargantas | Fenda dos Uivos | `BOSS-018` | $(0.24, 0.63)$ | $(666, 1359)$ |
| **23** | `REG-023` | Oásis da Serpente | `serpent_oasis` | 7–11 | Vila da Miragem | Poço dos Antigos | `BOSS-019` | $(0.38, 0.74)$ | $(997, 1562)$ |
| **24** | `REG-024` | Platô Escaldante | `sunscorched_plateau` | 10–14 | Refúgio da Rocha | Mina de Enxofre Solar | `BOSS-020` | $(0.13, 0.65)$ | $(407, 1396)$ |
| **25** | `REG-025` | Vale dos Monólitos | `monolith_valley` | 13–17 | Acampamento das Estelas | Cripta dos Gigantes | `BOSS-021` | $(0.26, 0.76)$ | $(714, 1598)$ |
| **26** | `REG-026` | Fenda de Sal | `salt_flats` | 15–19 | Posto do Sal Branco | Catacumbas Cristalinas | `BOSS-022` | $(0.12, 0.78)$ | $(383, 1635)$ |
| **27** | `REG-027` | Cidadela Vermelha | `red_citadel` | 18–22 | Baluarte Vermelho | Masmorras da Forja | `BOSS-023` | $(0.37, 0.86)$ | $(973, 1782)$ |
| **28** | `REG-028` | Labirinto de Cânions | `canyon_labyrinth` | 20–24 | Posto da Poeira | Gruta das Sombras Quentes | — | $(0.24, 0.87)$ | $(666, 1801)$ |
| **29** | `REG-029` | Deserto Silencioso | `silent_waste` | 23–27 | Acampamento Ermo | Tumba do Vento Perdido | — | $(0.12, 0.90)$ | $(383, 1856)$ |
| **30** | `REG-030` | Garganta do Fogo Profundo | `deepfire_gorge` | 26–32 | Fortaleza Subterrânea | Altar das Profundezas | — | $(0.28, 0.94)$ | $(761, 1930)$ |

---

### Continente NHAL'KORA (`CONT-04`) — Sudeste (Escudos Azul-Glacial 31 a 40)

| Nº | ID | Nome Canônico | Bioma | Nível | Cidade / Posto Seguro | Masmorra Vinculada | Chefe Associado | Centro Cartográfico $(X, Y)$ | Pixel $(Px, Py)$ |
|---|---|---|---|---|---|---|---|---|---|
| **31** | `REG-031` | Baía dos Afogados | `drowned_bay` | 1–6 | Cidadela dos Afogados | Naufrágio do Leviatã | `BOSS-024` | $(0.64, 0.64)$ | $(1610, 1378)$ |
| **32** | `REG-032` | Penhascos Espectrais | `ghostly_cliffs` | 4–8 | Posto do Farol | Catacumbas da Falésia | `BOSS-025` | $(0.77, 0.63)$ | $(1917, 1359)$ |
| **33** | `REG-033` | Recife Abissal | `abyssal_reef` | 7–11 | Aldeia das Marés | Fenda de Coral Negro | `BOSS-026` | $(0.63, 0.75)$ | $(1587, 1580)$ |
| **34** | `REG-034` | Costa das Névoas Frias | `cold_coast` | 10–14 | Vila do Quebra-Mar | Grota dos Ventos Glaciais | `BOSS-027` | $(0.88, 0.65)$ | $(2177, 1396)$ |
| **35** | `REG-035` | Fjord dos Condenados | `damned_fjord` | 13–17 | Refúgio dos Remadores | Caverna das Almas Perdidas | `BOSS-028` | $(0.75, 0.75)$ | $(1870, 1580)$ |
| **36** | `REG-036` | Geleira Sussurrante | `frozen_expanse` | 16–20 | Posto Glacial | Mina de Gelo Negro | `BOSS-029` | $(0.87, 0.76)$ | $(2153, 1598)$ |
| **37** | `REG-037` | Estuário dos Sussurros | `whisper_estuary` | 19–23 | Posto do Canal | Túmulo do Naufrágio | `BOSS-030` | $(0.69, 0.87)$ | $(1728, 1801)$ |
| **38** | `REG-038` | Maré Eterna | `eternal_tide` | 22–26 | Acampamento das Marés | Fenda Profunda das Conchas | — | $(0.81, 0.87)$ | $(2012, 1801)$ |
| **39** | `REG-039` | Fossa Oceânica | `oceanic_trench` | 25–29 | Cidadela Submersa | Altar das Correntes | — | $(0.68, 0.95)$ | $(1705, 1948)$ |
| **40** | `REG-040` | Fim do Abismo | `abyssal_end` | 28–35 | Santuário Abissal | Vórtice Final | — | $(0.82, 0.95)$ | $(2035, 1948)$ |

---

## 3. Simbologia Cartográfica Aplicada

No mapa vetorial e rasterizado, os seguintes pictogramas identificam os componentes territoriais:

1. **Escudos Numéricos (Badges 01 a 40):** Círculos de borda dupla sombreados com as cores da identidade continental:
   - *Veyrath:* Vermelho Vulcânico (`#802b12`) com contorno laranja (`#f08e56`).
   - *Sylvaran:* Verde Seiva (`#1b5e2b`) com contorno esmeralda (`#72e096`).
   - *Khar-Duum:* Ocre Terracota (`#875c12`) com contorno dourado (`#f5c862`).
   - *Nhal'Kora:* Azul Abissal (`#174e75`) com contorno ciano glacial (`#7ed2f7`).
2. **Capitais e Cidades Seguras (Ícone Dourado com Telhado Rubro):** Indicam zonas protegidas por `SafeZone` onde o combate hostil é suspenso, abrigando comerciantes, intendentes e curandeiros.
3. **Masmorras Regionais:** Indicadas na legenda lateral com a marcação 🏰, correspondendo aos pontos de interesse subterrâneos catalogados com nível mínimo de acesso.
4. **Chefes Demoníacos:** Regiões com chefes ativos ostentam na legenda lateral a identificação `[BOSS-XXX]`, correspondendo aos 30 chefes das arenas de combate.
5. **Vias Marítimas (Linhas Douradas Tracejadas):** As rotas de navegação cruzando o Mar da Cicatriz, conectando os quatro portos fortificados e as fendas profundas.

---

## 4. O Medalhão Dimensional da Hell Forge

Conforme determinação de design obrigatória, a **Hell Forge não figura como ilha nem continente físico**:

- **Posicionamento Visual:** Medallion planar circular heráldico no topo central do mapa ($X = 1280$, $Y = 95$), envolto por chamas astrais e runas de bronze dourado.
- **Inscrição Literal:**
  `"HELL FORGE — DIMENSÃO INDEPENDENTE • NEXUS PLANAR DE RESSURGIMENTO"`
  `"(Acessível estritamente por portais arcanos • Não pertence ao plano físico)"`
- **Conduítes Arcanos Conectados:**
  - Capital de Veyrath: `REG-001` (Baluarte das Cinzas).
  - Capital de Sylvaran: `REG-011` (Bosque das Almas).
  - Capital de Khar-Duum: `REG-021` (Fortaleza de Basalto).
  - Capital de Nhal'Kora: `REG-031` (Cidadela dos Afogados).
  - Fendas de Alto Nível: `REG-010`, `REG-020`, `REG-030`, `REG-040`.

---

## 5. O Mar da Cicatriz e a Rosa dos Ventos

- **Vórtice Central ($X = 1280, Y = 1120$):** Retratado com anéis concêntricos de sucção marítima em espiral e a silhueta em arte medieval do *Leviatã do Abismo*.
- **Rosa dos Ventos ($X = 360, Y = 1800$):** Bússola ornamental de 16 pontas em ouro e bronze com ponteiro superior apontando para o Norte boreal (*Septentrio*).
- **Escala Gráfica ($X = 820, Y = 1980$):** Barra alternada em preto e ouro graduada em incrementos de 50 até 200 Léguas Abissais ($1\text{ Légua} = 2,5\text{ km}$).
