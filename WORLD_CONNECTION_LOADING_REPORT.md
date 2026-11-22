# ABYSSAL PACT — SISTEMA DE CONEXÃO E CARREGAMENTO DO MUNDO
**Relatório Técnico de Arquitetura, Integração Geográfica e Carregamento de Cenas 3D**  
*Versão:* 1.0.0 — Godot 4.7.2 Engine  
*Data:* 21 de Novembro de 2026  
*Status:* 100% Implementado e Validado via Suíte Automatizada (3.703 checks / 0 falhas)

---

## 1. Visão Geral e Arquitetura do Sistema

O **Sistema de Conexão e Carregamento do Mundo** integra os quatro continentes (**Veyrath**, **Sylvaran**, **Khar-Duum** e **Nhal'Kora**), as 40 regiões 3D e a dimensão independente **Hell Forge** em uma malha contínua, coesa e navegável, aderindo rigorosamente às diretrizes de arquitetura modular, gestão estrita de memória e autoridade do anfitrião em sessões multiplayer privadas.

```
                              ┌────────────────────────────────────────┐
                              │            WORLD MANAGER               │
                              │    (Fachada de Mundo & Coordenação)     │
                              └──────────────────┬─────────────────────┘
                                                 │
            ┌───────────────────┬────────────────┴───────────────────┬───────────────────┐
            ▼                   ▼                                    ▼                   ▼
 ┌────────────────────┐┌─────────────────┐                 ┌───────────────────┐┌───────────────────┐
 │  ContinentManager  ││  RegionManager  │                 │WorldConnectionGrap││WorldTransitionSys│
 │ (4 Continentes,    ││(40 Regiões + HF,│                 │(Grafo de 41 Nós,  ││(Validação de Rota,│
 │  Capitais & Portos)││ Spawns & POIs)  │                 │ 150 Arestas, BFS) ││ Host Authority)  │
 └────────────────────┘└─────────────────┘                 └───────────────────┘└─────────┬─────────┘
                                                                                          │
                                                                   ┌──────────────────────┴────────┐
                                                                   ▼                               ▼
                                                        ┌─────────────────────┐        ┌───────────────────────┐
                                                        │  WorldSceneLoader   │        │  MultiplayerManager   │
                                                        │(Carga Síncrona/Assín│        │(RPCs de Sincronia de  │
                                                        │ Descarte 3D Prévio) │        │ Transição & Handshake)│
                                                        └─────────────────────┘        └───────────────────────┘
```

---

## 2. Os Doze Pilares Implementados

### 1. Gerenciador de Continentes (`ContinentManager`)
- **Arquivo:** [`managers/continent_manager.gd`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/managers/continent_manager.gd)
- **Funcionalidades:** 
  - Catálogo formal dos 4 continentes (`veyrath`, `sylvaran`, `khar_duum`, `nhal_kora`).
  - Mapeamento estrito de Capitais Imperiais e Terminais Marítimos/Portuários.
  - Cálculo dinâmico do percentual de exploração continental e global.
  - Regras de trânsito intercontinental (restrito a terminais e rotas navais autorizadas).

### 2. Gerenciador de Regiões (`RegionManager`)
- **Arquivo:** [`managers/region_manager.gd`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/managers/region_manager.gd)
- **Funcionalidades:**
  - Registro das 40 regiões + dimensão Hell Forge (`DIM-HELL-FORGE` / `&"hell_forge"`).
  - Consulta de metadados geográficos, biomas, níveis recomendados e limites de fronteira.
  - Controle de pontos de entrada (`spawns`), saídas (`gates`), masmorras e zonas seguras (`SafeZones`).

### 3. Sistema de Conexões (`WorldConnectionGraph`)
- **Arquivo:** [`core/world_connection_graph.gd`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/core/world_connection_graph.gd)
- **Funcionalidades:**
  - Ingestão determinística de `REGION_GRAPH.json` (41 nós e 150 conexões bidirecionais).
  - Algoritmo de busca em largura (**BFS**) para roteamento e validação de caminhos navegáveis.
  - **Validação de Invariante:** zero nós órfãos (todas as regiões possuem grau $\ge 2$).
  - 100% de conectividade (qualquer região alcança todas as demais).
  - Verificação de requisitos de nível e bloqueios por status de portal/missão.

### 4. Sistema de Transições (`WorldTransitionSystem`)
- **Arquivo:** [`core/world_transition_system.gd`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/core/world_transition_system.gd)
- **Funcionalidades:**
  - Ciclo de vida determinístico de transições (`requested` $\rightarrow$ `started` $\rightarrow$ `completed` / `failed`).
  - Validação estrita de viabilidade de trânsito pré-carregamento.
  - Desacoplamento através de eventos globais no [`EventBus`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/core/event_bus.gd).
  - Recuperação graciosa e tratamento de exceções em caso de falhas de carregamento.

### 5. Carregamento de Cenas (`WorldSceneLoader`)
- **Arquivo:** [`core/world_scene_loader.gd`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/core/world_scene_loader.gd)
- **Funcionalidades:**
  - Carregamento síncrono para inicialização imediata e testes determinísticos.
  - Carregamento assíncrono threaded via `ResourceLoader.load_threaded_request` com reporte contínuo de progresso (`region_load_progress`).
  - Suporte a fallback imediato caso a solicitação em segundo plano não esteja disponível.

### 6. Descarregamento Estrito de Regiões (Gestão de Memória)
- **Diretriz de Performance:** Evitar manter múltiplos ambientes 3D carregados simultaneamente.
- **Implementação:** Método `unload_active_region()`.
  - Desassocia o nó 3D da cena anterior da árvore (`remove_child`).
  - Executa descarte determinístico de memória (`queue_free()`).
  - Zera referências ativas e emite `EventBus.region_unloaded(prev_region_id)`.
  - Garante que apenas uma região 3D exista ativa em memória em qualquer instante de jogo.

### 7. Pontos de Entrada (Spawns e Fallbacks)
- **Resolução de Spawns:** Inspeção hierárquica do nó da região (`spawn_point(marker_name)`).
- **Mapeamento:** Portais, gates de fronteira e posições de desembarque naval.
- **Fallback Gracioso:** Se um marcador solicitado for inválido ou inexistente, o sistema recorre automaticamente ao marcador `"default"`, e, na sua ausência, à origem da cena (`Vector3.ZERO`), eliminando qualquer risco de crash.

### 8. Pontos de Saída (Gates e Triggers de Fronteira)
- **Gatilhos de Fronteira:** Triggers de volume associados a cada fronteira regional (`gate_north`, `gate_south`, etc.).
- **Detecção de Passagem:** Transição automática ao colidir com o trigger, validando permissões de nível antes de disparar o carregamento da região conectada.

### 9. Portais e Conduítes Dimensionais (`WorldPortal`)
- **Portais da Hell Forge:** 8 conduítes dimensionais nas 4 Capitais Imperiais e 4 Regiões Terminais.
- **Ativação e Viagem Rápida:** Registro de portais ativados (`activate_portal`, `is_portal_activated`) persistidos no perfil de mundo.

### 10. Salvamento da Última Região e Estado
- **Campos Persistidos:** `region_id` corrente, `last_spawn_marker`, lista de `discovered_regions` e `activated_portals`.
- **Restauração:** O mundo é restaurado no ponto exato em que o jogador estava, respeitando o estado do anfitrião.

### 11. Controle da Região Atual
- **Identificação Centralizada:** `WorldManager.current_region_id()` e `WorldManager.current_region_data()`.
- **Sincronização de Árvore:** Acompanhamento do nó ativo da cena 3D através de `WorldSceneLoader.active_region_node()`.

### 12. Registro de Regiões Descobertas
- **Persistência Dupla:**
  - No estado do mundo (`WorldSessionData.discovered_regions`).
  - Na caderneta de descobertas do personagem ativo (`CharacterData.discoveries.record(&"region", region_id)`).
- **Notificação:** Disparo de notificações e pontuação de experiência na primeira visita.

---

## 3. Preservação Estrita do Jogador durante Transições

Durante o descarregamento da região anterior e carregamento do novo cenário 3D, o jogador mantém:
1. **Identidade e Estado:** O nó do personagem permanece sob custódia do `CharacterManager` e `PlayerController`.
2. **Atributos e Nível:** Vida, mana, stamina e experiência acumulada permanecem inalterados.
3. **Inventário e Equipamentos:** Todos os itens, consumíveis e equipamentos alocados em slots mantêm-se exatamente iguais.
4. **Missões:** O diário de missões ativas e progresso de etapas não sofre reinicialização.
5. **Posicionamento Relativo:** O peão do jogador é reposicionado com precisão na coordenada do ponto de entrada da nova região.

---

## 4. Dimensão Hell Forge e Invariante de Ressurgimento

- **Natureza:** Dimensão independente e atemporal, acessível apenas por conduítes dimensionais. Não é continente físico.
- **Instância Lógica:** Instanciada isoladamente por mundo privado (`res://scenes/world/dimension/hell_forge.tscn`).
- **Santuário e Forja:** Contém a Bigorna Central, forjas infernais e SafeZone protegida.
- **Invariante de Ressurgimento:** 
  $$\text{resolve\_respawn}(p) = \text{Invariants.HUB\_REGION\_ID} \equiv \text{"hell\_forge"}$$
  Qualquer derrota em qualquer região dos 4 continentes conduz o jogador compulsoriamente à Hell Forge, garantindo a identidade mística do jogo.

---

## 5. Arquitetura Multiplayer Privado (Autoridade do Anfitrião)

- **Regra Fundamental:** Sem servidores públicos. O jogo opera exclusivamente através de mundos privados hospedados pelos próprios jogadores via protocolo ENet.
- **Capacidade:** Estritamente limitada a 8 jogadores por sessão (incluindo o anfitrião).
- **Autoridade de Transição:**
  - Quando um **cliente** atravessa um portal ou gate, envia requisição RPC ao host: `rpc_id(1, "rpc_request_region_transition", target_region, target_spawn)`.
  - O **anfitrião** valida a rota no `WorldConnectionGraph`, os níveis e requisitos.
  - Se aprovado, o anfitrião comanda a transição para todos os membros conectados: `rpc_sync_region_transition(target_region, target_spawn)`.
  - A persistência de save do mundo é exclusiva da autoridade do anfitrião (`collect_save_data()` bloqueia clientes não-host).

---

## 6. Resultados da Validação Automatizada

A suíte de testes [`tests/suites/suite_world_connection_loading.gd`](file:///c:/Users/fred_/Downloads/Abyssal%20Pact/tests/suites/suite_world_connection_loading.gd) foi integrada ao runner central (`tests/run_tests.tscn`), executando 12 seções dedicadas:

| Seção de Teste | Validações Realizadas | Resultado |
|---|---|:---:|
| **1. Grafo e Conexões** | Ingestão de 41 nós, 150 arestas, zero nós órfãos | **PASSOU** |
| **2. Rotas Terrestres** | Adjacências diretas, restrições e trânsito contíguo | **PASSOU** |
| **3. Rotas Marítimas** | Conexões navais entre terminais portuários autorizados | **PASSOU** |
| **4. Portais da Hell Forge** | 8 conduítes dimensionais das Capitais e Terminais | **PASSOU** |
| **5. Nível e Requisitos** | Bloqueio de regiões avançadas para personagens de baixo nível | **PASSOU** |
| **6. Algoritmo de Busca** | Algoritmo BFS traçando rotas de menor custo entre continentes | **PASSOU** |
| **7. Carga e Descarte 3D** | Carga síncrona/assíncrona e descarte imediato do 3D anterior | **PASSOU** |
| **8. Entradas e Saídas** | Spawns, gates, fallbacks graciosos e tolerância a marcadores nulos | **PASSOU** |
| **9. Hell Forge & Respawn** | Instanciação 3D da dimensão e resolução obrigatória de ressurgimento | **PASSOU** |
| **10. Persistência do Jogador** | Preservação total de inventário, atributos, itens e XP na transição | **PASSOU** |
| **11. Salvamento de Estado** | Serialização e restauração de `last_visited_region` e descobertas | **PASSOU** |
| **12. Autoridade do Host** | Validação multiplayer, réplica RPC e limite de 8 jogadores | **PASSOU** |

### Resumo Geral da Execução dos Testes:
```
=== RESUMO: 3703 checks, 0 falhas ===
RESULTADO: TODOS OS TESTES PASSARAM
```
- Total de Verificações na Suíte de Conexão: **157 checks** (100% de sucesso).
- Total de Verificações no Projeto Global: **3.703 checks** (100% de sucesso).
