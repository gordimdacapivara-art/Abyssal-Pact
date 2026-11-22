# Abyssal Pact — Arquitetura Técnica

## Decisões técnicas confirmadas

| Área | Decisão |
|---|---|
| Engine | Godot 4. |
| Linguagem de gameplay | GDScript. |
| Ferramenta de modelagem | Blender. |
| Formato de modelos em jogo | GLB. |
| Multiplayer | Exclusivamente privado. |
| Capacidade inicial | Máximo de 8 jogadores por mundo, incluindo anfitrião. |

## Premissas de compatibilidade

- Os modelos 3D são produzidos no Blender e, quando solicitada a exportação, devem ser exportados em formato GLB diretamente para dentro do projeto Godot 4, salvo decisão posterior documentada.
- Sistemas de rede devem aplicar o limite total de oito participantes, não oito convidados.
- A arquitetura deve preservar a Hell Forge como destino obrigatório de ressurgimento; esta é uma regra de produto, não uma substituição por spawn local.

## Decisões técnicas pendentes — não presumir

| Área | Questão a decidir | Por que bloqueia design detalhado |
|---|---|---|
| Autoridade de rede | Host-authoritative, servidor dedicado ou outro modelo? | Define segurança, sincronização e posse de estado. |
| Transporte/serviço | Solução de rede e convite privado. | Define conexão, NAT, reconexão e testes. |
| Persistência | O que é salvo, onde e quem é dono do estado? | Afeta mundos, personagens e respawn. |
| Topologia do mundo | Cenas, streaming, transições e instâncias. | Afeta 40 regiões e performance. |
| Plataformas-alvo | PC/console/outros e metas de hardware. | Define input, certificação e orçamento. |
| Controle de versão/CI | Repositório, ramificação, builds e validação. | Diretório atual não contém Git nem automação. |
| Pipeline GLB | Convenções de escala, eixos, materiais, rig e validação. | Evita importações inconsistentes. |
| Observabilidade | Logs, relatórios de falha e telemetria. | Necessária para depurar coop privado. |

## Estrutura lógica proposta (não implementada)

Quando as decisões acima forem aprovadas, manter separadas as camadas: apresentação (cenas/UI), regras de gameplay, estado/persistência, integração de rede e pipeline de conteúdo. Isto é uma orientação de organização, não a criação de módulos, nós Godot ou APIs.

## Riscos técnicos registrados

1. O modelo de autoridade indefinido pode exigir retrabalho de combate, inventário e chefes.
2. O limite de oito jogadores deve ser validado contra orçamento de CPU, rede, animação e VFX antes de escalar conteúdo.
3. GLB precisa de convenções de exportação e testes de importação antes da produção em massa de 230 demônios.
4. Sem plataforma-alvo e orçamento de performance, não há critérios para LOD, textura, iluminação ou streaming.
