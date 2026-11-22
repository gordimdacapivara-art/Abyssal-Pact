class_name PlatformStorageAdapter
extends RefCounted
## PlatformStorageAdapter — Camada de abstração de persistência multiplataforma.
##
## Permite desacoplar o salvamento do sistema de arquivos tradicional (user://)
## para suportar tanto o armazenamento local de PC quanto o Connected Storage (XGameSave)
## exigido pela certificação Xbox (XR-052: Connected Storage & User Association).
##
## Atende à regra do projeto:
## Não utiliza SDKs proprietários ou binários não autorizados; provê stubs e abstrações
## que podem ser compilados diretamente pelo Godot 4 ou substituídos por GDExtension oficial.

# Quota padrão da certificação Xbox para Connected Storage (64 MB por usuário)
const XBOX_CONNECTED_STORAGE_QUOTA_BYTES: int = 64 * 1024 * 1024

## Retorna o nome da implementação
func get_adapter_name() -> String:
	return "BasePlatformStorage"

## Salva um snapshot serializável em um slot
func save_data(slot: int, data: Dictionary) -> Error:
	return ERR_UNAVAILABLE

## Carrega o snapshot de um slot
func load_data(slot: int) -> Dictionary:
	return {}

## Verifica se o slot existe
func has_data(slot: int) -> bool:
	return false

## Remove os dados de um slot
func delete_data(slot: int) -> Error:
	return ERR_UNAVAILABLE

## Lista todos os slots disponíveis
func list_slots() -> Array[int]:
	return []

## Quota total suportada em bytes (-1 se ilimitado)
func get_quota_bytes() -> int:
	return -1

## Espaço utilizado em bytes
func get_used_bytes() -> int:
	return 0

## Informa se os dados possuem sincronização em nuvem ativa
func is_cloud_synced() -> bool:
	return false

# =========================================================================
# Implementação 1: Armazenamento Local (PC Windows / Dev)
# =========================================================================

class LocalStorageAdapter extends PlatformStorageAdapter:
	var base_directory: String = "user://saves"
	var file_pattern: String = "%s/slot_%d.json"

	func _init(p_dir: String = "user://saves") -> void:
		base_directory = p_dir

	func get_adapter_name() -> String:
		return "PC_LocalStorage"

	func _get_path(slot: int) -> String:
		return file_pattern % [base_directory, slot]

	func save_data(slot: int, data: Dictionary) -> Error:
		if slot < 0:
			return ERR_INVALID_PARAMETER
		DirAccess.make_dir_recursive_absolute(base_directory)
		var path := _get_path(slot)
		var file := FileAccess.open(path, FileAccess.WRITE)
		if file == null:
			return FileAccess.get_open_error()
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
		return OK

	func load_data(slot: int) -> Dictionary:
		var path := _get_path(slot)
		if not FileAccess.file_exists(path):
			return {}
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			return {}
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		file.close()
		if parsed is Dictionary:
			return parsed
		return {}

	func has_data(slot: int) -> bool:
		return FileAccess.file_exists(_get_path(slot))

	func delete_data(slot: int) -> Error:
		var path := _get_path(slot)
		if not FileAccess.file_exists(path):
			return ERR_DOES_NOT_EXIST
		return DirAccess.remove_absolute(path)

	func list_slots() -> Array[int]:
		var slots: Array[int] = []
		var dir := DirAccess.open(base_directory)
		if dir == null:
			return slots
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.begins_with("slot_") and file_name.ends_with(".json"):
				var raw_num := file_name.trim_prefix("slot_").trim_suffix(".json")
				if raw_num.is_valid_int():
					slots.append(raw_num.to_int())
			file_name = dir.get_next()
		dir.list_dir_end()
		slots.sort()
		return slots

	func get_used_bytes() -> int:
		var total_bytes: int = 0
		var dir := DirAccess.open(base_directory)
		if dir == null:
			return 0
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var file_path := "%s/%s" % [base_directory, file_name]
				var f := FileAccess.open(file_path, FileAccess.READ)
				if f != null:
					total_bytes += f.get_length()
					f.close()
			file_name = dir.get_next()
		dir.list_dir_end()
		return total_bytes

# =========================================================================
# Implementação 2: Xbox Connected Storage (XGameSave Stub / GDK Contract)
# =========================================================================

class XboxConnectedStorageAdapterStub extends PlatformStorageAdapter:
	## Representação simulada do XUser e Contêiner do Xbox GDK (XR-052)
	var active_xuid: String = "XUID_MOCK_CONSOLE_USER_001"
	var container_name: String = "AbyssalPact_SaveContainer"
	var simulated_storage: Dictionary = {} # slot -> Dictionary
	var quota_limit_bytes: int = XBOX_CONNECTED_STORAGE_QUOTA_BYTES

	func _init(p_xuid: String = "XUID_CONSOLE_DEFAULT") -> void:
		active_xuid = p_xuid

	func get_adapter_name() -> String:
		return "Xbox_ConnectedStorage_GDK_Stub"

	func save_data(slot: int, data: Dictionary) -> Error:
		if slot < 0:
			return ERR_INVALID_PARAMETER
		# Validação estrita de quota (Microsoft XR-052)
		var json_str := JSON.stringify(data)
		var data_size := json_str.to_utf8_buffer().size()
		if get_used_bytes() + data_size > quota_limit_bytes:
			push_error("Xbox Connected Storage Quota Exceeded (Max: %d bytes)" % quota_limit_bytes)
			return ERR_OUT_OF_MEMORY
		
		simulated_storage[slot] = data.duplicate(true)
		return OK

	func load_data(slot: int) -> Dictionary:
		if simulated_storage.has(slot):
			return (simulated_storage[slot] as Dictionary).duplicate(true)
		return {}

	func has_data(slot: int) -> bool:
		return simulated_storage.has(slot)

	func delete_data(slot: int) -> Error:
		if not simulated_storage.has(slot):
			return ERR_DOES_NOT_EXIST
		simulated_storage.erase(slot)
		return OK

	func list_slots() -> Array[int]:
		var slots: Array[int] = []
		for k in simulated_storage.keys():
			slots.append(int(k))
		slots.sort()
		return slots

	func get_quota_bytes() -> int:
		return quota_limit_bytes

	func get_used_bytes() -> int:
		var total_bytes: int = 0
		for slot in simulated_storage.keys():
			var s: String = JSON.stringify(simulated_storage[slot])
			total_bytes += s.to_utf8_buffer().size()
		return total_bytes

	func is_cloud_synced() -> bool:
		return true # Xbox Connected Storage sincroniza automaticamente com Xbox Cloud Saves
