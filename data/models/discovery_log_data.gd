class_name DiscoveryLogData
extends Resource
## Registro de descobertas por categoria ("demon", "boss", "region", ...).
## Categorias: StringNames livres; o catálogo de demônios usa DemonManager
## como ponto de entrada do domínio, mas o log pertence ao CharacterManager.

var entries: Dictionary = {} # category: StringName -> Array[StringName] (ref ids)

func record(category: StringName, ref_id: StringName) -> bool:
	var key := String(category)
	var list: Array = entries.get(key, [])
	if list.has(String(ref_id)):
		return false
	list.append(String(ref_id))
	entries[key] = list
	return true

func is_discovered(category: StringName, ref_id: StringName) -> bool:
	var list: Array = entries.get(String(category), [])
	return list.has(String(ref_id))

func count(category: StringName) -> int:
	return entries.get(String(category), []).size()

func to_dict() -> Dictionary:
	return {"entries": entries}

func from_dict(data: Dictionary) -> bool:
	entries = data.get("entries", {})
	return true
