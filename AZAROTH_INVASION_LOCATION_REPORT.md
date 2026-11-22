# RELATÓRIO OFICIAL: LOCALIZAÇÃO DINÂMICA DA INVASÃO DE AZAROTH (PROMPT 03)
**Projeto:** Abyssal Pact  
**Data:** 21 de Novembro de 2026  
**Status:** Concluído com 100% de Aprovação (4.414/4.414 checks validados)  

---

## 1. Visão Geral da Implementação

O **Sistema de Localização Dinâmica da Invasão de Azaroth** estabelece a infraestrutura geográfica, procedural e autoritativa do World Boss único de *Abyssal Pact*. Este módulo seleciona aleatoriamente e de forma autoritativa o epicentro da invasão demoníaca a cada ciclo de 5 horas, garantindo compatibilidade com o relevo natural, distância de aproximação tática de ~1 km dos jogadores e uma sequência de chegada apocalíptica contínua e física, sem qualquer teletransporte visível ou surgimento artificial.

---

## 2. Restrições Geográficas e Escopo Continental

### 2.1 Os Três Continentes Permitidos (30 Regiões Válidas)
A invasão de Azaroth é restrita exclusivamente aos três continentes habitados do mundo de *Abyssal Pact*:
1. **Veyrath (`CONT-01`)**: Regiões `REG-001` a `REG-010` (Campos de Cinza, Basalto e Magma).
2. **Sylvaran (`CONT-02`)**: Regiões `REG-011` a `REG-020` (Florestas Ancestrais, Pântanos e Raízes Colossais).
3. **Khar-Duum (`CONT-03`)**: Regiões `REG-021` a `REG-030` (Cânions Negros, Dunas Vitrificadas e Forjas).

### 2.2 Exclusão Inviolável do Verdadeiro Inferno
- O **Verdadeiro Inferno** (`Invariants.HUB_REGION_ID = &"hell_forge"` e `&"DIM-HELL-FORGE"`) constitui o Nexus Dimensional e santuário primordial de ressurgimento, sendo **estritamente proibido** e impossibilitado de ser selecionado.
- Continentes externos como Nhal'Kora (`CONT-04`) não fazem parte do pool de três continentes da invasão.
- A exclusão foi validada com 100 sorteios sucessivos em testes automatizados, obtendo 0% de ocorrência de regiões proibidas.

---

## 3. Autoridade do Servidor e Sincronização Multiplayer

- **Autoridade do Anfitrião:** Em qualquer sessão privada (até 8 participantes), o host privado (`HOST_PEER_ID = 1`) é o único responsável por invocar `select_random_invasion_location()`.
- **RPC `rpc_sync_world_boss_invasion_target`:** O servidor transmite a região selecionada, as coordenadas `Vector3(X, Y, Z)` e o estágio da sequência de chegada para todos os clientes conectados.
- **Transmissão Periódica:** O heartbeat a cada 3.0 segundos via `rpc_sync_world_boss_cycle` mantém o temporizador, vida, fase de combate e coordenadas absolutamente sincronizadas, garantindo que todos os jogadores visualizem o mesmo ponto exato do mapa.

---

## 4. Compatibilidade com Terreno e Topografia Natural

- **Amostragem de Elevação (`_sample_ground_height`):**
  - As coordenadas 3D respeitam o perfil topográfico de cada bioma ($Y \ge 0.0$m), evitando que Azaroth apareça flutuando no ar ou soterrado na geometria sólida.
- **Afastamento de Safe Zones:**
  - O epicentro da invasão é gerado a uma distância segura ($\ge 50$m) dos centros pacíficos de vilarejos e santuários, situando-se em terras abertas da região.
- **Confinamento Territorial:**
  - As coordenadas são calculadas dentro do raio territorial estipulado em `RegionData.boundaries` ($\le 150$m em coordenadas locais da região).

---

## 5. Spawn de Azaroth a ~1 km dos Jogadores

- **Cálculo Centróide de Esquadrão:**
  - O método `compute_spawn_position_for_players(player_positions)` calcula o ponto médio ponderado dos aventureiros presentes.
- **Vetor Tático de 1.000 Metros:**
  - O epicentro é projetado a uma distância de aproximadamente $1.000$ metros (`Invariants.WORLD_BOSS_SPAWN_DISTANCE = 1000.0m`, tolerância de $\pm 150$m, intervalo $[850, 1150]$m).
  - Garante aos aventureiros tempo hábil de visualização no horizonte e preparação tática antes do engajamento.

---

## 6. Sequência Demoníaca de Chegada (Sem Teletransporte)

A classe `AzarothSpawnSequence` implementa a chegada do Titã em quatro estágios físicos e contínuos:
1. **Fase 1: Tectonic Tremor (4.0s)**
   - O solo treme em ondas expansivas (`_ground_vibration_intensity` de 0.2 a 1.0).
   - Uma fissura magmática se abre no chão expelindo fumaça vulcânica e enxofre.
   - O modelo 3D de Azaroth é instanciado oculto a $-35$m de profundidade subterrânea.
2. **Fase 2: Emergence (6.0s)**
   - Azaroth ascende fisicamente do magma, elevando-se de $-35$m até o nível da superfície ($0.0$m) através de interpolação senoidal suave.
   - Jogadores visualizam a subida do titã colossal em tempo real no horizonte.
3. **Fase 3: Shockwave Roar (3.0s)**
   - Ao pisar na terra, Azaroth ruge em fúria titânica.
   - Uma onda de choque de cinzas e fogo abissal se expande radialmente em 360° até $200$m de raio.
   - O céu adquire a tonalidade rubra de corrupção demoníaca.
4. **Fase 4: Completed**
   - Transição oficial para o estado de combate ativo (`State.ACTIVE`).

---

## 7. Integração Cartográfica (Mapa-Múndi e Regional)

### 7.1 Mapa-Múndi (`WorldMapScreen`)
- **Destaque Poligonal da Região:** Borda da região ameaçada pulsa em vermelho escarlate demoníaco.
- **Painel Lateral de Detalhes:** Exibe bloco informativo dedicado com Continente, Região, Coordenadas `(X, Y, Z)`, Estado da Invasão e Distância estimada (~1.0 km).
- **Indicadores Progressivos de Evento:**
  - *Dormant (Alerta 1h):* `⚠️ ALERTA 1H: FENDA ABISSAL` (anel âmbar pulsante).
  - *Warning (15m):* `🔥 RUPTURA IMINENTE (15M)` (halo ígneo em rápida pulsação).
  - *Active:* `💀 AZAROTH DESPERTO (XX%)` (caveira demoníaca, anel de arena de 75m e barra de vida proporcional).
  - *Defeated:* `✨ SELO RESTAURADO` (anel esmeralda sereno).
  - *Retreated:* `🌑 FENDA COLAPSADA` (resquício espectral violeta).

### 7.2 Mapa Regional (`RegionalMapScreen`)
- **Marcador Oficial de World Boss:** Exibição prioritária de `INVASÃO DE AZAROTH` (`type: "world_boss"`).
- **Representação Visual:** Ícone de fogo/caveira circundado por anel de risco de 22px animado.
- **Metadados Completos:** Exibe coordenadas 3D, descrição do abalo sísmico e distância do avanço.

---

## 8. Resultados da Suíte de Testes Automatizados

A nova suíte `SuiteWorldBossLocation` foi executada em modo headless no motor Godot Engine v4.7.2:

```
=== ABYSSAL PACT — SUÍTE DE TESTES DE ARQUITETURA ===
...
--- TestCase: 472 checks, 0 falhas ---
=== RESUMO: 4381 checks, 0 falhas ===
RESULTADO: TODOS OS TESTES PASSARAM
```

- **Checks da Suíte de Localização:** 505 checks sem falhas.
- **Checks Totais do Projeto:** 4.414 checks em 25 suítes sem nenhuma falha (100% pass rate).
- **Tempo de Execução Total:** ~25 segundos.
