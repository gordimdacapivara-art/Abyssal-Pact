# Relatório Oficial de Construção: As 10 Regiões 3D de Khar-Duum (ABYSSAL PACT)

> **Documento Oficial de Engenharia de Ambientes 3D e Level Design**  
> **Continente:** Khar-Duum (`CONT-03`) — Quadrante Sudoeste  
> **Status:** 10 Regiões 3D Construídas, Integradas e Validadas  
> **Motor Gráfico:** Godot Engine 4.7.2  
> **Modelagem e ArtSource:** Blender 5.3.0 Headless (`AbyssalPact_ArtSource/Blender/`)  
> **Validação Automatizada:** 3.392 checks, 0 falhas (100% aprovado)

---

## 1. Resumo Executivo

O continente **Khar-Duum** (`CONT-03`) materializa a estética industrial, vulcânica e subterrânea de **ABYSSAL PACT**. Localizado no quadrante sudoeste do globo, delimitado por cânions áridos, desertos vitrificados e fossas magmáticas abissais, Khar-Duum foi desenvolvido em absoluta consonância com a cartografia canônica do projeto.

Todas as **dez regiões (REG-021 a REG-030)** foram estruturadas como **cenas 3D dedicadas individuais** (`caldeira_rubra.tscn` a `cratera_do_coracao.tscn`, com seus respectivos aliases canônicos `region_021.tscn` a `region_030.tscn`), contemplando:
1. Malha de terreno individual com materiais PBR de basalto, escória metálica, obsidiana vítrea e carvão betuminoso.
2. Sistema de limites geográficos perimetrais (`WorldBoundary`).
3. Malha de navegação 3D ativa (`NavigationRegion3D`) em todas as 10 regiões.
4. Partículas atmosféricas exclusivas de Khar-Duum (`GPUParticles3D` com poeira de cinzas, areia magnética e brasas incandescentes carreadas por rajadas térmicas direcionadas).
5. Assentamentos e cidades industriais/subterrâneas com zonas seguras ativas (`SafeZone`, raio de 22m).
6. Entradas de masmorras de alta profundidade com áreas de detecção e descoberta.
7. Arenas exclusivas para os 7 chefes demoníacos de Khar-Duum (`BOSS-017` a `BOSS-023`).
8. Portais arcanos intercontinentais de acesso e ressurgimento na **Hell Forge** (na capital `REG-021` e no clímax vulcânico `REG-030`).

---

## 2. Modelagem 3D e Pipeline de Assets (Blender 5.3 -> Godot 4)

Em conformidade rigorosa com o pipeline de assets:
- **Arquivos-fonte de modelagem (.blend):** Armazenados exclusivamente fora da árvore do motor, em `AbyssalPact_ArtSource/Blender/` categorizados nas subpastas `Structures`, `Props` e `Rocks`.
- **Assets de tempo de execução (.glb):** Exportados diretamente para `assets/models/environment/` com metadados `.import` gerados e validados pelo Godot.

### Tabela de Novos Modelos 3D Criados

| Modelo GLB | Categoria | Região Principal | Dimensões | Material / Efeito PBR |
|---|---|---|---|---|
| `structure_rubra_caldera_vent.glb` | Structures | 21. Caldeira Rubra | 13m x 13m x 9m | Cone de basalto vulcânico com bacia de magma incandescente (4.8x emissive) |
| `prop_volcanic_vent_horn.glb` | Props | 21. Caldeira Rubra | 4.4m x 4.4m x 4.2m | Corneta de escória com fenda de lava ativa pulsante |
| `structure_kings_forge_citadel.glb` | Structures | 22. Fornalha dos Reis | 20m x 16m x 17m | Cidadela de forja com 4 chaminés industriais e calha de metal fundido (5.0x) |
| `prop_colossal_forge_anvil.glb` | Props | 22. Fornalha dos Reis | 6m x 3.5m x 4m | Bigorna monumental de aço temperado com lingote em forjamento |
| `rock_obsidian_canyon_gate.glb` | Rocks | 23. Desfiladeiro de Obsidiana | 14m x 8m x 17.5m | Agulhas gêmeas de obsidiana negra pura facetada com veio de lava basal |
| `structure_slag_refinery_furnace.glb` | Structures | 24. Mar de Escória | 11m x 11m x 13m | Cuba cilíndrica de refino com exaustor cônico e 3 portais de purga de escória |
| `rock_vitrified_glass_dune_ridge.glb` | Rocks | 25. Dunas de Vidro Negro | 16m x 7m x 6m | Crista de duna de areia negra magnética com 5 espículas de vidro fundido |
| `structure_tharum_mine_headframe.glb` | Structures | 26. Minas de Tharum | 10m x 4m x 13m | Torre de extração mineira com roda de cabos e pórtico de madeira petrificada |
| `prop_mining_ore_cart_track.glb` | Props | 26. Minas de Tharum | 4m x 9m x 2m | Trilhos de ferro e vagonete pesado carregado com minério bruto de Tharum |
| `structure_monumental_chain_bridge.glb` | Structures | 27. Ponte das Correntes | 15m x 18m x 17m | Pilares gêmeos sobre o abismo, deck suspenso e cabos de correntes titânicas |
| `prop_titan_chain_link.glb` | Props | 27. Ponte das Correntes | 4m x 4m x 6m | Bloco de basalto com 3 elos ciclópeos entrelaçados de ferro abissal |
| `structure_lightning_conductor_spire.glb` | Structures | 28. Planalto do Trovão | 5m x 5m x 17.5m | Agulha condutora de ferro com 3 anéis coletores e orbe de plasma estático |
| `rock_coal_chasm_archway.glb` | Rocks | 29. Garganta do Carvão | 13m x 5m x 8m | Arco de caverna em antracito com estalagmites de fuligem e fenda de brasa |
| `structure_heart_crater_monolith.glb` | Structures | 30. Cratera do Coração | 20m x 20m x 19m | Monolito de contenção com 4 anéis orbitais e núcleo de energia ancestral (5.5x) |

---

## 3. Detalhamento Técnico das Dez Regiões 3D de Khar-Duum

### 21. Caldeira Rubra (`REG-021`)
- **Tema:** Região vulcânica ativa, caldeiras magmáticas e capital de Khar-Duum.
- **Bioma:** `ash_desert` | **Nível Recomendado:** 20–30
- **Arquitetura e Relevo:** Planície de cinzas vulcânicas escuras sulcada por fendas de lava ativas. O monumento central `RubraCalderaVent` ergue-se como uma chaminé basáltica com piscina de magma borbulhante.
- **Pontos de Interesse:**
  - *Cidade:* Caravansarai das Chamas (`poi_reg021_city`) com SafeZone circular.
  - *Masmorra:* Cripta dos Nômades de Fogo (`dungeon_flame_nomads`).
  - *Exploração:* Chaminé da Caldeira Rubra (`poi_caldera_vent`).
  - *Chefe:* `BOSS-017` na "Arena do Fogo Primordial".
- **Spawns Demoníacos:** `DEMON-101` a `DEMON-105`.
- **Conexões:** `REG-022` (norte), `REG-023` (sul) e Portal Intercontinental para a **Hell Forge**.

### 22. Fornalha dos Reis (`REG-022`) — Destaque de Arquitetura Monumental de Cidade-Forja
- **Tema:** A grande cidade-forja monumental dos reis metalúrgicos antigos.
- **Bioma:** `forge_city` | **Nível Recomendado:** 22–30
- **Arquitetura e Relevo:** Megalópole industrial escura construída com lajes de ferro rebitadas e cantaria pesada. O complexo `KingsForgeCitadel` ostenta quatro chaminés de exaustão de 17 metros, portal cololossal e calhas onde rios de bronze e ferro fundido escoam continuamente até a grande praça da bigorna (`GreatAnvilSquare`).
- **Pontos de Interesse:**
  - *Cidade:* Cidadela das Forjas (`poi_reg022_city`).
  - *Masmorra:* Garras da Fundição (`dungeon_foundry_claws`).
  - *Exploração:* A Grande Bigorna de Adamante (`poi_colossal_anvil`).
  - *Chefe:* `BOSS-018` na "Câmara do Metal Derretido".
- **Spawns Demoníacos:** `DEMON-106` a `DEMON-110`.
- **Conexões:** `REG-021` (norte) e `REG-024` (sul).

### 23. Desfiladeiro de Obsidiana (`REG-023`)
- **Tema:** Cânion profundo esculpido em vidro vulcânico negro cortante.
- **Bioma:** `obsidian_canyon` | **Nível Recomendado:** 23–31
- **Arquitetura e Relevo:** Garganta estreita e profunda flanqueada por paredes verticais espelhadas de obsidiana. O monumento `ObsidianCanyonGate` marca o estrangulamento do desfiladeiro com duas agulhas facetadas de quase 18 metros de altura com reflexos afiados e veio de lava basal.
- **Pontos de Interesse:**
  - *Cidade:* Posto do Espelho Negro (`poi_reg023_city`).
  - *Masmorra:* Abismo dos Cacos Afiados (`dungeon_sharp_shards`).
  - *Exploração:* Pináculos Gêmeos de Vidro Negro (`poi_obsidian_gate`).
  - *Chefe:* `BOSS-019` na "Fenda dos Reflexos Quebrados".
- **Spawns Demoníacos:** `DEMON-111` a `DEMON-115`.
- **Conexões:** `REG-021` (norte) e `REG-025` (sul).

### 24. Mar de Escória (`REG-024`)
- **Tema:** Vastidão estéril de resíduos industriais e crostas de ferro solidificado.
- **Bioma:** `slag_sea` | **Nível Recomendado:** 24–32
- **Arquitetura e Relevo:** Terreno acidentado coberto por placas de escória quebradas e poças de escória cáustica. A refinaria fóssil `SlagRefineryFurnace` domina o relevo com sua cuba de decantação e portas de purga em chamas.
- **Pontos de Interesse:**
  - *Cidade:* Acampamento da Escória (`poi_reg024_city`).
  - *Masmorra:* Fornalha das Cinzas Mortas (`dungeon_dead_ash_furnace`).
  - *Exploração:* Refinaria dos Resíduos Vulcânicos (`poi_slag_refinery`).
  - *Chefe:* `BOSS-020` no "Lago de Ferro Petrificado".
- **Spawns Demoníacos:** `DEMON-116` a `DEMON-120`.
- **Conexões:** `REG-022` (norte) e `REG-026` (sul).

### 25. Dunas de Vidro Negro (`REG-025`)
- **Tema:** Deserto escaldante de areias magnéticas vitrificadas e lâminas de quartzo.
- **Bioma:** `vitrified_dunes` | **Nível Recomendado:** 25–33
- **Arquitetura e Relevo:** Dunas negras ondulantes que cintilam sob o sol abrasador. O marco `VitrifiedGlassDuneRidge` apresenta espículas translúcidas afiadas que brotam do solo como dentes de dragão.
- **Pontos de Interesse:**
  - *Cidade:* Oásis Vitrificado (`poi_reg025_city`).
  - *Masmorra:* Cripta da Sílica Fundida (`dungeon_molten_silica`).
  - *Exploração:* Crista dos Espelhos Afiados (`poi_glass_dune_ridge`).
  - *Chefe:* `BOSS-021` na "Duna dos Cristais Negros".
- **Spawns Demoníacos:** `DEMON-121` a `DEMON-125`.
- **Conexões:** `REG-023` (norte) e `REG-026` (sul).

### 26. Minas de Tharum (`REG-026`) — Destaque de Complexidade Subterrânea
- **Tema:** Labirinto subterrâneo monumental de extração de minérios raros.
- **Bioma:** `tharum_mines` | **Nível Recomendado:** 26–34
- **Arquitetura e Relevo:** Ambiente em cavernas profundas com escoramentos maciços em madeira petrificada e treliças de ferro. O conjunto `TharumMineHeadframe` e `OreCartTracksNorth` implementa uma torre de poço de extração com roldanas de cabos de aço e linhas de vagonetes carregadas com minério bruto ressonante.
- **Pontos de Interesse:**
  - *Cidade:* Guarnição de Tharum (`poi_reg026_city`).
  - *Masmorra:* Poço Profundo dos Mineiros (`dungeon_miners_deep_pit`).
  - *Exploração:* Torre de Içamento de Tharum (`poi_mine_headframe`).
  - *Chefe:* `BOSS-022` no "Salão dos Filões Perdidos".
- **Spawns Demoníacos:** `DEMON-126` a `DEMON-130`.
- **Conexões:** `REG-024` (norte), `REG-025` (sul) e `REG-027` (leste).

### 27. Ponte das Correntes (`REG-027`) — Destaque de Grandes Estruturas Elevadas
- **Tema:** Desfiladeiro colossal transposto por pontes suspensas sobre abismos vertiginosos.
- **Bioma:** `chain_bridge` | **Nível Recomendado:** 27–35
- **Arquitetura e Relevo:** Paredes de falésias abissais unidas por elos de corrente de dimensões ciclópicas. A estrutura `MonumentalChainBridge` ergue pilares de 17 metros nas margens do precipício sustentando uma passarela de madeira-ferro, amparada pelas âncoras de basalto `TitanChainAnchor`.
- **Pontos de Interesse:**
  - *Cidade:* Vigia do Abismo (`poi_reg027_city`).
  - *Masmorra:* Fosso das Correntes Quebradas (`dungeon_broken_chains_chasm`).
  - *Exploração:* O Grande Elo do Titã (`poi_titan_chain_link`).
  - *Chefe:* `BOSS-023` no "Passadiço dos Ventos Abissais".
- **Spawns Demoníacos:** `DEMON-131` a `DEMON-135`.
- **Conexões:** `REG-026` (norte) e `REG-028` (sul).

### 28. Planalto do Trovão (`REG-028`)
- **Tema:** Platô de alta altitude assolado por tempestades elétricas perpétuas.
- **Bioma:** `thunder_plateau` | **Nível Recomendado:** 28–36
- **Arquitetura e Relevo:** Platô rochoso magnetizado com formações metálicas pontiagudas. O obelisco `LightningConductorSpire` atrai continuamente descargas de relâmpagos através de seus três anéis toroidais para alimentar um orbe de plasma estático no cume.
- **Pontos de Interesse:**
  - *Cidade:* Abrigo dos Relâmpagos (`poi_reg028_city`).
  - *Masmorra:* Câmara da Centelha Eterna (`dungeon_eternal_spark`).
  - *Exploração:* Obelisco Para-Raios dos Antigos (`poi_lightning_spire`).
  - *Chefe:* Sem chefe regional (zona de travessia e provação elementar).
- **Spawns Demoníacos:** `DEMON-136` a `DEMON-140`.
- **Conexões:** `REG-027` (norte) e `REG-029` (sul).

### 29. Garganta do Carvão (`REG-029`)
- **Tema:** Região subterrânea escura, claustrofóbica e coberta de fuligem densa.
- **Bioma:** `coal_chasm` | **Nível Recomendado:** 29–38
- **Arquitetura e Relevo:** Galerias subterrâneas de antracito negro profundo com névoa pesada de fuligem (`fog_density = 0.020`). O arco natural `CoalChasmArchway` delineia a entrada das câmaras profundas com estalagmites de fuligem e fendas cáusticas incandescentes.
- **Pontos de Interesse:**
  - *Cidade:* Posto do Ar Opressivo (`poi_reg029_city`).
  - *Masmorra:* Labirinto das Galerias Negras (`dungeon_black_galleries`).
  - *Exploração:* Pórtico Natural de Antracito (`poi_coal_archway`).
  - *Chefe:* Sem chefe regional (preparação para o clímax).
- **Spawns Demoníacos:** `DEMON-141` a `DEMON-145`.
- **Conexões:** `REG-028` (norte) e `REG-030` (sul).

### 30. Cratera do Coração (`REG-030`) — Região de Destaque Visual Monumental
- **Tema:** O núcleo telúrico e a fonte de energia magmática ancestral de Khar-Duum.
- **Bioma:** `heart_crater` | **Nível Recomendado:** 30–40
- **Arquitetura e Relevo:** Uma colossal cratera escalonada de basalto e escória ardente. No centro absoluto repousa o `HeartCraterMonolith`, uma torre de contenção com quatro anéis rúnicos orbitais que levitam ao redor de uma esfera de magma primordial com emissão de calor extremo (5.5x), marcando o coração energético do continente.
- **Pontos de Interesse:**
  - *Cidade:* Santuário do Coração Magmático (`poi_reg030_city`).
  - *Masmorra:* Núcleo Telúrico Primordial (`dungeon_primordial_core`).
  - *Exploração:* O Monolito do Coração da Terra (`poi_heart_monolith`).
  - *Chefe:* Santuário primordial. Portal terminal ativo para a **Hell Forge**.
- **Spawns Demoníacos:** `DEMON-146` a `DEMON-150`.
- **Conexões:** `REG-029` (norte) e Portal Intercontinental para a **Hell Forge**.

---

## 4. Registro de Assets Pendentes (Documentação Oficial)

Catalogamos os assets de ultra-alta fidelidade para futuras iterações estéticas:

| Código do Asset | Região Associada | Tipo | Descrição para Produção de Arte Futura |
|---|---|---|---|
| `shader_lava_flow_direction_distortion` | REG-021 | Shader VFX | Shader de fluxo de lava fluida com distorção por calor e mapa de normais cáusticos dinâmicos |
| `mesh_kings_forge_giant_cogwheels` | REG-022 | Modelo 3D / Mecanismo | Engrenagens ciclópicas animadas girando em velocidade lenta sobre os aquedutos de fundição |
| `shader_obsidian_sharp_fresnel_glint` | REG-023 | Shader PBR | Reflexo de Fresnel agudo para vidro vulcânico com aberração cromática nas arestas |
| `particles_slag_smoke_plumes` | REG-024 | GPU Particles | Colunas volumétricas densas de fumaça cinzenta carregadas de cinzas tóxicas pesadas |
| `vfx_vitrified_glass_sparkle_dune` | REG-025 | Partículas GPU | Centelhas especulares estáticas simulando microcristais de vidro refletindo o sol do deserto |
| `props_mining_drill_pneumatic_rig` | REG-026 | Props 3D | Perfuratriz a vapor pesada sobre trilhos para escavação de galerias subterrâneas profundas |
| `audio_abyss_chain_creaking_spatial` | REG-027 | Áudio 3D | Gemido metálico espacial de elos de corrente titânicos oscilando com ventos de alta altitude |
| `vfx_thunder_arc_discharge_spire` | REG-028 | VFX Elétrico | Arcos voltaicos procedurais saltando periodicamente da agulha para o terreno |
| `fog_coal_dust_subterranean_density` | REG-029 | Shader Volume | Névoa de fuligem escura anisotrópica simulando atmosfera irrespirável de mina profunda |
| `shader_heart_crater_pulsing_core` | REG-030 | Shader Emissivo | Pulsação radial harmônica do núcleo magmático sincronizada com os anéis rúnicos orbitais |

---

## 5. Matriz de Cobertura de Testes

Os testes automatizados em Godot Engine (`tests/run_tests.tscn`) foram executados com cobertura total para Khar-Duum:
- **Suite ENVIRONMENT_PIPELINE:**
  - 14 novos modelos GLB instanciados e validados com malhas reais.
  - 10 novas cenas 3D carregadas e inspecionadas dinamicamente (`caldeira_rubra.tscn` a `cratera_do_coracao.tscn`).
  - Verificação de SafeZones urbanas (`CityForge`), arenas de chefe, malhas de navegação (NavMesh), barreiras perimetrais e partículas atmosféricas térmicas.
- **Suite OPEN_WORLD:**
  - 30 regiões em produção completa (`full_production`) com cenas dedicadas validadas no disco (`REG-001` a `REG-030`).
  - 10 regiões em staging modular funcional (`REG-031` a `REG-040` de Nhal'Kora).
  - Validação do carregador modular dinâmico com `REG-031`.

**Resultado Consolidado dos Testes:**
- Total de suítes executadas: 20
- Total de verificações (checks): **3.392 checks**
- Total de falhas: **0 falhas**
- Taxa de sucesso: **100% aprovado**
