# Multiplayer — Mundos privados

## 1. Modelo confirmado

Abyssal Pact não terá servidores públicos no plano atual. O multiplayer será feito exclusivamente por mundos/servidores privados hospedados pelos jogadores.

- **Capacidade inicial planejada:** até 8 jogadores por mundo.
- **Acesso:** somente participantes autorizados pelo anfitrião.
- **Isolamento:** cada mundo mantém sua própria sessão e sua própria Hell Forge.

## 2. Hell Forge

A Hell Forge é o hub central de cada mundo privado.

Funções planejadas:
- Reunir os jogadores participantes daquele mundo.
- Servir como ponto central de preparação.
- Permitir iniciar viagens para os continentes do jogo.
- Permanecer restrita aos participantes do mundo correspondente.

A lista completa de serviços, interações, menus e regras de viagem ainda será especificada.

## 3. Questões técnicas pendentes

Antes da implementação, definir e testar:

1. Como o anfitrião cria, inicia, pausa e encerra um mundo.
2. Como convidados recebem convite e entram na sessão.
3. Como validar permissões e impedir acesso não autorizado.
4. Qual máquina tem autoridade sobre estado do mundo e resultados de combate.
5. Como sincronizar jogadores, inimigos, itens e eventos.
6. O que acontece quando o anfitrião desconecta.
7. Como salvar, recuperar e fazer backup do progresso.
8. Como lidar com latência, perda de conexão e reconexão.
9. Quais limites de rede e desempenho são aceitáveis para oito jogadores.

## 4. Requisitos de segurança

- Nunca armazenar tokens, senhas ou chaves privadas no repositório.
- Validar no lado autoritativo as ações que alteram o estado compartilhado.
- Não confiar em dados enviados por clientes sem validação.
- Planejar mecanismos de convite, autenticação e controle de acesso.
- Registrar decisões de segurança e testes relevantes.

## 5. Status

As regras de alto nível acima são premissas do projeto. A arquitetura de rede e a implementação ainda não estão concluídas.
