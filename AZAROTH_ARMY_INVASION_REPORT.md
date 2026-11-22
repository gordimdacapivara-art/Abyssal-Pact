# RELATÓRIO DO SISTEMA DE INVASÃO DO EXÉRCITO DE AZAROTH — PROMPT 04

## 1. Visão Geral
Em conformidade estrita com as diretrizes do **PROMPT 04 — INVASÃO DO EXÉRCITO DE AZAROTH**, foi desenvolvido e integrado o sistema dinâmico de invasão demoníaca que transforma a região selecionada de um dos três continentes (Veyrath, Sylvaran ou Khar-Duum) em um território ativamente corrompido e hostil.

O sistema opera sob autoridade do servidor privado/host, coordenando a transformação ambiental, a abertura de fendas no solo, a emergência física de criaturas sem teletransporte artificial, e a mobilização tática das forças militares de Azaroth divididas em sua hierarquia canônica.

---

## 2. Estrutura e Hierarquia Militar

Todas as tropas geradas durante o evento pertencem estritamente à facção canônica `Invariants.AZAROTH_ARMY_FACTION` (`ARMY_AZAROTH`).

| Patente Militar | Classificação e Papel Tático | Multiplicadores de Atributos | Habilidades e Recursos Especiais |
| :--- | :--- | :--- | :--- |
| **Demônios Inferiores** (`INFERIOR` / Rank 0) | Unidades comuns de linha de frente, infantaria de choque e escaramuçadores. | Base: $1.0\times$ HP ($120$), $1.0\times$ Dano ($18$), $1.0\times$ Def ($8$), Escala $1.0\times$. | `golpe_abissal`, formação de vanguarda. |
| **Demônios Superiores** (`SUPERIOR` / Rank 1) | Tropas de elite e comandantes de esquadrão tático com alta resistência. **NÃO são chefes individuais** do catálogo `BOSS-XXX`. | $1.75\times$ HP ($210$), $1.5\times$ Dano ($27$), $1.3\times$ Def, Escala $1.25\times$. | `grito_de_guerra`, `rajada_carmesim`, `esmagar_abissal`, Aura de Comando de esquadrão ($15.0$m, $+20\%$ dano). |
| **Primordiais** (`PRIMORDIAL` / Rank 2) | Criaturas gigantescas fortalecidas pela fenda abissal, funcionando como colossos de ruptura. | $3.0\times$ HP ($360$), $2.0\times$ Dano ($36$), $1.5\times$ Def ($12$), Escala Colossal $1.6\times$. | `furia_primordial`, `onda_magmatica`, `abismo_devorador`, `pele_de_rocha`, Aura Corrosiva ($10.0$m, $8.0$ DPS contínuo). |

---

## 3. Fases da Invasão

### Primeira Fase — A Corrupção
- **Gatilho:** Início do estado de alerta (`State.WARNING` aos 15 minutos restantes para Azaroth).
- **Atmosfera:**
  - Nível de corrupção do território elevado para $0.30$ ($30\%$).
  - Densidade volumétrica de neblina aumentada de $0.008$ para $0.022$ (`CORRUPTION_FOG_DENSITY`).
  - Tonalidade da névoa alterada para carmesim sombrio `#381619` (`Color(0.38, 0.14, 0.16)`).
  - Céu procedural com proporção de corrupção de $40\%$.
- **Fendas Demoníacas:**
  - Pelo menos 3 fendas ativas são geradas no relevo da região (`ThreatLevel.MINOR`).
  - Emergência física: criaturas sobem de $-8.0$m sob o solo até a superfície ($0.0$m) em curva senoidal suave ($2.0$s), sem qualquer teletransporte visível.
- **Táticas:**
  - Patrulhas de infantaria inferior e comandantes superiores.
  - **Emboscadas táticas (`trigger_ambush`):** esquadrões de 4 tropas surgem no arco de flanco/ponto cego ao redor da posição dos jogadores.

### Segunda Fase — Expansão da Invasão
- **Gatilho:** Contagem regressiva final de 5 minutos antes do despertar de Azaroth ($\le 300$s em `State.WARNING`).
- **Atmosfera:**
  - Nível de corrupção do território salta para $0.75$ ($75\%$).
  - Neblina carmesim profunda e espessa de densidade $0.045$ (`EXPANSION_FOG_DENSITY`).
  - Céu procedural saturado em $85\%$ de corrupção demoníaca.
- **Fendas Demoníacas de Grande Ameaça:**
  - Fendas expandem-se para `ThreatLevel.GREATER` (escala $1.6\times$, raio de perigo $12.0$m).
  - **Campo de Dano Ativo (Hazard Field):** inflige dano de área contínuo de $16.0$ DPS a todos os jogadores dentro do raio de $12.0$m.
  - Contagem mínima de fendas elevada para 6.
- **Reforços Contínuos & Primordiais:**
  - Ondas periódicas de reforço a cada 12 segundos despachadas através das fendas ativas.
  - Emergência de Criaturas Primordiais colossais com auras de dano corrosivo.
- **Táticas Avançadas:**
  - **Investida em Pinça Multidirecional (`trigger_pincer_assault`):** ataque simultâneo de tropas cercando os jogadores a partir de 3 ou mais eixos cardinais coordenados ($2\pi / 3$), combinando Primordiais na ponta de lança e Superiores/Inferiores nas alas de corte.

### Culminação e Expurgamento
- **Culminação:** Quando Azaroth desperta no campo (`State.ACTIVE`), a corrupção atinge $1.0$ ($100\%$) e o exército atua em suporte direto ao World Boss.
- **Expurgamento:** Na derrota de Azaroth (`State.DEFEATED`) ou recuo ao abismo (`State.RETREATED`), a invasão é expurgada: todas as fendas são seladas, tropas do exército são dissolvidas, nível de corrupção zera ($0.0$) e a atmosfera da região retorna à calmaria natural.

---

## 4. Integração Cartográfica e Visualização 2D/3D

1. **Mapa-Múndi (`world_map_screen.gd`):**
   - Ao selecionar a região ameaçada, o painel lateral detalha dinamicamente: fase da invasão, porcentagem de corrupção do território, contagem de fendas ativas e tropas em combate.
2. **Mapa Regional (`regional_map_screen.gd`):**
   - Todas as fendas ativas são mapeadas como pontos de interesse (`type: "demonic_fissure"`, ícone 🌋).
   - O canvas do mapa renderiza o epicentro da invasão com anéis pulsantes e as fendas demoníacas com perímetros visuais de perigo em tempo real.
3. **Ambiente 3D:**
   - O script `demonic_invasion_system.gd` aplica modificações diretas ao nó `WorldEnvironment` da cena carregada através de `apply_atmosphere_corruption()`.

---

## 5. Rede Multiplayer e Persistência

- **Autoridade do Servidor:** O host determina as fases e emite RPCs confiáveis para todos os clientes:
  - `rpc_sync_demonic_invasion_phase(phase, corruption, region_id)`
  - `rpc_trigger_invasion_ambush(target_pos, squad_size)`
  - `rpc_trigger_invasion_pincer(target_pos, directions_count, units_per_dir)`
- **Persistência Total:**
  - `collect_save_data()` e `apply_save_data()` no `WorldBossSystem` e `DemonicInvasionSystem` preservam estado de fase, corrupção, fendas ativas (com coordenadas 3D e nível de perigo) e tropas presentes.

---

## 6. Cobertura de Testes Automatizados

A nova suíte `res://tests/suites/suite_demonic_invasion.gd` foi integrada e executada através do `TestHost` em modo headless da Godot Engine 4.7.2:

- **10 Seções de Validação:**
  1. Ativação da Fase 1 (A Corrupção) e parâmetros atmosféricos.
  2. Abertura de fendas e subida física do solo ($-8$m a $0$m em curva senoidal sem teleporte).
  3. Hierarquia militar de Inferiores e Superiores (elites, não chefes individuais).
  4. Emboscadas coordenadas em pontos cegos dos combatentes.
  5. Ativação da Fase 2 (Expansão), expansão das fendas e dano em área ($16$ DPS).
  6. Atributos maciços e auras das Criaturas Primordiais.
  7. Cerco multidirecional com investidas em pinça em 3 eixos cardinais.
  8. Verificação de facção inviolável (`100%` das tropas em `ARMY_AZAROTH`).
  9. Integração completa do ciclo de vida com o `WorldBossSystem`.
  10. Persistência de save/load e chamadas RPC do `MultiplayerManager`.

**Resultado Geral dos Testes:**
- Total de suítes executadas: **26 suítes**
- Total de asserções executadas: **4.532 checks**
- Falhas: **0 falhas (100% de aprovação)**
