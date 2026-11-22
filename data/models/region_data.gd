class_name RegionData
extends Resource
## Dados de região de mundo aberto (REG-001..REG-040).
## 40 regiões distribuídas exatamente dez por continente (CONTINENTS_AND_REGIONS.md).
##
## Cada região define identidade visual própria, bioma, iluminação, terreno,
## limites geográficos, pontos de interesse (cidades, masmorras, chefes, exploração),
## portões e portais de transição, áreas de inimigos e lista de assets pendentes.

@export var id: StringName = &""
@export var display_name: String = ""
@export var continent_id: StringName = &""
@export var description: String = ""
## Bioma específico da região (ex.: ash_plains, basalt_peaks, spectral_marsh, etc.).
@export var biome: String = "plains"
## Faixa de nível recomendada para o conteúdo da região: Vector2i(min, max).
@export var level_range: Vector2i = Vector2i(1, 10)
## Regiões geograficamente vizinhas conectadas (RegionData.id).
@export var connections: PackedStringArray = PackedStringArray()
## Limites geográficos: {center: Vector3, radius: float, border_barrier: bool}.
@export var boundaries: Dictionary = {
	"radius": 150.0,
	"border_barrier": true,
	"center": Vector3.ZERO
}
## Iluminação e atmosfera: sun_color, sun_energy, ambient_color, fog_enabled, fog_color, fog_density.
@export var lighting_profile: Dictionary = {
	"sun_color": "#e8a478",
	"sun_energy": 1.2,
	"ambient_color": "#2c1d24",
	"fog_enabled": true,
	"fog_color": "#382329",
	"fog_density": 0.012
}
## Caminho da cena Godot que implementa a região (específica ou carregador modular).
@export var scene_path: String = "res://scenes/world/modular_region.tscn"
## Estado de produção: "full_production" (completa) ou "modular_staging" (staging com placeholders).
@export var status: String = "modular_staging"
## Pontos de interesse: Array de {id, name, type, position, description, discovery_xp}.
## Tipos canônicos: "city", "dungeon", "boss_arena", "exploration", "portal", "camp".
@export var points_of_interest: Array = []
## Portões de transição entre fronteiras: Array de {gate_id, target_region, target_spawn, position, radius}.
@export var gates: Array = []
## Portais de teletransporte / viagem rápida: Array de {portal_id, target_region, target_spawn, position, is_intercontinental}.
@export var portals: Array = []
## Zonas de spawn de inimigos (vinculadas aos 5 demônios catalogados desta região):
## Array de {spawn_id, demon_id, position, radius, count}.
@export var enemy_spawns: Array = []
## ID do chefe demoníaco alocado nesta região (BOSS-XXX do BossManager), se houver.
@export var boss_encounter_id: StringName = &""
## Configurações da arena de chefe: {position: Vector3, radius: float, hazards: PackedStringArray}.
@export var boss_arena: Dictionary = {}
## Lista explícita de assets 3D ausentes / pendentes de modelagem definitiva.
@export var pending_assets: PackedStringArray = PackedStringArray()

func is_full_production() -> bool:
	return status == "full_production"

func poi_by_id(poi_id: StringName) -> Dictionary:
	var target := String(poi_id)
	for poi: Dictionary in points_of_interest:
		if String(poi.get("id", "")) == target:
			return poi
	return {}

func gate_by_id(gate_id: StringName) -> Dictionary:
	var target := String(gate_id)
	for gate: Dictionary in gates:
		if String(gate.get("gate_id", "")) == target:
			return gate
	return {}

func portal_by_id(portal_id: StringName) -> Dictionary:
	var target := String(portal_id)
	for portal: Dictionary in portals:
		if String(portal.get("portal_id", "")) == target:
			return portal
	return {}

func pois_of_type(type_name: String) -> Array:
	var result: Array = []
	for poi: Dictionary in points_of_interest:
		if String(poi.get("type", "")) == type_name:
			result.append(poi)
	return result

func to_dict() -> Dictionary:
	return {
		"id": String(id),
		"display_name": display_name,
		"continent_id": String(continent_id),
		"description": description,
		"biome": biome,
		"level_range": [level_range.x, level_range.y],
		"connections": Array(connections),
		"boundaries": boundaries,
		"lighting_profile": lighting_profile,
		"scene_path": scene_path,
		"status": status,
		"points_of_interest": points_of_interest,
		"gates": gates,
		"portals": portals,
		"enemy_spawns": enemy_spawns,
		"boss_encounter_id": String(boss_encounter_id),
		"boss_arena": boss_arena,
		"pending_assets": Array(pending_assets),
	}

func from_dict(data: Dictionary) -> bool:
	if not data.has("id"):
		return false
	id = StringName(String(data.get("id", "")))
	display_name = String(data.get("display_name", ""))
	continent_id = StringName(String(data.get("continent_id", "")))
	description = String(data.get("description", ""))
	biome = String(data.get("biome", "plains"))
	var levels: Array = data.get("level_range", [1, 10])
	if levels.size() >= 2:
		level_range = Vector2i(int(levels[0]), int(levels[1]))
	connections = PackedStringArray(data.get("connections", []))
	boundaries = Dictionary(data.get("boundaries", {}))
	lighting_profile = Dictionary(data.get("lighting_profile", {}))
	scene_path = String(data.get("scene_path", "res://scenes/world/modular_region.tscn"))
	status = String(data.get("status", "modular_staging"))
	points_of_interest = Array(data.get("points_of_interest", []))
	gates = Array(data.get("gates", []))
	portals = Array(data.get("portals", []))
	enemy_spawns = Array(data.get("enemy_spawns", []))
	boss_encounter_id = StringName(String(data.get("boss_encounter_id", "")))
	boss_arena = Dictionary(data.get("boss_arena", {}))
	pending_assets = PackedStringArray(data.get("pending_assets", []))
	return true
