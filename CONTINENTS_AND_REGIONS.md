# Abyssal Pact — Continentes e Regiões

## Continentes confirmados

| ID | Nome | Identidade confirmada | Regiões atribuídas | Capital / Assentamento | Clima / Tema |
|---|---|---|---|---|---|
| CONT-01 | Veyrath | Vulcânico / Fissuras e Cinzas | REG-001–REG-010 (10) | Baluarte das Cinzas (REG-001) | Árido e cáustico; cinzas e rios de lava |
| CONT-02 | Sylvaran | Floresta Ancestral e Pântanos | REG-011–REG-020 (10) | Bosque das Almas (REG-011) | Subtropical úmido; névoas espectrais e pântanos |
| CONT-03 | Khar-Duum | Cânions e Deserto de Areias Negras | REG-021–REG-030 (10) | Fortaleza de Basalto (REG-021) | Desértico tórrido; tempestades de poeira e cânions |
| CONT-04 | Nhal'Kora | Litoral Abissal e Névoas Glaciais | REG-031–REG-040 (10) | Cidadela dos Afogados (REG-031) | Polar/oceânico; frio perene e fendas abissais |

**Total:** 4 continentes, 40 regiões (exatamente 10 regiões por continente).

---

## Estado do Registro e Implementação no Sistema (21/11/2026)

O sistema de mundo aberto de ABYSSAL PACT foi implementado em arquitetura data-driven desacoplada, integrando 14 subsistemas fundamentais:
1. **Sistema de Continentes** (`ContinentData` + `data/content/continents/*.tres`).
2. **Sistema de Regiões** (`RegionData` + `data/content/regions/*.tres`).
3. **Carregamento de Mapas** (`WorldManager.load_region()` sob demanda).
4. **Transições entre Regiões** (`WorldManager.transition_to_region()`, spawn markers dinâmicos).
5. **Limites Geográficos** (`WorldBoundary` com raio e barreira visual).
6. **Portais de Teleporte** (`WorldPortal` para Hell Forge e capitais).
7. **Pontos de Interesse (POIs)** (`PointOfInterest` com detecção, tipo, XP e notificações).
8. **Cidades e Assentamentos** (`SafeZone` desativando hostilidade).
9. **Masmorras** (`DungeonEntrance` com requisito de nível).
10. **Áreas de Chefes** (`BossArenaZone` circular integrada ao `BossEncounter`).
11. **Pontos de Exploração** (`ExplorationSpot` com monólitos e mirantes).
12. **Regiões Descobertas** (`WorldManager.discover_region()`, persistido no Character e WorldSession).
13. **Marcadores de Mapa** (`WorldManager.get_region_markers()`).
14. **Salvamento de Exploração** (coleta e restauração via `WorldSessionData`).

---

## Catálogo Canônico das 40 Regiões

| ID | Nome Canônico | Cont. | Bioma | Nível | Cidade / Posto | Masmorra | Chefe Associado | Status |
|---|---|---|---|---|---|---|---|---|
| REG-001 | Planície Cinzenta de Veyrath | CONT-01 | ash_plains | 1–5 | Baluarte das Cinzas | Catacumbas de Basalto | BOSS-001 | `full_production` |
| REG-002 | Fendas de Enxofre | CONT-01 | sulfur_crags | 3–7 | Posto de Enxofre | Minas de Pirita | — | `modular_staging` |
| REG-003 | Desfiladeiro de Magma | CONT-01 | magma_gorge | 5–10 | Acampamento da Forja | Cavernas Candentes | BOSS-002 | `modular_staging` |
| REG-004 | Pântano de Cinzas | CONT-01 | ash_mire | 8–12 | Aldeia Queimada | Fosso Lamacento | — | `modular_staging` |
| REG-005 | Picos de Obsidiana | CONT-01 | obsidian_peaks | 10–15 | Posto das Agulhas | Câmara das Lâminas | BOSS-003 | `modular_staging` |
| REG-006 | Deserto Fuliginoso | CONT-01 | soot_desert | 13–17 | Refúgio de Sílica | Túmulo dos Ventos | — | `modular_staging` |
| REG-007 | Cratera Abissal de Ferro | CONT-01 | iron_crater | 15–20 | Guarnição de Chumbo | Complexo de Ferro Profundo | BOSS-004 | `modular_staging` |
| REG-008 | Terra Férrea | CONT-01 | scorched_earth | 18–22 | Fortim de Ferro | Mina dos Condenados | — | `modular_staging` |
| REG-009 | Garganta Calcinada | CONT-01 | burnt_canyon | 20–25 | Posto do Abismo | Cripta dos Condenados | BOSS-005 | `modular_staging` |
| REG-010 | Voo de Cinzas | CONT-01 | caldera_edge | 23–28 | Santuário da Cinza | Santuário do Fogo Profundo | BOSS-006 | `modular_staging` |
| REG-011 | Bosque Sussurrante | CONT-02 | whispering_woods | 1–6 | Bosque das Almas | Raízes Esquecidas | BOSS-009 | `modular_staging` |
| REG-012 | Pântano Espectral | CONT-02 | spectral_fen | 4–8 | Refúgio da Bruma | Galeria dos Afogados | — | `modular_staging` |
| REG-013 | Clareira das Runas | CONT-02 | rune_glade | 6–10 | Posto Rúnico | Cripta dos Símbolos | BOSS-010 | `modular_staging` |
| REG-014 | Raízes Antigas | CONT-02 | ancient_roots | 9–13 | Vila do Tronco Oco | Labirinto das Raízes | — | `modular_staging` |
| REG-015 | Vale dos Salgueiros Negros | CONT-02 | black_willows | 12–16 | Acampamento Fúnebre | Túmulo das Lágrimas | BOSS-011 | `modular_staging` |
| REG-016 | Cume das Névoas | CONT-02 | misty_ridge | 14–18 | Mirante das Brumas | Salão Enevoado | — | `modular_staging` |
| REG-017 | Pântano de Sangue | CONT-02 | blood_mire | 17–21 | Fortaleza Rubra | Fosso dos Sacrifícios | BOSS-012 | `modular_staging` |
| REG-018 | Selva das Sombras | CONT-02 | shadow_jungle | 19–23 | Posto do Dossel | Antro das Vinhas Negras | — | `modular_staging` |
| REG-019 | Fenda Esmeralda | CONT-02 | emerald_fissure | 22–26 | Vila Esmeralda | Cavernas dos Cristais Verdes | BOSS-013 | `modular_staging` |
| REG-020 | Coração da Floresta Abissal | CONT-02 | abyssal_heart | 25–30 | Santuário da Seiva | Santuário Corrompido | BOSS-014 | `modular_staging` |
| REG-021 | Dunas de Areia Negra | CONT-03 | black_sand_dunes | 1–6 | Fortaleza de Basalto | Templo Soterrado | BOSS-017 | `modular_staging` |
| REG-022 | Cânion dos Ventos Áridos | CONT-03 | dry_canyon | 4–8 | Posto das Gargantas | Fenda dos Uivos | — | `modular_staging` |
| REG-023 | Oásis da Serpente | CONT-03 | serpent_oasis | 7–11 | Vila da Miragem | Poço dos Antigos | BOSS-018 | `modular_staging` |
| REG-024 | Platô Escaldante | CONT-03 | sunscorched_plateau | 10–14 | Refúgio da Rocha | Mina de Enxofre Solar | — | `modular_staging` |
| REG-025 | Vale dos Monólitos | CONT-03 | monolith_valley | 13–17 | Acampamento das Estelas | Cripta dos Gigantes | BOSS-019 | `modular_staging` |
| REG-026 | Fenda de Sal | CONT-03 | salt_flats | 15–19 | Posto do Sal Branco | Catacumbas Cristalinas | — | `modular_staging` |
| REG-027 | Cidadela Vermelha | CONT-03 | red_citadel | 18–22 | Baluarte Vermelho | Masmorras da Forja | BOSS-020 | `modular_staging` |
| REG-028 | Labirinto de Cânions | CONT-03 | canyon_labyrinth | 20–24 | Posto da Poeira | Gruta das Sombras Quentes | — | `modular_staging` |
| REG-029 | Deserto Silencioso | CONT-03 | silent_waste | 23–27 | Acampamento Ermo | Tumba do Vento Perdido | BOSS-021 | `modular_staging` |
| REG-030 | Garganta do Fogo Profundo | CONT-03 | deepfire_gorge | 26–32 | Fortaleza Subterrânea | Altar das Profundezas | BOSS-022 | `modular_staging` |
| REG-031 | Baía dos Afogados | CONT-04 | drowned_bay | 1–6 | Cidadela dos Afogados | Naufrágio do Leviatã | BOSS-025 | `modular_staging` |
| REG-032 | Penhascos Espectrais | CONT-04 | ghostly_cliffs | 4–8 | Posto do Farol | Catacumbas da Falésia | — | `modular_staging` |
| REG-033 | Recife Abissal | CONT-04 | abyssal_reef | 7–11 | Aldeia das Marés | Fenda de Coral Negro | BOSS-026 | `modular_staging` |
| REG-034 | Costa das Névoas Frias | CONT-04 | cold_coast | 10–14 | Vila do Quebra-Mar | Grota dos Ventos Glaciais | — | `modular_staging` |
| REG-035 | Fjord dos Condenados | CONT-04 | damned_fjord | 13–17 | Refúgio dos Remadores | Caverna das Almas Perdidas | BOSS-027 | `modular_staging` |
| REG-036 | Geleira Sussurrante | CONT-04 | frozen_expanse | 16–20 | Posto Glacial | Mina de Gelo Negro | — | `modular_staging` |
| REG-037 | Estuário dos Sussurros | CONT-04 | whisper_estuary | 19–23 | Posto do Canal | Túmulo do Naufrágio | BOSS-028 | `modular_staging` |
| REG-038 | Maré Eterna | CONT-04 | eternal_tide | 22–26 | Acampamento das Marés | Fenda Profunda das Conchas | — | `modular_staging` |
| REG-039 | Fossa Oceânica | CONT-04 | oceanic_trench | 25–29 | Cidadela Submersa | Altar das Correntes | BOSS-029 | `modular_staging` |
| REG-040 | Fim do Abismo | CONT-04 | abyssal_end | 28–35 | Santuário Abissal | Vórtice Final | BOSS-030 | `modular_staging` |

---

## Estratégia de Desenvolvimento e Modelos

### 1. Região Piloto de Produção Completa (REG-001 Veyrath)
- Localização: `scenes/world/regions/region_001.tscn` + `scenes/world/regions/region_001.gd`.
- Terreno de cinzas estruturado (360×360 m) com fenda de lava iluminada e elevações colidentes.
- Cidade **Baluarte das Cinzas** com SafeZone funcional (raio 22 m) e POI de descoberta (+100 XP).
- Masmorra **Catacumbas de Basalto** (`DungeonEntrance`, nível mínimo 1).
- Arena de Chefe **Arena do Vazio Vulcânico** (`BOSS-001`).
- Portões de fronteira: GateNorth (`REG-002`) e GateSouth (`REG-003`).
- Portal arcano conectado a **Hell Forge**.
- 5 Spawners configurados para a fauna regional de Veyrath: `DEMON-001` a `DEMON-005`.

### 2. Estrutura Modular das Demais 39 Regiões (Modular Staging)
- Localização: `scenes/world/modular_region.tscn` + `scenes/world/modular_region.gd`.
- Construção dinâmica baseada em `RegionData` (`.tres`), adaptando iluminação, nevoeiro e paleta de cores por continente.
- Instanciação de limites, portões, portais, POIs, cidades, masmorras, arenas de chefes e 5 zonas de spawn para os demônios associados.
- Registro explícito de assets 3D pendentes no campo `pending_assets` de cada arquivo `.tres`, evitando falsas representações de conclusão de arte.
