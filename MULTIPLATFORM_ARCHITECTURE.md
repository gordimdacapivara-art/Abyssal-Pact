# ARQUITETURA MULTIPLATAFORMA (XBOX SERIES X|S & PC)
## ABYSSAL PACT — GODOT 4.7.2

**Data:** 22 de Novembro de 2026  
**Versão da Arquitetura:** 1.0.0-PROD  
**Plataformas Suportadas:** Windows PC (Steam/Direct), Xbox Series S, Xbox Series X.

---

## 1. VISÃO GERAL & PRINCÍPIOS FUNDAMENTAIS

O desenvolvimento de **ABYSSAL PACT** adota uma estratégia de **base de código unificada (Single Codebase)** no Godot 4. Toda a lógica de jogo, catálogo de criaturas (300 monstros + 230 demônios), sistemas de combate, equipamentos (100 armas), progressão e geração de mundo opera de forma idêntica e sem bifurcação de código entre as plataformas.

As diferenças de hardware, restrições de memória unificada, formatos de persistência em nuvem e métodos de entrada são encapsuladas por **interfaces de abstração padronizadas** localizadas em `res://systems/platform/`.

```
                                  +---------------------------------------+
                                  |         GAMEPLAY & CORE SYSTEMS       |
                                  |  (Characters, Loot, Quests, Combat)   |
                                  +-------------------+-------------------+
                                                      |
                                                      v
                                  +---------------------------------------+
                                  |            PlatformManager            |
                                  |   (Hardware Profiles & Optimization)  |
                                  +---+---------------+---------------+---+
                                      |               |               |
              +-----------------------+               |               +-----------------------+
              v                                       v                                       v
+---------------------------+           +---------------------------+           +---------------------------+
|       DeviceManager       |           |  PlatformStorageAdapter   |           | MultiplayerCrossplayMgr   |
| - Detecção Teclado/Xbox   |           | - LocalStorage (PC)       |           | - Limite 8 jogadores      |
| - Glifos Adaptativos      |           | - XGameSave Stub (Xbox)   |           | - Privilégios XR-053      |
| - Árvore de Foco (XR-051) |           | - Quota estrita de 64 MB  |           | - Hell Forge Exclusiva    |
+---------------------------+           +---------------------------+           +---------------------------+
```

---

## 2. CAMADA DE PERFIS DE PLATAFORMA (`PlatformProfile`)

O recurso `PlatformProfile` (`res://systems/platform/platform_profile.gd`) parametriza todas as variáveis de execução conforme as capacidades específicas de cada equipamento:

### 2.1. Especificações Técnicas por Perfil

| Parâmetro Técnico | Xbox Series S (Restritivo) | Xbox Series X (Fidelidade) | Windows PC (Escalável) |
| :--- | :--- | :--- | :--- |
| **Tipo de Perfil** | `XBOX_SERIES_S` | `XBOX_SERIES_X` | `PC_WINDOWS` |
| **Resolução Alvo** | 1080p (1920x1080) | 4K Nativo (3840x2160) | 1080p a 4K configurável |
| **Taxa de Quadros** | 60 FPS travado | 60 FPS travado | 60 / 120 / Desbloqueado |
| **Resolução Dinâmica** | Ativada (Min: 0.67 / ~720p) | Desativada (Opcional 0.85) | Configurável pelo usuário |
| **Orçamento de RAM/VRAM** | 7.500 MB (Teto de Segurança) | 13.500 MB | 8.192 MB (Recomendado) |
| **Tamanho Máx. Texturas** | 2048 x 2048 | 4096 x 4096 | 4096 x 4096 |
| **Atlas de Sombras** | 2048 x 2048 | 4096 x 4096 | 4096 x 4096 |
| **Threshold de LOD Pixels**| 1.6 (Transições agressivas) | 0.9 (Alta densidade) | 1.0 (Padrão de referência) |
| **Partículas por Emissor** | Máx. 600 partículas | Máx. 2500 partículas | Máx. 2000 partículas |
| **Backend Gráfico** | Direct3D 12 (D3D12) | Direct3D 12 (D3D12) | Vulkan / D3D12 |

---

## 3. GERENCIADOR DE PLATAFORMA (`PlatformManager`)

O `PlatformManager` atua como o coordenador central:
1. **Detecção Dinâmica:** Avalia flags de linha de comando (`--platform=series_s`, `--platform=series_x`), tags de compilação da engine (`OS.has_feature("xbox_series_s")`) ou o sistema operacional hospedeiro.
2. **Aplicação de Diretivas de Engine:**
   - Trava a taxa de quadros via `Engine.max_fps`.
   - Ajusta o `mesh_lod_threshold` e a qualidade de MSAA 3D no `Viewport`.
   - Modifica dinamicamente a escala do renderizador 3D (`rendering/scaling_3d/scale`).
   - Define a dimensão do atlas de sombras direcionais no `RenderingServer`.
3. **Monitor de Memória Contínuo:**
   - A cada 5 segundos, afere `OS.get_static_memory_usage()`.
   - Caso o consumo supere 85% do teto estabelecido para o console, dispara o sinal `memory_warning` para acionar garbage collection e purga preventiva de recursos descarregados de regiões adjacentes.

---

## 4. SISTEMA DE ENTRADA E ACESSIBILIDADE (`DeviceManager`)

Em conformidade com a certificação **Microsoft XR-051**, nenhum elemento do jogo pode exigir o cursor do mouse:
1. **Comutação Dinâmica:** Detecta instantaneamente qualquer entrada via teclado/mouse ou gatilhos/botões de controle Xbox, alternando sem pausa ou congelamento.
2. **Prompts Adaptativos:** Converte dinamicamente textos de tutorial e dicas de interface (`[A]`, `[B]`, `[X]`, `[Y]`, `[LB]`, `[RB]`, `[LT]`, `[RT]`, `[Menu]`, `[View]`).
3. **Amarração Automática de Árvore de Foco:** O método `setup_focus_tree(control)` percorre recursivamente contêineres e listas, vinculando as propriedades `focus_neighbor_top` e `focus_neighbor_bottom`, garantindo navegação fluida em menus pelo D-Pad.

---

## 5. PERSISTÊNCIA E QUOTAS DE ARMAZENAMENTO (`PlatformStorageAdapter`)

A certificação **Microsoft XR-052** proíbe a gravação desgovernada no sistema de arquivos local:
- **`LocalStorageAdapter` (PC):** Persiste em `user://saves/` utilizando JSON seguro e versionado.
- **`XboxConnectedStorageAdapterStub` (Xbox):** Empacota o save em contêineres associados ao `XUserHandle` do perfil ativo, respeitando o limite máximo regulatório de **64 MB** por usuário e provendo interface para sincronização em nuvem da Xbox Live.

---

## 6. SESSÕES PRIVADAS E CROSSPLAY PC-XBOX (`MultiplayerCrossplayManager`)

1. **Paridade Absoluta:** Jogadores de PC e Xbox jogam juntos nos mesmos mundos privados sem qualquer distinção de regras mecânicas.
2. **Teto Inegociável de 8 Jogadores:** O anfitrião (Host) rejeita categoricamente qualquer tentativa de ingresso a partir do 9º participante.
3. **Validação de Privilégios (XR-053):** A chamada simulada de `XUserCheckPrivilege` garante que jogadores com restrições parentais ou sem assinatura ativa recebam feedbacks informativos sem que o jogo trave.
4. **Tolerância a Quedas (60s Reconnection Grace Period):** Jogadores que sofram desconexão abrupta têm seus tokens de sessão e instâncias no mundo preservados por 60 segundos, permitindo reinserção instantânea.
5. **Hell Forge Exclusiva por Mundo:** A forja é única no mundo privado e de acesso mutuamente exclusivo (apenas 1 jogador operando por vez), com nível de corrupção e infusões sincronizados pelo Host.
