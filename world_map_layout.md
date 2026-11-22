# Abyssal Pact — Layout e Estrutura do Mapa-Múndi (World Map Layout)

> **Documento Oficial de Engenharia Gráfica e Especificação de Layout Visual**  
> **Autoridade:** Cartógrafo Principal de ABYSSAL PACT  
> **Status:** Cânone Cartográfico Consolidado  
> **Versão:** 2.0.0 (Data-Driven / Vector & Raster Specifications)  
> **Arquivos Associados:** [world_map.svg](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/world_map.svg), [world_map.png](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/world_map.png), [world_map_legend.md](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/world_map_legend.md), [WORLD_MAP_DATA.json](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/WORLD_MAP_DATA.json), [REGION_GRAPH.json](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/REGION_GRAPH.json)

---

## 1. Especificações Técnicas do Canvas

O Mapa-Múndi Visual Oficial de **ABYSSAL PACT** foi dimensionado em resolução ultra-ampla para permitir tanto visualização panorâmica de conjunto quanto inspeção minuciosa de cada uma das 40 regiões e seus acidentes geográficos:

- **Dimensões do Canvas:** $3.200 \times 2.200\text{ pixels}$.
- **Proporção de Tela (Aspect Ratio):** $16:11$ ($1.455:1$), formato consagrado da cartografia renascentista e medieval.
- **Resolução de Rasterização Equivalente:** $300\text{ DPI}$ para saídas em alta definição.
- **Padrão de Cores:** Espaço sRGB com estética *Dark Fantasy Sepia* e contrastes acentuados por continente.
- **Formato Vetorial Primário:** SVG 1.1 (`world_map.svg`), totalmente escalável, vetorialmente editável e compatível com ferramentas modernas de vetor (Inkscape, Illustrator, Figma, navegadores web e Godot Engine).
- **Formato Raster Secundário:** PNG sem perdas (`world_map.png`), gerado diretamente pelo rasterizador nativo da Godot Engine a $3.200 \times 2.200$ pixels.

---

## 2. Divisão Espacial e Geometria do Layout

O espaço do mapa de $3.200 \times 2.200$ pixels está dividido em quatro macrozonas funcionais:

```
0 px                                                  2480 px            3200 px
+--------------------------------------------------------+---------------------+ 0 px
| [ZONA A: CABEÇALHO & MEDALHÃO PLANAR DA HELL FORGE]    |                     |
| Título: ABYSSAL PACT • Medalhão Transdimensional       |                     |
+--------------------------------------------------------+ [ZONA C:            | 180 px
|                                                        |  LEGENDA LATERAL    |
| [ZONA B: ÁREA DO MAPA MUNDIAL CARTOGRÁFICO]            |  COMPLETA]          |
|                                                        |                     |
|   • VEYRATH (NW)              • SYLVARAN (NE)          |  • 40 Regiões       |
|   Regiões 01 a 10             Regiões 11 a 20          |  • Cidades          |
|                                                        |  • Masmorras        |
|             ~~~~~~~~~~~~~~~~~~~~~~~~                   |  • Chefes [BOSS]    |
|             ~~~ MAR DA CICATRIZ ~~~                    |  • Biomas           |
|             ~~~~~~~~~~~~~~~~~~~~~~~~                   |                     |
|                                                        |  • Simbologia       |
|   • KHAR-DUUM (SW)            • NHAL'KORA (SE)         |  • Selo Oficial     |
|   Regiões 21 a 30             Regiões 31 a 40          |                     |
|                                                        |                     |
| [ZONA D: INSTRUMENTOS CARTOGRÁFICOS]                   |                     |
| Rosa dos Ventos • Escala Gráfica em Léguas             |                     |
+--------------------------------------------------------+---------------------+ 2120 px
                                                                                 2200 px
```

### 2.1. Equações de Mapeamento de Coordenadas

O viewport do mapa geográfico na **Zona B** ocupa exatamente:
- $X_{\min} = 100\text{ px}$, $X_{\max} = 2.460\text{ px} \implies \text{Largura} = 2.360\text{ px}$.
- $Y_{\min} = 200\text{ px}$, $Y_{\max} = 2.040\text{ px} \implies \text{Altura} = 1.840\text{ px}$.

A conversão entre as coordenadas normalizadas $(\mathbf{n}_x, \mathbf{n}_y) \in [0.0, 1.0]$ estabelecidas em `WORLD_MAP_DATA.json` e os pixels $(P_x, P_y)$ do canvas é expressa por:

$$P_x = 100 + \mathbf{n}_x \times 2360$$
$$P_y = 200 + \mathbf{n}_y \times 1840$$

#### Pontos Notáveis Transformados:
- **Origem Noroeste $(0.0, 0.0)$:** $(100\text{ px}, 200\text{ px})$.
- **Vórtice Central da Cicatriz $(0.50, 0.50)$:** $(1280\text{ px}, 1120\text{ px})$.
- **Extremo Sudeste $(1.0, 1.0)$:** $(2460\text{ px}, 2040\text{ px})$.

---

## 3. Estrutura de Camadas (Layer Stack)

O arquivo SVG foi estruturado em 9 camadas sequenciais sobrepostas, garantindo ordem visual límpida:

1. **Camada 1 — Fundo de Pergaminho (`#parchment-base`):** Gradiente radial rico de sépia escuro com vinheta periférica, evocando pergaminho curtido e envelhecido por séculos.
2. **Camada 2 — Bacia Oceânica do Mar da Cicatriz (`#mar-da-cicatriz-vortex`):** Massa de água escura com gradiente do azul-petróleo ao negro abissal, com anéis de distância e rumos náuticos irradiando a cada $15^\circ$ a partir do vórtice central.
3. **Camada 3 — Polígonos das 40 Regiões:** Cada uma das 40 regiões é preenchida por gradientes específicos do seu continente e delimitada por traço duplo sombreado, com contorno de arrebentação costeira estilizada.
4. **Camada 4 — Relevo Pictórico Medieval:** Elementos ilustrados isométricos representados no mapa:
   - *Picos Montanhosos:* Cones sombreados com hachuras de iluminação a oeste e sombra a leste.
   - *Caldeiras e Vulcões:* Elipses de lava incandescente com plumas de fumaça cinzenta ascendente.
   - *Maciços Florestais:* Agrupamentos de copas arredondadas com troncos e sombras vegetais.
   - *Dunas do Deserto:* Ondulações sinuosas de cristas de areia e hachuras eólicas.
   - *Geleiras e Fiordes:* Prismas cortantes de gelo azul-ciano refletindo frio perene.
5. **Camada 5 — Rotas Náuticas Intercontinentais:** Linhas douradas pontilhadas conectando os portos das capitais pelo Mar da Cicatriz.
6. **Camada 6 — Insígnias, Brasões e Nomes das 40 Regiões:**
   - Escudos circulares de borda dupla com algarismos cardinais `01` a `40`.
   - Flâmulas com os nomes canônicos das regiões em tipografia serifada gótica.
   - Ícones de cidades fortificadas nas sedes de assentamento seguro.
7. **Camada 7 — Banners Continentais & Elementos Heráldicos:**
   - Cartouches monumentais identificando `VEYRATH`, `SYLVARAN`, `KHAR-DUUM` e `NHAL'KORA`.
   - Título principal *"ABYSSAL PACT — CHARTA TERRARUM ET PROFUNDI"*.
8. **Camada 8 — O Medalhão Planar da Hell Forge:**
   - Posicionado no topo central ($X = 1280, Y = 95$), fora de qualquer continente físico.
   - Disco solar/abissal com anéis concêntricos flamejantes, bigorna ancestral e a legenda:
     `DIMENSÃO INDEPENDENTE — NEXUS PLANAR DE RESSURGIMENTO`.
9. **Camada 9 — Barra Lateral de Legenda & Moldura Externa:**
   - Painel lateral direito ($X = 2500$ a $3140$) contendo o índice exaustivo das 40 regiões, níveis, masmorras, cidades e chefes.
   - Rosa dos ventos e escala métrica gráfica ornamental.
   - Moldura cartográfica tripla com cantoneiras em filigrana dourada.

---

## 4. Paleta Cromática Canônica (Dark Fantasy Medieval)

| Elemento / Domínio | Cor Primária | Cor Secundária | Destaque / Acento | Significado Semiótico |
|---|---|---|---|---|
| **Base Pergaminho** | `#1f1815` | `#16110f` | `#0d0908` | Velo antigo, envelhecimento natural por fogo e tempo |
| **Mar da Cicatriz** | `#090d12` | `#18222d` | `#253242` | Profundezas oceânicas abissais e correntes revoltas |
| **Veyrath (NW)** | `#362923` | `#221916` | `#c85a2b` | Cinzas compactadas, basalto e lava incandescente |
| **Sylvaran (NE)** | `#1d2b1f` | `#18241a` | `#4ec98b` | Seiva vegetal profunda, musgo e brumas arcanas |
| **Khar-Duum (SW)** | `#3b2b1b` | `#241910` | `#d6a638` | Arenito calcinado, areia negra magnética e sol tórrido |
| **Nhal'Kora (SE)** | `#1e2c38` | `#17222b` | `#6ec5e8` | Ardósia boreal, permafrost e gelo cristalino |
| **Hell Forge (Nexo)** | `#ffe6a3` | `#ff7b2b` | `#b81b1b` | Fogo transdimensional, bigorna cósmica e forja do Abismo |
| **Ouro Cartográfico** | `#f5e1a4` | `#d4af37` | `#694e0d` | Títulos imperiais, escalas e bordas heráldicas |

---

## 5. Tipografia Aplicada

O arquivo SVG foi composto utilizando uma hierarquia tipográfica clássica inspirada nas inscrições romanas e códices medievais:

1. **Títulos Principais e Continentes:** `Trajan Pro`, `Cinzel Decorative`, `Georgia`, serifada maiúscula com alto espaçamento de letras (`letter-spacing: 5px a 6px`).
2. **Nomes de Regiões:** `Cinzel`, `Georgia`, serifada com peso médio/negrito e fundo escuro contrastante (`letter-spacing: 0.5px`).
3. **Números nos Escudos (01 a 40):** `Trajan Pro`, algarismos romanos-arábicos compactos centralizados de alta legibilidade.
4. **Legenda Lateral e Textos Auxiliares:** `Georgia`, serifada clássica com variações em itálico e regular para metadados (níveis, masmorras e cidades).

---

## 6. Integração com a Godot Engine e Telas do Jogo

O mapa foi projetado para servir como referência visual direta das telas de interface do jogo:

1. **`WorldMapScreen` (`scenes/ui/screens/world_map_screen.gd`):** Utiliza as mesmas posições de quadrantes, centros e coordenadas das regiões para seleção tática de continentes e teletransporte para a Hell Forge.
2. **`RegionalMapScreen` (`scenes/ui/screens/regional_map_screen.gd`):** Os marcadores e limites de cada uma das 40 regiões coincidem com os polígonos e centros definidos nesta cartografia.
3. **Asset 2D Oficial:** O arquivo rasterizado `world_map.png` ($3200 \times 2200$) reside na raiz do projeto, podendo ser carregado diretamente como `Texture2D` em menus, códices ou fundos de interface via `load("res://world_map.png")`.
