class_name GameStates
## Estados globais do jogo controlados pelo GameManager.
##
## A máquina de estados é deliberadamente mínima: fluxos completos (menu →
## criação de personagem → mundo) aguardam decisões de design pendentes.

enum State {
	## Boot dos sistemas em andamento.
	BOOT,
	## Em menus/fora de mundo (hub de telas).
	MENU,
	## Transição de cena em andamento.
	LOADING,
	## Em mundo (hub Hell Forge ou região).
	WORLD,
	## Jogo em pausa (overlay).
	PAUSED,
	## Encerrando a aplicação.
	SHUTDOWN,
}
