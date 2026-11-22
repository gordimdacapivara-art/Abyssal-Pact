# FICHA TÉCNICA: Dagon'Kora, o Arauto dos Afogados (BOSS-024)

> **Documento Oficial de Especificação Técnica de Chefe Supremo**  
> **Universo:** Abyssal Pact | **Identificador:** `BOSS-024` | **Categoria:** Demônio Supremo (Chefe de Masmorra)  
> **Caminho do Arquivo:** `Demons/Supreme/BOSS_024.md`

---

## TABELA DE AUDITORIA INICIAL E RESOLUÇÃO TÉCNICA

| Campo Técnico | Estado no Repositório | Ação de Resolução |
|---|---|---|
| **01 — Identificação** | PARCIAL | Preservado ID `BOSS-024`, oficializado nome com lore `Dagon'Kora, o Arauto dos Afogados`, título e progressão. |
| **02 — Família e Subespécie** | AUSENTE | Definida casta de Titã Demoníaco Soberano de Masmorra e linhagem abissal primordial. |
| **03 — Continente e Região** | PARCIAL | Preservados `CONT-04` (Nhal'Kora) e `REG-031` (Baía dos Afogados), arena `Naufrágio do Leviatã (REG-031)`. |
| **04 — Bioma e Habitat** | PARCIAL | Detalhada arena fechada de combate, perigos ambientais de masmorra e clima hostil. |
| **05 — Anatomia Completa** | AUSENTE | Descrição completa da anatomia colossal, cabeça titânica, quatro braços e núcleo abissal. |
| **06 — Dimensões e Proporções** | PARCIAL | Definidas dimensões colossais (7.6m, 6080kg, escala 4.22x vs jogador). |
| **07 — Paleta de Cores HEX** | AUSENTE | Criada paleta individual exclusiva com 7 códigos HEX e nomenclaturas de pigmento de chefe. |
| **08 — Materiais e Texturas** | AUSENTE | Especificadas propriedades PBR de alto detalhe e shaders de fendas ativas e pulsação. |
| **09 — Modelo 3D e Acessórios** | AUSENTE | Definido orçamento LOD0–LOD2, silhueta monumental, armadura profana e armas forjadas. |
| **10 — Animações e Rig** | PARCIAL | Projetado esqueleto mestre de 68 ossos deformadores, IK quádruplo e fases de combate. |
| **11 — IA e Comportamento** | PARCIAL | Desenvolvida IA de 3 fases sincronizadas (Pressão de Solo, Pressão Mista, Fúria Final). |
| **12 — Habilidades e Ataques** | PARCIAL | Detalhadas 5 habilidades de chefe (Slam, Beam, Hazard, Summon, Enrage) com VFX/SFX. |
| **13 — Resistências e Fraquezas** | PARCIAL | Mapeada matriz de resistências, imunidades a atordoamento direto e janelas de vulnerabilidade. |
| **14 — Drops e Materiais** | PARCIAL | Preservados 980 XP e 490 Ouro, definidos artefatos lendários e núcleos de chefe. |
| **15 — Variantes e Raridade** | PARCIAL | Preservada raridade `boss_elite`, criados modificadores de modo Heroico/Mítico. |

---

## 01 — IDENTIFICAÇÃO

- **Nome Oficial:** Dagon'Kora, o Arauto dos Afogados
- **ID Único:** `BOSS-024`
- **Título / Epíteto:** Terror do Naufrágio Imperial
- **Categoria Demoníaca:** Demônio Supremo
- **Classificação de Perigo:** Ameaça SS (Lorde Supremo de Masmorra)
- **Faixa de Progressão:** End Game (Níveis 45–60+)
- **Papel no Ecossistema:** Comandante supremo regional, guardião da masmorra Naufrágio do Leviatã e ápice do poder abissal local.

---

## 02 — FAMÍLIA E SUBESPÉCIE

- **Família Canônica:** Titã Demoníaco Soberano (Lorde da Calamidade)
- **Subespécie:** Arquidemônio Colossal de Elemento Água Abissal e Almas
- **Linhagem Demoníaca:** Gerado durante a primeira fratura abissal do continente Nhal'Kora, nutrido diretamente pelas veias de miasma subterrâneo.
- **Relação com Outras Espécies:** Comanda autoritariamente todas as criaturas inferiores e superiores de `REG-031`; sua presença impede a dispersão da horda.
- **Características Distintivas:** Núcleo de poder incrustado no peito que ressoa com o elemento Água Abissal e Almas, quatro membros superiores funcionais e mente tática com conhecimento ancestral.

---

## 03 — CONTINENTE E REGIÃO

- **Continente de Origem:** Nhal'Kora (`CONT-04`)
- **Região Específica:** Baía dos Afogados (`REG-031`)
- **Arena de Batalha:** `Naufrágio do Leviatã (REG-031)` (Câmara terminal da masmorra Naufrágio do Leviatã).
- **Raio da Arena:** 24.0 metros circulares delimitados por colunas em chamas e barreiras de contenção rúnica.
- **Território de Domínio:** Toda a extensão subterrânea de `REG-031`, irradiando corrupção para as fendas de superfície.

---

## 04 — BIOMA E HABITAT

- **Bioma Principal:** Costa Rochosa Enevoada com Naufrágios Antigos (Zona Subterrânea Profunda)
- **Condições Ambientais:** Alta concentração de gases asfixiantes, temperatura extrema oscilando com os ciclos de erupção de miasma, piso condutor de energia.
- **Perigos de Arena:** Rachaduras no solo que ejetam jatos de chamas/miasma em intervalos regulares a cada 18 segundos.
- **Estrutura da Arena:** Altar circular maciço de basalto entalhado com runas abissais, sustentado por pilares monumentais que podem ser usados como cobertura parcial.
- **Condições de Encontro:** Encontro de instância de chefe ativado ao atravessar a névoa de entrada com limite para grupos de até 8 jogadores.

---

## 05 — ANATOMIA COMPLETA

- **Cabeça e Crânio:** Crânio titânico coroado por quatro chifres maciços retorcidos de ferro abissal que se estendem por 1.4 metros.
- **Olhos e Pupilas:** Seis órbitas oculares brilhantes alinhadas em dois triângulos simétricos na face, emanando energia `Emissão Glacial Profunda de Nhal'Kora`.
- **Boca e Mandíbula:** Mandíbula dupla articulada capaz de desferir mordidas colossais, ladeada por presas de obsidiana afiadas.
- **Tronco e Caixa Torácica:** Tronco titânico com couraça de pedra vulcânica fundida à carne viva, com costelas externas protegendo o núcleo rúnico pulsante.
- **Membros Superiores:** Quatro braços colossais articulados: o par superior empunha armas rituais forjadas na Hell Forge; o par inferior termina em garras perfurantes.
- **Membros Inferiores:** Pernas pilares com musculatura de tendões expostos e pés em cascos partidos de aço escuro que cravam no solo.
- **Cauda e Dorsal:** Cauda espinhosa de 4.8 metros articulada como um chicote de placas ósseas, utilizada para varredura de área em 360°.
- **Núcleo de Energia:** Esfera no esterno contendo miasma concentrado, cuja cor muda de intensidade conforme as fases de vida do chefe.

---

## 06 — DIMENSÕES E PROPORÇÕES

- **Altura Total:** 7.6 metros
- **Largura dos Ombros:** 4.6 metros
- **Comprimento Total (com cauda):** 5.24 metros
- **Peso Estimado:** 6080 kg
- **Escala vs Jogador (1.80m):** 4.22x a estatura de um personagem humano comum.
- **Proporção Visual:** Silhueta imponente que ocupa o campo visual da câmera de terceira pessoa, transmitindo sensação imediata de confronto com um semideus profano.

---

## 07 — PALETA DE CORES HEX

| Aplicação Anatômica | Código HEX | Nome Descritivo do Pigmento |
|---|---|---|
| **Cor Primária (Couraça Titânica)** | `#0D1BB8` | Azul Fossa Abissal |
| **Cor Secundária (Carne Profana)** | `#1B3B78` | Ardósia Marinha Gélida |
| **Cor das Sombras (Fendas Oclusas)** | `#050B12` | Vácuo Oceânico Escuro |
| **Cor dos Detalhes (Armadura / Runas)** | `#3A7D8C` | Coral Negro Espectro |
| **Cor dos Olhos (Foco Espectral)** | `#00E5FF` | Cyan Abissal Puro |
| **Cor Sobrenatural (Aura de Chefe)** | `#2A0845` | Trevas de Maré Cósmica |
| **Emissão Luminosa (Núcleo de Poder)** | `#18D2E6` | Emissão Glacial Profunda de Nhal'Kora |

---

## 08 — MATERIAIS E TEXTURAS

- **PBR Master:** Conjunto de texturas em resolução 4096x4096 com mapeamento UDIM para tronco e membros.
- **Propriedades Físicas:**
  - `Roughness`: 0.85 nas placas de rocha basáltica; 0.25 no metal forjado das lâminas rituais.
  - `Metallic`: 0.65 nos componentes de armadura Hell Forge integrados ao corpo.
  - `Normal Map Depth`: 2.0 (relevo de entalhes rúnicos profundos e fraturas geológicas).
  - `Emissive Power`: 6.5 cd/m² pulsando em ritmo cardíaco de 60 bpm, acelerando para 120 bpm na fase 3.
- **Shaders Exclusivos:**
  - `boss_barrier_shield.tres`: Escudo semitransparente com distorção de refração de calor que surge nas transições de fase.
  - `boss_ground_crack.tres`: Decal projetado no piso que se expande antes de erupções de magma/miasma.

---

## 09 — MODELO 3D E ACESSÓRIOS

- **Topologia e Geometria:**
  - `LOD0 (Arena Principal):` 48.000 triângulos (dedos independentes, correntes físicas, dentes e relevo rúnico completo).
  - `LOD1 (Câmera Afastada):` 24.000 triângulos.
  - `LOD2 (Otimização):` 10.500 triângulos.
- **Partes Destacáveis em Batalha:**
  - A ombreira esquerda pode ser destruída na Fase 2, expondo um ponto fraco que concede +20% de dano crítico.
  - O par inferior de garras pode sofrer amputação temporária com dano concentrado de sangramento.
- **Equipamentos Empunhados:** Duas maças de ferro negro com cabeças em formato de crânio esculpido que emitem fumaça quente constante.

---

## 10 — ANIMAÇÕES E RIG

- **Nome do Esqueleto:** `rig_boss_supreme_titan_v2`
- **Contagem de Ossos:** 68 ossos deformadores principais + 18 nós IK e controladores de dinâmica de tecidos.
- **Clipes de Animação Especiais (30 FPS):**
  1. `intro_cinematic` (150 frames @ 30fps) - Entrada cinematográfica descendo do teto da arena com impacto sísmico.
  2. `idle_phase_1` (60 frames @ 30fps) - Postura altiva e firme com respiração cadenciada.
  3. `attack_slam` (50 frames @ 30fps) - Salto e impacto devastador no chão gerando onda de choque radial.
  4. `cast_beam` (80 frames @ 30fps) - Canalização peitoral disparando raio contínuo de energia em varredura de 120°.
  5. `cast_hazard` (65 frames @ 30fps) - Cravamento das maças no piso ativando armadilhas na arena inteira.
  6. `summon_minions` (70 frames @ 30fps) - Rugido que racha o solo invocando 4 demônios inferiores de apoio.
  7. `transition_phase_2` (90 frames @ 30fps) - Rompimento de carapaça com emissão de luz e grito de fúria.
  8. `transition_phase_3` (100 frames @ 30fps) - Queda temporária de joelhos e ascensão em chamas com aumento de velocidade.
  9. `death_cinematic` (120 frames @ 30fps) - Colapso lento de joelhos, núcleo peitoral se racha e explode em chuva de cinzas.

---

## 11 — IA E COMPORTAMENTO (SISTEMA DE 3 FASES)

A batalha segue uma máquina de estados estrita orientada por limiares de vida decrescentes:

### Fase 1: Pressão de Solo (100% a 66% de Vida)
- **Comportamento:** Ataques lentos, previsíveis e extremamente punitivos. Foco no tanque principal.
- **Habilidades Ativas:** `ABIL-BOSS-SLAM`.
- **Dinâmica:** Mantém posicionamento no centro da arena e testa o posicionamento dos atacantes à distância.

### Fase 2: Pressão Mista e Invocação (66% a 33% de Vida)
- **Transição:** Escudo de imunidade temporária de 4 segundos enquanto invoca criaturas inferiores.
- **Comportamento:** Agressividade ampliada, alternando ataques corporais com ataques à distância e varredura de raio.
- **Habilidades Ativas:** `ABIL-BOSS-SLAM`, `ABIL-BOSS-BEAM`, `ABIL-BOSS-HAZARD`.
- **Dinâmica:** Os jogadores precisam esquivar dos feixes rotativos enquanto controlam os demônios menores invocados.

### Fase 3: Fúria Abissal Enraivecida (33% a 0% de Vida)
- **Transição:** Emissão contínua de miasma na arena; velocidade de ataque aumentada em 35%.
- **Comportamento:** Ataques frenéticos sem tempo de espera entre combinações; perseguição implacável do jogador com maior dano.
- **Habilidades Ativas:** Todas as habilidades anteriores com tempo de recarga reduzido em 50% + `ABIL-BOSS-ENRAGE`.

---

## 12 — HABILIDADES E ATAQUES CANÔNICOS

| Habilidade | Descrição Visual e Efeito | Tipo de Dano | Dano Numérico | Recarga / Telegrafia |
|---|---|---|---:|---|
| **ABIL-BOSS-SLAM** | Salto monumental no ar seguido de colapso de punhos no solo; gera onda de choque circular de 10m de raio. | Físico + Ígneo | 140.8 pts | 6.0s (1.2s telegrafia) |
| **ABIL-BOSS-BEAM** | Feixe concentrado disparado pelo núcleo peitoral varrendo a arena horizontalmente em arco de 140°. | Abissal Puro | 110.0 pts/s | 14.0s (1.5s telegrafia) |
| **ABIL-BOSS-HAZARD** | Golpes simultâneos no chão que detonam 6 fendas de miasma sob os pés dos jogadores mais distantes. | Elemental Água Abissal e Almas | 123.2 pts | 18.0s (1.8s telegrafia) |
| **ABIL-BOSS-SUMMON** | Rugido que fratura os cantos da arena, abrindo portais de onde emergem 3 a 4 demônios locais. | Invocação Tática | — | 35.0s (2.0s telegrafia) |
| **ABIL-BOSS-ENRAGE** | Pulsação de aura avermelhada que aumenta o dano de todas as ações em +30% até o fim do combate. | Buff Permanente | Auto-Buff | Fase 3 (Uma única vez) |

---

## 13 — RESISTÊNCIAS E FRAQUEZAS

| Tipo de Dano | Multiplicador | Classificação | Efeito no Combate |
|---|---:|---|---|
| **Dano Físico** | `0.7x` | Resistente | Armadura colossal absorve impactos convencionais. |
| **Dano Abissal** | `0.6x` | Altamente Resistente | Imunidade a efeitos de sangramento e miasma abissal. |
| **Dano de Fogo** | `0.9x` | Resistente | Adaptado ao calor extremo de forja de masmorra. |
| **Dano Gélido** | `1.20x` | Fraqueza Moderada | Reduz temporariamente a velocidade de rotação do chefe em 15%. |
| **Dano Sagrado** | `1.45x` | Fraqueza Primária | Causa colapso no escudo rúnico e abre janelas de vulnerabilidade. |

- **Imunidades de Chefe:** Totalmente imune a atordoamento direto (Stun), paralisia, medo, controle mental e empurrões.
- **Mecânica de Desequilíbrio (Stagger):** Acúmulo de 1.800 pontos de postura quebra a guarda do chefe por 5 segundos, interrompendo conjurações e garantindo acertos críticos automáticos.

---

## 14 — DROPS E MATERIAIS LENDÁRIOS

| Categoria | Nome do Item Dropado | Chance (%) | Quantidade | Destino no Gameplay |
|---|---|---:|---|---|
| **Lendário** | Coração da Calamidade (BOSS-024) | 100% | 1 un | Criação de armas de conjunto de chefe na Hell Forge. |
| **Lendário** | Troféu de Conquista de Baía dos Afogados | 100% | 1 un | Conclusão de missões de códice e glória regional. |
| **Raro** | Essência Pura de Água Abissal e Almas | 75% | 2–4 un | Alquimia de infusão lendária e aprimoramento de pactos. |
| **Hell Forge** | Lingote Demoníaco de Alta Densidade | 60% | 3–6 un | Material mestre para armaduras de grau máximo. |
| **Equipamento** | Peça de Conjunto de Armadura do Soberano | 35% | 1 un | Equipamento lendário com bônus de conjunto de masmorra. |

- **Recompensa de Experiência:** `980 XP`
- **Recompensa Financeira:** `490 Moedas de Ouro`

---

## 15 — VARIANTES E RARIDADE

- **Raridade Canônica:** `boss_elite` (Encontro de Chefe de Masmorra)
- **Modo Heroico / Mítico de Masmorra:**
  - Acesso: Ativado mediante pedra de chave abissal obtida em eventos regionais.
  - Modificadores: +80% de vida máxima, +45% de dano, novos perigos móveis na arena e velocidade de ataque aumentada em 20%.
- **Vínculo com a Invasão de Azaroth:**
  - Durante o evento global do World Boss Azaroth, este chefe atua como general de suporte, enviando tropas de elite para o mapa aberto da região invadida.
