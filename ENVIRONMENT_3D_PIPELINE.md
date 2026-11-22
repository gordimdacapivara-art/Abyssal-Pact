# ABYSSAL PACT — Pipeline de Construção de Ambientes 3D

Este documento estabelece a arquitetura oficial, os padrões técnicos, o fluxo de trabalho externo (Blender) e as diretrizes de integração interna (Godot 4) para a construção dos ambientes 3D das **40 regiões** do mundo de ABYSSAL PACT.

---

## 1. Visão Geral da Arquitetura

O pipeline de ambientes foi concebido sob princípios rigorosos de **modularidade, desacoplamento e consistência visual Dark Fantasy**:

1. **Modelagem Externa Profissional (Blender):** Modelagem de malhas, otimização de topologia, UV mapping e materiais base em arquivos `.blend` mantidos estritamente fora do repositório do jogo.
2. **Exportação Padronizada (glTF 2.0 Binary - `.glb`):** Todos os assets são compilados em formato binário `.glb` e importados para o diretório canônico `res://assets/models/environment/`.
3. **Composição Modular no Motor (Godot 4):** A arquitetura divide a geração e o gerenciamento dos cenários em 12 subsistemas desacoplados, permitindo que regiões em produção total ou encenação modular compartilhem a mesma infraestrutura de renderização, navegação, colisões e gameplay.

```
                           +-----------------------------------+
                           |  AbyssalPact_ArtSource (EXTERNO)  |
                           |   Blender 5.3+ (.blend sources)   |
                           +-----------------+-----------------+
                                             | Export GLB
                                             v
                           +-----------------------------------+
                           |    Godot 4: assets/models/env/    |
                           +-----------------+-----------------+
                                             | Instanciação & Cache
                                             v
                           +-----------------------------------+
                           |      RegionAssetLoader (S12)      |
                           +-----------------+-----------------+
                                             |
             +-------------------------------+-------------------------------+
             |                               |                               |
             v                               v                               v
+------------------------+      +------------------------+      +------------------------+
| RegionTerrainSystem    |      | RegionStructureSystem  |      | RegionPropsSystem      |
| RegionMaterialSystem   |      | RegionVegetationSystem |      | RegionAtmosphereSystem |
| RegionCollisionSystem  |      | RegionPOISystem        |      | RegionLightingSystem   |
+------------------------+      +------------------------+      +------------------------+
             |                               |                               |
             +-------------------------------+-------------------------------+
                                             |
                                             v
                           +-----------------------------------+
                           |    RegionSceneBuilder (S01)       |
                           |     (Cinzália / REG-001..040)     |
                           +-----------------------------------+
```

---

## 2. Estrutura Externa do Pipeline Blender

Para garantir a integridade do repositório Git e evitar arquivos binários pesados de autoria (.blend) no versionamento do projeto de runtime, toda a base de arte fonte reside em um diretório externo irmão:

```
AbyssalPact_ArtSource/
  └── Blender/
      ├── Environments/     # Cenas mestras de terreno e blocos geográficos
      ├── Buildings/        # Edificações completas e assentamentos
      ├── Nature/           # Árvores calcinadas, troncos secos, arbustos de espinhos
      ├── Rocks/            # Boulders vulcânicos, agulhas basálticas, crateras
      ├── Props/            # Monólitos de pacto, braseiros, altares, totens
      ├── Structures/       # Arcos imperiais, muralhas de bastião, torres em ruínas, pilares
      ├── Materials/        # Bibliotecas de texturas e paletas de materiais Dark Fantasy
      └── Exports/          # Registro local de exportações e logs de processamento
```

### Regras Mandatórias:
- **Regra de Ouro:** Arquivos `.blend` **NUNCA** entram no repositório da Godot.
- **Exportação Direta:** Scripts e operadores do Blender exportam os arquivos `.glb` diretamente para a árvore de assets da Godot (`res://assets/models/environment/{nature,props,rocks,structures}`).
- **Convenção de Transform:**
  - Origem (Pivot) na base do objeto (Y = 0) para encaixe perfeito no terreno.
  - Escala aplicada (`1.0, 1.0, 1.0`) antes da exportação.
  - Forward: `-Z`, Up: `+Y` (padrão Godot / glTF).

---

## 3. Os 12 Subsistemas do Pipeline

| Nº | Subsistema | Script GDScript | Responsabilidade |
|:---|:---|:---|:---|
| **01** | **Cenas Regionais** | `region_scene_builder.gd` | Orquestra e instancia todos os subsistemas montando a hierarquia completa da região. |
| **02** | **Terrenos** | `region_terrain_system.gd` | Constrói a malha de relevo escalonado, solo principal, fendas de magma e relevo acidentado. |
| **03** | **Materiais PBR** | `region_material_system.gd` | Centraliza definições de materiais PBR (rugosidade, emissão, albedo) por continente e bioma. |
| **04** | **Vegetação** | `region_vegetation_system.gd` | Espalhamento procedural de árvores calcinadas e arbustos com colisão cilíndrica de troncos. |
| **05** | **Estruturas Modulares** | `region_structure_system.gd` | Alinha e posiciona arcos imperiais, muralhas de bastião, torres de vigia e pilares quebrados. |
| **06** | **Objetos Ambientais (Props)** | `region_props_system.gd` | Posiciona rochas basálticas, agulhas vulcânicas, crateras de impacto e braseiros iluminados. |
| **07** | **Colisão** | `region_collision_system.gd` | Padroniza camadas físicas (Layers 1 a 6) e constrói barreiras perimetrais invisíveis no raio da região. |
| **08** | **Navegação (NavMesh)** | `region_navigation_system.gd` | Configura `NavigationRegion3D` e parâmetros de malha (`agent_radius=0.5`, `agent_height=1.8`, `cell_height=0.25`). |
| **09** | **Iluminação** | `region_lighting_system.gd` | Gerencia `DirectionalLight3D` com sombras PSSM (4 splits) e fontes locais dinâmicas (fogo, lava, portais). |
| **10** | **Efeitos Atmosféricos** | `region_atmosphere_system.gd` | Configura `WorldEnvironment` (céu procedural, neblina volumétrica) e partículas GPU (cinzas, esporos, neve). |
| **11** | **Pontos de Interesse (POIs)**| `region_poi_system.gd` | Instancia SafeZones (cidades), entradas de masmorras, arenas de chefes, marcos de exploração e portais. |
| **12** | **Carregamento de Assets** | `region_asset_loader.gd` | Carrega modelos GLB com cache de memória e gera placeholders identificados caso algum asset esteja pendente. |

---

## 4. Padrões de Física e Colisão

As camadas de colisão 3D seguem estritamente a tabela arquitetural do projeto:

| Camada | Nome | Descrição |
|:---|:---|:---|
| **Layer 1** | `LAYER_WORLD` | Terreno, solo principal, rochas, muralhas, pilares, troncos de árvore e obstáculos estáticos. |
| **Layer 2** | `LAYER_PLAYER` | Corpo cinemático do personagem do jogador (`CharacterBody3D`). |
| **Layer 3** | `LAYER_ENEMIES` | Demônios regionais e chefes hostis. |
| **Layer 4** | `LAYER_TRIGGERS` | Áreas de detecção de POIs, safe zones, entradas de masmorras, arenas e portões. |
| **Layer 5** | `LAYER_INTERACTABLES` | Monólitos de pacto, baús, altares e objetos acionáveis. |
| **Layer 6** | `LAYER_BOUNDARIES` | Paredes invisíveis cilíndricas ao redor do perímetro da região. |

---

## 5. Padrões de Iluminação e Atmosfera por Continente

| Continente | Bioma Referência | Cor do Sol / Energia | Cor Ambiente | Neblina | Partículas Atmosféricas |
|:---|:---|:---|:---|:---|:---|
| **Veyrath** | `ash_plains` | Âmbar vulcânico (`#e8a478`, 1.3) | Escura cinzenta (`#2c1d24`) | Densidade 0.008 (`#382329`) | Cinzas e fagulhas incandescentes em queda |
| **Sylvaran** | `whispering_woods` | Luar esmeralda suave (`#a6d999`, 0.95) | Verde musgo escuro (`#1f2e24`) | Densidade 0.010 (`#243829`) | Esporos luminescentes suspensos |
| **Khar-Duum** | `scorched_dunes` | Sol desértico carmesim (`#ff8c4d`, 1.4) | Marrom sulfúrico (`#3d261a`) | Densidade 0.007 (`#4a2e1f`) | Tempestade de areia e poeira árida |
| **Nhal'Kora** | `frozen_wastes` | Alvorada polar ciano (`#99bfff`, 1.1) | Azul gélido profundo (`#1f2938`) | Densidade 0.012 (`#29364a`) | Nevasca e cristais de gelo cintilantes |

---

## 6. Região Modelo de Referência: CINZÁLIA (Veyrath / REG-001)

A primeira região desenvolvida e totalmente integrada em produção é **Cinzália** (`scenes/world/regions/cinzalia.tscn` / `region_001.tscn`):

### Características de Cinzália:
- **Terreno:** Solo vulcânico negro com textura PBR calcinada, variação de elevação através das colinas leste e oeste, e uma fenda de lava ativa com emissão brilhante e luz dinâmica `OmniLight3D`.
- **Malha de Navegação (NavMesh):** Polígono caminhável em `NavigationRegion3D` cobrindo o relevo com margens de segurança para pathfinding de IA demoníaca e jogadores.
- **Vegetação Escassa:** Árvores calcinadas (`tree_charred_ash.glb`) com colisão sólida nos troncos e arbustos de espinhos de cinzas (`shrub_ashen_thorn.glb`).
- **Estruturas Modulares:**
  - Grande Arco Imperial (`ruin_imperial_arch.glb`) enquadrando a passagem principal.
  - Muralhas de Bastião Leste e Oeste (`structure_bastion_wall.glb`) protegendo o assentamento.
  - Torre de Vigia Imperial em ruínas (`structure_watchtower_ruin.glb`) sobre a elevação rochosa.
  - Pilares imperiais fragmentados (`ruin_broken_pillar.glb`) ao longo da antiga estrada.
- **Props Ambientais:**
  - Boulders basálticos (`rock_volcanic_boulder.glb`) espalhados pelo relevo.
  - Agulhas rochosas pontiagudas (`rock_volcanic_crag.glb`).
  - Bordas de crateras vulcânicas de impacto (`rock_crater_rim.glb`).
  - Braseiros vulcânicos acesos (`prop_volcanic_brazier.glb`) com luzes locais quentes.
- **Pontos de Interesse Integrados:**
  - **Baluarte das Cinzas:** Assentamento central e `SafeZone` funcional (raio 22m).
  - **Catacumbas de Basalto:** Entrada funcional de masmorra (`DungeonEntrance`).
  - **Arena de Chefe BOSS-001:** Arena fechada para confronto de chefe demoníaco.
  - **Monólito do Primeiro Pacto:** Marco de exploração com o modelo 3D real `prop_ash_monolith.glb`.
  - **Portal da Forja Abissal:** Portal interdimensional conectado à Hell Forge.
  - **Portões Norte e Sul:** Conexões para as regiões vizinhas REG-002 e REG-003.
- **Atmosfera:** WorldEnvironment com céu procedural de cinzas, neblina dramática e emissor de partículas GPU simulando cinzas incandescentes caindo continuamente.

---

## 7. Procedimento Padrão para Construir as Outras 39 Regiões

Para expandir qualquer uma das 39 regiões em encenação modular (`modular_staging`) para o padrão de produção completa:

1. **Modelagem de Assets Específicos do Bioma no Blender:**
   - Crie as malhas temáticas em `AbyssalPact_ArtSource/Blender/{Nature, Rocks, Structures, Props}/`.
   - Mantenha o pivot na base, aplique transformações e exporte via script ou interface do Blender para `res://assets/models/environment/<categoria>/<nome>.glb`.
2. **Reimportação na Godot:**
   - Execute o Godot Editor para gerar os metadados de importação `.import` e registrar o asset.
3. **Criação da Cena Dedicada da Região:**
   - Crie a cena `res://scenes/world/regions/region_<id>.tscn` herdando a estrutura base.
   - Ou utilize o método programático de produção:
     ```gdscript
     RegionSceneBuilder.build_complete_region(root_node, region_data_resource)
     ```
4. **Configuração de POIs e Conexões:**
   - Vincule a cidade/safe zone regional, as masmorras, os portões de transição e o portal arcano conforme catalogado em `data/content/regions/region_<id>.tres`.
5. **Ajuste de Iluminação e Clima:**
   - Ajuste o perfil no resource `lighting_profile` (cor do sol, intensidade, cor da neblina e densidade).
6. **Bake da Malha de Navegação:**
   - Ajuste as áreas estáticas no `NavigationRegion3D` e execute o bake para garantir o pathfinding da IA dos demônios regionais.
7. **Validação Automatizada:**
   - Execute a suíte de testes do motor (`tests/run_tests.tscn`) para confirmar que todas as regras, nós e colisores da nova região passam com 0 falhas.

---

## 8. Verificação e Testes

O pipeline está totalmente coberto pela suíte automatizada `suite_environment_pipeline.gd`, integrada ao executor global de testes `tests/run_tests.tscn`. Todos os testes verificam:
- Existência e instanciação dos 12 subsistemas arquiteturais.
- Carregamento de todos os modelos GLB reais importados do Blender.
- Resiliência com fallback para assets ausentes.
- Integridade estrutural, colisões e navegação do protótipo Cinzália.
- Capacidade de construção dinâmica do `RegionSceneBuilder` para qualquer região catalogada.
