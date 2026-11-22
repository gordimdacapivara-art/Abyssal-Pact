# Abyssal Pact — Classes

## Escopo confirmado

O jogo terá **80 classes**. Nenhum nome, papel, árvore de habilidades, arma, recurso, requisito, progressão ou relação com raças foi definido no material disponível.

## Registro completo de capacidade

| Registros | Nome | Papel / identidade | Estado |
|---|---|---|---|
| CLASS-001–CLASS-010 | Pendente | Pendente | Não definido |
| CLASS-011–CLASS-020 | Pendente | Pendente | Não definido |
| CLASS-021–CLASS-030 | Pendente | Pendente | Não definido |
| CLASS-031–CLASS-040 | Pendente | Pendente | Não definido |
| CLASS-041–CLASS-050 | Pendente | Pendente | Não definido |
| CLASS-051–CLASS-060 | Pendente | Pendente | Não definido |
| CLASS-061–CLASS-070 | Pendente | Pendente | Não definido |
| CLASS-071–CLASS-080 | Pendente | Pendente | Não definido |

**Contagem validada:** 80 registros de classe reservados.

## Modelo editorial para aprovação futura

Cada classe deverá registrar: nome canônico, fantasia de poder, papel em solo/grupo, armas, habilidades, recursos, limitações, progressão, requisitos, compatibilidade multiplayer e dependências de arte/animação. Esse modelo não define mecânicas.

## Dependências de design

O catálogo de classes depende de decisões ainda pendentes sobre combate, equipamentos, progressão, raça/sub-raça e rede. Nenhuma dessas decisões deve ser inferida desta contagem.

## Estado do registro no sistema (14/11/2026)

- As **80 classes estão registradas no catálogo de dados** (`data/content/classes/class_001..080.tres`) com seus IDs editoriais oficiais (CLASS-001..CLASS-080). Nenhum nome oficial existia neste documento — os 79 registros não-protótipo permanecem com nome editorial "Classe CLASS-XXX (pendente de design)".
- **Organização editorial em 8 grupos** (`CLASS-GROUP-01..08`, 10 classes cada). ATENÇÃO: este documento NÃO registra grupos nomeados — os IDs de grupo são editoriais e os NOMES dos grupos estão pendentes de design (nada foi inventado).
- **Protótipo funcional completo: CLASS-001 "Arcanista"** — atributos iniciais, 2 habilidades ativas demonstráveis (básica + especial), 1 passiva demonstrável + 1 passiva RESERVADA pendente (ABIL-ARC-12, nada inventado), árvore de 4 nós, progressão e desbloqueios por nível. Validação: suíte `suite_classes` (ver `ARCHITECTURE.md`).
- Os demais 79 registros estão estruturados com `pending_fields` declarados e prontos para receber conteúdo de design, sem modificar código central.
- Campos de balanceamento do protótipo (cooldowns/custos/dano) são PROVISÓRIOS ("tuning" pendente).
