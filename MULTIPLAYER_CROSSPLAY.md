# GUIA DE MULTIPLAYER E CROSSPLAY (PC & XBOX)
## ABYSSAL PACT — SESSÕES PRIVADAS E ARQUITETURA AUTORITATIVA

**Data:** 22 de Novembro de 2026  
**Versão do Protocolo de Rede:** 1.0.0-PROD  
**Transporte:** ENetMultiplayerPeer (Nativo Godot 4) + Camada Crossplay Abyssal  

---

## 1. PRINCÍPIOS FUNDAMENTAIS DO MULTIPLAYER

1. **Ausência Total de Servidores Públicos Dedicados:**  
   Em conformidade estrita com o documento de visão de Abyssal Pact, o jogo não possui servidores mundiais abertos ou lobbies de matchmaking competitivos. Todo o multiplayer ocorre exclusivamente em **Mundos Privados Hospedados pelos Jogadores**.
2. **Limite Rígido de 8 Jogadores:**  
   O mundo privado suporta no máximo **8 participantes simultâneos** (1 Anfitrião + até 7 Convidados), assegurando estabilidade em conexões domésticas e paridade de desempenho no Xbox Series S.
3. **Autoridade Absoluta do Anfitrião (Host-Authoritative):**  
   O jogador que cria o mundo privado é o servidor da sessão (`Peer 1`). Todos os clientes (jogadores em PC Windows ou Xbox Series X|S) são meros terminais que transmitem comandos de entrada e recebem snapshots do mundo.
4. **Crossplay PC-Xbox Nativo:**  
   Jogadores em computadores Windows e consoles Xbox podem jogar juntos em qualquer combinação (ex: Host no Xbox Series S com convidados no PC, ou vice-versa).

---

## 2. FLUXO DE CONEXÃO, AUTENTICAÇÃO E HANDSHAKE

```
+---------------+                                                      +---------------+
| CLIENTE (Xbox)|                                                      | HOST (PC / XB)|
+-------+-------+                                                      +-------+-------+
        |                                                                      |
        | 1. Checagem Local XR-053 (XUserCheckPrivilege)                       |
        |--------------------------------------------------------------------->|
        |                                                                      |
        | 2. Envio de Handshake (Versão, Gamertag, PlatformType, Ticket)       |
        |--------------------------------------------------------------------->|
        |                                                                      |
        |                                       3. Validação do Host:          |
        |                                          - Versão de Protocolo? OK   |
        |                                          - Vagas < 8? OK             |
        |                                          - Crossplay Permitido? OK   |
        |                                          - Gera Reconnect Token      |
        |                                                                      |
        | 4. Confirmação de Admissão & Sincronização Inicial                   |
        |<---------------------------------------------------------------------|
        |    (World Snapshot, Estado da Hell Forge, Roster de 8 jogadores)     |
        |                                                                      |
```

---

## 3. MECANISMO DE RECONEXÃO COM TOLERÂNCIA A QUEDAS (60 SEGUNDOS)

Quedas de rede transitórias ou interrupções de Wi-Fi não podem desconectar permanentemente o jogador do progresso de sua equipe no mundo privado.

1. **Geração de Ticket de Sessão (`AP_TICKET`):**  
   Ao ingressar com sucesso, cada cliente recebe um token criptográfico único vinculado à sua ficha de personagem (`character_id`) e identidade de plataforma.
2. **Janela de Graça (Grace Period):**  
   Quando um cliente é desconectado sem emitir o evento voluntário de saída (`session_left`):
   - O anfitrião mantém a vaga do jogador reservada durante **60 segundos**.
   - O avatar do jogador permanece no mundo com estado de invulnerabilidade transitória.
   - O token de reconexão é arquivado na tabela `_reconnect_tickets`.
3. **Reconexão Transparente:**  
   Se o jogador reconectar dentro dos 60 segundos com um novo `peer_id`, o Host valida o ticket, restaura a sessão, transfere o pawn do personagem e descarta o token antigo sem resetar buffs, vida ou inventário.

---

## 4. VALIDAÇÃO AUTORITATIVA DE INVENTÁRIO, LOOT E PROGRESSÃO

Para impedir a proliferação de trapaças originadas em versões modificadas de PC afetando jogadores de console:

| Ação do Jogador | Processamento no Cliente | Validação Obrigatória no Host |
| :--- | :--- | :--- |
| **Drop de Inimigo** | Exibe efeito visual e som. | O Host calcula a tabela de loot das 530 entidades registradas, gera o item e autoriza a inserção no inventário. |
| **Crafting na Hell Forge** | Renderiza animação do fogo. | O Host verifica materiais, calcula o nível de corrupção e entrega o equipamento aprimorado. |
| **Completar Missão / Pacto** | Dispara interface de recompensa. | O Host valida o cumprimento dos objetivos antes de alterar o progresso permanente. |
| **Mutação de Atributos** | Solicita alocação de pontos de status. | O Host recalcula a árvore de talentos com base no nível legítimo do personagem. |

---

## 5. A HELL FORGE EXCLUSIVA DO MUNDO PRIVADO

A Forja Infernal (**Hell Forge**) segue regras arquiteturais estritas no ecossistema multiplayer:

1. **Instância Única por Mundo:**  
   Não existem instâncias individuais ou paralelas da Hell Forge. O mundo privado abriga apenas **uma única forja**.
2. **Exclusividade de Acesso Mútuo (Concurrency Lock):**  
   Enquanto um jogador estiver operando o painel de forja, o estado `in_use_by_peer` é bloqueado para os outros 7 participantes. A interface exibe *"A Forja Infernal está sendo operada por outro guerreiro"*.
3. **Sincronização de Estado Térmico e Corrupção:**  
   - O nível de corrupção (0% a 100%) e as infusões ativas (fogo, trevas, abismo) afetam todo o mundo privado.
   - A cada ciclo de forjamento, o Host sincroniza o snapshot da forja via evento `hell_forge_synced` para todos os 8 peers conectados.

---

## 6. REQUISITOS DE REDE, PORTAS E CONFIGURAÇÃO DE ROTEADOR

- **Porta Padrão:** `UDP 24565` (pode ser alterada no menu de configurações do anfitrião).
- **Largura de Banda Estimada:**
  - *Host:* Mínimo de 3 Mbps de Upload estável (para suportar até 7 convidados a 20 ticks/seg).
  - *Cliente:* Mínimo de 1 Mbps de Download / 512 Kbps de Upload.
- **NAT:** O suporte nativo a UPnP (`UPNP.new()`) foi integrado ao bootstrapper de rede do Godot para mapeamento automático de portas em roteadores domésticos.
