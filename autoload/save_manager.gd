class_name SaveManager
extends ManagerBase
## SaveManager â€” persistÃªncia por slots em user://saves/.
##
## Formato: JSON versionado. Snapshot = contribuiÃ§Ãµes de cada gerenciador
## que adere ao contrato ManagerBase.collect_save_data()/apply_save_data().
## Categorias cobertas pela arquitetura: mundo privado, personagens,
## progressÃ£o, equipamentos, inventÃ¡rio, descobertas e missÃµes.
##
## IntegraÃ§Ã£o:
##   - Emite (EventBus): save_started/completed/failed, load_started/completed/failed.
##   - Consome (registry, na hora do uso): GameManager â†’ SystemRegistry â†’
##     contribuidores. Nenhuma referÃªncia direta a gerenciadores.
## Autoload: "Save".

const KEY: StringName = SystemNames.SAVE

## Expõe a chave constante (constantes não são sobrescíveis em GDScript).
func system_key() -> StringName:
	return KEY

const SAVE_DIR := "user://saves"
const SLOT_FILE := "%s/slot_%d.json"

var _last_error := ""

# --------------------------------------------------------------------- API --

## Salva o estado de todos os contribuidores no slot.
func save_slot(slot: int) -> Error:
	if slot < 0:
		return _fail_save(slot, "slot invÃ¡lido")
	EventBus.save_started.emit(slot)

	var snapshot := _build_snapshot(slot)
	if snapshot.is_empty():
		return _fail_save(slot, "snapshot vazio")
	var json_error := _validate_json_safe(snapshot)
	if json_error != "":
		return _fail_save(slot, "payload nÃ£o serializÃ¡vel: %s" % json_error)

	if _write_file(_slot_path(slot), snapshot) != OK:
		return _fail_save(slot, _last_error)
	log_info("Slot %d salvo (%d contribuiÃ§Ãµes)." % [slot, (snapshot["contributions"] as Dictionary).size()])
	EventBus.save_completed.emit(slot)
	return OK

## Carrega o slot e aplica as contribuiÃ§Ãµes aos gerenciadores vivos.
func load_slot(slot: int) -> Error:
	if slot < 0:
		return _fail_load(slot, "slot invÃ¡lido")
	EventBus.load_started.emit(slot)

	var snapshot := _read_file(_slot_path(slot))
	if snapshot.is_empty():
		return _fail_load(slot, _last_error if _last_error != "" else "arquivo ausente ou vazio")
	if not _is_valid_snapshot(snapshot):
		return _fail_load(slot, "formato de save invÃ¡lido")

	var contributions: Dictionary = snapshot["contributions"]
	for system_key: String in contributions.keys():
		var system := _registry.get_system(StringName(system_key))
		if system == null:
			return _fail_load(slot, "contribuidor ausente: %s" % system_key)
		if not system.call("apply_save_data", contributions[system_key]):
			return _fail_load(slot, "falha ao aplicar contribuiÃ§Ã£o de %s" % system_key)

	log_info("Slot %d carregado e aplicado." % slot)
	EventBus.load_completed.emit(slot)
	return OK

func slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(_slot_path(slot))

func delete_slot(slot: int) -> Error:
	var path := _slot_path(slot)
	if not FileAccess.file_exists(path):
		return ERR_FILE_NOT_FOUND
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	return OK

## Metadados leves do slot (sem aplicar contribuiÃ§Ãµes).
func read_slot_metadata(slot: int) -> Dictionary:
	if not slot_exists(slot):
		return {}
	var snapshot := _read_file(_slot_path(slot))
	if snapshot.is_empty():
		return {}
	return {
		"slot": int(snapshot.get("slot", slot)),
		"saved_at": String(snapshot.get("saved_at", "")),
		"format_version": int(snapshot.get("format_version", 0)),
		"contributions": (snapshot.get("contributions", {}) as Dictionary).keys(),
	}

func last_error() -> String:
	return _last_error

# ------------------------------------------------------------------ INTERNO --

func _build_snapshot(slot: int) -> Dictionary:
	var contributions := {}
	for system in _systems():
		var data: Dictionary = system.call("collect_save_data")
		if data.is_empty():
			continue # Contribuidores sem estado nÃ£o gravam seÃ§Ã£o.
		contributions[String(system.system_key())] = data
	if contributions.is_empty():
		return {}
	return {
		"format": Invariants.SAVE_FORMAT_ID,
		"format_version": Invariants.SAVE_FORMAT_VERSION,
		"slot": slot,
		"saved_at": Time.get_datetime_string_from_system(true),
		"contributions": contributions,
	}

## Contribuidores = sistemas no registry que implementam o contrato de save.
func _systems() -> Array[Node]:
	var contributors: Array[Node] = []
	for system in _registry.all_systems():
		if system.has_method("collect_save_data") and system.has_method("apply_save_data"):
			contributors.append(system)
	return contributors

func _slot_path(slot: int) -> String:
	return SLOT_FILE % [SAVE_DIR, slot]

func _write_file(path: String, snapshot: Dictionary) -> Error:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_last_error = "nÃ£o foi possÃ­vel abrir %s (erro %d)" % [path, FileAccess.get_open_error()]
		return ERR_CANT_OPEN
	file.store_string(JSON.stringify(snapshot, "\t"))
	file.close()
	return OK

func _read_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		_last_error = "arquivo ausente: %s" % path
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_last_error = "falha ao abrir %s" % path
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary):
		_last_error = "JSON invÃ¡lido em %s" % path
		return {}
	return parsed

func _is_valid_snapshot(snapshot: Dictionary) -> bool:
	return snapshot.get("format", "") == Invariants.SAVE_FORMAT_ID \
		and snapshot.get("format_version", 0) == Invariants.SAVE_FORMAT_VERSION \
		and snapshot.has("contributions")

## VerificaÃ§Ã£o bÃ¡sica: sÃ³ tipos JSON-safe podem ser gravados.
func _validate_json_safe(value: Variant, path := "$") -> String:
	if value == null or value is String or value is float or value is bool:
		return ""
	if value is int:
		return ""
	if value is Dictionary:
		for key: Variant in (value as Dictionary).keys():
			if not (key is String):
				return "chave nÃ£o-String em %s" % path
			var issue := _validate_json_safe(value[key], "%s.%s" % [path, key])
			if issue != "":
				return issue
		return ""
	if value is Array:
		for index in (value as Array).size():
			var issue := _validate_json_safe(value[index], "%s[%d]" % [path, index])
			if issue != "":
				return issue
		return ""
	return "tipo nÃ£o suportado em %s" % path

func _fail_save(slot: int, reason: String) -> Error:
	_last_error = reason
	log_error("Falha ao salvar slot %d: %s" % [slot, reason])
	EventBus.save_failed.emit(slot, reason)
	return FAILED

func _fail_load(slot: int, reason: String) -> Error:
	_last_error = reason
	log_error("Falha ao carregar slot %d: %s" % [slot, reason])
	EventBus.load_failed.emit(slot, reason)
	return FAILED

func verify() -> PackedStringArray:
	var issues := super()
	if _registry == null:
		issues.append("registry nÃ£o injetado (setup nÃ£o executado)")
	elif _systems().is_empty():
		issues.append("nenhum contribuidor de save registrado")
	if Invariants.SAVE_FORMAT_VERSION < 1:
		issues.append("versÃ£o de formato de save invÃ¡lida")
	return issues

func collect_save_data() -> Dictionary:
	return {} # O prÃ³prio SaveManager nÃ£o grava estado nesta etapa.
