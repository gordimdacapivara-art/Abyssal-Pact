# METAS DE DESEMPENHO E OTIMIZAÇÃO POR PLATAFORMA
## ABYSSAL PACT — ORÇAMENTOS DE HARDWARE, FRAME TIME E CARREGAMENTO

**Data:** 22 de Novembro de 2026  
**Meta Geral:** 60 FPS Estável (16,67 ms por frame) em Todos os Cenários de Combate e Invasão  
**Versão do Documento:** 1.0.0-PERF  

---

## 1. VISÃO GERAL DE METAS POR PLATAFORMA

| Métrica / Plataforma | Xbox Series S (Prioridade) | Xbox Series X (Fidelidade) | Windows PC (Referência) |
| :--- | :--- | :--- | :--- |
| **Resolução Alvo** | 1080p Dinâmico (720p–1080p FSR) | 4K Nativo (3840x2160) | 1080p a 4K (Configurável) |
| **Meta de FPS** | **60 FPS** cravado | **60 FPS** cravado | **60 / 120 / Desbloqueado** |
| **Orçamento de Frame**| **16,67 ms** | **16,67 ms** | **16,67 ms / 8,33 ms** |
| **Orçamento de Memória**| **7.500 MB** (do total de 10 GB)| **13.500 MB** (do total de 16 GB)| **8.192 MB** (RAM base) |
| **Teto de VRAM Texturas**| 2048 x 2048 (BC7/ASTC) | 4096 x 4096 (BC7/ASTC) | 4096 x 4096 (BC7/ASTC) |
| **Qualidade Anti-Aliasing**| MSAA 2X / TAA / FSR 2.2 | MSAA 4X / TAA | MSAA 2X a 8X / TAA / FSR |
| **Atlas de Sombras** | 2048 x 2048 (16-bit depth) | 4096 x 4096 (24-bit depth) | 4096 x 4096 (Configurável) |
| **Partículas por Emissor**| Máx. 600 partículas | Máx. 2.500 partículas | Máx. 2.000 partículas |
| **Mesh LOD Threshold** | 1.6 (Transição agressiva) | 0.9 (Transição suave) | 1.0 (Padrão) |
| **Tempo Máx. de Loading**| < 3,5 segundos | < 2,0 segundos (NVMe) | < 3,0 segundos (SSD) |

---

## 2. DECOMPOSIÇÃO DO ORÇAMENTO DE FRAME TIME (16,67 ms @ 60 FPS)

Para garantir estabilidade mesmo durante a **Fase 4 da Batalha contra Azaroth** (com centenas de lacaios do exército demoníaco e efeitos de fogo simultâneos), o tempo de processamento por quadro é dividido rigidamente:

```
+-----------------------------------------------------------------------------------------+
| TOTAL FRAME BUDGET: 16.67 ms (60 FPS)                                                   |
+-----------------------------------------------------------------------------------------+
|  CPU SIMULATION (Máx. 7.50 ms)              |  GPU RENDERING (Máx. 8.50 ms)             |
|  - Física & Colisões: 2.0 ms               |  - Depth Pre-pass & Culling: 1.2 ms        |
|  - Lógica GDScript & Combate: 2.5 ms       |  - Shadow Map Atlas: 1.8 ms                |
|  - IA & Pathfinding de Inimigos: 1.8 ms    |  - Forward+ Shading & Luzes: 3.5 ms        |
|  - Replicação de Rede ENet: 1.2 ms         |  - Pós-Processamento & FSR Upscaling: 2.0 ms|
+-----------------------------------------------------------------------------------------+
|  HEADROOM / MARGEM DE SEGURANÇA: ~0.67 ms                                               |
+-----------------------------------------------------------------------------------------+
```

---

## 3. ESTRATÉGIAS DE OTIMIZAÇÃO CRÍTICAS PARA O XBOX SERIES S

O Xbox Series S possui uma restrição de banda de memória em sua partição lenta (2 GB a 56 GB/s) e GPU de 4 TFLOPs RDNA2. Para atingir 60 FPS constantes:

### 3.1. Resolução Dinâmica com FSR (AMD FidelityFX Super Resolution)
- O renderizador opera em resolução interna adaptativa.
- Sob condições ideais, renderiza a 1080p nativo.
- Em picos de partículas abissais ou emboscadas com mais de 30 demônios simultâneos, a escala interna reduz de forma contínua até 67% (~720p base) com reconstrução temporal FSR, mantendo os 60 FPS intocados sem perda perceptível de nitidez em televisores de sala.

### 3.2. Culling e Oclusão Agressivos (Occlusion Culling BVH)
- Todas as 40 regiões possuem árvores de oclusão pré-calculadas.
- Geometrias de cavernas, fortalezas e relevo montanhoso bloqueiam a renderização de elementos traseiros antes do envio dos vértices ao rasterizador.

### 3.3. Streaming de Regiões e Descarregamento de Memória
- Somente a região ativa e as regiões imediatamente conectadas por portais permanecem carregadas em memória.
- Regiões de outros continentes têm seus buffers de colisão e malhas purgados da RAM assim que o jogador conclui a transição.

### 3.4. Otimização de Densidade de NPCs e IA em Área
- Inimigos além de 60 metros da câmera têm sua taxa de atualização de IA (tick rate) reduzida de 60 Hz para 15 Hz.
- Animações esqueléticas de demônios distantes utilizam interpolação por chaveamento simplificado (Animation LOD).

---

## 4. OTIMIZAÇÕES PARA O XBOX SERIES X

O Xbox Series X possui 12 TFLOPs de poder gráfico e 16 GB de memória GDDR6 veloz (560 GB/s):
- **4K Nativo Imersivo:** Sem necessidade de reconstrução temporal agressiva.
- **Atlas de Sombras Completo (4096px):** Projeção nítida de sombras para todas as tochas e fendas demoníacas da invasão de Azaroth.
- **Partículas Plenas:** Efeitos volumétricos de fumaça, brasa e tempestade abissal renderizados na capacidade máxima de 2.500 partículas por emissor.
- **Distância de Fade Expandida:** Visibilidade de até 150 metros para marcos geográficos e estruturas dos quatro continentes.

---

## 5. PRESETS GRÁFICOS NO WINDOWS PC

Para computadores pessoais, o menu de configurações do jogo expõe perfis predefinidos que aplicam automaticamente as variáveis do `PlatformProfile`:
1. **Baixo (Low):** Equivalente a hardware com 4 GB de VRAM (GTX 1050 Ti), texturas 1024px, sombras 1024px, 30-60 FPS.
2. **Médio (Medium):** Equivalente ao perfil do Xbox Series S (GTX 1660 / RX 5600 XT), texturas 2048px, 60 FPS com FSR.
3. **Alto (High):** Recomendado para RTX 3060 / RX 6700 XT, 1440p nativo a 60-120 FPS, sombras 4096px.
4. **Ultra:** Equivalente ao Xbox Series X (RTX 4070 / RX 7800 XT ou superior), 4K nativo a 60+ FPS, fidelidade geométrica máxima.
