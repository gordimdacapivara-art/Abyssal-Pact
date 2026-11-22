class_name ContinentManager
extends RefCounted
## ContinentManager — Gerenciador e catálogo de continentes de ABYSSAL PACT.
##
## Responsabilidade:
##   - Catalogar e validar os 4 continentes (Veyrath, Sylvaran, Khar-Duum, Nhal'Kora);
##   - Mapear capitais continentais e regiões terminais de alta periculosidade;
##   - Calcular progresso de exploração por continente;
##   - Identificar e validar trânsito intercontinental.

const CONTINENT_CAPITALS := {
	&"CONT-01": &"REG-001", # Cinzália (Veyrath)
	&"CONT-02": &"REG-011", # Raiz Antiga (Sylvaran)
	&"CONT-03": &"REG-021", # Caldeira Rubra (Khar-Duum)
	&"CONT-04": &"REG-031"  # Geleira dos Ecos (Nhal'Kora)
}

const CONTINENT_TERMINALS := {
	&"CONT-01": &"REG-010", # Torre de Aster (Veyrath)
	&"CONT-02": &"REG-020", # Fonte do Primeiro Broto (Sylvaran)
	&"CONT-03": &"REG-030", # Cratera do Coração (Khar-Duum)
	&"CONT-04": &"REG-040"  # Trono da Aurora Morta (Nhal'Kora)
}

var _continents: Dictionary = {} # StringName -> ContinentData
var _world_ref: WeakRef = null

func _init(continents_dict: Dictionary = {}, world_manager: Object = null) -> void:
	_continents = continents_dict
	if world_manager != null:
		_world_ref = weakref(world_manager)

func set_continents(continents_dict: Dictionary) -> void:
	_continents = continents_dict

func has_continent(continent_id: StringName) -> bool:
	return _continents.has(String(continent_id)) or _continents.has(continent_id)

func get_continent(continent_id: StringName) -> ContinentData:
	var s_id := String(continent_id)
	if _continents.has(s_id):
		return _continents[s_id] as ContinentData
	if _continents.has(continent_id):
		return _continents[continent_id] as ContinentData
	return null

func all_continents() -> Array[ContinentData]:
	var result: Array[ContinentData] = []
	for c in _continents.values():
		result.append(c as ContinentData)
	return result

func continent_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for c_id in _continents.keys():
		result.append(StringName(String(c_id)))
	return result

func capital_of_continent(continent_id: StringName) -> StringName:
	return CONTINENT_CAPITALS.get(continent_id, &"")

func terminal_region_of_continent(continent_id: StringName) -> StringName:
	return CONTINENT_TERMINALS.get(continent_id, &"")

func regions_of_continent(continent_id: StringName) -> Array[RegionData]:
	var result: Array[RegionData] = []
	var world := _get_world()
	if world != null and world.has_method("regions"):
		for reg: RegionData in world.call("regions"):
			if reg.continent_id == continent_id:
				result.append(reg)
	return result

func get_continent_by_region(region_id: StringName) -> ContinentData:
	var world := _get_world()
	if world != null and world.has_method("get_region"):
		var reg: RegionData = world.call("get_region", region_id)
		if reg != null and not reg.continent_id.is_empty():
			return get_continent(reg.continent_id)
	return null

func is_intercontinental(from_region: StringName, to_region: StringName) -> bool:
	var cont_a := get_continent_by_region(from_region)
	var cont_b := get_continent_by_region(to_region)
	if cont_a == null or cont_b == null:
		return false
	return cont_a.id != cont_b.id

## Retorna porcentagem (0.0 a 1.0) de exploração de um continente com base nas regiões descobertas.
func calculate_continent_exploration(continent_id: StringName, discovered_regions: PackedStringArray) -> float:
	var cont_regions := regions_of_continent(continent_id)
	if cont_regions.is_empty():
		return 0.0
	var discovered_count := 0
	for reg in cont_regions:
		if discovered_regions.has(String(reg.id)):
			discovered_count += 1
	return float(discovered_count) / float(cont_regions.size())

func _get_world() -> Object:
	return _world_ref.get_ref() if _world_ref != null else null
