class_name MonsterData
extends Resource
## Dados de criatura do Bestiário de MONSTROS de Abyssal Pact (300 criaturas).
##
## CATEGORIA INDEPENDENTE: Estritamente separada do catálogo de 230 DEMÔNIOS.
## Os monstros representam a fauna selvagem, predadores, mortos-vivos, gigantes,
## e elementais dos 4 continentes de Abyssal Pact.

const SUBCATEGORIES: PackedStringArray = [
	"humanoids",
	"beasts",
	"reptiles_dragons",
	"undead",
	"demons_abyssals",
	"giants_colossi",
	"magical_elementals",
	"insects_arachnids",
	"aquatic",
	"rare_anomalies"
]

const RARITIES: PackedStringArray = ["common", "uncommon", "rare", "elite", "legendary"]

@export var id: StringName = &""
@export var numeric_id: int = 1
@export var display_name: String = ""
@export var clean_id: String = ""
@export var subcategory: StringName = &"humanoids"
@export var family_display: String = "Humanoides monstruosos"
@export var continent: String = "Veyrath"
@export var region_id: StringName = &"REG-001"
@export var biome: String = "Vulcânico"
@export var habitat: String = ""
@export var rarity: StringName = &"common"
@export var base_color_hex: String = "#3d3733"
@export var emission_color_hex: String = "#ff5500"
@export var is_pilot: bool = false

@export var blend_path: String = ""
@export var glb_path: String = ""
@export var preview_path: String = ""

@export var stats: Dictionary = {
	"max_health": 250,
	"damage": 18,
	"defense": 0.70,
	"move_speed": 3.0,
	"attack_range": 2.2,
	"attack_cooldown": 2.0,
	"xp_reward": 35,
	"gold_reward": 15
}

@export var combat_info: Dictionary = {
	"family_role": "brute",
	"abilities": PackedStringArray(),
	"resistances": {
		"physical": 1.0,
		"abyssal": 1.0,
		"fire": 1.0
	}
}

func has_model() -> bool:
	return not glb_path.is_empty() and ResourceLoader.exists(glb_path)

func health() -> float:
	return float(stats.get("max_health", 100.0))

func damage() -> float:
	return float(stats.get("damage", 10.0))

func to_dict() -> Dictionary:
	return {
		"id": String(id),
		"numeric_id": numeric_id,
		"name": display_name,
		"clean_id": clean_id,
		"subcategory": String(subcategory),
		"family": family_display,
		"continent": continent,
		"region": String(region_id),
		"biome": biome,
		"habitat": habitat,
		"rarity": String(rarity),
		"is_pilot": is_pilot,
		"blend_path": blend_path,
		"glb_path": glb_path,
		"preview_path": preview_path,
		"stats": stats,
		"combat_info": combat_info
	}

func from_dict(data: Dictionary) -> bool:
	if not data.has("id"):
		return false
	id = StringName(String(data.get("id", "")))
	numeric_id = int(data.get("numeric_id", 1))
	display_name = String(data.get("name", ""))
	clean_id = String(data.get("clean_id", ""))
	family_display = String(data.get("family", "Humanoides monstruosos"))
	
	# Mapear display para subcategory key
	var f_lower = family_display.to_lower()
	if "humanoide" in f_lower:
		subcategory = &"humanoids"
	elif "fera" in f_lower:
		subcategory = &"beasts"
	elif "réptil" in f_lower or "drac" in f_lower:
		subcategory = &"reptiles_dragons"
	elif "morto" in f_lower:
		subcategory = &"undead"
	elif "demônio" in f_lower or "abissal" in f_lower:
		subcategory = &"demons_abyssals"
	elif "gigante" in f_lower or "colosso" in f_lower:
		subcategory = &"giants_colossi"
	elif "mágic" in f_lower or "element" in f_lower:
		subcategory = &"magical_elementals"
	elif "inseto" in f_lower or "aracn" in f_lower:
		subcategory = &"insects_arachnids"
	elif "aquátic" in f_lower:
		subcategory = &"aquatic"
	else:
		subcategory = &"rare_anomalies"

	continent = String(data.get("continent", "Veyrath"))
	region_id = StringName(String(data.get("region", "REG-001")))
	biome = String(data.get("biome", "Vulcânico"))
	habitat = String(data.get("habitat", ""))
	rarity = StringName(String(data.get("rarity", "common")))
	is_pilot = bool(data.get("is_pilot", false))

	blend_path = String(data.get("blend_path", ""))
	glb_path = String(data.get("glb_path", ""))
	preview_path = String(data.get("preview_path", ""))

	if data.has("stats"):
		stats = data["stats"]
	if data.has("combat_info"):
		combat_info = data["combat_info"]
	return true
