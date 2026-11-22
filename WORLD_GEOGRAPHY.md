# Abyssal Pact — Geografia Mundial (World Geography)

> **Documento Oficial de Cartografia Planetária e Estrutura Geográfica**  
> **Autoridade:** Cartógrafo Principal de ABYSSAL PACT  
> **Status do Registro:** Cânone Cartográfico Consolidado & Dados Integrados  
> **Versão:** 2.0.0 (Data-Driven / Engine Coherent)  
> **Arquivos Associados:** [CONTINENT_LAYOUT.md](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/CONTINENT_LAYOUT.md), [REGION_BOUNDARIES.md](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/REGION_BOUNDARIES.md), [REGION_CONNECTIONS.md](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/REGION_CONNECTIONS.md), [WORLD_MAP_DATA.json](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/WORLD_MAP_DATA.json), [REGION_GRAPH.json](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/REGION_GRAPH.json)

---

## 1. Visão Geral e Cosmologia Geográfica

O mundo de **ABYSSAL PACT** é estruturado sobre uma bacia tectônica primordial centrada em uma colossal fenda oceânica conhecida como o **Mar da Cicatriz**. Ao redor desta massa aquática abissal distribuem-se **quatro grandes massas continentais**, cada qual ocupando um quadrante geográfico específico e ostentando uma identidade geológica, biológica e climática radicalmente distinta.

```
       [ NOROESTE ]                              [ NORDESTE ]
  ======================                    ======================
  CONTINENTE VEYRATH                        CONTINENTE SYLVARAN
  - Imperial & Vulcânico                    - Floresta Ancestral & Dossel
  - Montanhas de Obsidiana                  - Pântanos Espectrais
  - Planícies de Cinzas                     - Ilhas Aéreas Suspensas
  - 10 Regiões (REG-001..010)               - 10 Regiões (REG-011..020)
  ======================                    ======================
                   \                            /
                    \   CANAL DO NORTE         /
                     \                        /
                      ~~~~~~~~~~~~~~~~~~~~~~~~
                      ~~~ MAR DA CICATRIZ ~~~  <--- Ponto Central (0.5, 0.5)
                      ~~~ (Oceano Central) ~~~
                      ~~~~~~~~~~~~~~~~~~~~~~~~
                     /                        \
                    /   CANAL DO SUL           \
                   /                            \
  ======================                    ======================
  CONTINENTE KHAR-DUUM                      CONTINENTE NHAL'KORA
  - Cânions Áridos & Dunas                  - Litoral Glacial & Fiordes
  - Areia Negra Magnética                   - Gelo Negro & Névoas Frias
  - Cidadelas Subterrâneas                  - Fossas Oceânicas Abissais
  - 10 Regiões (REG-021..030)               - 10 Regiões (REG-031..040)
  ======================                    ======================
       [ SUDOESTE ]                              [ SUDESTE ]
```

---

## 2. A Dimensão Independente: Hell Forge

> [!IMPORTANT]
> **A Hell Forge NÃO É UM CONTINENTE FÍSICO nem uma ilha no mapa mundi.**  
> Qualquer representação da Hell Forge como um pedaço de terra sobre o oceano viola as diretrizes ontológicas de ABYSSAL PACT.

- **Natureza Planar:** A **Hell Forge** reside em uma dimensão etérea/abissal independente, desconectada da malha física planar do mundo mortal.
- **Função Mecânica Canônica:** É o **hub central do jogo** e o **destino obrigatório e incondicional de ressurgimento** após a morte de qualquer jogador ou entidade vinculada a pactos demoníacos (`HELL_FORGE.md`).
- **Acessibilidade:** Exclusivamente através de mecanismos arcanos, conduítes de dobra espacial e portais dimensionais (`WorldPortal`). Os quatro continentes possuem portais arcanos permanentes em suas respectivas capitais continentais (`REG-001`, `REG-011`, `REG-021`, `REG-031`), bem como fendas de alto nível em suas regiões terminais (`REG-010`, `REG-020`, `REG-030`, `REG-040`).
- **Coordenadas Cartográficas:** Classificada formalmente como `Dimensional / Extracartográfica`. No grafo regional (`REGION_GRAPH.json`), figura como o nó unificador `DIM-HELL-FORGE`, conectado bidirecionalmente a todas as regiões portadoras de portais ativos.

---

## 3. O Oceano Central: Mar da Cicatriz

O **Mar da Cicatriz** é o coração hidrológico e náutico do mundo conhecido.

- **Origem Geológica:** Fratura tectônica profunda onde a crosta planetária se rompeu em eras imemoriais, liberando energias do Abismo que tingiram as águas de um azul-cobalto quase negro.
- **Profundidade:** Atinge mais de 8.500 metros em sua trincheira submarina central.
- **Hidrodinâmica e Correntes:** As correntes marítimas fluem em um vórtice ciclônico contínuo no sentido horário, sugando águas superficiais em direção à **Fenda da Cicatriz** e expelindo correntes quentes e saturadas de minerais para as costas dos quatro continentes.
- **Canais Intercontinentais:**
  1. *Canal do Norte:* Estreito que separa a costa leste de Veyrath da costa oeste de Sylvaran.
  2. *Canal do Sul:* Estreito que separa a costa sudeste de Khar-Duum do litoral noroeste de Nhal'Kora.
  3. *Canal do Oeste:* Passagem marítima entre o sul de Veyrath e o norte de Khar-Duum.
  4. *Canal do Leste:* Passagem marítima entre o sul de Sylvaran e o norte de Nhal'Kora.
- **Vias de Navegação Comerciais e Militares:**
  - *Rota do Estreito Setentrional:* Liga `REG-001` (Baluarte das Cinzas) a `REG-011` (Bosque das Almas).
  - *Canal Ocidental da Escória:* Liga `REG-001` (Baluarte das Cinzas) a `REG-021` (Fortaleza de Basalto).
  - *Travessia das Brumas Orientais:* Liga `REG-011` (Bosque das Almas) a `REG-031` (Cidadela dos Afogados).
  - *Passagem Meridional dos Naufrágios:* Liga `REG-021` (Fortaleza de Basalto) a `REG-031` (Cidadela dos Afogados).
  - *Rota Transoceânica da Cicatriz:* Rota de alto risco cortando o vórtice central entre `REG-002` e `REG-031`.

---

## 4. Mares Periféricos Exteriores

Além do Mar da Cicatriz interior, os limites exteriores do mundo conhecido confrontam vastidões oceânicas misteriosas:

1. **Mar do Vazio (Noroeste):** Águas gélidas onde flutuam blocos de escória vulcânica porosa e cinzas finas. As correntes empurram continuamente em direção ao horizonte ocidental vazio.
2. **Mar Espectral (Nordeste):** Águas mornas e estagnadas sob bancos densos de nevoeiro fluorescente que desorientam bússolas e instrumentos de navegação.
3. **Mar Silencioso (Sudoeste):** Águas rasas supersaturadas de sal e sedimentos minerais onde nunca sopra vento, aprisionando embarcações à vela.
4. **Mar dos Condenados (Sudeste):** Águas tempestuosas com ondas gigantescas de 15 metros de altura e icebergs de gelo negro à deriva que naufragam qualquer nau de grande calado.

---

## 5. Sistema de Coordenadas Cartográficas Normalizadas

Para garantir interoperabilidade matemática perfeita entre as interfaces gráficas 2D (Mini-mapa, Mapa Mundial `WorldMapScreen`, Mapa Regional `RegionalMapScreen`) e a engine de simulação 3D (`WorldManager`, `ModularRegion`, marcadores de navegação), o mundo utiliza um **Espaço Cartográfico Euclidiano Normalizado**:

$$\mathbf{P} = (X, Y) \in [0.0, 1.0] \times [0.0, 1.0]$$

- **Eixo X (Horizontal):** Oeste ($0.0$) $\longrightarrow$ Leste ($1.0$).
- **Eixo Y (Vertical):** Norte ($0.0$) $\longrightarrow$ Sul ($1.0$).
- **Centro Cartográfico:** $(0.50, 0.50)$, correspondente ao ponto médio exato do Mar da Cicatriz.

### Delimitação Normalizada dos Quadrantes Continentais

| Continente | Quadrante | Faixa X | Faixa Y | Centro Normalizado | Área Relativa |
|---|---|---|---|---|---|
| **Veyrath** (`CONT-01`) | Noroeste (NW) | $[0.05, 0.46]$ | $[0.05, 0.46]$ | $(0.25, 0.25)$ | $23.5\%$ |
| **Sylvaran** (`CONT-02`) | Nordeste (NE) | $[0.54, 0.95]$ | $[0.05, 0.46]$ | $(0.75, 0.25)$ | $26.0\%$ |
| **Khar-Duum** (`CONT-03`) | Sudoeste (SW) | $[0.05, 0.46]$ | $[0.54, 0.95]$ | $(0.25, 0.75)$ | $25.5\%$ |
| **Nhal'Kora** (`CONT-04`) | Sudeste (SE) | $[0.54, 0.95]$ | $[0.54, 0.95]$ | $(0.75, 0.75)$ | $25.0\%$ |
| **Mar da Cicatriz** (`OCEAN-01`) | Centro | $[0.42, 0.58]$ | $[0.42, 0.58]$ | $(0.50, 0.50)$ | Corredor Marítimo |
| **Hell Forge** (`DIM-HELL-FORGE`) | Extracartográfico | — | — | Extradimensional | Nexo Planar |

### Equação de Transformação 2D para Espaço 3D Local (Godot Engine)

Quando um agente ou jogador se encontra em uma região $R_i$ com centro normalizado $(c_{x, i}, c_{y, i})$ e raio geográfico $r_{m}$, a conversão entre o vetor normalizado local $\mathbf{p}_{\text{norm}}$ e as coordenadas mundiais do nó Godot $\mathbf{P}_{\text{godot}}$ é dada por:

$$\mathbf{P}_{\text{godot}} = \begin{bmatrix} (p_{\text{norm}, x} - c_{x, i}) \cdot S_{\text{world}} \\ Y_{\text{elevation}} \\ (p_{\text{norm}, y} - c_{y, i}) \cdot S_{\text{world}} \end{bmatrix}$$

Onde $S_{\text{world}}$ é a constante de escala territorial estabelecida em $2.500\text{ metros}$ por unidade cartográfica inteira ($1.0$).

---

## 6. Orogênese e Tectônica Global

O relevo mundial é consequência de um processo de rifteamento tridimensional antigo:

1. **A Fenda Primordial da Cicatriz:** As placas continentais de Veyrath e Khar-Duum deslizam lentamente para o oeste, enquanto as placas de Sylvaran e Nhal'Kora recuam para o leste, mantendo o abismo central aberto em expansão milimétrica contínua.
2. **Cordilheira das Agulhas de Obsidiana (Veyrath):** Formada pelo cavalgamento da placa oceânica ocidental sobre a crosta continental rica em basalto e escória.
3. **Maciço do Cume das Névoas e Fenda Esmeralda (Sylvaran):** Estrutura geológica mista onde blocos de quartzo ressonante foram elevados e estabilizados por correntes arcanas de seiva mineral, permitindo o fenômeno das ilhas suspensas.
4. **Escarpa Vermelha e Cordilheira dos Titãs (Khar-Duum):** Levantamento epirogênico maciço submetido a milhões de anos de dessecação atmosférica e erosão eólica, criando os cânions em garganta.
5. **Cadeia dos Sussurros Gélidos (Nhal'Kora):** Orogênese associada ao congelamento perpétuo e isostasia glacial, onde o peso da geleira sussurrante afunda a crosta leste e projeta penhascos agudos sobre o mar.

---

## 7. Climatologia e Circulação de Névoas

A atmosfera de ABYSSAL PACT não segue ciclos meteorológicos terrestres mundanos, sendo governada pela interação entre o calor geotérmico, a biomassa abissal e a atração da Cicatriz:

- **Célula de Circulação de Cinzas (Veyrath):** Ar superaquecido ascende da Caldeira de Veyrath e viaja em altitude até o sul, resfriando-se em tempestades de fuligem escura sobre o Pântano de Cinzas.
- **Célula de Bruma Espectral (Sylvaran):** Evapotranspiração massiva da copa arbórea condensa-se em um nevoeiro contínuo saturado de pólen bioluminescente que flutua a baixa altitude.
- **Célula Térmica das Areias Negras (Khar-Duum):** As dunas de magnetita absorvem radiação calórica gerando vórtices de ar quente e frentes de rajadas secas (Siroco das Gargantas) com velocidade superior a 90 km/h.
- **Célula Boreal de Cristais (Nhal'Kora):** Frentes polares gélidas descem das calotas de gelo negro e colidem com as correntes mornas do Mar da Cicatriz, gerando as "Névoas Frias Cegantes".

---

## 8. Conformidade Canônica e Integridade de Dados

- **Total de Regiões:** Exatamente 40 regiões catalogadas, 10 em cada continente (`REG-001` a `REG-040`), sem omissões ou duplicidades.
- **Nomes Canônicos:** Todos os 40 nomes são idênticos aos formalizados em `CONTINENTS_AND_REGIONS.md`.
- **Topologia de Fronteiras:** Nenhuma região é isolada ou desprovida de conexão justificada (ilhas ou plataformas suspensas possuem pontes arcanas, raízes gigantescas ou rotas fluviais/marítimas).
- **Consistência Bidirecional:** Todos os vizinhos terrestres e rotas marítimas são rigorosamente simétricos (testados e validados por `tools/build_cartography_data.py`).
