class_name RegionManager
extends RefCounted
## RegionManager — Gerenciador detalhado das 40 regiões e dimensões de ABYSSAL PACT.
##
## Responsabilidade:
##   - Acesso a metadados regionais (RegionData), biomas, faixas de nível e status;
##   - Inspeção de pontos de entrada (spawns), saídas (gates), portais, masmorras e safe zones;
##   - Filtragem por atributos cartográficos e de jogabilidade.

var _regions: Dictionary = {} # StringName -> RegionData
var _world_ref: WeakRef = null

func _init(regions_dict: Dictionary = {}, world_manager: Object = null) -> void:
	_regions = regions_dict
	if world_manager != null:
		_world_ref = weakref(world_manager)

func set_regions(regions_dict: Dictionary) -> void:
	_regions = regions_dict

func has_region(region_id: StringName) -> bool:
	var s_id := String(region_id)
	return _regions.has(s_id) or _regions.has(region_id)

func get_region(region_id: StringName) -> RegionData:
	var s_id := String(region_id)
	if _regions.has(s_id):
		return _regions[s_id] as RegionData
	if _regions.has(region_id):
		return _regions[region_id] as RegionData
	return null

func all_regions() -> Array[RegionData]:
	var result: Array[RegionData] = []
	for r in _regions.values():
		result.append(r as RegionData)
	return result

func region_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for r_id in _regions.keys():
		result.append(StringName(String(r_id)))
	return result

func regions_by_biome(biome: String) -> Array[RegionData]:
	var result: Array[RegionData] = []
	for reg in all_regions():
		if reg.biome == biome:
			result.append(reg)
	return result

func regions_by_level_range(min_lvl: int, max_lvl: int) -> Array[RegionData]:
	var result: Array[RegionData] = []
	for reg in all_regions():
		if reg.level_range.x <= max_lvl and reg.level_range.y >= min_lvl:
			result.append(reg)
	return result

func get_scene_path(region_id: StringName) -> String:
	var reg := get_region(region_id)
	return reg.scene_path if reg != null else ""

func get_entry_points(region_id: StringName) -> Array[String]:
	var points: Array[String] = ["default", "portal_main"]
	var reg := get_region(region_id)
	if reg != null:
		for gate: Dictionary in reg.gates:
			var target_spawn := String(gate.get("target_spawn", ""))
			if not target_spawn.is_empty() and not points.has(target_spawn):
				points.append(target_spawn)
			var gate_id := String(gate.get("gate_id", ""))
			if not gate_id.is_empty() and not points.has(gate_id):
				points.append(gate_id)
	return points

func get_exit_points(region_id: StringName) -> Array[Dictionary]:
	var reg := get_region(region_id)
	if reg == null:
		return []
	var result: Array[Dictionary] = []
	for gate: Dictionary in reg.gates:
		result.append(gate)
	return result

func get_portals(region_id: StringName) -> Array[Dictionary]:
	var reg := get_region(region_id)
	if reg == null:
		return []
	var result: Array[Dictionary] = []
	for port: Dictionary in reg.portals:
		result.append(port)
	return result

func get_safe_zones(region_id: StringName) -> Array[Dictionary]:
	var reg := get_region(region_id)
	if reg == null:
		return []
	return reg.pois_of_type("city")

func get_dungeons(region_id: StringName) -> Array[Dictionary]:
	var reg := get_region(region_id)
	if reg == null:
		return []
	return reg.pois_of_type("dungeon")

func get_boss_arena(region_id: StringName) -> Dictionary:
	var reg := get_region(region_id)
	if reg == null:
		return {}
	return reg.boss_arena
