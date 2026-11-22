extends Node
## Cena de boot — primeira cena do jogo (project.godot: main_scene).
##
## O boot dos sistemas é executado pelo autoload Game ANTES desta cena
## carregar (autoloads precedem a main scene). Aqui apenas registramos o
## resultado e deixamos os fluxos sinalizados no EventBus agirem
## (UIManager abre a tela principal ao receber game_state_changed → MENU).
## Fluxo completo menu → mundo: aguarda decisões de design (convites privados).

func _ready() -> void:
	var game := get_node("/root/Game")
	if not game.is_booted():
		push_error("Boot: GameManager não concluiu o boot antes da cena inicial.")
		return
	if not game.boot_success:
		push_error("Boot concluído com problemas — verifique as saídas de erro:")
		for issue in game.boot_issues:
			push_error("  - %s" % issue)
		return
	print("Abyssal Pact — boot OK (estado=%d, sistemas=%d)." % [game.state, game.registry().count()])
