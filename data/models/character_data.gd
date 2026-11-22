class_name CharacterData
extends Resource
## Personagem: perfil + progressão + descobertas. A validação de raça,
## sub-raça e classe ocorre em CharacterManager (usa os catálogos vivos);
## aqui só o estado serializável.

var id: StringName = &""
var display_name: String = ""
var race_id: StringName = &""
var subrace_id: StringName = &""
var class_id: StringName = &""
## Personalização definida na criação (Dictionary JSON-safe): chaves em
## snake_case, valores em String (cores hex "#rrggbb")/float/bool. Exemplo:
## {"skin_color": "#8a6a52", "hair_style": "short", "hair_color": "#2b1d12",
##  "eye_color": "#7fd4ff", "face_mark": "scar", "extra_accessories": ["horn"],
##  "vestiment": "robe", "extra_scale": 1.0}. Carregado pelo RaceVisualBuilder.
## Persistido no save (CharacterManager.collect_save_data → to_dict).
var appearance: Dictionary = {}
var active_pact_id: StringName = &""
var pact_tiers: Dictionary = {} # String(pact_id) -> int(tier)
var progression: ProgressionData
var discoveries: DiscoveryLogData

func _init() -> void:
	progression = ProgressionData.new()
	discoveries = DiscoveryLogData.new()

func to_dict() -> Dictionary:
	return {
		"id": String(id),
		"display_name": display_name,
		"race_id": String(race_id),
		"subrace_id": String(subrace_id),
		"class_id": String(class_id),
		"appearance": appearance,
		"active_pact_id": String(active_pact_id),
		"pact_tiers": pact_tiers,
		"progression": progression.to_dict(),
		"discoveries": discoveries.to_dict(),
	}

func from_dict(data: Dictionary) -> bool:
	var required: Array[String] = ["id", "display_name", "race_id", "subrace_id", "class_id"]
	for key in required:
		if not data.has(key):
			return false
	id = StringName(String(data.get("id", "")))
	display_name = String(data.get("display_name", ""))
	race_id = StringName(String(data.get("race_id", "")))
	subrace_id = StringName(String(data.get("subrace_id", "")))
	class_id = StringName(String(data.get("class_id", "")))
	appearance = data.get("appearance", {})
	active_pact_id = StringName(String(data.get("active_pact_id", "")))
	pact_tiers = data.get("pact_tiers", {})
	if progression == null or discoveries == null:
		return false
	if not progression.from_dict(data.get("progression", {})):
		return false
	if not discoveries.from_dict(data.get("discoveries", {})):
		return false
	return true
