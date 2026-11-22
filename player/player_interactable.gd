class_name PlayerInteractable
extends Area3D
## Contrato de objetos interativos do mundo.
##
## O InteractionSensor do personagem detecta áreas desta família (camada de
## colisão 2), escolhe a mais próxima e executa `interact(player)` com E.
## Subclasses sobrescrevem `interact()` e integram com os sistemas de domínio
## (EventBus/registry) — a camada de interação em si NÃO tem gameplay.
##
## IDs editoriais: use IDs neutros (ex.: TEST-INT-001, OBJ-###) até o cânone
## de lore definir objetos nomeados.

## Camada de colisão reservada a interativos (o sensor varre apenas ela).
const INTERACTABLE_LAYER := 2

@export var prompt := "Interagir"
@export var enabled := true

func _init() -> void:
	collision_layer = 1 << (INTERACTABLE_LAYER - 1)
	collision_mask = 0
	monitorable = true
	monitoring = false

## Texto exibido ao jogador quando este é o alvo mais próximo.
func interaction_prompt() -> String:
	return prompt

## Guarda de uso (alcance, estado, condições). O sensor checa antes de agir.
func can_interact(_player: Node3D) -> bool:
	return enabled

## Executa a interação. Retorna true quando algo aconteceu (permite encadeia-
## mento/feedback). Subclasses integram aqui com os gerenciadores.
func interact(_player: Node3D) -> bool:
	return false
