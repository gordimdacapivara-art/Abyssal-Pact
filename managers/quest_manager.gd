class_name QuestManager
extends ManagerBase
## QuestManager â€” catÃ¡logo de missÃµes + diÃ¡rio vivos por personagem.
##
## Responsabilidade: carregar QuestData (data/content/quests); aceitar,
## progredir, concluir e abandonar missÃµes com verificaÃ§Ãµes bÃ¡sicas.
## Autoria de missÃµes, narrativa e estado compartilhado em multiplayer
## PENDENTES (GAMEPLAY_SYSTEMS.md): a mÃ¡quina de estados aqui Ã© mÃ­nima e
## determinÃ­stica (aceita â†’ objetivos â†’ concluÃ­da/abandonada).
##
## IntegraÃ§Ã£o:
##   - Emite (EventBus): catalog_loaded / catalog_invalid, quest_accepted,
##     quest_abandoned, objective_progress, quest_completed.
##   - Consome (registry): nenhum (diÃ¡rio Ã© criado sob demanda por id).
##   - Save (contrato ManagerBase): diÃ¡rios por personagem (QuestLogData).
## ServiÃ§o: registro "Quests" (criado por GameManager).

const KEY: StringName = SystemNames.QUESTS

## Expõe a chave constante (constantes não são sobrescíveis em GDScript).
func system_key() -> StringName:
	return KEY

const QUESTS_DIR := "res://data/content/quests"

const STATE_ACTIVE := &"active"
const STATE_COMPLETED := &"completed"
const STATE_ABANDONED := &"abandoned"

var _quests: Dictionary = {} # String(id) -> QuestData
var _logs: Dictionary = {} # String(character_id) -> QuestLogData

func initialize() -> void:
	super()
	load_catalog()

# ------------------------------------------------------------------ CATÃLOGO --

func load_catalog() -> bool:
	_quests.clear()
	var issues := PackedStringArray()
	if not DirAccess.dir_exists_absolute(QUESTS_DIR):
		issues.append("diretÃ³rio ausente: %s" % QUESTS_DIR)
	else:
		for file_name in DirAccess.get_files_at(QUESTS_DIR):
			if not file_name.ends_with(".tres"):
				continue
			var resource := load(QUESTS_DIR + "/" + file_name) as QuestData
			if resource == null:
				issues.append("recurso invÃ¡lido (esperado QuestData): %s" % file_name)
				continue
			var data_id := String(resource.id)
			if data_id.is_empty():
				issues.append("id vazio em %s" % file_name)
				continue
			if resource.get_objective_ids().is_empty():
				issues.append("missÃ£o '%s' sem objetivos" % data_id)
				continue
			for objective_id in resource.get_objective_ids():
				if resource.get_objective_required(objective_id) < 1:
					issues.append("objetivo '%s' da missÃ£o '%s' sem meta vÃ¡lida" % [objective_id, data_id])
			if _quests.has(data_id):
				issues.append("missÃ£o duplicada: %s" % data_id)
				continue
			_quests[data_id] = resource

	if issues.is_empty():
		log_info("CatÃ¡logo de missÃµes carregado: %d missÃµes." % _quests.size())
		EventBus.catalog_loaded.emit(&"quests", _quests.size())
		return true
	EventBus.catalog_invalid.emit(&"quests", issues)
	return false

func has_quest(quest_id: StringName) -> bool:
	return _quests.has(String(quest_id))

func get_quest(quest_id: StringName) -> QuestData:
	return _quests.get(String(quest_id)) as QuestData

func quests() -> Array[QuestData]:
	var result: Array[QuestData] = []
	for value in _quests.values():
		result.append(value as QuestData)
	return result

func quests_of_category(p_category: StringName) -> Array[QuestData]:
	var result: Array[QuestData] = []
	for quest in quests():
		if quest.category == p_category:
			result.append(quest)
	return result

# -------------------------------------------------------------------- DIÃRIO --

func log_of(character_id: StringName) -> QuestLogData:
	var key := String(character_id)
	if key.is_empty():
		return null
	if not _logs.has(key):
		var quest_log := QuestLogData.new()
		quest_log.character_id = character_id
		_logs[key] = quest_log
	return _logs[key] as QuestLogData

func active_quests(character_id: StringName) -> Array[QuestEntryData]:
	var quest_log := log_of(character_id)
	return quest_log.entries_in_state(STATE_ACTIVE) if quest_log != null else []

func quest_state(character_id: StringName, quest_id: StringName) -> StringName:
	var quest_log := log_of(character_id)
	if quest_log == null:
		return &""
	var entry := quest_log.find_entry(quest_id)
	return entry.state if entry != null else &""

# ------------------------------------------------------------------- FLUXO --

func accept_quest(character_id: StringName, quest_id: StringName) -> Error:
	if not has_quest(quest_id):
		return ERR_DOES_NOT_EXIST
	var quest_log := log_of(character_id)
	if quest_log == null:
		return ERR_INVALID_PARAMETER
	if quest_log.find_entry(quest_id) != null:
		return ERR_ALREADY_IN_USE
	var entry := QuestEntryData.new()
	entry.quest_id = quest_id
	entry.state = STATE_ACTIVE
	for objective_id in get_quest(quest_id).get_objective_ids():
		entry.progress[String(objective_id)] = 0
	quest_log.entries.append(entry)
	log_info("MissÃ£o aceita: %s (personagem %s)." % [quest_id, character_id])
	EventBus.quest_accepted.emit(character_id, quest_id)
	return OK

func abandon_quest(character_id: StringName, quest_id: StringName) -> Error:
	var entry := _require_active_entry(character_id, quest_id)
	if entry == null:
		return ERR_DOES_NOT_EXIST
	entry.state = STATE_ABANDONED
	log_info("MissÃ£o abandonada: %s." % quest_id)
	EventBus.quest_abandoned.emit(character_id, quest_id)
	return OK

## Progresso de objetivo, clampado Ã  meta. Conclui a missÃ£o quando todos os
## objetivos completam (estado mÃ­nimo; regras de narrativa pendentes).
func progress_objective(character_id: StringName, quest_id: StringName, objective_id: StringName, amount: int = 1) -> Error:
	var entry := _require_active_entry(character_id, quest_id)
	if entry == null:
		return ERR_DOES_NOT_EXIST
	var quest := get_quest(quest_id)
	if not quest.get_objective_ids().has(String(objective_id)):
		return ERR_INVALID_PARAMETER
	if amount <= 0:
		return ERR_INVALID_PARAMETER

	var required := quest.get_objective_required(objective_id)
	var key := String(objective_id)
	var value := mini(int(entry.progress.get(key, 0)) + amount, required)
	entry.progress[key] = value
	EventBus.objective_progress.emit(character_id, quest_id, objective_id, value, required)

	if entry.all_objectives_complete(quest):
		entry.state = STATE_COMPLETED
		log_info("MissÃ£o concluÃ­da: %s." % quest_id)
		EventBus.quest_completed.emit(character_id, quest_id)
	return OK

# ------------------------------------------------------------------ INTERNO --

func _require_active_entry(character_id: StringName, quest_id: StringName) -> QuestEntryData:
	var quest_log := log_of(character_id)
	if quest_log == null:
		return null
	var entry := quest_log.find_entry(quest_id)
	if entry == null or entry.state != STATE_ACTIVE:
		return null
	return entry

# ---------------------------------------------------------------------- SAVE --

func collect_save_data() -> Dictionary:
	var logs: Dictionary = {}
	for key in _logs.keys():
		logs[key] = (_logs[key] as QuestLogData).to_dict()
	return {"quest_logs": logs}

func apply_save_data(data: Dictionary) -> bool:
	_logs.clear()
	for key: String in (data.get("quest_logs", {}) as Dictionary).keys():
		var quest_log := QuestLogData.new()
		if not quest_log.from_dict(data["quest_logs"][key]):
			return false
		_logs[key] = quest_log
	return true

func verify() -> PackedStringArray:
	var issues := super()
	if _quests.is_empty():
		issues.append("catÃ¡logo de missÃµes vazio")
	for key in _logs.keys():
		var quest_log := _logs[key] as QuestLogData
		for entry in quest_log.entries:
			if not has_quest(entry.quest_id):
				issues.append("missÃ£o fora do catÃ¡logo no diÃ¡rio de '%s': %s" % [key, entry.quest_id])
	return issues
