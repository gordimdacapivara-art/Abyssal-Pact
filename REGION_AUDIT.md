# AUDITORIA DOS MAPAS REGIONAIS 2D — ABYSSAL PACT
**Data da Auditoria:** 21 de Novembro de 2026  
**Escopo:** 40 Mapas Cartográficos Regionais Individuais (Camada Vetorial 2D / SVG)  
**Status da Auditoria:** Realizada com rigor forense — Nenhuma inconsistência foi ocultada

---

## 1. Visão Geral da Camada Cartográfica Regional 2D

Os mapas regionais 2D de **ABYSSAL PACT** foram construídos no formato vetorial SVG sob a diretriz estética de **Dark Fantasy Medieval Cartography** (pergaminho iluminado, relevo hachurado, bordas gravadas, ícones medievais para cidades, masmorras, chefes e portais cardeais).

Todos os arquivos estão localizados no diretório raiz do repositório sob `assets/maps/regions/`, particionados pelos diretórios dos quatro continentes:
- `assets/maps/regions/veyrath/` (12 arquivos SVG — incluindo versões canônicas de transição)
- `assets/maps/regions/sylvaran/` (10 arquivos SVG)
- `assets/maps/regions/khar_duum/` (10 arquivos SVG)
- `assets/maps/regions/nhal_kora/` (10 arquivos SVG)

**Total de Arquivos Auditados:** 42 arquivos SVG (40 regiões cobertas, com 2 arquivos de versão dual em Veyrath).

---

## 2. Auditoria de Conteúdo e Elementos Cartográficos

A inspeção forense da estrutura interna dos arquivos vetoriais revelou:
1. **Nenhum arquivo vazio:** Todos os 42 arquivos possuem entre $14.318$ e $19.910$ bytes, contendo elementos vetoriais densos (`<path>`, `<polygon>`, `<rect>`, gradientes `<defs>` e rotulagem textual `<text>`).
2. **Topografia e Relevo:** Todos os mapas contêm representação de relevo, limites cardeais de região e variações de cor por bioma (cinzas vulcânicas, musgo florestal, areia de obsidiana e gelo polar).
3. **Caminhos e Vias de Trânsito:** Presença de estradas principais e trilhas secundárias ligando o assentamento central aos portões de fronteira.
4. **Pontos de Interesse (POIs):**
   - Assentamento/Capital com demarcação expressa de *Safe Zone* (*"Zona Segura • Sem Dano Hostil (Raio 25m)"*).
   - Entrada de Masmorra (*Dungeon Entrance*) com identificação temática.
   - Arena de Chefe Regional demarcada com ícone de crânio e cornos de guerra.
   - Marco Geográfico / Ponto de Exploração (*Landmark*).
   - Portal Dimensional ou Altar de Viagem Rápida.
5. **Entradas e Saídas:** Portões cardeais devidamente rotulados (`Gate North`, `Gate South`, `Gate East`, `Gate West`) coerentes com o grafo de vizinhança.

---

## 3. Divergências Detectadas na Nomenclatura dos Mapas 2D

> [!WARNING]
> ### DESALINHAMENTO NOMINAL NOS VETORES REGIONAIS (38/40 REGIÕES)
> Os arquivos vetoriais foram confeccionados na Etapa 3 com base no rascunho geográfico preliminar.
> Posteriormente, nas Etapas 5 a 8, a nomenclatura canônica definitiva foi introduzida:
> - Em **Veyrath**, apenas `region_01` e `region_02` receberam cópias renomeadas (`region_01_cinzalia.svg` e `region_02_coroa_partida.svg`). As regiões `03` a `10` mantêm nomes antigos (`region_03_desfiladeiro_de_magma.svg` em vez de `vale_dos_sinos.svg`, etc.).
> - Em **Sylvaran**, todas as 10 regiões mantêm os nomes do draft (`region_11_bosque_sussurrante.svg` em vez de `raiz_antiga.svg`, etc.).
> - Em **Khar-Duum**, todas as 10 regiões mantêm os nomes do draft (`region_21_dunas_de_areia_negra.svg` em vez de `caldeira_rubra.svg`, etc.).
> - Em **Nhal'Kora**, todas as 10 regiões mantêm os nomes do draft (`region_31_baia_dos_afogados.svg` em vez de `geleira_dos_ecos.svg`, etc.).
> 
> **Classificação:** As regiões cujo mapa SVG contém o nome antigo são classificadas como **Parcialmente concluído** no escopo da auditoria de correspondência nominal, embora sua geografia e topologia vetorial estejam completas.

---

## 4. Tabela de Estado Individual das 40 Regiões (Camada 2D)

| ID | Nome Canônico (Produção) | Arquivo SVG Existente | Tamanho | POIs Mapeados | Entradas / Saídas | Correspondência Nominal | Classificação |
| :---: | :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| **REG-001** | Cinzália | `region_01_cinzalia.svg` | 17.990 b | Cidade, Dungeon, Chefe, Portal | 4 cardeais | Idêntica | **Concluído** |
| **REG-002** | Coroa Partida | `region_02_coroa_partida.svg` | 16.703 b | Cidade, Dungeon, Chefe, Portal | 3 cardeais | Idêntica | **Concluído** |
| **REG-003** | Vale dos Sinos | `region_03_desfiladeiro_de_magma.svg` | 16.469 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-004** | Bosque Oco | `region_04_pantano_de_cinzas.svg` | 16.271 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-005** | Lago de Vidro | `region_05_picos_de_obsidiana.svg` | 16.738 b | Posto, Dungeon, Chefe, Portal | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-006** | Costa das Cinzas | `region_06_deserto_fuliginoso.svg` | 16.275 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-007** | Passo da Vigília | `region_07_cratera_abissal_de_ferro.svg` | 17.361 b | Fortaleza, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-008** | Catacumbas de Orun | `region_08_terra_ferrea.svg` | 16.241 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-009** | Campos de Sal | `region_09_garganta_calcinada.svg` | 15.745 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-010** | Torre de Aster | `region_10_voo_de_cinzas.svg` | 15.164 b | Santuário, Dungeon, Chefe, Fenda | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-011** | Raiz Antiga | `region_11_bosque_sussurrante.svg` | 19.910 b | Santuário, Dungeon, Chefe, Portal | 4 cardeais | Divergente | **Parcialmente concluído** |
| **REG-012** | Pântano das Lanternas | `region_12_pantano_espectral.svg` | 15.884 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-013** | Copa Celeste | `region_13_clareira_das_runas.svg` | 18.552 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-014** | Jardim Afogado | `region_14_raizes_antigas.svg` | 18.542 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-015** | Arquipélago Suspenso | `region_15_vale_dos_salgueiros_negros.svg` | 18.290 b | Posto, Dungeon, Chefe, Portal | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-016** | Vale das Mariposas | `region_16_cume_das_nevoas.svg` | 16.648 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-017** | Espinha Verde | `region_17_pantano_de_sangue.svg` | 14.921 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-018** | Ninho das Brumas | `region_18_selva_das_sombras.svg` | 18.587 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-019** | Ruínas de Lyth | `region_19_fenda_esmeralda.svg` | 15.293 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-020** | Fonte do Primeiro Broto | `region_20_coracao_da_floresta_abissal.svg` | 17.142 b | Santuário, Dungeon, Chefe, Fenda | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-021** | Caldeira Rubra | `region_21_dunas_de_areia_negra.svg` | 17.296 b | Forja, Dungeon, Chefe, Portal | 4 cardeais | Divergente | **Parcialmente concluído** |
| **REG-022** | Fornalha dos Reis | `region_22_canion_dos_ventos_aridos.svg` | 16.675 b | Cidade, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-023** | Desfiladeiro de Obsidiana | `region_23_oasis_da_serpente.svg` | 15.859 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-024** | Mar de Escória | `region_24_plato_escaldante.svg` | 15.621 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-025** | Dunas de Vidro Negro | `region_25_vale_dos_monolitos.svg` | 16.200 b | Posto, Dungeon, Chefe, Portal | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-026** | Minas de Tharum | `region_26_fenda_de_sal.svg` | 16.220 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-027** | Ponte das Correntes | `region_27_cidadela_vermelha.svg` | 15.583 b | Fortaleza, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-028** | Planalto do Trovão | `region_28_labirinto_de_canions.svg` | 16.351 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-029** | Garganta do Carvão | `region_29_deserto_silencioso.svg` | 15.282 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-030** | Cratera do Coração | `region_30_garganta_do_fogo_profundo.svg` | 16.956 b | Fortaleza, Dungeon, Chefe, Fenda | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-031** | Geleira dos Ecos | `region_31_baia_dos_afogados.svg` | 16.923 b | Cidadela, Dungeon, Chefe, Portal | 4 cardeais | Divergente | **Parcialmente concluído** |
| **REG-032** | Cidade Submersa de Gelo | `region_32_penhascos_espectrais.svg` | 16.689 b | Cidade, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-033** | Tundra Branca | `region_33_recife_abissal.svg` | 15.533 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-034** | Pináculo do Silêncio | `region_34_costa_das_nevoas_frias.svg` | 15.337 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-035** | Bosque de Cristal | `region_35_fjord_dos_condenados.svg` | 16.574 b | Posto, Dungeon, Chefe, Portal | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-036** | Fenda do Inverno | `region_36_geleira_sussurrante.svg` | 15.971 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-037** | Costa Boreal | `region_37_estuario_dos_sussurros.svg` | 16.542 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-038** | Palácio Adormecido | `region_38_mare_eterna.svg` | 14.546 b | Palácio, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-039** | Cemitério das Estrelas | `region_39_fossa_oceanica.svg` | 14.318 b | Posto, Dungeon, Chefe, Marco | 3 cardeais | Divergente | **Parcialmente concluído** |
| **REG-040** | Trono da Aurora Morta | `region_40_fim_do_abismo.svg` | 15.143 b | Trono, Dungeon, Chefe, Fenda | 3 cardeais | Divergente | **Parcialmente concluído** |

---

## 5. Resumo da Auditoria dos Mapas 2D

- **Existência física:** $100\%$ ($42/40$ arquivos presentes, nenhum arquivo vazio ou corrompido).
- **Conteúdo topográfico e POIs:** $100\%$ (todas as regiões possuem trilhas, cidades com safe zone, dungeons e chefes mapeados).
- **Alinhamento de nomenclatura com a produção 3D:** $5\%$ estrito ($2/40$ com arquivos nomeados conforme canônica; $38/40$ requerem renomeação de arquivo e atualização de rótulo textual interno no SVG).
