class_name ProgressionData
extends Resource
## Progressão de um personagem. Regras de nível/atributos pendentes de design
## (GAMEPLAY_SYSTEMS.md): estrutura pronta, valores determinísticos.

var level: int = 1
var experience: int = 0
## Atributos: dicionário aberto até design de combate confirmado.
var attributes: Dictionary = {}

func add_experience(amount: int) -> void:
	experience = maxi(0, experience + amount)

func to_dict() -> Dictionary:
	return {"level": level, "experience": experience, "attributes": attributes}

func from_dict(data: Dictionary) -> bool:
	if not data.has("level") or not data.has("experience"):
		return false
	level = int(data.get("level", 1))
	experience = int(data.get("experience", 0))
	attributes = data.get("attributes", {})
	return true
