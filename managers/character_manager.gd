class_name CharacterManager
extends ManagerBase
## CharacterManager â€” perfis de personagem, seleÃ§Ã£o, progressÃ£o, descobertas.
##
## Responsabilidade: criar/validar/excluir personagens (validando raÃ§a,
## sub-raÃ§a e classe nos catÃ¡logos vivos), seleÃ§Ã£o ativa, progressÃ£o mÃ­nima
## e log de descobertas (demon/boss/region). Regras de combate/atributos
## PENDENTES (GAMEPLAY_SYSTEMS.md): apenas bookkeeping determinÃ­stico.
##
## IntegraÃ§Ã£o:
##   - Emite (EventBus): character_created/deleted/selected,
##     progression_changed, discovery_recorded.
##   - Consome (registry): Race (catÃ¡logo), Class (catÃ¡logo) â€” dinÃ¢mico.
##   - Save (contrato ManagerBase): personagens + seleÃ§Ã£o + descobertas.
## ServiÃ§o: registro "Character" (criado por GameManager).

const KEY: StringName = SystemNames.CHARACTER

## Expõe a chave constante (constantes não são sobrescíveis em GDScript).
func system_key() -> StringName:
	return KEY

var _characters: Dictionary = {} # String(id) -> CharacterData
var _selected_id := "" # String(id) ou ""
var _id_counter := 0

# --------------------------------------------------------------------- API --

## Cria personagem validando catÃ¡logos. Retorna null + log quando invÃ¡lido.
## Cria personagem validando catálogos. `appearance` (opcional, JSON-safe)
## é a personalização definida na criação (ver CharacterData.appearance).
## Retorna null + log quando inválido.
func create_character(display_name: String, race_id: StringName, subrace_id: StringName, class_id: StringName, appearance: Dictionary = {}) -> CharacterData:
	var issues := _validate_creation(display_name, race_id, subrace_id, class_id)
	if not issues.is_empty():
		for issue in issues:
			log_warn("CriaÃ§Ã£o recusada: %s" % issue)
		return null

	_id_counter += 1
	var character := CharacterData.new()
	character.id = StringName("CHAR-%03d" % _id_counter)
	character.display_name = display_name.strip_edges()
	character.race_id = race_id
	character.subrace_id = subrace_id
	character.class_id = class_id
	character.appearance = appearance
	_characters[String(character.id)] = character
	log_info("Personagem criado: %s (%s / %s / %s)." % [character.id, race_id, subrace_id, class_id])
	EventBus.character_created.emit(character.id)
	return character

func delete_character(character_id: StringName) -> bool:
	var key := String(character_id)
	if not _characters.has(key):
		return false
	if key == _selected_id:
		_selected_id = ""
	_characters.erase(key)
	log_info("Personagem excluÃ­do: %s." % character_id)
	EventBus.character_deleted.emit(character_id)
	return true

func get_character(character_id: StringName) -> CharacterData:
	return _characters.get(String(character_id)) as CharacterData

func characters() -> Array[CharacterData]:
	var result: Array[CharacterData] = []
	for value in _characters.values():
		result.append(value as CharacterData)
	return result

func character_count() -> int:
	return _characters.size()

func select_character(character_id: StringName) -> Error:
	var key := String(character_id)
	if not _characters.has(key):
		return ERR_DOES_NOT_EXIST
	if key == _selected_id:
		return ERR_ALREADY_IN_USE
	_selected_id = key
	log_info("Personagem selecionado: %s." % character_id)
	EventBus.character_selected.emit(character_id)
	return OK

func selected_character_id() -> StringName:
	return StringName(_selected_id)

func selected_character() -> CharacterData:
	return get_character(StringName(_selected_id))

## ProgressÃ£o mÃ­nima: xp/acÃºmulo com sinais; nÃ­veis/atributos pendentes.
func add_progression(character_id: StringName, kind: StringName, amount: int) -> Error:
	var character := get_character(character_id)
	if character == null:
		return ERR_DOES_NOT_EXIST
	if amount <= 0:
		return ERR_INVALID_PARAMETER
	if kind == &"experience":
		character.progression.add_experience(amount)
		EventBus.progression_changed.emit(character_id, kind, character.progression.experience)
		return OK
	log_warn("Tipo de progressÃ£o sem regra definida: %s (pendente de design)." % kind)
	return ERR_INVALID_PARAMETER

## Log de descobertas (consolidado por categorias StringName livres).
func record_discovery(character_id: StringName, category: StringName, ref_id: StringName) -> bool:
	var character := get_character(character_id)
	if character == null:
		return false
	var is_new := character.discoveries.record(category, ref_id)
	if is_new:
		log_info("Descoberta registrada: %s/%s (personagem %s)." % [category, ref_id, character_id])
		EventBus.discovery_recorded.emit(character_id, category, ref_id)
	return is_new

func is_discovered(character_id: StringName, category: StringName, ref_id: StringName) -> bool:
	var character := get_character(character_id)
	return character != null and character.discoveries.is_discovered(category, ref_id)

## Pactos do Personagem
func set_character_pact(character_id: StringName, pact_id: StringName) -> Error:
	var character := get_character(character_id)
	if character == null:
		return ERR_DOES_NOT_EXIST
	character.active_pact_id = pact_id
	if not character.pact_tiers.has(String(pact_id)):
		character.pact_tiers[String(pact_id)] = 1
	EventBus.ui_action_requested.emit(&"pact_bound")
	return OK

func get_character_pact(character_id: StringName) -> StringName:
	var character := get_character(character_id)
	return character.active_pact_id if character != null else &""

func get_character_pact_tier(character_id: StringName, pact_id: StringName) -> int:
	var character := get_character(character_id)
	if character == null:
		return 0
	return int(character.pact_tiers.get(String(pact_id), 1))

func evolve_character_pact(character_id: StringName, pact_id: StringName) -> int:
	var character := get_character(character_id)
	if character == null:
		return 0
	var key := String(pact_id)
	var current_tier: int = int(character.pact_tiers.get(key, 1))
	if current_tier >= 5:
		return current_tier
	current_tier += 1
	character.pact_tiers[key] = current_tier
	EventBus.ui_action_requested.emit(&"pact_evolved")
	return current_tier

# ------------------------------------------------------------------ INTERNO --

func _validate_creation(display_name: String, race_id: StringName, subrace_id: StringName, class_id: StringName) -> PackedStringArray:
	var issues := PackedStringArray()
	if display_name.strip_edges().is_empty():
		issues.append("nome vazio")
	var race := get_system(SystemNames.RACE)
	var class_service := get_system(SystemNames.CLASS)
	if race == null or not race.call("has_race", race_id):
		issues.append("raÃ§a fora do catÃ¡logo: %s" % race_id)
	if race == null or not race.call("has_subrace", subrace_id):
		issues.append("sub-raÃ§a fora do catÃ¡logo: %s" % subrace_id)
	elif not race.call("validate_link", subrace_id, race_id):
		issues.append("sub-raÃ§a '%s' nÃ£o pertence Ã  raÃ§a '%s'" % [subrace_id, race_id])
	if class_service == null or not class_service.call("has_class", class_id):
		issues.append("classe fora do catÃ¡logo: %s" % class_id)
	# Compatibilidade raça→classe (dados do catálogo): recusada somente quando
	# a raça DECLARA restrição (compatible_class_groups vazio = todas).
	if race != null and class_service != null \
			and race.call("has_race", race_id) and class_service.call("has_class", class_id) \
			and not race.call("can_use_class", race_id, class_id):
		issues.append("raça '%s' não é compatível com a classe '%s'" % [race_id, class_id])
	return issues

# ---------------------------------------------------------------------- SAVE --

func collect_save_data() -> Dictionary:
	var characters: Dictionary = {}
	for key in _characters.keys():
		characters[key] = (_characters[key] as CharacterData).to_dict()
	return {"characters": characters, "selected": _selected_id}

func apply_save_data(data: Dictionary) -> bool:
	_characters.clear()
	_selected_id = ""
	for key: String in (data.get("characters", {}) as Dictionary).keys():
		var character := CharacterData.new()
		if not character.from_dict(data["characters"][key]):
			return false
		_characters[key] = character
		_id_counter = maxi(_id_counter, _numeric_suffix(character.id))
	var selected := String(data.get("selected", ""))
	if selected != "" and _characters.has(selected):
		_selected_id = selected
	return true

func _numeric_suffix(character_id: StringName) -> int:
	var text := String(character_id)
	if text.begins_with("CHAR-"):
		return int(text.trim_prefix("CHAR-"))
	return 0

func verify() -> PackedStringArray:
	var issues := super()
	if _selected_id != "" and not _characters.has(_selected_id):
		issues.append("seleÃ§Ã£o aponta para personagem inexistente")
	for key in _characters.keys():
		var character := _characters[key] as CharacterData
		if String(character.id) != key:
			issues.append("id divergente no dicionÃ¡rio: %s" % key)
	return issues
