# GUIA DE REFERÊNCIA TÉCNICA DE PRODUÇÃO: 230 DEMÔNIOS DE ABYSSAL PACT

> **Documento Oficial de Engenharia, Arte 3D, Animação e Combate**  
> **Localização:** `Demons/Technical_Reference/DEMON_TECHNICAL_REFERENCE_GUIDE.md`  
> **Público-Alvo:** Modeladores 3D, Riggers, Animadores, Designers de IA, Designers de Combate e Programadores de Gameplay

---

## 1. INTRODUÇÃO E DIRETRIZES GERAIS DE DESIGN

Este guia consolida as convenções técnicas, orçamentos de performance, arquitetura de rigs esqueléticos, padrões de shaders PBR e matrizes de IA aplicados a todos os **230 demônios de Abyssal Pact**.

### Princípios Fundamentais:
1. **Preservação Canônica Rígida:** Nenhuma criatura foi removida ou renomeada aleatoriamente; todos os identificadores oficiais (`DEMON-001` a `DEMON-200` e `BOSS-001` a `BOSS-030`) e vínculos de dados foram rigorosamente respeitados.
2. **Leitura Visual Imediata (Readability):** Cada família de demônios possui silhueta, proporção e linguagem de formas única, distinguível à distância mesmo através de fumaça vulcânica, neblina florestal ou tempestade de areia.
3. **Coerência Biológica e Continental:** A paleta de cores, couraça e habilidades refletem a geologia e o ecossistema do continente e região onde a criatura se manifesta.

---

## 2. ARQUITETURA DE RIGS E ESQUELETOS (BLENDER 5.3 & GODOT 4.7.2)

Todos os modelos utilizam convenções universais compatíveis com exportação GLB/glTF 2.0 e retargeting no Godot 4.7.2.

| Rig Padronizado | Morfologia | Contagem de Ossos Deformadores | Controles IK / Mecânicos | Famílias Atendidas |
|---|---|---:|---:|---|
| `rig_demon_brute_heavy_v2` | Bípede Hipertrofiado | 42 ossos | IK Duplo nas Pernas, Coluna 4 nós | `brute` (Inferior e Superior) |
| `rig_demon_stalker_agile_v2` | Quadrúpede Predatório / Ágil | 48 ossos | IK Tríplice nas Pernas, Cauda 6 nós | `stalker` (Inferior e Superior) |
| `rig_demon_caster_mystic_v2` | Bípede Levitação / Ocultista | 46 ossos | IK de Mãos 5 dedos, Manto / Vestes | `caster` (Inferior e Superior) |
| `rig_demon_swarm_skitter_v2` | Insetóide / Miriápode | 36 ossos | IK de 8 Patas Articuladas, Mandíbulas | `swarm` (Inferior e Superior) |
| `rig_demon_flyer_wings_v2` | Alado / Quiróptero | 52 ossos | Cadeia de Asas 8 nós por asa, Cauda | `flyer` (Inferior e Superior) |
| `rig_demon_sentinel_bastion_v2` | Blindado Mecano-Demoníaco | 40 ossos | Nó de Escudo Integrado, Ancoragens | `sentinel` (Inferior e Superior) |
| `rig_boss_supreme_titan_v2` | Titã Supremo Multimembros | 68 ossos | 4 Membros Superiores, Cauda, Peitoral | `Demônios Supremos` (30 Bosses) |
| `rig_demon_primordial_void_v2` | Colosso Eldritch Abissal | 76 ossos | Tentáculos Múltiplos, Cauda Abissal | `Demônios Primordiais` (10 Criaturas) |

### Requisitos Técnicos de Rigging:
- **Hierarquia Raiz:** Raiz única `root` com translação no plano XZ em `(0, 0, 0)` e osso de centro de gravidade `pelvis` / `cog`.
- **Eixos Locais:** Eixo Y apontando ao longo do osso, Eixo X para flexão e rotação lateral, Eixo Z para torção.
- **Envelope de Pesos (Skinning):** Máximo de 4 influências de ossos por vértice (compatível com os limites de GPU para Web/Vulkan Mobile).

---

## 3. ORÇAMENTO POLIGONAL E NÍVEIS DE DETALHE (LOD)

| Categoria | LOD0 (0m–15m) | LOD1 (15m–40m) | LOD2 (>40m) | Texturas (UDIM / Resolução) |
|---|---:|---:|---:|---|
| **Inferior (Comum / Incomum)** | 14.000 – 18.500 tris | 7.000 – 9.000 tris | 2.500 – 3.500 tris | 1x 2048x2048 (Base, Normal, ORM) |
| **Superior (Raro / Elite)** | 22.000 – 28.000 tris | 11.000 – 14.000 tris | 4.000 – 5.500 tris | 2x 2048x2048 ou 1x 4096x4096 |
| **Supremo (Chefes de Masmorra)** | 45.000 – 55.000 tris | 22.000 – 28.000 tris | 9.000 – 12.000 tris | 2x 4096x4096 (UDIM 1001 e 1002) |
| **Primordial (Calamidades)** | 60.000 – 75.000 tris | 30.000 – 38.000 tris | 12.000 – 15.000 tris | 3x 4096x4096 |

---

## 4. SHADERS E MATERIAL PBR DEMONÍACO

Todos os materiais utilizam o fluxo PBR Metalness/Roughness padrão do Godot 4 com empacotamento **ORM** (Oclusão no canal R, Roughness no canal G, Metallic no canal B):

1. **Shader de Fissuras Emissivas (`abyssal_emission_pulse.gdshader`):**
   - Pulsação senoidal configurável de 0.8 Hz a 2.5 Hz.
   - Intensidade emissiva de base entre 2.5 cd/m² e 8.0 cd/m².
   - Variação cromática nas bordas da fratura dérmica simulando queima e calor interno.
2. **Shader de Dissolução na Morte (`abyssal_dissolve.gdshader`):**
   - Dissolve por textura de ruído Simplex tridimensional.
   - Borda de combustão incandescente com partículas de cinzas ascendentes geradas via GPU.
3. **Shader de Gelo e Choque Térmico (`thermal_frost_shatter.gdshader`):**
   - Transição dinâmica de cor ao receber dano gélido, adicionando camada branca de geada sobre a carapaça e aumentando o `roughness` para 0.95.

---

## 5. SISTEMA DE IA E COMPORTAMENTO DE COMBATE

A árvore de comportamento de todos os demônios é padronizada na classe `CreatureAI` com desacoplamento de dados:

1. **Estado de Patrulha / Emboscada:**
   - Movimentação procedural entre nós de waypoint locais.
   - Teste de visão e audição a cada 0.25 segundos para economia de CPU.
2. **Engajamento e Seleção de Alvo:**
   - Cálculo de ameaça (Aggro Table) baseado em dano causado, proximidade e papel de suporte (curandeiros acumulam 1.3x mais aggro).
3. **Desengajamento Seguro (Anti-Exploit Leash):**
   - Se o alvo ultrapassa a distância de leash (24m–30m para criaturas normais; 40m para chefes), o demônio entra em estado de retorno inalcançável (`invulnerable_return`), retornando velozmente à sua posição inicial com regeneração completa de vida.
4. **Ciclo Global de Invasão de Azaroth:**
   - Durante as frentes ativas de invasão de Azaroth, os limites de leash são expandidos em 100%, e demônios de diferentes famílias cooperam em bandos táticos mistos (tanque + conjurador + enxame).
