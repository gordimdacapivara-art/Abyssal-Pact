extends Node
## Bootstrapper da cena de testes: transfere a execução para um TestHost
## anexado direto a root (sobrevive a trocas de cena durante os testes).
## Guarda anti-reinicialização: se os testes já rodam, não faz nada — a suíte
## de SceneManager troca de cena mas NUNCA volta para run_tests.tscn.

const TESTS_RUNNING_META := "abyssal_pact_tests_running"

func _ready() -> void:
	if Engine.has_meta(TESTS_RUNNING_META) or get_tree().root.has_node("TestHost"):
		return
	Engine.set_meta(TESTS_RUNNING_META, true)
	var host: Node = preload("res://tests/test_host.gd").new()
	host.name = "TestHost"
	get_tree().root.add_child.call_deferred(host)
