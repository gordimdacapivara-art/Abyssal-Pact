class_name MonsterManager
extends RefCounted
## MonsterManager — Gerenciador do Catálogo de MONSTROS de Abyssal Pact.
##
## CATEGORIA INDEPENDENTE:
## Gerencia as 300 criaturas do bestiário de monstros em suas 10 subcategorias,
## desacoplado de DemonManager e BossManager.

const CATALOG_JSON_PATH := "res://data/content/monsters/monsters_300_catalog.json"
const MonsterDataScript := preload("res://data/models/monster_data.gd")

var _monsters: Dictionary = {} # String(id) -> MonsterData
var _by_subcategory: Dictionary = {} # StringName -> Array[MonsterData]
var _by_region: Dictionary = {} # StringName -> Array[MonsterData]
var _is_loaded: bool = false

func _init() -> void:
	load_catalog()

func load_catalog() -> bool:
	_monsters.clear()
	_by_subcategory.clear()
	_by_region.clear()

	for subcat in MonsterDataScript.SUBCATEGORIES:
		_by_subcategory[StringName(subcat)] = [] as Array

	if not FileAccess.file_exists(CATALOG_JSON_PATH):
		push_warning("MonsterManager: Catálogo JSON não encontrado em %s" % CATALOG_JSON_PATH)
		return false

	var file := FileAccess.open(CATALOG_JSON_PATH, FileAccess.READ)
	if file == null:
		push_error("MonsterManager: Falha ao abrir %s" % CATALOG_JSON_PATH)
		return false

	var json_str := file.get_as_text()
	var test_json := JSON.new()
	var parse_err := test_json.parse(json_str)
	if parse_err != OK:
		push_error("MonsterManager: Erro ao parsear JSON: %s" % test_json.get_error_message())
		return false

	var dict: Dictionary = test_json.data
	var list: Array = dict.get("monsters", [])

	for m_dict in list:
		var m_data = MonsterDataScript.new()
		if m_data.from_dict(m_dict):
			var m_id := String(m_data.id)
			_monsters[m_id] = m_data

			# Indexar por subcategoria
			var sub_key: StringName = m_data.subcategory
			if not _by_subcategory.has(sub_key):
				_by_subcategory[sub_key] = [] as Array
			_by_subcategory[sub_key].append(m_data)

			# Indexar por região
			var reg_key: StringName = m_data.region_id
			if not _by_region.has(reg_key):
				_by_region[reg_key] = [] as Array
			_by_region[reg_key].append(m_data)

	_is_loaded = true
	print("[Monsters] Catálogo carregado: %d monstros em 10 subcategorias." % _monsters.size())
	return true

func is_loaded() -> bool:
	return _is_loaded

func count() -> int:
	return _monsters.size()

func has_monster(monster_id: StringName) -> bool:
	return _monsters.has(String(monster_id))

func get_monster(monster_id: StringName) -> MonsterData:
	return _monsters.get(String(monster_id), null)

func get_all_monsters() -> Array[MonsterData]:
	var result: Array[MonsterData] = []
	for m in _monsters.values():
		result.append(m)
	return result

func get_monsters_by_subcategory(subcat: StringName) -> Array[MonsterData]:
	if _by_subcategory.has(subcat):
		var res: Array[MonsterData] = []
		res.assign(_by_subcategory[subcat])
		return res
	return []

func get_monsters_by_region(region_id: StringName) -> Array[MonsterData]:
	if _by_region.has(region_id):
		var res: Array[MonsterData] = []
		res.assign(_by_region[region_id])
		return res
	return []

func get_pilot_monsters() -> Array[MonsterData]:
	var result: Array[MonsterData] = []
	for m in _monsters.values():
		if m.is_pilot:
			result.append(m)
	return result
