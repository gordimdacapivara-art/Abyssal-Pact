extends PlayerInteractable
## Objeto de prova de interação do playground (ID editorial NEUTRO:
## TEST-INT-001 — sem lore; substituível por objetos canônicos depois).
## Valida o ciclo completo do InteractionSensor (detecção → prompt → uso).

var uses := 0

func interaction_prompt() -> String:
	if uses == 0:
		return "Examinar pedra de prova (TEST-INT-001)"
	return "Pedra examinada (TEST-INT-001) — sem uso adicional"

func interact(_player: Node3D) -> bool:
	uses += 1
	print("[playtest] TEST-INT-001 examinada (uso %d)" % uses)
	return true
