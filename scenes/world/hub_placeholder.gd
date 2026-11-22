extends Node3D
## Placeholder do hub Hell Forge (cena de destino do ressurgimento).
##
## PLACEHOLDER arquitetural: layout, NPCs, forja, comércio e regras do hub
## NÃO existem ainda (HELL_FORGE.md). A cena existe para que o SceneManager
## e a regra de ressurgimento tenham um destino concreto em testes e fluxos.
## Regra preservada: ressurgimento resolve SEMPRE para este hub (invariante).

const DEFAULT_TITLE := "Hell Forge — hub central (placeholder)"

var _params: Dictionary = {}

@onready var _title: Label3D = $Title

## Contrato de parâmetros usado pelo SceneManager (change_scene + setup).
func setup(params: Dictionary = {}) -> void:
	_params = params
	if _title != null and params.has("title"):
		_title.text = String(params["title"])

func received_params() -> Dictionary:
	return _params

## Ponto de chegada do ressurgimento (consumido por sistemas futuros).
func spawn_point() -> Node3D:
	return $SpawnPoint as Node3D
