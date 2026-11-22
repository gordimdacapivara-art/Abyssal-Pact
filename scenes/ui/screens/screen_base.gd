class_name ScreenBase
extends Control
## Base reutilizável para telas do router do UIManager.
##
## Contrato (ver ARCHITECTURE.md): a tela é instanciada como filha da camada
## "Screens" do autoload UI; open(params) é chamado após add_child quando o
## gerenciador abre a tela; close() antes de queue_free.

## Identificador registrado no UIManager (deve casar com a chave do router).
@export var screen_id: StringName = &""

## Chamado pelo UIManager quando a tela se torna ativa.
func open(_params: Dictionary = {}) -> void:
	pass

## Chamado pelo UIManager antes de liberar a tela.
func close() -> void:
	pass

## Helper: emitir ação de UI sem lógica de fluxo local (consumidores decidem).
func emit_ui_action(action: StringName) -> void:
	EventBus.ui_action_requested.emit(action)
