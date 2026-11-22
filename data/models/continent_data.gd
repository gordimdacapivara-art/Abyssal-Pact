class_name ContinentData
extends Resource
## Dados de continente. Escopo confirmado (CONTINENTS_AND_REGIONS.md):
## Veyrath, Sylvaran, Khar-Duum, Nhal'Kora. Cada continente abriga
## exatamente 10 regiões catalogadas (decisão de design registrada).

@export var id: StringName = &""
@export var display_name: String = ""
@export var description: String = ""
## Tema e bioma predominante do continente (Dark Fantasy).
@export var theme: String = ""
## Lista canônica das 10 regiões pertencentes (RegionData.id).
@export var region_ids: PackedStringArray = PackedStringArray()
## Região principal ou capital do continente.
@export var capital_region_id: StringName = &""
## Clima / atmosfera predominante.
@export var climate: String = ""
## Registro de assets 3D pendentes de modelagem final para o continente.
@export var pending_assets: PackedStringArray = PackedStringArray()

func region_count() -> int:
	return region_ids.size()

func has_region(target_region_id: StringName) -> bool:
	return region_ids.has(String(target_region_id))

func to_dict() -> Dictionary:
	return {
		"id": String(id),
		"display_name": display_name,
		"description": description,
		"theme": theme,
		"region_ids": Array(region_ids),
		"capital_region_id": String(capital_region_id),
		"climate": climate,
		"pending_assets": Array(pending_assets),
	}

func from_dict(data: Dictionary) -> bool:
	if not data.has("id"):
		return false
	id = StringName(String(data.get("id", "")))
	display_name = String(data.get("display_name", ""))
	description = String(data.get("description", ""))
	theme = String(data.get("theme", ""))
	region_ids = PackedStringArray(data.get("region_ids", []))
	capital_region_id = StringName(String(data.get("capital_region_id", "")))
	climate = String(data.get("climate", ""))
	pending_assets = PackedStringArray(data.get("pending_assets", []))
	return true
