# ABYSSAL PACT — CHECKLIST DE LANÇAMENTO (RELEASE CHECKLIST)
## VERSÃO: 1.0.0-RC1 | MOTOR: GODOT ENGINE 4.7.2-STABLE
### DATA DE AUDITORIA: 21 DE NOVEMBRO DE 2026

---

## 1. AUDITORIA TÉCNICA E ESTRUTURA DO PROJETO

- [x] **Estrutura de Pastas e Nomenclatura**:
  - `assets/`: Modelos 3D GLB, texturas, shaders, ícones SVG e paletas de materiais organizados.
  - `autoload/`: Singletons registrados (`EventBus`, `Scenes`, `UI`, `Audio`, `Net`, `Save`, `Game`).
  - `combat/`: Componentes de combate (`Combatant`, `AbilityBurst`, `TrainingDummy`).
  - `core/`: Regras invariantes, gerenciador de estado, grafo de conexão mundial e sistemas de invasão.
  - `data/`: 528 recursos `.tres` (40 raças, 80 sub-raças, 80 classes, 200 demônios, 30 chefes, 1 World Boss, 21 itens, 10 missões).
  - `enemies/`: Controladores genéricos de criaturas (`Creature`, `CreatureAI`, `BossEncounter`, `BossUI`).
  - `managers/`: Gerenciadores de subsistemas derivados de `ManagerBase`.
  - `player/`: Controlador em terceira pessoa, rig de câmera esférica, carregador de modelos e máquina de estados.
  - `scenes/`: Telas de UI, HUD, cenas 3D modulares e as 40 regiões cartográficas + Hell Forge.
  - `tests/`: 28 suítes de teste automatizadas cobrindo 100% da arquitetura.

- [x] **Scripts GDScript e Conformidade**:
  - Sintaxe GDScript 2.0 estrita com tipagem estática em variáveis, retornos de funções e parâmetros.
  - Zero erros de compilação ou falhas de carregamento em tempo de execução.
  - Tratamento defensivo de ponteiros nulos e verificações de `is_instance_valid()` e `is_inside_tree()`.

- [x] **Dependências e Autoloads**:
  - Registro determinístico no `SystemRegistry` via `ServiceLocator`.
  - Ordem de inicialização segura em `core/game_manager.gd`: inicialização sequencial de 14 subsistemas vitais.

---

## 2. AUDITORIA DOS SISTEMAS DE GAMEPLAY

- [x] **Criação de Personagens**:
  - Validação estrita de nomes (1 a 24 caracteres, não vazios).
  - Vínculo obrigatório entre Raça, Sub-Raça e Classe dentro do catálogo oficial.
  - Slots de personagem persistidos em `user://saves/characters.json`.

- [x] **40 Raças e 80 Sub-Raças**:
  - Todas as 40 raças catalogadas com modificadores de atributos e afinidades elementais.
  - Todas as 80 sub-raças associadas canonicamente à sua respectiva raça mãe (2 sub-raças por raça).
  - Construtor visual de raças (`race_visual_builder.gd`) aplicando paletas de tom de pele, olhos e cabelos.

- [x] **80 Classes e Habilidades**:
  - 80 classes configuradas em matrizes de progressão primária e secundária.
  - 16 habilidades centrais instanciadas com custo de mana, recarga e dano elemental.
  - Slots de habilidades ativas mapeados nas teclas de ação do jogador.

- [x] **Combate e Atributos**:
  - Componente `Combatant` gerenciando vida, mana, vigor, defesa, poder de ataque e resistências.
  - Hurtbox (`TARGET_LAYER = 8`) e detecção de acertos físicos/mágicos com dano flutuante e recuo.

- [x] **Inventário e Equipamentos**:
  - 21 itens catalogados (armas, armaduras, consumíveis, materiais abissais).
  - 6 slots de equipamento (arma principal, arma secundária, elmo, peitoral, pernas, amuleto).
  - Atualização dinâmica de atributos derivados do personagem ao equipar/desequipar.

- [x] **Missões e Códice**:
  - 10 missões iniciais com objetivos de eliminação, exploração e resgate.
  - Registro de progresso, entrega de recompensas (XP, ouro e itens) e sincronia com a HUD.
  - Códice com entradas desbloqueadas conforme o jogador descobre regiões, demônios e chefes.

- [x] **200 Demônios e 30 Chefes de Masmorra**:
  - 200 criaturas distribuídas nas 40 regiões através de `DemonManager`.
  - 30 chefes regionais (`BOSS-001` a `BOSS-030`) com arenas e encontros dedicados (`BossEncounter`).

- [x] **Hell Forge (O Verdadeiro Inferno) e Ressurgimento**:
  - Dimensão independente funcionando como hub central e santuário neutro seguro.
  - Invariante de ressurgimento: ao morrer em qualquer continente, o jogador ressuscita na Hell Forge.
  - Portais de retorno desbloqueados conforme regiões mortais são exploradas.

---

## 3. AUDITORIA DO MUNDO E CARTOGRAFIA

- [x] **4 Continentes e 40 Regiões**:
  - Continente 1 (*Veyrath*): Regiões 01 a 10 (Vulcânico / Cinzas).
  - Continente 2 (*Sylvaran*): Regiões 11 a 20 (Pântano / Floresta Ancestral).
  - Continente 3 (*Khar-Duum*): Regiões 21 a 30 (Industrial / Cânions de Obsidiana).
  - Continente 4 (*Nhal'Kora*): Regiões 31 a 40 (Costa Boreal / Geleiras).
  - Existência física das 40 cenas 3D (`region_001.tscn` a `region_040.tscn`).

- [x] **Sistema de Conexão e Transição de Cenas**:
  - Grafo geográfico bidirecional (`core/world_connection_graph.gd`).
  - Carregamento assíncrono via `WorldSceneLoader` com suporte a multithreading.
  - Descarregamento estrito (`unload_active_region()`) evitando múltiplos ambientes 3D em memória.
  - Resolução de pontos de entrada (spawns padrão e direcionais).

- [x] **Visualização Cartográfica em 3 Níveis**:
  - Nível 1: Mapa-Múndi com limites continentais, portais e rotas.
  - Nível 2: Mapa Regional com relevo, POIs, masmorras e chefes.
  - Nível 3: Minimapa HUD com radar circular, bússola, estruturas próximas e inimigos.

---

## 4. AUDITORIA DO WORLD BOSS: AZAROTH E INVASÃO DEMONÍACA

- [x] **Identidade Exclusiva**:
  - Azaroth é o único World Boss global do jogo.
  - Comandante supremo com 1.000.000 de HP e 4 fases de combate.
  - Demônios superiores integram a hierarquia militar da invasão (não são chefes de masmorra).

- [x] **Ciclo Persistente de 5 Horas**:
  - Temporizador autoritativo no servidor de 18.000s (4h 15m DORMANT, 15m WARNING, 30m ACTIVE).
  - Imune à abertura de telas/mapas (`PROCESS_MODE_ALWAYS`).
  - Persistência e restauração precisa no segundo exato via Save/Load.

- [x] **Seleção de Região e Proibição do Verdadeiro Inferno**:
  - Sorteio randômico restrito às 30 regiões dos 3 continentes mortais.
  - Hell Forge (`hell_forge`) categoricamente excluída e nunca sorteada.
  - Spawn de Azaroth a ~1 km dos jogadores respeitando o relevo natural do terreno.

- [x] **Alerta Cinematográfico de 1 Hora**:
  - Disparado aos 3.600s restantes no canto superior esquerdo da HUD.
  - Mensagem canônica oficial dinâmica com nomes da região e continente em maiúsculas.
  - Animação de entrada/saída, moldura em brasa abissal e contagem regressiva.

- [x] **Invasão em Duas Fases**:
  - Fase 1: Corrupção a 30%, 3 fendas ativas, demônios inferiores e emboscadas nos flancos.
  - Fase 2: Expansão a 75%, 6 fendas com dano em área, primordiais e investidas em pinça simultâneas.

- [x] **Batalha de 4 Fases e Conclusão**:
  - Escalonamento progressivo de dano ($1.0\times \to 1.6\times$) e velocidade ($1.0\times \to 1.35\times$).
  - Transições cinematográficas invulneráveis de 4.5s com banner animado na HUD.
  - Sequência de colapso de 6.0s (`collapse_death`).
  - Expurgamento total do território (corrupção zerada, fendas seladas, status `CLEANSED`).
  - Recompensas de World Boss distribuídas para todos os participantes do mundo privado.

---

## 5. AUDITORIA MULTIPLAYER

- [x] **Topologia de Rede**:
  - Arquitetura autoritativa baseada em `ENetMultiplayerPeer`.
  - Servidor/Anfitrião privado com limite rígido de até 8 jogadores (`Invariants.MAX_PARTICIPANTS`).
  - Recusa formal de conexões além do limite (9º jogador rejeitado com segurança).

- [x] **Sistema de Convites e Sessão**:
  - Geração de código alfanumérico exclusivo por mundo (`AP-XXXX`).
  - Lista de mundos privados locais e entrada via código de convite ou IP/porta.

- [x] **Sincronização em Rede**:
  - RPCs de ciclo global de World Boss, alvos de invasão, fases territoriais e combate.
  - Sincronização de posições de jogadores no mapa regional e minimapa.
  - Recuperação suave e salvamento de estado na desconexão de participantes.

---

## 6. AUDITORIA DE ASSETS, ÁUDIO E PERFORMANCE

- [x] **Pipeline de Modelos 3D GLB**:
  - 66 modelos GLB verificados (árvores, ruínas, forjas, santuários, cristais, armas, humanoides).
  - Configuração de LOD de malhas e VRAM compression habilitados em `project.godot`.

- [x] **Occlusion Culling e Otimização de Câmera**:
  - Occlusion culling ativado no motor para descarte de geometrias ocultas.
  - Frustum culling natural do Godot Renderer para elementos fora da visão da câmera.

- [x] **Áudio e Efeitos**:
  - Buses de áudio configurados (`Master`, `Music`, `SFX`, `UI`).
  - Efeitos visuais de corrupção atmosférica, névoa volumétrica e shaders de lava/gelo validados.

---

## 7. MATRIZ DE TESTES AUTOMATIZADOS

| Módulo de Teste | Suítes | Verificações | Falhas | Status |
| :--- | :---: | :---: | :---: | :---: |
| **Núcleo & Boot** | `suite_core`, `suite_boot`, `suite_catalogs` | 313 | 0 | **APROVADO** |
| **Personagem & Classes** | `suite_character`, `suite_classes`, `suite_races`, `suite_player` | 643 | 0 | **APROVADO** |
| **Mundo & Navegação** | `suite_world`, `suite_open_world`, `suite_map_navigation`, `suite_world_connection_loading` | 2.502 | 0 | **APROVADO** |
| **Combate & Criaturas** | `suite_bestiary`, `suite_models`, `suite_environment_pipeline` | 344 | 0 | **APROVADO** |
| **Inventário & Missões** | `suite_inventory`, `suite_quest` | 68 | 0 | **APROVADO** |
| **Salva & Interface** | `suite_save`, `suite_scene_ui`, `suite_ui_systems` | 247 | 0 | **APROVADO** |
| **Multiplayer** | `suite_net`, `suite_integration`, `suite_multiplayer_complete` | 134 | 0 | **APROVADO** |
| **Azaroth & Invasão** | `suite_world_boss`, `suite_world_boss_alert`, `suite_world_boss_location`, `suite_demonic_invasion`, `suite_azaroth_battle`, `suite_azaroth_invasion_restructure` | 633 | 0 | **APROVADO** |
| **TOTAL CONSOLIDADO** | **28 Suítes** | **4.884 Checks** | **0 Falhas** | **100% GREEN** |

---

## 8. STATUS FINAL DE PRONTIDÃO (RELEASE VERDICT)

> [!IMPORTANT]
> **VEREDITO DE QUALIDADE**: **APROVADO PARA LANÇAMENTO (RELEASE CANDIDATE 1)**
> Todos os sistemas de arquitetura, dados, persistência, rede, cartografia e eventos globais atendem aos critérios técnicos e foram exaustivamente validados sem qualquer regressão.
