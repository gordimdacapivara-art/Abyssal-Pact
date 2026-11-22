# Abyssal Pact — Delimitação das Regiões (Region Boundaries)

> **Documento Oficial de Delimitação Territorial, Polígonos e Coordenadas**  
> **Autoridade:** Cartógrafo Principal de ABYSSAL PACT  
> **Status do Registro:** Cânone Cartográfico Consolidado  
> **Versão:** 2.0.0 (Data-Driven / Engine Coherent)  
> **Arquivos Associados:** [WORLD_GEOGRAPHY.md](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/WORLD_GEOGRAPHY.md), [CONTINENT_LAYOUT.md](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/CONTINENT_LAYOUT.md), [REGION_CONNECTIONS.md](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/REGION_CONNECTIONS.md), [WORLD_MAP_DATA.json](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/WORLD_MAP_DATA.json), [REGION_GRAPH.json](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/REGION_GRAPH.json)

---

## 1. Princípios de Delimitação Cartográfica

Todas as 40 regiões de ABYSSAL PACT foram delimitadas segundo os seguintes critérios rigorosos:
1. **Polígonos Orgânicos Naturais:** Nenhuma região possui formato retangular ou quadrado genérico. As fronteiras acompanham acidentes geográficos reais: escarpas, cristas orográficas, cursos d'água, falhas tectônicas e linhas de costa.
2. **Coordenadas Normalizadas:** Todas as posições de vértices e centros situam-se no espaço $[0.0, 1.0] \times [0.0, 1.0]$, garantindo correspondência direta 1:1 com as telas de mapa 2D da interface (`WorldMapScreen`, `RegionalMapScreen`) e a engine Godot.
3. **Topologia Conexa:** Não existem regiões isoladas sem rota de acesso fundamentada (passagens terrestres, rotas marítimas ou portais de sustentação).
4. **Nomes Canônicos Inalterados:** Os 40 nomes oficiais de `CONTINENTS_AND_REGIONS.md` são rigorosamente preservados.

---

## Continente Veyrath (CONT-01)

### REG-001: Planície Cinzenta de Veyrath

- **Identificador Único:** `REG-001`
- **Nome Canônico:** Planície Cinzenta de Veyrath
- **Continente:** `CONT-01` (Veyrath)
- **Bioma:** `ash_plains`
- **Faixa de Nível Recomendada:** 1–5
- **Status de Produção:** `full_production`
- **Capital / Assentamento Seguro:** Baluarte das Cinzas (`SafeZone` ativa)
- **Masmorra Vinculada:** Catacumbas de Basalto (Requisito: nível 1+)
- **Chefe Associado:** `BOSS-001`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.24, 0.36)`
- **Bounding Box Normalizada:** `[min_x: 0.18, min_y: 0.30, max_x: 0.32, max_y: 0.44]`
- **Vértices do Polígono de Fronteira:** `(0.20, 0.30), (0.30, 0.30), (0.32, 0.38), (0.28, 0.44), (0.18, 0.42), (0.17, 0.35)`
- **Perfil de Elevação:** Altitude Mínima: **120 m** | Máxima: **310 m** | Média: **185 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Extensa planície aluvial recoberta por camadas milenares de cinzas vulcânicas. Sede do Baluarte das Cinzas e ponto focal do império ancestral de Veyrath.
- **Material e Relevo Primário:** Solo compactado de cinza cinzenta, fendas de magma menores, monólitos de basalto negro e paliçadas imperiais.
- **Limite Norte:** Borda pantanosa de cinzas de REG-004 e colinas de escória.
- **Limite Sul:** Costa rochosa do Canal Ocidental e declive para o desfiladeiro de REG-003.
- **Limite Leste:** Fissuras de enxofre e cristas amarelas de REG-002 descendo para o Mar da Cicatriz.
- **Limite Oeste:** Encostas íngremes e agulhas de basalto da cordilheira de REG-005.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-002` (Fendas de Enxofre) via `gate_reg-001_to_reg-002`
  - Conexão com `REG-003` (Desfiladeiro de Magma) via `gate_reg-001_to_reg-003`
  - Conexão com `REG-004` (Pântano de Cinzas) via `gate_reg-001_to_reg-004`
  - Conexão com `REG-005` (Picos de Obsidiana) via `gate_reg-001_to_reg-005`
- **Conexões Marítimas (Mar da Cicatriz):**
  - Rota Náutica para `REG-011` (Bosque Sussurrante) via `harbor_reg-001_to_reg-011`
  - Rota Náutica para `REG-021` (Dunas de Areia Negra) via `harbor_reg-001_to_reg-021`
  - Rota Náutica para `REG-031` (Baía dos Afogados) via `harbor_reg-001_to_reg-031`
- **Acessos Especiais e Portais Dimensionais:**
  - Portal para **Hell Forge** (`portal_reg-001_hell_forge`): Localizado em *Baluarte das Cinzas* (permanent_conduit).

---

### REG-002: Fendas de Enxofre

- **Identificador Único:** `REG-002`
- **Nome Canônico:** Fendas de Enxofre
- **Continente:** `CONT-01` (Veyrath)
- **Bioma:** `sulfur_crags`
- **Faixa de Nível Recomendada:** 3–7
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Posto de Enxofre (`SafeZone` ativa)
- **Masmorra Vinculada:** Minas de Pirita (Requisito: nível 3+)
- **Chefe Associado:** `BOSS-002`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.36, 0.34)`
- **Bounding Box Normalizada:** `[min_x: 0.30, min_y: 0.27, max_x: 0.44, max_y: 0.42]`
- **Vértices do Polígono de Fronteira:** `(0.30, 0.30), (0.38, 0.27), (0.44, 0.34), (0.42, 0.42), (0.34, 0.41), (0.31, 0.36)`
- **Perfil de Elevação:** Altitude Mínima: **40 m** | Máxima: **220 m** | Média: **110 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Território fraturado por fumarolas ativas, depósitos maciços de enxofre cristalino e vapores tóxicos que margeiam as águas do Mar da Cicatriz.
- **Material e Relevo Primário:** Rochas sedimentares amarelas e avermelhadas, piscinas ácidas fumegantes, fendas de desgaseificação e pontes de ferro fundido.
- **Limite Norte:** Planaltos de terra férrea de REG-008 com cristas de minério.
- **Limite Sul:** Falésias marítimas de pirita voltadas para o Mar da Cicatriz.
- **Limite Leste:** Águas costeiras do Mar da Cicatriz.
- **Limite Oeste:** Planície Cinzenta de REG-001.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-001` (Planície Cinzenta de Veyrath) via `gate_reg-002_to_reg-001`
  - Conexão com `REG-004` (Pântano de Cinzas) via `gate_reg-002_to_reg-004`
  - Conexão com `REG-008` (Terra Férrea) via `gate_reg-002_to_reg-008`
- **Conexões Marítimas (Mar da Cicatriz):**
  - Rota Náutica para `REG-031` (Baía dos Afogados) via `harbor_reg-002_to_reg-031`
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-003: Desfiladeiro de Magma

- **Identificador Único:** `REG-003`
- **Nome Canônico:** Desfiladeiro de Magma
- **Continente:** `CONT-01` (Veyrath)
- **Bioma:** `magma_gorge`
- **Faixa de Nível Recomendada:** 5–10
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Acampamento da Forja (`SafeZone` ativa)
- **Masmorra Vinculada:** Cavernas Candentes (Requisito: nível 5+)
- **Chefe Associado:** `BOSS-003`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.18, 0.42)`
- **Bounding Box Normalizada:** `[min_x: 0.10, min_y: 0.37, max_x: 0.24, max_y: 0.46]`
- **Vértices do Polígono de Fronteira:** `(0.18, 0.37), (0.24, 0.39), (0.23, 0.46), (0.14, 0.46), (0.10, 0.43), (0.12, 0.38)`
- **Perfil de Elevação:** Altitude Mínima: **80 m** | Máxima: **480 m** | Média: **260 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Garganta tectônica profunda rasgada por uma torrente de lava incandescente. Local de extração piroclástica e forjas primitivas.
- **Material e Relevo Primário:** Paredões verticais de andesito, rios de rocha derretida, pontes de pedra negra e cavernas incandescentes.
- **Limite Norte:** Transição suave para a Planície Cinzenta de REG-001.
- **Limite Sul:** Penhascos costeiros do Canal Ocidental que separa Veyrath de Khar-Duum.
- **Limite Leste:** Baluarte das Cinzas de REG-001.
- **Limite Oeste:** Bases maciças das Agulhas de Obsidiana de REG-005.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-001` (Planície Cinzenta de Veyrath) via `gate_reg-003_to_reg-001`
  - Conexão com `REG-005` (Picos de Obsidiana) via `gate_reg-003_to_reg-005`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-004: Pântano de Cinzas

- **Identificador Único:** `REG-004`
- **Nome Canônico:** Pântano de Cinzas
- **Continente:** `CONT-01` (Veyrath)
- **Bioma:** `ash_mire`
- **Faixa de Nível Recomendada:** 8–12
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Aldeia Queimada (`SafeZone` ativa)
- **Masmorra Vinculada:** Fosso Lamacento (Requisito: nível 8+)
- **Chefe Associado:** `BOSS-004`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.28, 0.24)`
- **Bounding Box Normalizada:** `[min_x: 0.22, min_y: 0.18, max_x: 0.36, max_y: 0.30]`
- **Vértices do Polígono de Fronteira:** `(0.24, 0.19), (0.34, 0.18), (0.36, 0.26), (0.30, 0.30), (0.22, 0.28), (0.22, 0.22)`
- **Perfil de Elevação:** Altitude Mínima: **15 m** | Máxima: **90 m** | Média: **45 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Depressão lacustre onde o escoamento hídrico das montanhas mistura-se a cinzas finas, criando um atoleiro movediço de lama quente e vapor.
- **Material e Relevo Primário:** Lama cinzenta borbulhante, troncos petrificados submersos, juncos calcinados e passarelas precárias de madeira reforçada.
- **Limite Norte:** Escarpa sul da Cratera Abissal de Ferro de REG-007.
- **Limite Sul:** Planície Cinzenta de REG-001 e Fendas de Enxofre de REG-002.
- **Limite Leste:** Camadas sedimentares de Terra Férrea de REG-008.
- **Limite Oeste:** Colinas de cinzas transicionando para o deserto fuliginoso de REG-006.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-001` (Planície Cinzenta de Veyrath) via `gate_reg-004_to_reg-001`
  - Conexão com `REG-002` (Fendas de Enxofre) via `gate_reg-004_to_reg-002`
  - Conexão com `REG-007` (Cratera Abissal de Ferro) via `gate_reg-004_to_reg-007`
  - Conexão com `REG-008` (Terra Férrea) via `gate_reg-004_to_reg-008`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-005: Picos de Obsidiana

- **Identificador Único:** `REG-005`
- **Nome Canônico:** Picos de Obsidiana
- **Continente:** `CONT-01` (Veyrath)
- **Bioma:** `obsidian_peaks`
- **Faixa de Nível Recomendada:** 10–15
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Posto das Agulhas (`SafeZone` ativa)
- **Masmorra Vinculada:** Câmara das Lâminas (Requisito: nível 10+)
- **Chefe Associado:** `BOSS-005`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.11, 0.28)`
- **Bounding Box Normalizada:** `[min_x: 0.05, min_y: 0.20, max_x: 0.18, max_y: 0.38]`
- **Vértices do Polígono de Fronteira:** `(0.10, 0.20), (0.17, 0.23), (0.18, 0.34), (0.13, 0.38), (0.06, 0.36), (0.05, 0.26)`
- **Perfil de Elevação:** Altitude Mínima: **350 m** | Máxima: **1420 m** | Média: **890 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Cadeia montanhosa de vidro vulcânico negro com arestas afiadas como lâminas. As agulhas barram os ventos marítimos do oeste.
- **Material e Relevo Primário:** Arestas cortantes de vidro vulcânico, desfiladeiros estreitos, neblina de sílica suspensa e cavernas de lâminas refletoras.
- **Limite Norte:** Dunas escuras de sílica do Deserto Fuliginoso de REG-006.
- **Limite Sul:** Desfiladeiro de Magma de REG-003.
- **Limite Leste:** Planície Cinzenta de REG-001.
- **Limite Oeste:** Costas inóspitas voltadas para o oceano externo ocidental.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-001` (Planície Cinzenta de Veyrath) via `gate_reg-005_to_reg-001`
  - Conexão com `REG-003` (Desfiladeiro de Magma) via `gate_reg-005_to_reg-003`
  - Conexão com `REG-006` (Deserto Fuliginoso) via `gate_reg-005_to_reg-006`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-006: Deserto Fuliginoso

- **Identificador Único:** `REG-006`
- **Nome Canônico:** Deserto Fuliginoso
- **Continente:** `CONT-01` (Veyrath)
- **Bioma:** `soot_desert`
- **Faixa de Nível Recomendada:** 13–17
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Refúgio de Sílica (`SafeZone` ativa)
- **Masmorra Vinculada:** Túmulo dos Ventos (Requisito: nível 13+)
- **Chefe Associado:** `BOSS-006`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.14, 0.15)`
- **Bounding Box Normalizada:** `[min_x: 0.06, min_y: 0.08, max_x: 0.22, max_y: 0.22]`
- **Vértices do Polígono de Fronteira:** `(0.12, 0.08), (0.20, 0.10), (0.21, 0.18), (0.16, 0.22), (0.08, 0.21), (0.06, 0.13)`
- **Perfil de Elevação:** Altitude Mínima: **180 m** | Máxima: **520 m** | Média: **310 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Extensas dunas de fuligem e cinza fina varridas por rajadas térmicas constantes que apagam qualquer rastro de caravanas.
- **Material e Relevo Primário:** Dunas ondulantes de fuligem preta, formações rochosas esqueléticas e tempestades de poeira sufocante.
- **Limite Norte:** Contrafortes rochosos da Garganta Calcinada de REG-009.
- **Limite Sul:** Picos de Obsidiana de REG-005.
- **Limite Leste:** Borda ocidental da Cratera de Ferro de REG-007.
- **Limite Oeste:** Escarpa litoral do noroeste.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-005` (Picos de Obsidiana) via `gate_reg-006_to_reg-005`
  - Conexão com `REG-007` (Cratera Abissal de Ferro) via `gate_reg-006_to_reg-007`
  - Conexão com `REG-009` (Garganta Calcinada) via `gate_reg-006_to_reg-009`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-007: Cratera Abissal de Ferro

- **Identificador Único:** `REG-007`
- **Nome Canônico:** Cratera Abissal de Ferro
- **Continente:** `CONT-01` (Veyrath)
- **Bioma:** `iron_crater`
- **Faixa de Nível Recomendada:** 15–20
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Guarnição de Chumbo (`SafeZone` ativa)
- **Masmorra Vinculada:** Complexo de Ferro Profundo (Requisito: nível 15+)
- **Chefe Associado:** `BOSS-007`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.26, 0.14)`
- **Bounding Box Normalizada:** `[min_x: 0.20, min_y: 0.08, max_x: 0.33, max_y: 0.20]`
- **Vértices do Polígono de Fronteira:** `(0.24, 0.08), (0.31, 0.09), (0.33, 0.17), (0.28, 0.20), (0.20, 0.17), (0.20, 0.11)`
- **Perfil de Elevação:** Altitude Mínima: **-60 m** | Máxima: **410 m** | Média: **120 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Depressão circular colossal de origem meteórica ou demoníaca, rica em veios de ferro abissal e cercada por muralhas naturais de basalto.
- **Material e Relevo Primário:** Terraceamento artificial imperial, minas profundas escavadas na rocha ferruginosa, guindastes e fundições ancestrais.
- **Limite Norte:** Cordilheira da Garganta Calcinada de REG-009.
- **Limite Sul:** Pântano de Cinzas de REG-004.
- **Limite Leste:** Planalto de Terra Férrea de REG-008.
- **Limite Oeste:** Deserto Fuliginoso de REG-006.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-004` (Pântano de Cinzas) via `gate_reg-007_to_reg-004`
  - Conexão com `REG-006` (Deserto Fuliginoso) via `gate_reg-007_to_reg-006`
  - Conexão com `REG-008` (Terra Férrea) via `gate_reg-007_to_reg-008`
  - Conexão com `REG-009` (Garganta Calcinada) via `gate_reg-007_to_reg-009`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-008: Terra Férrea

- **Identificador Único:** `REG-008`
- **Nome Canônico:** Terra Férrea
- **Continente:** `CONT-01` (Veyrath)
- **Bioma:** `scorched_earth`
- **Faixa de Nível Recomendada:** 18–22
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Fortim de Ferro (`SafeZone` ativa)
- **Masmorra Vinculada:** Mina dos Condenados (Requisito: nível 18+)
- **Chefe Associado:** `BOSS-008`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.38, 0.18)`
- **Bounding Box Normalizada:** `[min_x: 0.32, min_y: 0.10, max_x: 0.45, max_y: 0.27]`
- **Vértices do Polígono de Fronteira:** `(0.36, 0.10), (0.44, 0.12), (0.45, 0.22), (0.40, 0.27), (0.32, 0.23), (0.33, 0.15)`
- **Perfil de Elevação:** Altitude Mínima: **110 m** | Máxima: **620 m** | Média: **340 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Planalto ressecado com crostas minerais densas e solo vitrificado por antigas explosões celestes. Zona militarizada do império de Veyrath.
- **Material e Relevo Primário:** Solo duro cor de ferrugem, fortificações imperiais de pedra negra, trincheiras e monólitos de sinalização.
- **Limite Norte:** Rampa de cinzas do cone vulcânico de REG-010.
- **Limite Sul:** Fendas de Enxofre de REG-002.
- **Limite Leste:** Falésias marítimas que descem para o Estreito Setentrional.
- **Limite Oeste:** Cratera Abissal de Ferro de REG-007 e Pântano de Cinzas de REG-004.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-002` (Fendas de Enxofre) via `gate_reg-008_to_reg-002`
  - Conexão com `REG-004` (Pântano de Cinzas) via `gate_reg-008_to_reg-004`
  - Conexão com `REG-007` (Cratera Abissal de Ferro) via `gate_reg-008_to_reg-007`
  - Conexão com `REG-010` (Voo de Cinzas) via `gate_reg-008_to_reg-010`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-009: Garganta Calcinada

- **Identificador Único:** `REG-009`
- **Nome Canônico:** Garganta Calcinada
- **Continente:** `CONT-01` (Veyrath)
- **Bioma:** `burnt_canyon`
- **Faixa de Nível Recomendada:** 20–25
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Posto do Abismo (`SafeZone` ativa)
- **Masmorra Vinculada:** Cripta dos Condenados (Requisito: nível 20+)
- **Chefe Associado:** Nenhum chefe demoníaco alocado

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.24, 0.07)`
- **Bounding Box Normalizada:** `[min_x: 0.16, min_y: 0.05, max_x: 0.30, max_y: 0.12]`
- **Vértices do Polígono de Fronteira:** `(0.18, 0.05), (0.28, 0.05), (0.30, 0.10), (0.26, 0.12), (0.17, 0.11), (0.16, 0.07)`
- **Perfil de Elevação:** Altitude Mínima: **380 m** | Máxima: **1150 m** | Média: **720 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Cânion profundo e sombrio rasgado entre as montanhas setentrionais, canalizando correntes de ar fervente provenientes da grande caldeira.
- **Material e Relevo Primário:** Paredes de rocha calcinada, cascalho escorregadio, pontes em arco destruídas e túmulos esculpidos na pedra.
- **Limite Norte:** Costa setentrional inóspita do continente.
- **Limite Sul:** Deserto Fuliginoso de REG-006 e Cratera de Ferro de REG-007.
- **Limite Leste:** Santuário e encostas da Caldeira de REG-010.
- **Limite Oeste:** Encostas setentrionais da cordilheira ocidental.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-006` (Deserto Fuliginoso) via `gate_reg-009_to_reg-006`
  - Conexão com `REG-007` (Cratera Abissal de Ferro) via `gate_reg-009_to_reg-007`
  - Conexão com `REG-010` (Voo de Cinzas) via `gate_reg-009_to_reg-010`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-010: Voo de Cinzas

- **Identificador Único:** `REG-010`
- **Nome Canônico:** Voo de Cinzas
- **Continente:** `CONT-01` (Veyrath)
- **Bioma:** `caldera_edge`
- **Faixa de Nível Recomendada:** 23–28
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Santuário da Cinza (`SafeZone` ativa)
- **Masmorra Vinculada:** Santuário do Fogo Profundo (Requisito: nível 23+)
- **Chefe Associado:** Nenhum chefe demoníaco alocado

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.36, 0.08)`
- **Bounding Box Normalizada:** `[min_x: 0.29, min_y: 0.05, max_x: 0.44, max_y: 0.14]`
- **Vértices do Polígono de Fronteira:** `(0.32, 0.05), (0.42, 0.05), (0.44, 0.12), (0.38, 0.14), (0.30, 0.12), (0.29, 0.07)`
- **Perfil de Elevação:** Altitude Mínima: **800 m** | Máxima: **2650 m** | Média: **1720 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** O cume e a borda da monumental Caldeira de Veyrath. Ventos uivantes espalham plumas de cinzas incandescentes por todo o quadrante norte.
- **Material e Relevo Primário:** Escarpa de cratera vulcânica ativa, lago de lava central, fumarolas de alta pressão e altares rituais esculpidos em basalto.
- **Limite Norte:** Borda externa da cratera descendo em precipício para o mar glacial do norte.
- **Limite Sul:** Terras endurecidas de REG-008.
- **Limite Leste:** Queda marítima em direção ao Estreito Setentrional.
- **Limite Oeste:** Garganta Calcinada de REG-009.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-008` (Terra Férrea) via `gate_reg-010_to_reg-008`
  - Conexão com `REG-009` (Garganta Calcinada) via `gate_reg-010_to_reg-009`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:**
  - Portal para **Hell Forge** (`portal_reg-010_abyssal_forge`): Localizado em *Santuário da Cinza* (high_tier_rift).

---

## Continente Sylvaran (CONT-02)

### REG-011: Bosque Sussurrante

- **Identificador Único:** `REG-011`
- **Nome Canônico:** Bosque Sussurrante
- **Continente:** `CONT-02` (Sylvaran)
- **Bioma:** `whispering_woods`
- **Faixa de Nível Recomendada:** 1–6
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Bosque das Almas (`SafeZone` ativa)
- **Masmorra Vinculada:** Raízes Esquecidas (Requisito: nível 1+)
- **Chefe Associado:** `BOSS-009`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.64, 0.36)`
- **Bounding Box Normalizada:** `[min_x: 0.56, min_y: 0.28, max_x: 0.70, max_y: 0.43]`
- **Vértices do Polígono de Fronteira:** `(0.58, 0.30), (0.68, 0.29), (0.70, 0.37), (0.66, 0.43), (0.57, 0.41), (0.56, 0.34)`
- **Perfil de Elevação:** Altitude Mínima: **30 m** | Máxima: **180 m** | Média: **85 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Florestas ancestrais de carvalhos e teixos colossais cujas folhas emitem sussurros incompreensíveis ao sabor do vento do Mar da Cicatriz. Abriga a capital espiritual Bosque das Almas.
- **Material e Relevo Primário:** Húmus denso recoberto de musgo prateado, clareiras sagradas, menires envoltos em líquen e pontes vivas de cipó trançado.
- **Limite Norte:** Clareira das Runas de REG-013 e cumes de névoa de REG-016.
- **Limite Sul:** Costa pantanosa voltada para o Mar da Cicatriz.
- **Limite Leste:** Pântano Espectral de REG-012.
- **Limite Oeste:** Canal do Estreito Setentrional que separa Sylvaran de Veyrath.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-012` (Pântano Espectral) via `gate_reg-011_to_reg-012`
  - Conexão com `REG-013` (Clareira das Runas) via `gate_reg-011_to_reg-013`
  - Conexão com `REG-016` (Cume das Névoas) via `gate_reg-011_to_reg-016`
- **Conexões Marítimas (Mar da Cicatriz):**
  - Rota Náutica para `REG-001` (Planície Cinzenta de Veyrath) via `harbor_reg-011_to_reg-001`
  - Rota Náutica para `REG-031` (Baía dos Afogados) via `harbor_reg-011_to_reg-031`
- **Acessos Especiais e Portais Dimensionais:**
  - Portal para **Hell Forge** (`portal_reg-011_hell_forge`): Localizado em *Bosque das Almas* (permanent_conduit).

---

### REG-012: Pântano Espectral

- **Identificador Único:** `REG-012`
- **Nome Canônico:** Pântano Espectral
- **Continente:** `CONT-02` (Sylvaran)
- **Bioma:** `spectral_fen`
- **Faixa de Nível Recomendada:** 4–8
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Refúgio da Bruma (`SafeZone` ativa)
- **Masmorra Vinculada:** Galeria dos Afogados (Requisito: nível 4+)
- **Chefe Associado:** `BOSS-010`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.76, 0.38)`
- **Bounding Box Normalizada:** `[min_x: 0.69, min_y: 0.31, max_x: 0.84, max_y: 0.45]`
- **Vértices do Polígono de Fronteira:** `(0.70, 0.32), (0.80, 0.31), (0.84, 0.38), (0.81, 0.45), (0.71, 0.44), (0.69, 0.37)`
- **Perfil de Elevação:** Altitude Mínima: **5 m** | Máxima: **60 m** | Média: **22 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Vasto paul alagadiço de águas escuras e espelhos d'água luminescentes onde vagueiam aparições e fogos-fátuos de almas perdidas.
- **Material e Relevo Primário:** Águas paradas rasas, tapetes de macrófitas bioluminescentes, salgueiros arqueados e túmulos aquáticos de pedra cinzenta.
- **Limite Norte:** Elevações de Raízes Antigas de REG-014.
- **Limite Sul:** Litoral leste do Mar da Cicatriz.
- **Limite Leste:** Vale dos Salgueiros Negros de REG-015.
- **Limite Oeste:** Bosque Sussurrante de REG-011.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-011` (Bosque Sussurrante) via `gate_reg-012_to_reg-011`
  - Conexão com `REG-014` (Raízes Antigas) via `gate_reg-012_to_reg-014`
  - Conexão com `REG-015` (Vale dos Salgueiros Negros) via `gate_reg-012_to_reg-015`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-013: Clareira das Runas

- **Identificador Único:** `REG-013`
- **Nome Canônico:** Clareira das Runas
- **Continente:** `CONT-02` (Sylvaran)
- **Bioma:** `rune_glade`
- **Faixa de Nível Recomendada:** 6–10
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Posto Rúnico (`SafeZone` ativa)
- **Masmorra Vinculada:** Cripta dos Símbolos (Requisito: nível 6+)
- **Chefe Associado:** `BOSS-011`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.66, 0.25)`
- **Bounding Box Normalizada:** `[min_x: 0.58, min_y: 0.18, max_x: 0.72, max_y: 0.30]`
- **Vértices do Polígono de Fronteira:** `(0.60, 0.19), (0.70, 0.18), (0.72, 0.26), (0.67, 0.30), (0.59, 0.28), (0.58, 0.22)`
- **Perfil de Elevação:** Altitude Mínima: **90 m** | Máxima: **310 m** | Média: **175 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Clareira circular sagrada pontilhada por gigantescos dólmens e pedras talhadas com glifos que pulsam em tons de esmeralda e violeta.
- **Material e Relevo Primário:** Pradarias verdes pontilhadas de flores fluorescentes, círculos megalíticos, altares arcanos e terraços de pedra viva.
- **Limite Norte:** Cânion verdejante da Fenda Esmeralda de REG-019.
- **Limite Sul:** Bosque Sussurrante de REG-011.
- **Limite Leste:** Labirinto lenhoso de Raízes Antigas de REG-014.
- **Limite Oeste:** Escarpa do Cume das Névoas de REG-016.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-011` (Bosque Sussurrante) via `gate_reg-013_to_reg-011`
  - Conexão com `REG-014` (Raízes Antigas) via `gate_reg-013_to_reg-014`
  - Conexão com `REG-016` (Cume das Névoas) via `gate_reg-013_to_reg-016`
  - Conexão com `REG-019` (Fenda Esmeralda) via `gate_reg-013_to_reg-019`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-014: Raízes Antigas

- **Identificador Único:** `REG-014`
- **Nome Canônico:** Raízes Antigas
- **Continente:** `CONT-02` (Sylvaran)
- **Bioma:** `ancient_roots`
- **Faixa de Nível Recomendada:** 9–13
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Vila do Tronco Oco (`SafeZone` ativa)
- **Masmorra Vinculada:** Labirinto das Raízes (Requisito: nível 9+)
- **Chefe Associado:** `BOSS-012`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.78, 0.26)`
- **Bounding Box Normalizada:** `[min_x: 0.71, min_y: 0.18, max_x: 0.85, max_y: 0.32]`
- **Vértices do Polígono de Fronteira:** `(0.73, 0.19), (0.82, 0.18), (0.85, 0.27), (0.81, 0.32), (0.72, 0.30), (0.71, 0.23)`
- **Perfil de Elevação:** Altitude Mínima: **70 m** | Máxima: **260 m** | Média: **140 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Maciço labirinto de raízes titânicas de dezenas de metros de diâmetro que emergem do solo formando arcos, túneis e pontes naturais.
- **Material e Relevo Primário:** Raízes lenhosas gigantescas cobertas de musgo espesso, cavernas no interior de troncos ocos, solo húmico úmido e orquídeas parasitas.
- **Limite Norte:** Dossel fechado da Selva das Sombras de REG-018.
- **Limite Sul:** Pântano Espectral de REG-012.
- **Limite Leste:** Salgueiros e brejos de REG-015.
- **Limite Oeste:** Clareira das Runas de REG-013.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-012` (Pântano Espectral) via `gate_reg-014_to_reg-012`
  - Conexão com `REG-013` (Clareira das Runas) via `gate_reg-014_to_reg-013`
  - Conexão com `REG-015` (Vale dos Salgueiros Negros) via `gate_reg-014_to_reg-015`
  - Conexão com `REG-018` (Selva das Sombras) via `gate_reg-014_to_reg-018`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-015: Vale dos Salgueiros Negros

- **Identificador Único:** `REG-015`
- **Nome Canônico:** Vale dos Salgueiros Negros
- **Continente:** `CONT-02` (Sylvaran)
- **Bioma:** `black_willows`
- **Faixa de Nível Recomendada:** 12–16
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Acampamento Fúnebre (`SafeZone` ativa)
- **Masmorra Vinculada:** Túmulo das Lágrimas (Requisito: nível 12+)
- **Chefe Associado:** `BOSS-013`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.88, 0.32)`
- **Bounding Box Normalizada:** `[min_x: 0.82, min_y: 0.24, max_x: 0.94, max_y: 0.40]`
- **Vértices do Polígono de Fronteira:** `(0.84, 0.25), (0.92, 0.25), (0.94, 0.35), (0.90, 0.40), (0.83, 0.38), (0.82, 0.30)`
- **Perfil de Elevação:** Altitude Mínima: **20 m** | Máxima: **140 m** | Média: **65 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Vale úmido dominado por salgueiros de seiva escura e folhagem negra que goteja seiva corrosiva em ribeirões silenciosos.
- **Material e Relevo Primário:** Cursos d'água lentos de cor púrpura escura, vegetação gótica sombria, túmulos de pedra e pontes suspensas decadentes.
- **Limite Norte:** Pântano de Sangue de REG-017.
- **Limite Sul:** Falésias marítimas orientais voltadas para o oceano exterior.
- **Limite Leste:** Costa oriental de Sylvaran.
- **Limite Oeste:** Raízes Antigas de REG-014 e Pântano Espectral de REG-012.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-012` (Pântano Espectral) via `gate_reg-015_to_reg-012`
  - Conexão com `REG-014` (Raízes Antigas) via `gate_reg-015_to_reg-014`
  - Conexão com `REG-017` (Pântano de Sangue) via `gate_reg-015_to_reg-017`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-016: Cume das Névoas

- **Identificador Único:** `REG-016`
- **Nome Canônico:** Cume das Névoas
- **Continente:** `CONT-02` (Sylvaran)
- **Bioma:** `misty_ridge`
- **Faixa de Nível Recomendada:** 14–18
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Mirante das Brumas (`SafeZone` ativa)
- **Masmorra Vinculada:** Salão Enevoado (Requisito: nível 14+)
- **Chefe Associado:** `BOSS-014`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.58, 0.18)`
- **Bounding Box Normalizada:** `[min_x: 0.54, min_y: 0.10, max_x: 0.65, max_y: 0.27]`
- **Vértices do Polígono de Fronteira:** `(0.56, 0.11), (0.64, 0.11), (0.65, 0.20), (0.61, 0.27), (0.55, 0.25), (0.54, 0.17)`
- **Perfil de Elevação:** Altitude Mínima: **300 m** | Máxima: **1180 m** | Média: **680 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Cordilheira alta recortada por pontes de rocha suspensa e arquipélagos de ilhas flutuantes envoltas em bruma perpétua.
- **Material e Relevo Primário:** Ilhas flutuantes ancoradas por cipós gigantescos, abismos cobertos de névoa, plataformas rúnicas voadoras e vento úmido perene.
- **Limite Norte:** Fenda Esmeralda de REG-019.
- **Limite Sul:** Bosque Sussurrante de REG-011.
- **Limite Leste:** Clareira das Runas de REG-013.
- **Limite Oeste:** Canal marítimo setentrional.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-011` (Bosque Sussurrante) via `gate_reg-016_to_reg-011`
  - Conexão com `REG-013` (Clareira das Runas) via `gate_reg-016_to_reg-013`
  - Conexão com `REG-019` (Fenda Esmeralda) via `gate_reg-016_to_reg-019`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-017: Pântano de Sangue

- **Identificador Único:** `REG-017`
- **Nome Canônico:** Pântano de Sangue
- **Continente:** `CONT-02` (Sylvaran)
- **Bioma:** `blood_mire`
- **Faixa de Nível Recomendada:** 17–21
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Fortaleza Rubra (`SafeZone` ativa)
- **Masmorra Vinculada:** Fosso dos Sacrifícios (Requisito: nível 17+)
- **Chefe Associado:** `BOSS-015`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.88, 0.18)`
- **Bounding Box Normalizada:** `[min_x: 0.82, min_y: 0.10, max_x: 0.94, max_y: 0.25]`
- **Vértices do Polígono de Fronteira:** `(0.85, 0.10), (0.93, 0.11), (0.94, 0.20), (0.89, 0.25), (0.83, 0.23), (0.82, 0.15)`
- **Perfil de Elevação:** Altitude Mínima: **10 m** | Máxima: **85 m** | Média: **35 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Terreno alagadiço de águas carmesins ricas em ferro orgânico e algas predadoras que drenam seiva das árvores moribundas da orla oriental.
- **Material e Relevo Primário:** Lodo vermelho denso, flores carnívoras de grande porte, raízes afiadas como espinhos e totens druídicos ensanguentados.
- **Limite Norte:** Floresta fechada da Selva das Sombras de REG-018.
- **Limite Sul:** Vale dos Salgueiros Negros de REG-015.
- **Limite Leste:** Costas rochosas do mar oriental.
- **Limite Oeste:** Borda da Selva das Sombras de REG-018.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-015` (Vale dos Salgueiros Negros) via `gate_reg-017_to_reg-015`
  - Conexão com `REG-018` (Selva das Sombras) via `gate_reg-017_to_reg-018`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-018: Selva das Sombras

- **Identificador Único:** `REG-018`
- **Nome Canônico:** Selva das Sombras
- **Continente:** `CONT-02` (Sylvaran)
- **Bioma:** `shadow_jungle`
- **Faixa de Nível Recomendada:** 19–23
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Posto do Dossel (`SafeZone` ativa)
- **Masmorra Vinculada:** Antro das Vinhas Negras (Requisito: nível 19+)
- **Chefe Associado:** `BOSS-016`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.77, 0.14)`
- **Bounding Box Normalizada:** `[min_x: 0.70, min_y: 0.08, max_x: 0.85, max_y: 0.21]`
- **Vértices do Polígono de Fronteira:** `(0.72, 0.08), (0.82, 0.08), (0.85, 0.16), (0.80, 0.21), (0.71, 0.19), (0.70, 0.13)`
- **Perfil de Elevação:** Altitude Mínima: **80 m** | Máxima: **360 m** | Média: **190 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Selva hiperdensa cujo dossel a 100 metros de altura bloqueia integralmente a luz solar. O solo vive em penumbra eterna povoada por criaturas sombrias.
- **Material e Relevo Primário:** Sub-bosque escuro iluminado por cogumelos luminescentes, cipós estranguladores, trilhas de raízes e arcos góticos vegetais.
- **Limite Norte:** Plataforma central do Coração da Floresta Abissal de REG-020.
- **Limite Sul:** Raízes Antigas de REG-014 e Pântano de Sangue de REG-017.
- **Limite Leste:** Pântano de Sangue de REG-017.
- **Limite Oeste:** Fenda Esmeralda de REG-019.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-014` (Raízes Antigas) via `gate_reg-018_to_reg-014`
  - Conexão com `REG-017` (Pântano de Sangue) via `gate_reg-018_to_reg-017`
  - Conexão com `REG-019` (Fenda Esmeralda) via `gate_reg-018_to_reg-019`
  - Conexão com `REG-020` (Coração da Floresta Abissal) via `gate_reg-018_to_reg-020`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-019: Fenda Esmeralda

- **Identificador Único:** `REG-019`
- **Nome Canônico:** Fenda Esmeralda
- **Continente:** `CONT-02` (Sylvaran)
- **Bioma:** `emerald_fissure`
- **Faixa de Nível Recomendada:** 22–26
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Vila Esmeralda (`SafeZone` ativa)
- **Masmorra Vinculada:** Cavernas dos Cristais Verdes (Requisito: nível 22+)
- **Chefe Associado:** Nenhum chefe demoníaco alocado

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.65, 0.10)`
- **Bounding Box Normalizada:** `[min_x: 0.58, min_y: 0.05, max_x: 0.72, max_y: 0.16]`
- **Vértices do Polígono de Fronteira:** `(0.60, 0.05), (0.70, 0.05), (0.72, 0.13), (0.67, 0.16), (0.59, 0.15), (0.58, 0.09)`
- **Perfil de Elevação:** Altitude Mínima: **140 m** | Máxima: **680 m** | Média: **390 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Fenda tectônica atravessada por veios de cristal verde ressonante e cascatas de seiva pura. Corredor místico de acesso ao santuário boreal.
- **Material e Relevo Primário:** Paredões com geodos gigantes de cristal verde, pontes de madeira élfica ancestral, cavernas cintilantes e riachos de água mineral pura.
- **Limite Norte:** Declive em direção ao oceano polar setentrional.
- **Limite Sul:** Clareira das Runas de REG-013 e Cume das Névoas de REG-016.
- **Limite Leste:** Selva das Sombras de REG-018 e Coração da Floresta de REG-020.
- **Limite Oeste:** Contrafortes ocidentais do Cume das Névoas.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-013` (Clareira das Runas) via `gate_reg-019_to_reg-013`
  - Conexão com `REG-016` (Cume das Névoas) via `gate_reg-019_to_reg-016`
  - Conexão com `REG-018` (Selva das Sombras) via `gate_reg-019_to_reg-018`
  - Conexão com `REG-020` (Coração da Floresta Abissal) via `gate_reg-019_to_reg-020`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-020: Coração da Floresta Abissal

- **Identificador Único:** `REG-020`
- **Nome Canônico:** Coração da Floresta Abissal
- **Continente:** `CONT-02` (Sylvaran)
- **Bioma:** `abyssal_heart`
- **Faixa de Nível Recomendada:** 25–30
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Santuário da Seiva (`SafeZone` ativa)
- **Masmorra Vinculada:** Santuário Corrompido (Requisito: nível 25+)
- **Chefe Associado:** Nenhum chefe demoníaco alocado

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.78, 0.07)`
- **Bounding Box Normalizada:** `[min_x: 0.70, min_y: 0.05, max_x: 0.88, max_y: 0.12]`
- **Vértices do Polígono de Fronteira:** `(0.73, 0.05), (0.85, 0.05), (0.87, 0.11), (0.81, 0.12), (0.72, 0.11), (0.71, 0.07)`
- **Perfil de Elevação:** Altitude Mínima: **250 m** | Máxima: **1600 m** | Média: **840 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** O núcleo vital e místico de Sylvaran: a gigantesca Árvore-Mãe que ancora as ilhas flutuantes superiores e abriga a Fenda Abissal de Seiva Negra.
- **Material e Relevo Primário:** Troncos titânicos, ilhas aéreas suspensas por feixes de luz mágica, cascatas de seiva bioluminescente e santuários arcanos intocados.
- **Limite Norte:** Falésias boreais e céu aberto sobre o oceano polar.
- **Limite Sul:** Selva das Sombras de REG-018.
- **Limite Leste:** Extremo nordeste costeiro de Sylvaran.
- **Limite Oeste:** Fenda Esmeralda de REG-019.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-018` (Selva das Sombras) via `gate_reg-020_to_reg-018`
  - Conexão com `REG-019` (Fenda Esmeralda) via `gate_reg-020_to_reg-019`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:**
  - Portal para **Hell Forge** (`portal_reg-020_abyssal_forge`): Localizado em *Santuário da Seiva* (high_tier_rift).

---

## Continente Khar-Duum (CONT-03)

### REG-021: Dunas de Areia Negra

- **Identificador Único:** `REG-021`
- **Nome Canônico:** Dunas de Areia Negra
- **Continente:** `CONT-03` (Khar-Duum)
- **Bioma:** `black_sand_dunes`
- **Faixa de Nível Recomendada:** 1–6
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Fortaleza de Basalto (`SafeZone` ativa)
- **Masmorra Vinculada:** Templo Soterrado (Requisito: nível 1+)
- **Chefe Associado:** `BOSS-017`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.36, 0.64)`
- **Bounding Box Normalizada:** `[min_x: 0.28, min_y: 0.56, max_x: 0.44, max_y: 0.71]`
- **Vértices do Polígono de Fronteira:** `(0.31, 0.57), (0.41, 0.56), (0.44, 0.65), (0.39, 0.71), (0.30, 0.69), (0.28, 0.62)`
- **Perfil de Elevação:** Altitude Mínima: **20 m** | Máxima: **190 m** | Média: **75 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Erg colossal de dunas de magnetita e sílica negra estendendo-se ao longo da costa do Mar da Cicatriz. Abriga a maciça Fortaleza de Basalto.
- **Material e Relevo Primário:** Areia fina negra magnética, cristas eólicas afiadas, pilares de basalto esculpidos por ventos e caravanas fortificadas.
- **Limite Norte:** Litoral sul do Canal Ocidental e águas do Mar da Cicatriz.
- **Limite Sul:** Oásis da Serpente de REG-023.
- **Limite Leste:** Costa do Mar da Cicatriz com piers de atracação da Fortaleza.
- **Limite Oeste:** Cânion dos Ventos Áridos de REG-022.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-022` (Cânion dos Ventos Áridos) via `gate_reg-021_to_reg-022`
  - Conexão com `REG-023` (Oásis da Serpente) via `gate_reg-021_to_reg-023`
- **Conexões Marítimas (Mar da Cicatriz):**
  - Rota Náutica para `REG-001` (Planície Cinzenta de Veyrath) via `harbor_reg-021_to_reg-001`
  - Rota Náutica para `REG-031` (Baía dos Afogados) via `harbor_reg-021_to_reg-031`
- **Acessos Especiais e Portais Dimensionais:**
  - Portal para **Hell Forge** (`portal_reg-021_hell_forge`): Localizado em *Fortaleza de Basalto* (permanent_conduit).

---

### REG-022: Cânion dos Ventos Áridos

- **Identificador Único:** `REG-022`
- **Nome Canônico:** Cânion dos Ventos Áridos
- **Continente:** `CONT-03` (Khar-Duum)
- **Bioma:** `dry_canyon`
- **Faixa de Nível Recomendada:** 4–8
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Posto das Gargantas (`SafeZone` ativa)
- **Masmorra Vinculada:** Fenda dos Uivos (Requisito: nível 4+)
- **Chefe Associado:** `BOSS-018`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.24, 0.63)`
- **Bounding Box Normalizada:** `[min_x: 0.16, min_y: 0.56, max_x: 0.30, max_y: 0.70]`
- **Vértices do Polígono de Fronteira:** `(0.18, 0.57), (0.28, 0.56), (0.30, 0.65), (0.26, 0.70), (0.17, 0.68), (0.16, 0.61)`
- **Perfil de Elevação:** Altitude Mínima: **110 m** | Máxima: **480 m** | Média: **290 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Rede de gargantas profundas de arenito vermelho e ocre onde as correntes térmicas produzem silvos e uivos perpétuos entre os paredões.
- **Material e Relevo Primário:** Leitos secos fluviais, desfiladeiros estreitos com sombras profundas, arcos naturais de pedra e postos de vigia escavados.
- **Limite Norte:** Canal marítimo ocidental.
- **Limite Sul:** Vale dos Monólitos de REG-025.
- **Limite Leste:** Dunas de Areia Negra de REG-021.
- **Limite Oeste:** Platô Escaldante de REG-024.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-021` (Dunas de Areia Negra) via `gate_reg-022_to_reg-021`
  - Conexão com `REG-024` (Platô Escaldante) via `gate_reg-022_to_reg-024`
  - Conexão com `REG-025` (Vale dos Monólitos) via `gate_reg-022_to_reg-025`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-023: Oásis da Serpente

- **Identificador Único:** `REG-023`
- **Nome Canônico:** Oásis da Serpente
- **Continente:** `CONT-03` (Khar-Duum)
- **Bioma:** `serpent_oasis`
- **Faixa de Nível Recomendada:** 7–11
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Vila da Miragem (`SafeZone` ativa)
- **Masmorra Vinculada:** Poço dos Antigos (Requisito: nível 7+)
- **Chefe Associado:** `BOSS-019`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.38, 0.74)`
- **Bounding Box Normalizada:** `[min_x: 0.31, min_y: 0.68, max_x: 0.45, max_y: 0.81]`
- **Vértices do Polígono de Fronteira:** `(0.33, 0.69), (0.42, 0.68), (0.45, 0.76), (0.41, 0.81), (0.32, 0.79), (0.31, 0.73)`
- **Perfil de Elevação:** Altitude Mínima: **15 m** | Máxima: **120 m** | Média: **45 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Oásis sinuoso em formato de serpente alimentado por um lençol freático termal. Ponto vital de comércio e descanso antes do deserto profundo.
- **Material e Relevo Primário:** Palmeiras carmesins raras, lagoas de águas termais azul-turquesa, tendas de nômades, mesquitas em ruínas e solos salobros.
- **Limite Norte:** Dunas de Areia Negra de REG-021.
- **Limite Sul:** Escarpa vermelha de REG-027.
- **Limite Leste:** Costa rochosa do Mar da Cicatriz.
- **Limite Oeste:** Vale dos Monólitos de REG-025.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-021` (Dunas de Areia Negra) via `gate_reg-023_to_reg-021`
  - Conexão com `REG-025` (Vale dos Monólitos) via `gate_reg-023_to_reg-025`
  - Conexão com `REG-027` (Cidadela Vermelha) via `gate_reg-023_to_reg-027`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-024: Platô Escaldante

- **Identificador Único:** `REG-024`
- **Nome Canônico:** Platô Escaldante
- **Continente:** `CONT-03` (Khar-Duum)
- **Bioma:** `sunscorched_plateau`
- **Faixa de Nível Recomendada:** 10–14
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Refúgio da Rocha (`SafeZone` ativa)
- **Masmorra Vinculada:** Mina de Enxofre Solar (Requisito: nível 10+)
- **Chefe Associado:** `BOSS-020`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.13, 0.65)`
- **Bounding Box Normalizada:** `[min_x: 0.05, min_y: 0.57, max_x: 0.19, max_y: 0.73]`
- **Vértices do Polígono de Fronteira:** `(0.08, 0.58), (0.17, 0.57), (0.19, 0.67), (0.15, 0.73), (0.06, 0.71), (0.05, 0.63)`
- **Perfil de Elevação:** Altitude Mínima: **380 m** | Máxima: **920 m** | Média: **610 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Planalto elevado de rocha nua exposto a insolação brutal sem qualquer cobertura de vegetação. O ar vibra em miragens perpétuas.
- **Material e Relevo Primário:** Basalto fraturado pelo calor, pedregulhos soltos, poços de piche endurecido e abrigos sob lajes de pedra escorada.
- **Limite Norte:** Costas escarpadas do oceano ocidental.
- **Limite Sul:** Fenda de Sal de REG-026.
- **Limite Leste:** Cânion dos Ventos Áridos de REG-022.
- **Limite Oeste:** Penhascos intransponíveis do extremo ocidente.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-022` (Cânion dos Ventos Áridos) via `gate_reg-024_to_reg-022`
  - Conexão com `REG-026` (Fenda de Sal) via `gate_reg-024_to_reg-026`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-025: Vale dos Monólitos

- **Identificador Único:** `REG-025`
- **Nome Canônico:** Vale dos Monólitos
- **Continente:** `CONT-03` (Khar-Duum)
- **Bioma:** `monolith_valley`
- **Faixa de Nível Recomendada:** 13–17
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Acampamento das Estelas (`SafeZone` ativa)
- **Masmorra Vinculada:** Cripta dos Gigantes (Requisito: nível 13+)
- **Chefe Associado:** `BOSS-021`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.26, 0.76)`
- **Bounding Box Normalizada:** `[min_x: 0.18, min_y: 0.69, max_x: 0.33, max_y: 0.83]`
- **Vértices do Polígono de Fronteira:** `(0.20, 0.70), (0.30, 0.69), (0.33, 0.78), (0.28, 0.83), (0.19, 0.81), (0.18, 0.74)`
- **Perfil de Elevação:** Altitude Mínima: **140 m** | Máxima: **420 m** | Média: **260 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Planície desértica coberta por centenas de monólitos ciclópicos erguidos por titãs pré-humanos, cobertos por inscrições que zumbem com a brisa.
- **Material e Relevo Primário:** Areia alaranjada, megálitos verticais de granito negro, sepulturas saqueadas e caminhos de caravana bem demarcados.
- **Limite Norte:** Cânion dos Ventos de REG-022.
- **Limite Sul:** Labirinto de Cânions de REG-028.
- **Limite Leste:** Oásis da Serpente de REG-023.
- **Limite Oeste:** Fenda de Sal de REG-026.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-022` (Cânion dos Ventos Áridos) via `gate_reg-025_to_reg-022`
  - Conexão com `REG-023` (Oásis da Serpente) via `gate_reg-025_to_reg-023`
  - Conexão com `REG-026` (Fenda de Sal) via `gate_reg-025_to_reg-026`
  - Conexão com `REG-028` (Labirinto de Cânions) via `gate_reg-025_to_reg-028`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-026: Fenda de Sal

- **Identificador Único:** `REG-026`
- **Nome Canônico:** Fenda de Sal
- **Continente:** `CONT-03` (Khar-Duum)
- **Bioma:** `salt_flats`
- **Faixa de Nível Recomendada:** 15–19
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Posto do Sal Branco (`SafeZone` ativa)
- **Masmorra Vinculada:** Catacumbas Cristalinas (Requisito: nível 15+)
- **Chefe Associado:** `BOSS-022`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.12, 0.78)`
- **Bounding Box Normalizada:** `[min_x: 0.05, min_y: 0.71, max_x: 0.19, max_y: 0.86]`
- **Vértices do Polígono de Fronteira:** `(0.07, 0.72), (0.17, 0.71), (0.19, 0.80), (0.14, 0.86), (0.06, 0.84), (0.05, 0.77)`
- **Perfil de Elevação:** Altitude Mínima: **-20 m** | Máxima: **110 m** | Média: **30 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Extensa bacia de sal branco ofuscante resultante da dessecação de um mar antigo. Cristais afiados cobrem respiradouros geotérmicos mortais.
- **Material e Relevo Primário:** Crosta brilhante de sal puro, fendas profundas com salmoura cáustica, colunas de sal gema e ruínas de antigas salinas.
- **Limite Norte:** Platô Escaldante de REG-024.
- **Limite Sul:** Deserto Silencioso de REG-029.
- **Limite Leste:** Vale dos Monólitos de REG-025.
- **Limite Oeste:** Borda montanhosa ocidental.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-024` (Platô Escaldante) via `gate_reg-026_to_reg-024`
  - Conexão com `REG-025` (Vale dos Monólitos) via `gate_reg-026_to_reg-025`
  - Conexão com `REG-029` (Deserto Silencioso) via `gate_reg-026_to_reg-029`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-027: Cidadela Vermelha

- **Identificador Único:** `REG-027`
- **Nome Canônico:** Cidadela Vermelha
- **Continente:** `CONT-03` (Khar-Duum)
- **Bioma:** `red_citadel`
- **Faixa de Nível Recomendada:** 18–22
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Baluarte Vermelho (`SafeZone` ativa)
- **Masmorra Vinculada:** Masmorras da Forja (Requisito: nível 18+)
- **Chefe Associado:** `BOSS-023`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.37, 0.86)`
- **Bounding Box Normalizada:** `[min_x: 0.30, min_y: 0.80, max_x: 0.45, max_y: 0.93]`
- **Vértices do Polígono de Fronteira:** `(0.33, 0.81), (0.42, 0.80), (0.45, 0.89), (0.39, 0.93), (0.31, 0.91), (0.30, 0.85)`
- **Perfil de Elevação:** Altitude Mínima: **210 m** | Máxima: **890 m** | Média: **480 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Bastião militar e religioso esculpido diretamente nas entranhas de uma montanha de pedra carmesim. Protege as passagens subterrâneas do sul.
- **Material e Relevo Primário:** Fortificações colossais de arenito vermelho, fossos secos, portões monumentais de bronze escuro e forjas subterrâneas ativas.
- **Limite Norte:** Oásis da Serpente de REG-023.
- **Limite Sul:** Fissura vulcânica de REG-030.
- **Limite Leste:** Falésias marítimas do Estreito Meridional que separa Khar-Duum de Nhal'Kora.
- **Limite Oeste:** Labirinto de Cânions de REG-028.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-023` (Oásis da Serpente) via `gate_reg-027_to_reg-023`
  - Conexão com `REG-028` (Labirinto de Cânions) via `gate_reg-027_to_reg-028`
  - Conexão com `REG-030` (Garganta do Fogo Profundo) via `gate_reg-027_to_reg-030`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-028: Labirinto de Cânions

- **Identificador Único:** `REG-028`
- **Nome Canônico:** Labirinto de Cânions
- **Continente:** `CONT-03` (Khar-Duum)
- **Bioma:** `canyon_labyrinth`
- **Faixa de Nível Recomendada:** 20–24
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Posto da Poeira (`SafeZone` ativa)
- **Masmorra Vinculada:** Gruta das Sombras Quentes (Requisito: nível 20+)
- **Chefe Associado:** Nenhum chefe demoníaco alocado

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.24, 0.87)`
- **Bounding Box Normalizada:** `[min_x: 0.17, min_y: 0.81, max_x: 0.31, max_y: 0.93]`
- **Vértices do Polígono de Fronteira:** `(0.19, 0.82), (0.29, 0.81), (0.31, 0.89), (0.26, 0.93), (0.18, 0.91), (0.17, 0.85)`
- **Perfil de Elevação:** Altitude Mínima: **90 m** | Máxima: **520 m** | Média: **280 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Gargantas sinuosas entrecruzadas formando um dédalo natural inexpugnável onde correntes de ar fervente e poeira sufocante desorientam viajantes.
- **Material e Relevo Primário:** Paredões labirínticos com saliências estreitas, cavernas de bandidos e eremitas, escombros de desmoronamentos e poços de areia movediça.
- **Limite Norte:** Vale dos Monólitos de REG-025.
- **Limite Sul:** Garganta do Fogo Profundo de REG-030.
- **Limite Leste:** Cidadela Vermelha de REG-027.
- **Limite Oeste:** Deserto Silencioso de REG-029.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-025` (Vale dos Monólitos) via `gate_reg-028_to_reg-025`
  - Conexão com `REG-027` (Cidadela Vermelha) via `gate_reg-028_to_reg-027`
  - Conexão com `REG-029` (Deserto Silencioso) via `gate_reg-028_to_reg-029`
  - Conexão com `REG-030` (Garganta do Fogo Profundo) via `gate_reg-028_to_reg-030`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-029: Deserto Silencioso

- **Identificador Único:** `REG-029`
- **Nome Canônico:** Deserto Silencioso
- **Continente:** `CONT-03` (Khar-Duum)
- **Bioma:** `silent_waste`
- **Faixa de Nível Recomendada:** 23–27
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Acampamento Ermo (`SafeZone` ativa)
- **Masmorra Vinculada:** Tumba do Vento Perdido (Requisito: nível 23+)
- **Chefe Associado:** Nenhum chefe demoníaco alocado

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.12, 0.90)`
- **Bounding Box Normalizada:** `[min_x: 0.05, min_y: 0.83, max_x: 0.19, max_y: 0.95]`
- **Vértices do Polígono de Fronteira:** `(0.07, 0.84), (0.17, 0.83), (0.19, 0.91), (0.14, 0.95), (0.06, 0.94), (0.05, 0.88)`
- **Perfil de Elevação:** Altitude Mínima: **180 m** | Máxima: **610 m** | Média: **360 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Território de silêncio sobrenatural no extremo sudoeste onde nem pássaros nem insetos sobrevivem. Dunas petrificadas guardam tumbas esquecidas.
- **Material e Relevo Primário:** Dunas de areia ocre petrificada, esqueletos de feras pré-históricas desidratadas, tótens de proteção arruinados e ar imóvel.
- **Limite Norte:** Fenda de Sal de REG-026.
- **Limite Sul:** Borda austral do mundo conhecido.
- **Limite Leste:** Labirinto de Cânions de REG-028 e Garganta do Fogo de REG-030.
- **Limite Oeste:** Costas desoladas do oceano ocidental.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-026` (Fenda de Sal) via `gate_reg-029_to_reg-026`
  - Conexão com `REG-028` (Labirinto de Cânions) via `gate_reg-029_to_reg-028`
  - Conexão com `REG-030` (Garganta do Fogo Profundo) via `gate_reg-029_to_reg-030`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-030: Garganta do Fogo Profundo

- **Identificador Único:** `REG-030`
- **Nome Canônico:** Garganta do Fogo Profundo
- **Continente:** `CONT-03` (Khar-Duum)
- **Bioma:** `deepfire_gorge`
- **Faixa de Nível Recomendada:** 26–32
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Fortaleza Subterrânea (`SafeZone` ativa)
- **Masmorra Vinculada:** Altar das Profundezas (Requisito: nível 26+)
- **Chefe Associado:** Nenhum chefe demoníaco alocado

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.28, 0.94)`
- **Bounding Box Normalizada:** `[min_x: 0.20, min_y: 0.89, max_x: 0.36, max_y: 0.96]`
- **Vértices do Polígono de Fronteira:** `(0.22, 0.90), (0.34, 0.89), (0.36, 0.95), (0.29, 0.96), (0.21, 0.95), (0.20, 0.92)`
- **Perfil de Elevação:** Altitude Mínima: **-150 m** | Máxima: **850 m** | Média: **310 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Fissura continental extrema que penetra no manto terrestre, expondo câmaras de magma primordiais e forjas titânicas há muito abandonadas.
- **Material e Relevo Primário:** Câmaras subterrâneas gigantescas, pontes de ferro sobre rios de magma puro, maquinário colossal de forja arcaica e ar sufocante de cinzas.
- **Limite Norte:** Cidadela Vermelha de REG-027 e Labirinto de Cânions de REG-028.
- **Limite Sul:** Limite austral do mapa e abismo igneo.
- **Limite Leste:** Cidadela Vermelha de REG-027.
- **Limite Oeste:** Deserto Silencioso de REG-029.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-027` (Cidadela Vermelha) via `gate_reg-030_to_reg-027`
  - Conexão com `REG-028` (Labirinto de Cânions) via `gate_reg-030_to_reg-028`
  - Conexão com `REG-029` (Deserto Silencioso) via `gate_reg-030_to_reg-029`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:**
  - Portal para **Hell Forge** (`portal_reg-030_abyssal_forge`): Localizado em *Fortaleza Subterrânea* (high_tier_rift).

---

## Continente Nhal'Kora (CONT-04)

### REG-031: Baía dos Afogados

- **Identificador Único:** `REG-031`
- **Nome Canônico:** Baía dos Afogados
- **Continente:** `CONT-04` (Nhal'Kora)
- **Bioma:** `drowned_bay`
- **Faixa de Nível Recomendada:** 1–6
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Cidadela dos Afogados (`SafeZone` ativa)
- **Masmorra Vinculada:** Naufrágio do Leviatã (Requisito: nível 1+)
- **Chefe Associado:** `BOSS-024`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.64, 0.64)`
- **Bounding Box Normalizada:** `[min_x: 0.56, min_y: 0.56, max_x: 0.71, max_y: 0.71]`
- **Vértices do Polígono de Fronteira:** `(0.58, 0.57), (0.69, 0.56), (0.71, 0.65), (0.67, 0.71), (0.57, 0.69), (0.56, 0.62)`
- **Perfil de Elevação:** Altitude Mínima: **0 m** | Máxima: **110 m** | Média: **40 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Baía protegida cercada por falésias de basalto e pontilhada por cascos de navios afundados ao longo de séculos. Sede da Cidadela dos Afogados e porto do Mar da Cicatriz.
- **Material e Relevo Primário:** Litoral de cascalho negro, piers de madeira apodrecida ancorados em pedra, cascos de galeões encalhados e marés calmas de tom anil.
- **Limite Norte:** Costa voltada para o Canal do Leste e Mar da Cicatriz.
- **Limite Sul:** Recifes negros de REG-033.
- **Limite Leste:** Penhascos Espectrais de REG-032.
- **Limite Oeste:** Canal do Estreito Meridional que separa Nhal'Kora de Khar-Duum.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-032` (Penhascos Espectrais) via `gate_reg-031_to_reg-032`
  - Conexão com `REG-033` (Recife Abissal) via `gate_reg-031_to_reg-033`
- **Conexões Marítimas (Mar da Cicatriz):**
  - Rota Náutica para `REG-001` (Planície Cinzenta de Veyrath) via `harbor_reg-031_to_reg-001`
  - Rota Náutica para `REG-002` (Fendas de Enxofre) via `harbor_reg-031_to_reg-002`
  - Rota Náutica para `REG-011` (Bosque Sussurrante) via `harbor_reg-031_to_reg-011`
  - Rota Náutica para `REG-021` (Dunas de Areia Negra) via `harbor_reg-031_to_reg-021`
- **Acessos Especiais e Portais Dimensionais:**
  - Portal para **Hell Forge** (`portal_reg-031_hell_forge`): Localizado em *Cidadela dos Afogados* (permanent_conduit).

---

### REG-032: Penhascos Espectrais

- **Identificador Único:** `REG-032`
- **Nome Canônico:** Penhascos Espectrais
- **Continente:** `CONT-04` (Nhal'Kora)
- **Bioma:** `ghostly_cliffs`
- **Faixa de Nível Recomendada:** 4–8
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Posto do Farol (`SafeZone` ativa)
- **Masmorra Vinculada:** Catacumbas da Falésia (Requisito: nível 4+)
- **Chefe Associado:** `BOSS-025`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.77, 0.63)`
- **Bounding Box Normalizada:** `[min_x: 0.70, min_y: 0.56, max_x: 0.84, max_y: 0.70]`
- **Vértices do Polígono de Fronteira:** `(0.72, 0.57), (0.82, 0.56), (0.84, 0.65), (0.80, 0.70), (0.71, 0.68), (0.70, 0.61)`
- **Perfil de Elevação:** Altitude Mínima: **80 m** | Máxima: **520 m** | Média: **290 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Falésias verticais de rocha negra contra as quais o oceano quebra com violência inaudita. No topo ergue-se o secular Farol da Luz Fria.
- **Material e Relevo Primário:** Promontórios ventosos e rochosos, escadarias talhadas na rocha à beira do abismo, faróis antigos e catacumbas costeiras.
- **Limite Norte:** Costa oriental do Mar da Cicatriz.
- **Limite Sul:** Fjord dos Condenados de REG-035.
- **Limite Leste:** Costa das Névoas Frias de REG-034.
- **Limite Oeste:** Baía dos Afogados de REG-031.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-031` (Baía dos Afogados) via `gate_reg-032_to_reg-031`
  - Conexão com `REG-034` (Costa das Névoas Frias) via `gate_reg-032_to_reg-034`
  - Conexão com `REG-035` (Fjord dos Condenados) via `gate_reg-032_to_reg-035`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-033: Recife Abissal

- **Identificador Único:** `REG-033`
- **Nome Canônico:** Recife Abissal
- **Continente:** `CONT-04` (Nhal'Kora)
- **Bioma:** `abyssal_reef`
- **Faixa de Nível Recomendada:** 7–11
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Aldeia das Marés (`SafeZone` ativa)
- **Masmorra Vinculada:** Fenda de Coral Negro (Requisito: nível 7+)
- **Chefe Associado:** `BOSS-026`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.63, 0.75)`
- **Bounding Box Normalizada:** `[min_x: 0.56, min_y: 0.68, max_x: 0.70, max_y: 0.82]`
- **Vértices do Polígono de Fronteira:** `(0.58, 0.69), (0.68, 0.68), (0.70, 0.77), (0.66, 0.82), (0.57, 0.80), (0.56, 0.73)`
- **Perfil de Elevação:** Altitude Mínima: **-15 m** | Máxima: **65 m** | Média: **20 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Barreira litorânea de coral negro pontiagudo e lagunas rasas onde as marés mudam com violência repentina puxadas pela atração abissal.
- **Material e Relevo Primário:** Corais pontiagudos de tom obsidiano, poças de maré habitadas por anêmonas venenosas, passadiços sobre estacas e aldeias de pescadores.
- **Limite Norte:** Baía dos Afogados de REG-031.
- **Limite Sul:** Estuário dos Sussurros de REG-037.
- **Limite Leste:** Fjord dos Condenados de REG-035.
- **Limite Oeste:** Águas do Estreito Meridional.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-031` (Baía dos Afogados) via `gate_reg-033_to_reg-031`
  - Conexão com `REG-035` (Fjord dos Condenados) via `gate_reg-033_to_reg-035`
  - Conexão com `REG-037` (Estuário dos Sussurros) via `gate_reg-033_to_reg-037`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-034: Costa das Névoas Frias

- **Identificador Único:** `REG-034`
- **Nome Canônico:** Costa das Névoas Frias
- **Continente:** `CONT-04` (Nhal'Kora)
- **Bioma:** `cold_coast`
- **Faixa de Nível Recomendada:** 10–14
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Vila do Quebra-Mar (`SafeZone` ativa)
- **Masmorra Vinculada:** Grota dos Ventos Glaciais (Requisito: nível 10+)
- **Chefe Associado:** `BOSS-027`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.88, 0.65)`
- **Bounding Box Normalizada:** `[min_x: 0.81, min_y: 0.57, max_x: 0.94, max_y: 0.73]`
- **Vértices do Polígono de Fronteira:** `(0.83, 0.58), (0.92, 0.57), (0.94, 0.67), (0.90, 0.73), (0.82, 0.71), (0.81, 0.63)`
- **Perfil de Elevação:** Altitude Mínima: **10 m** | Máxima: **220 m** | Média: **95 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Litoral boreal fustigado por neblinas marítimas geladas com fragmentos de cristais de gelo que rasgam a pele de viajantes despreparados.
- **Material e Relevo Primário:** Praias de areia gélida e gelo moído, espigões de pedra contra o mar tempestuoso, vilarejos de caçadores de leviatãs e cavernas marinhas congeladas.
- **Limite Norte:** Oceano boreal exterior.
- **Limite Sul:** Geleira Sussurrante de REG-036.
- **Limite Leste:** Oceano glacial oriental.
- **Limite Oeste:** Penhascos Espectrais de REG-032.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-032` (Penhascos Espectrais) via `gate_reg-034_to_reg-032`
  - Conexão com `REG-036` (Geleira Sussurrante) via `gate_reg-034_to_reg-036`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-035: Fjord dos Condenados

- **Identificador Único:** `REG-035`
- **Nome Canônico:** Fjord dos Condenados
- **Continente:** `CONT-04` (Nhal'Kora)
- **Bioma:** `damned_fjord`
- **Faixa de Nível Recomendada:** 13–17
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Refúgio dos Remadores (`SafeZone` ativa)
- **Masmorra Vinculada:** Caverna das Almas Perdidas (Requisito: nível 13+)
- **Chefe Associado:** `BOSS-028`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.75, 0.75)`
- **Bounding Box Normalizada:** `[min_x: 0.68, min_y: 0.68, max_x: 0.82, max_y: 0.82]`
- **Vértices do Polígono de Fronteira:** `(0.70, 0.69), (0.80, 0.68), (0.82, 0.77), (0.77, 0.82), (0.69, 0.80), (0.68, 0.73)`
- **Perfil de Elevação:** Altitude Mínima: **40 m** | Máxima: **780 m** | Média: **360 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Fiorde sinuoso encaixado entre montanhas cobertas de permafrost. Águas escuras e profundas refletem as neves eternas das geleiras circundantes.
- **Material e Relevo Primário:** Paredões de gelo e granito de 600 metros de altura, canais navegáveis gélidos, cais de barcos fúnebres e acampamentos cravados em fendas.
- **Limite Norte:** Penhascos Espectrais de REG-032.
- **Limite Sul:** Estuário dos Sussurros de REG-037 e Maré Eterna de REG-038.
- **Limite Leste:** Geleira Sussurrante de REG-036.
- **Limite Oeste:** Recife Abissal de REG-033.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-032` (Penhascos Espectrais) via `gate_reg-035_to_reg-032`
  - Conexão com `REG-033` (Recife Abissal) via `gate_reg-035_to_reg-033`
  - Conexão com `REG-036` (Geleira Sussurrante) via `gate_reg-035_to_reg-036`
  - Conexão com `REG-037` (Estuário dos Sussurros) via `gate_reg-035_to_reg-037`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-036: Geleira Sussurrante

- **Identificador Único:** `REG-036`
- **Nome Canônico:** Geleira Sussurrante
- **Continente:** `CONT-04` (Nhal'Kora)
- **Bioma:** `frozen_expanse`
- **Faixa de Nível Recomendada:** 16–20
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Posto Glacial (`SafeZone` ativa)
- **Masmorra Vinculada:** Mina de Gelo Negro (Requisito: nível 16+)
- **Chefe Associado:** `BOSS-029`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.87, 0.76)`
- **Bounding Box Normalizada:** `[min_x: 0.80, min_y: 0.70, max_x: 0.94, max_y: 0.83]`
- **Vértices do Polígono de Fronteira:** `(0.82, 0.71), (0.92, 0.70), (0.94, 0.79), (0.89, 0.83), (0.81, 0.81), (0.80, 0.75)`
- **Perfil de Elevação:** Altitude Mínima: **420 m** | Máxima: **1680 m** | Média: **940 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Monumento de gelo azul milenar e compacto. O gelo estala continuamente emitindo frequências ressonantes conhecidas como 'os lamentos dos afogados'.
- **Material e Relevo Primário:** Seracs imensos de gelo transparente, fendas profundas de centenas de metros, cavernas de degelo azuladas e minas de gelo negro místico.
- **Limite Norte:** Costa das Névoas Frias de REG-034.
- **Limite Sul:** Maré Eterna de REG-038.
- **Limite Leste:** Borda da calota polar exterior.
- **Limite Oeste:** Fjord dos Condenados de REG-035.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-034` (Costa das Névoas Frias) via `gate_reg-036_to_reg-034`
  - Conexão com `REG-035` (Fjord dos Condenados) via `gate_reg-036_to_reg-035`
  - Conexão com `REG-038` (Maré Eterna) via `gate_reg-036_to_reg-038`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-037: Estuário dos Sussurros

- **Identificador Único:** `REG-037`
- **Nome Canônico:** Estuário dos Sussurros
- **Continente:** `CONT-04` (Nhal'Kora)
- **Bioma:** `whisper_estuary`
- **Faixa de Nível Recomendada:** 19–23
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Posto do Canal (`SafeZone` ativa)
- **Masmorra Vinculada:** Túmulo do Naufrágio (Requisito: nível 19+)
- **Chefe Associado:** `BOSS-030`

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.69, 0.87)`
- **Bounding Box Normalizada:** `[min_x: 0.61, min_y: 0.81, max_x: 0.76, max_y: 0.93]`
- **Vértices do Polígono de Fronteira:** `(0.63, 0.82), (0.73, 0.81), (0.76, 0.89), (0.71, 0.93), (0.62, 0.91), (0.61, 0.85)`
- **Perfil de Elevação:** Altitude Mínima: **5 m** | Máxima: **140 m** | Média: **55 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Delta labiríntico onde as correntes de degelo das montanhas encontram o oceano glacial em meio a bancos de lodo negro e bancos de gelo flutuante.
- **Material e Relevo Primário:** Ilhotas de permafrost lamacento, canais rasos de maré, pontões de barcaças abandonadas e mirantes de vigília contra leviatãs.
- **Limite Norte:** Recife Abissal de REG-033 e Fjord dos Condenados de REG-035.
- **Limite Sul:** Fossa Oceânica de REG-039.
- **Limite Leste:** Maré Eterna de REG-038.
- **Limite Oeste:** Limite litorâneo do Estreito Meridional.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-033` (Recife Abissal) via `gate_reg-037_to_reg-033`
  - Conexão com `REG-035` (Fjord dos Condenados) via `gate_reg-037_to_reg-035`
  - Conexão com `REG-038` (Maré Eterna) via `gate_reg-037_to_reg-038`
  - Conexão com `REG-039` (Fossa Oceânica) via `gate_reg-037_to_reg-039`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-038: Maré Eterna

- **Identificador Único:** `REG-038`
- **Nome Canônico:** Maré Eterna
- **Continente:** `CONT-04` (Nhal'Kora)
- **Bioma:** `eternal_tide`
- **Faixa de Nível Recomendada:** 22–26
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Acampamento das Marés (`SafeZone` ativa)
- **Masmorra Vinculada:** Fenda Profunda das Conchas (Requisito: nível 22+)
- **Chefe Associado:** Nenhum chefe demoníaco alocado

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.81, 0.87)`
- **Bounding Box Normalizada:** `[min_x: 0.74, min_y: 0.81, max_x: 0.88, max_y: 0.93]`
- **Vértices do Polígono de Fronteira:** `(0.76, 0.82), (0.86, 0.81), (0.88, 0.89), (0.83, 0.93), (0.75, 0.91), (0.74, 0.85)`
- **Perfil de Elevação:** Altitude Mínima: **0 m** | Máxima: **85 m** | Média: **30 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Golfo oceânico açoitado por tempestades e ressacas perpétuas cujas ondas de dez metros varrem ilhotas de rocha nua dia e noite.
- **Material e Relevo Primário:** Rochedos negros lavados por ondas quebrando violentamente, quebra-mares ciclópicos de alvenaria ancestral e cavernas de sucção de maré.
- **Limite Norte:** Geleira Sussurrante de REG-036.
- **Limite Sul:** Vórtice do Fim do Abismo de REG-040.
- **Limite Leste:** Oceano austral exterior.
- **Limite Oeste:** Estuário dos Sussurros de REG-037.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-036` (Geleira Sussurrante) via `gate_reg-038_to_reg-036`
  - Conexão com `REG-037` (Estuário dos Sussurros) via `gate_reg-038_to_reg-037`
  - Conexão com `REG-040` (Fim do Abismo) via `gate_reg-038_to_reg-040`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-039: Fossa Oceânica

- **Identificador Único:** `REG-039`
- **Nome Canônico:** Fossa Oceânica
- **Continente:** `CONT-04` (Nhal'Kora)
- **Bioma:** `oceanic_trench`
- **Faixa de Nível Recomendada:** 25–29
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Cidadela Submersa (`SafeZone` ativa)
- **Masmorra Vinculada:** Altar das Correntes (Requisito: nível 25+)
- **Chefe Associado:** Nenhum chefe demoníaco alocado

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.68, 0.95)`
- **Bounding Box Normalizada:** `[min_x: 0.60, min_y: 0.90, max_x: 0.76, max_y: 0.98]`
- **Vértices do Polígono de Fronteira:** `(0.62, 0.91), (0.74, 0.90), (0.76, 0.96), (0.70, 0.98), (0.61, 0.97), (0.60, 0.93)`
- **Perfil de Elevação:** Altitude Mínima: **-850 m** | Máxima: **40 m** | Média: **-320 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** Fossa submarina profunda cujas plataformas superiores emergem na maré baixa, revelando arcadas submersas de uma civilização pré-diluviana.
- **Material e Relevo Primário:** Plataformas de cantaria submersas, florestas de quelp gigante azulado, correntes abissais verticais e aberturas para as profundezas oceânicas.
- **Limite Norte:** Estuário dos Sussurros de REG-037.
- **Limite Sul:** Abismo abissal infinito.
- **Limite Leste:** Fim do Abismo de REG-040.
- **Limite Oeste:** Profundezas marinhas meridionais.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-037` (Estuário dos Sussurros) via `gate_reg-039_to_reg-037`
  - Conexão com `REG-040` (Fim do Abismo) via `gate_reg-039_to_reg-040`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:** Nenhum conduíte direto para Hell Forge nesta região.

---

### REG-040: Fim do Abismo

- **Identificador Único:** `REG-040`
- **Nome Canônico:** Fim do Abismo
- **Continente:** `CONT-04` (Nhal'Kora)
- **Bioma:** `abyssal_end`
- **Faixa de Nível Recomendada:** 28–35
- **Status de Produção:** `modular_staging`
- **Capital / Assentamento Seguro:** Santuário Abissal (`SafeZone` ativa)
- **Masmorra Vinculada:** Vórtice Final (Requisito: nível 28+)
- **Chefe Associado:** Nenhum chefe demoníaco alocado

#### Coordenadas Cartográficas e Polígono de Fronteira
- **Centro Normalizado:** `(0.82, 0.95)`
- **Bounding Box Normalizada:** `[min_x: 0.75, min_y: 0.90, max_x: 0.89, max_y: 0.98]`
- **Vértices do Polígono de Fronteira:** `(0.77, 0.91), (0.87, 0.90), (0.89, 0.96), (0.84, 0.98), (0.76, 0.97), (0.75, 0.93)`
- **Perfil de Elevação:** Altitude Mínima: **-1200 m** | Máxima: **150 m** | Média: **-450 m**

#### Fisiografia e Limites Naturais
- **Descrição Topográfica:** O limite sudeste do mundo: um redemoinho titânico onde as águas glaciais tombam em cascata no Vórtice Final do Abismo, revelando rifts dimensionais.
- **Material e Relevo Primário:** Vórtice ciclônico marinho, pilares de gelo que se precipitam no vazio, anéis rituais de pedra flutuante e rifts de energia dimensional.
- **Limite Norte:** Maré Eterna de REG-038.
- **Limite Sul:** Vazio infinito do Abismo.
- **Limite Leste:** Horizonte de água em queda livre.
- **Limite Oeste:** Fossa Oceânica de REG-039.

#### Pontos de Entrada, Saída e Conexões
- **Fronteiras Terrestres:**
  - Conexão com `REG-038` (Maré Eterna) via `gate_reg-040_to_reg-038`
  - Conexão com `REG-039` (Fossa Oceânica) via `gate_reg-040_to_reg-039`
- **Conexões Marítimas:** Inexistentes (região interior ou sem infraestrutura portuária formal).
- **Acessos Especiais e Portais Dimensionais:**
  - Portal para **Hell Forge** (`portal_reg-040_abyssal_forge`): Localizado em *Santuário Abissal* (high_tier_rift).

---
