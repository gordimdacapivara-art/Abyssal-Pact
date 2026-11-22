# FICHA TÉCNICA: Degolador de Pântano de Cinzas (DEMON-020)

> **Documento Oficial de Especificação Técnica de Criatura**  
> **Universo:** Abyssal Pact | **Identificador:** `DEMON-020` | **Categoria:** Demônio Inferior  
> **Caminho do Arquivo:** `Demons/Inferior/DEMON_020.md`

---

## TABELA DE AUDITORIA INICIAL E RESOLUÇÃO TÉCNICA

| Campo Técnico | Estado no Repositório | Ação de Resolução |
|---|---|---|
| **01 — Identificação** | PARCIAL | Preservado ID `DEMON-020`, oficializado nome canônico, categoria e nível. |
| **02 — Família e Subespécie** | PARCIAL | Preservada família `stalker`, completada linhagem abissal e subespécie biológica. |
| **03 — Continente e Região** | PARCIAL | Preservados `CONT-01` (Veyrath) e `REG-004` (Pântano de Cinzas), detalhado covil. |
| **04 — Bioma e Habitat** | PARCIAL | Preservado bioma `Charneca Cáustica de Cinzas Úmidas`, completadas condições climáticas e gatilhos. |
| **05 — Anatomia Completa** | AUSENTE | Criada morfologia detalhada (crânio, olhos, garras, couraça e traços abissais). |
| **06 — Dimensões e Proporções** | PARCIAL | Convertido raio de colisão em métricas volumétricas (1.7m, 180kg, escala 0.94x). |
| **07 — Paleta de Cores HEX** | AUSENTE | Criada paleta individual exclusiva com 7 códigos HEX e nomenclaturas de pigmento. |
| **08 — Materiais e Texturas** | AUSENTE | Especificadas propriedades PBR (Roughness, Metallic, Normal) e shaders requeridos. |
| **09 — Modelo 3D e Acessórios** | AUSENTE | Definido orçamento poligonal LOD0–LOD2, silhueta e partes quebráveis/destacáveis. |
| **10 — Animações e Rig** | PARCIAL | Projetado esqueleto de 48 ossos, IK avançado e lista de 10 clipes essenciais. |
| **11 — IA e Comportamento** | PARCIAL | Expandidos raios matemáticos em rotinas táticas, percepção sensorial e desengajamento. |
| **12 — Habilidades e Ataques** | PARCIAL | Preservada `ABIL-DEM-STALKER`, detalhados telegrafia, dano numérico, VFX e SFX. |
| **13 — Resistências e Fraquezas** | PARCIAL | Preservados multiplicadores de dados, adicionadas matrizes elementais e CC. |
| **14 — Drops e Materiais** | PARCIAL | Preservados 20 XP e 12 Ouro, adicionada tabela de loot e partes de monstros. |
| **15 — Variantes e Raridade** | PARCIAL | Preservada raridade `common`, criadas mutações visuais e formas alfas. |

---

## 01 — IDENTIFICAÇÃO

- **Nome Oficial:** Degolador de Pântano de Cinzas (DEMON-020)
- **ID Único:** `DEMON-020`
- **Título / Apelido:** Espreitador das Sombras de Pântano de Cinzas
- **Categoria Demoníaca:** Demônio Inferior
- **Classificação de Perigo:** Ameaça E (Comum) a D (Incomum)
- **Faixa de Progressão:** Early Game (Níveis 1–15)
- **Papel no Ecossistema:** Fauna hostil predatória e força de choque das fendas abissais locais.

---

## 02 — FAMÍLIA E SUBESPÉCIE

- **Família Canônica:** `stalker`
- **Subespécie:** Predador Ágil de Emboscada Abissal
- **Linhagem Demoníaca:** Descendente direto da corrupção tectônica do continente de Veyrath, adaptado à pressão e escória abissal.
- **Relação Biológica / Abissal:** Atua em simbiose com as fendas ativas, alimentando-se da emanação de miasma e servindo de patrulha para criaturas maiores.
- **Características Distintivas:** Carapaça mineralizada com compostos específicos de Charneca Cáustica de Cinzas Úmidas, resistência adaptada ao clima regional e ausência de medo diante de invasores.

---

## 03 — CONTINENTE E REGIÃO

- **Continente de Origem:** Veyrath (`CONT-01`)
- **Região Específica:** Pântano de Cinzas (`REG-004`)
- **Localização Habitual / Covil:** Fendas profundas, cavernas colapsadas e depressões cáusticas ao redor de Aldeia Queimada.
- **Territórios Dominados:** Raio de 1.5 km ao redor de pontos de emanação de energia da masmorra Fosso Lamacento.
- **Regiões de Aparição Secundária:** Fronteiras montanhosas e fendas periféricas que conectam `REG-004` às regiões vizinhas.

---

## 04 — BIOMA E HABITAT

- **Bioma Principal:** Charneca Cáustica de Cinzas Úmidas
- **Condições Ambientais:** Atmosfera carregada de partículas suspensas, temperatura entre 45°C e 70°C (ou frio extremo em zonas glaciais), solo instável.
- **Tipo de Terreno:** Solo rochoso irregular, escombros cortantes, placas de escória e fissuras que exalam gases sob pressão.
- **Habitat Natural:** Tocas escavadas na rocha basáltica, reentrâncias de penhascos e crateras de fenda ativa.
- **Estrutura do Local:** Galeria tubular subterrânea com piso coberto de ossadas polidas e cascalho vítreo.
- **Condições para Aparição:** Permanente na região; intensidade e velocidade de respawn aumentam em 40% durante o ciclo da Invasão de Azaroth.

---

## 05 — ANATOMIA COMPLETA

- **Cabeça e Crânio:** Crânio dolicocéfalo esguio com focinho alongado, narinas termo-sensíveis e fendas auditivas laterais.
- **Olhos e Pupilas:** Quatro olhos estigmáticos dispostos em arco com pupilas verticais luminescentes e percepção de calor.
- **Boca, Mandíbula e Dentes:** Mandíbula bipartida retrátil com fileiras duplas de dentes afiados recurvados como agulhas de vidro.
- **Chifres, Espinhos e Protuberâncias:** Espigões cefálicos delgados e curvados para trás rentes ao pescoço, servindo como lemes aerodinâmicos.
- **Tronco e Estrutura Corporal:** Tronco delgado e altamente flexível com caixa torácica elástica e espinha dorsal saliente com espinhos.
- **Braços, Mãos e Garras:** Membros anteriores ágeis com cotovelos de articulação estendida, mãos com 3 dedos longos e garras em foice de 25 cm.
- **Pernas e Pés:** Pernas digitígradas alongadas com tendões de alta tensão que permitem saltos parabólicos de até 12 metros.
- **Cauda, Asas ou Membros Adicionais:** Cauda longa e chicoteadora de 2.2 metros com lâmina terminal serrilhada para ataque de retaguarda.
- **Estrutura Muscular e Óssea:** Densidade óssea 3.5 vezes superior à humana, fibras musculares escuras ricas em mioglobina e reforçadas por queratina mineralizada.
- **Características Sobrenaturais:** Fissuras dérmicas luminescentes por onde pulsa energia demoníaca de tom Emissão Magmática Brilhante.
- **Dimorfismo / Diferenças:** Espécimes dominantes exibem chifres 20% mais longos e fissuras com brilho emissivo mais intenso.

---

## 06 — DIMENSÕES E PROPORÇÕES

- **Altura Total:** 1.7 m
- **Largura Corporal (Ombros/Carapaça):** 0.9 m
- **Comprimento (Focinho à Cauda/Pálio):** 2.3 m
- **Peso Estimado:** 180 kg
- **Proporções Corporais:** Centro de massa rebaixado para estabilidade contra impactos, musculatura anterior hipertrofiada.
- **Escala vs Jogador (1.80m):** 0.94x a altura de um guerreiro padrão humano.
- **Relação com a Fauna:** Predador de topo em seu nicho de combate, superando as criaturas comuns da região em massa e alcance.

---

## 07 — PALETA DE CORES HEX

| Aplicação Anatômica | Código HEX | Nome Descritivo do Pigmento |
|---|---|---|
| **Cor Primária (Couraça / Pele)** | `#2A1854` | Carvão Vulcânico Profundo |
| **Cor Secundária (Musculatura / Ventre)** | `#8C25CC` | Vermelho Magma Escuro |
| **Cor das Sombras (Fissuras Oclusas)** | `#120B08` | Cinza Basáltico Sombrio |
| **Cor dos Detalhes (Chifres / Garras)** | `#D95A1E` | Laranja Brasa Ardente |
| **Cor dos Olhos (Globos Oculares)** | `#FFAA00` | Âmbar Incandescente |
| **Cor Sobrenatural (Chamas / Miasma)** | `#FF3300` | Fogo Demoníaco de Veyrath |
| **Emissão Luminosa (Cores de Pulsação)** | `#FF5500` | Emissão Magmática Brilhante |

---

## 08 — MATERIAIS E TEXTURAS

- **Pele / Couraça:** Textura áspera e porosa com micro-rugosidades semelhantes a rocha calcinada e couro espesso de rinoceronte.
- **Musculatura Exposta:** Fibras estriadas úmidas com sulcos profundos e reflexo specular anisotrópico.
- **Chifres e Espigões:** Material ósseo hipercalcificado com anéis de crescimento e ranhuras de fricção mineral.
- **Garras e Dentes:** Obsidiana densa e quitina endurecida com pontas polidas e brilho vítreo cortante.
- **Parâmetros PBR:**
  - `BaseColor`: Textura difusa 2048x2048 com mapas de curvatura embutidos.
  - `Roughness`: 0.78 nas placas ósseas, 0.42 na pele úmida entre as dobras.
  - `Metallic`: 0.15 (partículas metálicas de escória incorporadas à queratina).
  - `Normal Map Depth`: 1.45 (relevo agressivo com sulcos de até 3 cm de profundidade visual).
  - `Emission Strength`: 2.8 cd/m² com curva senoidal de pulsação de 1.2 Hz.
- **Shaders Especiais:** Shader de dissipação abissal (`dissolve_abyssal.tres`) ativado durante a animação de morte, e shader de borda com brilho de fresnel avermelhado.

---

## 09 — MODELO 3D E ACESSÓRIOS

- **Silhueta Geral:** Silhueta assimétrica e agressiva de leitura instantânea mesmo em condições de nevoeiro ou tempestade de cinzas.
- **Orçamento Poligonal:**
  - `LOD0 (Gameplay Próximo):` 18.500 triângulos (alta fidelidade em garras, dentes e espinhos).
  - `LOD1 (Distância Média - 15m a 40m):` 9.200 triângulos (simplificação de dentes menores e dobras musculares).
  - `LOD2 (Distância Longa - > 40m):` 3.400 triângulos (silhueta fechada sem dedos independentes).
- **Partes Modulares:** Chifre esquerdo, couraça do ombro direito e ponta da cauda modelados como sub-malhas destacáveis.
- **Elementos Quebráveis em Combate:** O chifre frontal pode ser fraturado após acúmulo de dano de concussão pesada, reduzindo o dano de investida em 25%.
- **Acessórios e Armaduras:** Correntes rituais fundidas à carne e restos de placas de ferro abissal cravadas no dorso.
- **Iluminação Local:** Uma luz pontual (`OmniLight3D`) atrelada ao tórax, com cor `#FF5500` e raio de 2.2 m com atenuação quadrática.

---

## 10 — ANIMAÇÕES E RIG

- **Nome do Esqueleto:** `rig_demon_stalker_agile_v2`
- **Estrutura Óssea:** 48 ossos deformadores principais + 12 nós auxiliares para controles IK e cinemática inversa.
- **Cadeias Secundárias de Física:** Deformação por jiggle elástico na papada e ventre; cadeia oscilatória na cauda e espigões com amortecimento dinâmico.
- **Tabela de Clipes de Animação (30 FPS):**
  1. `idle`: idle_predator_stalk (45 frames @ 30fps) - postura agachada inquieta com cabeça oscilando lateralmente
  2. `walk`: walk_silent_prowl (35 frames @ 30fps) - deslocamento rasteiro e furtivo mantendo centro de gravidade baixo
  3. `run`: run_lunge_sprint (25 frames @ 30fps) - corrida quadrupedal em zig-zag veloz rente ao chão
  4. `attack_basic`: attack_twin_claw_slash (30 frames @ 30fps) - golpe cruzado veloz com as duas garras em foice
  5. `attack_special`: attack_pounce_latch (50 frames @ 30fps) - salto acrobático sobre o alvo tentando derrubá-lo ao solo
  6. `block_or_flinch`: hurt_sidestep_flinch (15 frames @ 30fps) - recuo rápido com meia esquiva lateral ágil
  7. `stunned`: stunned_dazed (40 frames @ 30fps) - tronco cambaleante com cabeça inclinada e passos curtos para trás
  8. `taunt_roar`: roar_intimidation (50 frames @ 30fps) - erguer do tórax com estufamento e abertura total das mandíbulas
  9. `turn_180`: turn_quick_spin (20 frames @ 30fps) - rotação sobre o pé de pivô com rabo chicoteando para equilíbrio
  10. `death`: death_spasm_sprawl (45 frames @ 30fps) - salto espasmódico no ar seguido de colapso estendido e inerte

---

## 11 — IA E COMPORTAMENTO

- **Estado de Repouso:** Patrulha territorial circular em raio de 14 metros ao redor de seu ninho de escória, farejando o solo a cada 12 segundos.
- **Percepção Sensorial:**
  - Visão: Cone de 120° com alcance diurno de 18 metros e noturno de 12 metros.
  - Audição: Detecção de passos pesados de jogadores com armadura a até 22 metros.
  - Sentido Abissal: Percepção imediata de jogadores que estejam usando habilidades com pactos demoníacos a até 30 metros.
- **Raios de Combate:**
  - Raio de Percepção: 14 m
  - Raio de Aggro: 9 m
  - Raio de Desengajamento (Leash): 26 m
- **Táticas de Combate:** Flanqueamento furtivo contornando tanques para alcançar curandeiros e conjuradores, atacando pelas costas em saltos súbitos.
- **Reação a Grupos:** Se confrontado por mais de 2 jogadores, prioriza alternar ataques entre alvos para interromper conjurações e dispersar o grupo.
- **Condições de Fúria (Enrage):** Ao atingir 25% de vida máxima, seus olhos brilham com intensidade dobrada, sua velocidade de movimento aumenta em 20% e o intervalo de recarga de ataques cai em 30%.
- **Desengajamento e Retorno:** Ao ultrapassar o raio de leash, entra em estado inalcançável (`invulnerable_return`), correndo de volta ao covil a 4.5 m/s e recuperando vida a 10% por segundo.

---

## 12 — HABILIDADES E ATAQUES

### Ataque Básico: Golpe Físico Primário
- **Nome:** Pata Cortante / Esmagamento Frontal
- **Tipo de Dano:** Físico Contundente / Perfurante
- **Dano Base:** 13.0 pontos de dano
- **Alcance / AoE:** 2.0 metros | Arco frontal de 90°
- **Tempo de Recarga:** 1.6 segundos
- **Telegrafia:** Braço recua por 0.4s com emissão de poeira e grunhido grave antes do impacto no solo.
- **Efeito Visual (VFX):** Linhas de corte cinzentas no ar e impacto de cascalho no piso.
- **Efeito Sonoro (SFX):** Choque seco de pedra com ressonância grave de 120 Hz.

### Habilidade Especial Canônica: `ABIL-DEM-STALKER`
- **Nome:** Assalto da Fenda Vulcânica
- **Descrição Visual:** A criatura canaliza energia abissal pelo solo, projetando um pico de rocha incandescentes sob o alvo.
- **Tipo de Dano:** 60% Físico + 40% Dano Abissal / Ígneo
- **Dano Numérico:** 24.1 pontos de dano
- **Alcance e Área:** Alcance de 12 metros | Círculo de 3.5 metros de raio
- **Tempo de Recarga:** 8.0 segundos | Tempo de Conjuração: 0.85 segundos
- **Telegrafia:** Círculo rúnico avermelhado surge sob os pés do jogador 0.8s antes do estalo.
- **VFX:** Erupção de espinhos rochosos pontiagudos com labaredas de miasma `#FF5500`.
- **SFX:** Estrondo de trovão subterrâneo com estilhaçamento de pedra.

---

## 13 — RESISTÊNCIAS E FRAQUEZAS

| Tipo de Dano | Multiplicador | Classificação | Efeito no Combate |
|---|---:|---|---|
| **Dano Físico** | `0.9x` | Resistente | Couraça mineral amortece cortes superficiais. |
| **Dano Abissal** | `1.0x` | Neutro | Afinidade natural com o miasma das fendas. |
| **Dano de Fogo** | `1.0x` | Neutro | Carapaça adaptada ao calor vulcânico regional. |
| **Dano de Gelo / Glacial** | `1.35x` | Vulnerável | Choque térmico provoca rachaduras e fragilidade na couraça. |
| **Dano Sagrado / Radiante** | `1.50x` | Fraqueza Crítica | Dissipa o núcleo de corrupção abissal, infligindo dano direto à carne. |

- **Suscetibilidade a Controle de Grupo (CC):**
  - Atordoamento (Stun): Suscetível por até 2.0s.
  - Lentidão (Slow): Eficácia normal de 100%.
  - Silêncio: Não interrompe ataques físicos; desativa habilidades mágicas por 4s.
  - Queimadura (Burn): Imune a dano ao longo do tempo por fogo vulgar.
- **Limiar de Desequilíbrio (Stagger):** Requer 350 pontos de impacto pesado contínuo em janela de 4 segundos para entrar em estado de atordoamento postural.

---

## 14 — DROPS E MATERIAIS

| Categoria | Nome do Item Dropado | Chance (%) | Quantidade | Utilidade / Destino |
|---|---|---:|---|---|
| **Comum** | Couro de Demônio de Veyrath | 85% | 1–3 un | Alfaiataria e curtimento de armaduras intermediárias. |
| **Comum** | Cinzas Condensadas de Fenda | 70% | 2–5 un | Ingrediente de alquimia para óleos bélicos. |
| **Incomum** | Garra de Basalto Retorcido | 40% | 1–2 un | Reforço de pontas de flecha e lâminas de corte. |
| **Raro** | Cristal de Núcleo Demoníaco (stalker) | 15% | 1 un | Encantamento de anéis e catalisadores arcanos. |
| **Hell Forge** | Fragmento de Ferro Abissal Impuro | 8% | 1 un | Forja de armas demoníacas e aprimoramento de pactos. |

- **Recompensa de Experiência:** `20 XP`
- **Recompensa Financeira:** `12 Moedas de Ouro`

---

## 15 — VARIANTES E RARIDADE

- **Raridade Canônica:** `common`
- **Variante Alfa / Predador Veterano:**
  - Frequência: 1 em cada 15 spawns na região.
  - Modificações Visuais: Escala 1.25x maior, espinhos dorsais dourados e emissão avermelhada mais saturada.
  - Modificações Numéricas: +40% de vida máxima, +25% de dano e imunidade a lentidão.
- **Variante Climática (Cinza Sólida / Fenda Ativa):**
  - Espécimes encontrados no fundo das gargantas apresentam textura carbonizada escura com fumaça subindo passivamente do dorso.
- **Condições Especiais de Aparição:**
  - Durante o ciclo ativo da **Invasão de Azaroth**, surgem variantes marcadas com a insígnia rúnica de Azaroth na testa, concedendo aura de agressividade compartilhada com demônios adjacentes.
