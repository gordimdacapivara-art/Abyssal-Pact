# Abyssal Pact

**Abyssal Pact** é um projeto de RPG de fantasia sombria em desenvolvimento com **Godot 4** e **GDScript**.

> Este repositório está começando como a base oficial de documentação e desenvolvimento. Sistemas, conteúdo, números de balanceamento e recursos ainda precisam ser implementados e validados.

## Visão do projeto

- **Engine:** Godot 4
- **Linguagem principal:** GDScript
- **Plataformas planejadas:** PC e Xbox Series X|S
- **Multiplayer:** mundos privados hospedados pelos próprios jogadores
- **Capacidade inicial planejada:** até 8 jogadores por mundo privado
- **Servidores públicos:** não fazem parte do plano atual

## Conceito central do multiplayer

Cada mundo privado possui sua própria **Hell Forge**, um hub central onde os participantes daquele mundo podem se encontrar e iniciar viagens para os continentes. A Hell Forge é exclusiva dos jogadores autorizados naquele mundo.

## Estrutura da documentação

| Documento | Conteúdo |
| --- | --- |
| [Visão geral](docs/PROJECT_OVERVIEW.md) | Premissas, objetivos e escopo inicial |
| [Multiplayer](docs/MULTIPLAYER.md) | Mundos privados, hospedagem e Hell Forge |
| [Plano de conteúdo](docs/CONTENT_ROADMAP.md) | Organização de raças, classes, monstros, demônios e itens |

## Estrutura de pastas planejada

```text
Abyssal-Pact/
├── docs/          # Game design e documentação técnica
├── assets/        # Modelos, texturas, animações, áudio e interface
├── scenes/        # Cenas Godot
├── scripts/       # Scripts GDScript
├── systems/       # Sistemas de jogo
└── tests/         # Testes e validações
```

As pastas de produção serão preenchidas conforme os recursos forem criados e integrados ao projeto.

## Princípios de desenvolvimento

1. Documentar decisões importantes antes de implementar sistemas complexos.
2. Manter conteúdo e balanceamento organizados em dados sempre que possível.
3. Projetar o multiplayer considerando desconexões, autoridade do anfitrião e sincronização.
4. Não assumir que compatibilidade com Xbox está garantida apenas por usar Godot; validar exportação, requisitos e processo de publicação separadamente.
5. Evitar incluir chaves, senhas, tokens ou credenciais neste repositório público.

## Estado atual

Este repositório contém a estrutura documental inicial. Ainda não representa uma versão jogável do Abyssal Pact.

## Contribuições

Ideias, correções e propostas podem ser registradas por meio de Issues e Pull Requests. Mudanças de escopo devem ser discutidas antes de serem tratadas como decisões definitivas.
