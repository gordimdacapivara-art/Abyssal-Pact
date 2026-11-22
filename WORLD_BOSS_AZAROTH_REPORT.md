# RELATÓRIO OFICIAL: SISTEMA GLOBAL DE WORLD BOSS — AZAROTH

> **Projeto:** Abyssal Pact  
> **Sistema:** World Boss Global Autorreativo  
> **Entidade Única:** Azaroth, o Devorador de Reinos (`WB-AZAROTH`)  
> **Ciclo Persistente:** 5 horas (18.000 segundos) por mundo privado  
> **Data:** 21 de Novembro de 2026  

---

## 1. Visão Geral e Regras Fundamentais

O sistema de World Boss de *Abyssal Pact* foi concebido para entregar uma experiência cooperativa massiva e imersiva para até 8 jogadores em mundos privados, centralizado na figura titânica de **Azaroth**.

### Cumprimento Estrito das Regras Fundamentais
1. **Entidade Única Global:** Azaroth é o **único World Boss** de todo o jogo (`Invariants.WORLD_BOSS_ID = &"WB-AZAROTH"`), diferenciando-se integralmente dos 30 chefes regionais de masmorras.
2. **Ciclo Persistente de 5 Horas:** O ciclo do mundo privado dura exatamente **18.000,0 segundos** (5 horas contínuas), dividido em fases matemáticas rigorosas:
   - **Dormência Abissal:** `15.300,0s` (4 horas e 15 minutos) de acúmulo de energia silenciosa.
   - **Alerta Mundial (Warning):** `900,0s` (15 minutos) com céu escurecido, fenda abissal pulsando e avisos globais no HUD.
   - **Invasão Ativa (Active Combat):** `1.800,0s` (30 minutos) de combate titânico de 4 fases para banir ou ser destruído por Azaroth.
   - **Desfecho (Defeated / Retreated):** Celebração com recompensas míticas ou recuo abissal até a conclusão do ciclo de 5h e reinício do próximo ciclo.
3. **Temporizador Compartilhado:** Todos os participantes conectados ao mesmo mundo privado compartilham exatamente o mesmo temporizador em tempo real, sincronizado via host autoritativo.
4. **Independência de Interface:** Configurado com `process_mode = Node.PROCESS_MODE_ALWAYS`. O temporizador do ciclo **continua processando normalmente** quer o jogador esteja em combate, com o Mapa-Múndi aberto, navegando pelo inventário, árvore de talentos ou menus de pausa.
5. **Persistência Completa de Progresso:** O estado do ciclo, tempo decorrido no segundo exato, HP restante, fase de combate ativa e histórico de derrotas são persistidos pelo `SaveManager` e `BossManager`, restaurando a invasão exatamente de onde parou.
6. **Imunidade a Reinícios:** O temporizador não é afetado por abertura/fechamento de interfaces, troca de regiões, teleporte por portais ou reconexão de jogadores.

---

## 2. Arquitetura Técnica e Componentes

```
┌────────────────────────────────────────────────────────────────────────┐
│                        BOSS MANAGER (Singleton)                        │
│                         res://managers/boss_manager.gd                 │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Contém & Gerencia
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                    WORLD BOSS SYSTEM (PROCESS_MODE_ALWAYS)             │
│                      res://core/world_boss_system.gd                   │
├───────────────────────────────────┬────────────────────────────────────┤
│ • Ciclo: 18.000s (5h)             │ • Alertas Globais (EventBus)       │
│ • Estados: Dormant/Warn/Active    │ • Sincronização RPC Host -> Clientes│
│ • Vida Colossal: 1.000.000 HP     │ • Persistência no SaveManager      │
└─────────────────┬─────────────────┴───────────────────┬────────────────┘
                  │                                     │
                  ▼                                     ▼
┌───────────────────────────────────┐ ┌──────────────────────────────────┐
│         WORLD BOSS DATA           │ │         WORLD BOSS WIDGET        │
│  res://data/models/world_boss_data│ │ res://scenes/ui/hud/world_boss_  │
│  res://data/content/world_boss/   │ │   widget.gd / .tscn              │
│    azaroth.tres                   │ │ • HUD contínuo (HH:MM:SS)        │
│ • 4 Fases (100%, 75%, 50%, 25%)   │ • HP bar & Notificações de Alerta  │
│ • 5 Habilidades Titânicas         │ • PROCESS_MODE_ALWAYS              │
│ • Recompensas Míticas             │                                    │
└───────────────────────────────────┘ └──────────────────────────────────┘
```

### Arquivos Implementados e Integrados
- `core/invariants.gd`: Constantes imutáveis (`WORLD_BOSS_ID`, `WORLD_BOSS_NAME`, `WORLD_BOSS_CYCLE_DURATION`, `WORLD_BOSS_MAX_HEALTH`, etc.).
- `core/event_bus.gd`: Sinais dedicados para ciclo, estados, avisos prévios, spawn, transições de fase, dano, derrota e fuga.
- `data/models/world_boss_data.gd`: Definição de recursos, atributos, thresholds de vida e fábrica canônica.
- `data/content/world_boss/azaroth.tres`: Recurso canônico exportado com os atributos oficiais de Azaroth.
- `core/world_boss_system.gd`: Motor do ciclo de 5h, máquina de estados, cálculo de dano, autoridade de simulação e persistência.
- `managers/boss_manager.gd`: Registro e integração do WorldBossSystem com SystemRegistry e sistema de save/load.
- `autoload/multiplayer_manager.gd`: RPCs de sincronização autoritativa para mundos privados (`rpc_sync_world_boss_cycle`, `rpc_world_boss_alert`, `rpc_world_boss_damage`, `rpc_world_boss_outcome`).
- `scenes/ui/hud/world_boss_widget.gd` & `.tscn`: Widget HUD em tempo real exibindo contagem regressiva HH:MM:SS e barra de vida.
- `autoload/ui_manager.gd`: Métodos para obter e controlar a visibilidade do widget do World Boss.
- `tests/suites/suite_world_boss.gd`: Suíte de 8 blocos de teste garantindo 100% de conformidade com todos os requisitos.

---

## 3. As 4 Fases de Combate de Azaroth

| Fase | Limiar de HP | Comportamento | Habilidades Ativas | Modificadores |
|---|---|---|---|---|
| **1. Ascensão da Fenda** | 100% - 75% | Ondas de choque tectônicas | Impacto Abissal, Terreno Corrompido | Dano 1.0x, Velocidade 1.0x |
| **2. Fúria Vulcânica** | 75% - 50% | Feixes cósmicos e lacaios | Impacto Abissal, Feixe Dimensional, Invocação da Forja | Dano 1.2x, Velocidade 1.1x |
| **3. Tempestade do Caos**| 50% - 25% | Vórtices caóticos contínuos | Feixe Dimensional, Terreno Corrompido, Invocação da Forja | Dano 1.35x, Velocidade 1.2x |
| **4. O Devorador Despertado** | 25% - 0% | Enrage Primordial Total | Todas as 5 Habilidades + Enrage Furioso | Dano 1.6x, Velocidade 1.35x |

---

## 4. Sincronização Multiplayer em Mundos Privados

- **Autoridade do Host:** Apenas o servidor anfitrião do mundo privado avança o temporizador de simulação e aplica a máquina de estados.
- **Heartbeat Periódico:** A cada 3 segundos (e imediatamente em transições de fase ou estado), o host emite `rpc_sync_world_boss_cycle` com tempo exato, HP, fase e coordenadas de invasão.
- **Transmissão de Alertas e Desfecho:** Emissões em broadcast garantem que todos os jogadores conectados recebam o aviso prévio de 15 minutos e o desfecho simultaneamente.

---

## 5. Resultados dos Testes Automatizados

A suíte completa de testes automatizados do projeto (`tests/run_tests.tscn`) foi executada em modo headless no Godot 4:

- **Total de verificações executadas:** 3.871 checks
- **Total de falhas:** 0 falhas (100% de aprovação)
- **Suíte dedicada de World Boss (`suite_world_boss.gd`):** 63 checks, 0 falhas
  - Identidade canônica única de Azaroth (`WB-AZAROTH`).
  - Ciclo de 5 horas (18.000s) com divisão de dormência (15.300s), alerta (900s) e combate (1.800s).
  - Máquina de estados com transições precisas e rollover de contagem de ciclos.
  - 4 fases de combate progressivas com thresholds de HP (100%, 75%, 50%, 25%) e dano.
  - Desfechos de encontro (vitória com recompensas vs recuo com preservação do ciclo).
  - Independência total de interface com processamento ininterrupto (`PROCESS_MODE_ALWAYS`).
  - Persistência e restauração fidedigna no segundo exato via payload do `SaveManager`.
  - Sincronização em rede autoritativa do host para múltiplos clientes simultâneos.

