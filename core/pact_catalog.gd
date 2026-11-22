class_name PactCatalog
extends RefCounted
## Catálogo de Pactos Abissais.
## Carrega e disponibiliza os pactos cadastrados em res://data/content/pacts/.

const PACTS_DIR := "res://data/content/pacts"

static var _cached_pacts: Dictionary = {} # String(id) -> PactData

static func load_pacts() -> Dictionary:
	_cached_pacts.clear()
	if not DirAccess.dir_exists_absolute(PACTS_DIR):
		return _cached_pacts

	for file_name in DirAccess.get_files_at(PACTS_DIR):
		if not file_name.ends_with(".tres"):
			continue
		var pact := load(PACTS_DIR + "/" + file_name) as PactData
		if pact != null and not String(pact.id).is_empty():
			_cached_pacts[String(pact.id)] = pact

	return _cached_pacts

static func get_pact(pact_id: StringName) -> PactData:
	if _cached_pacts.is_empty():
		load_pacts()
	return _cached_pacts.get(String(pact_id)) as PactData

static func has_pact(pact_id: StringName) -> bool:
	if _cached_pacts.is_empty():
		load_pacts()
	return _cached_pacts.has(String(pact_id))

static func pacts() -> Array[PactData]:
	if _cached_pacts.is_empty():
		load_pacts()
	var result: Array[PactData] = []
	for p in _cached_pacts.values():
		result.append(p as PactData)
	return result

static func pact_count() -> int:
	if _cached_pacts.is_empty():
		load_pacts()
	return _cached_pacts.size()
