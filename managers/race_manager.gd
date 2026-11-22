class_name RaceManager
extends ManagerBase
## RaceManager â€” catÃ¡logo de raÃ§as e sub-raÃ§as.
##
## Responsabilidade: carregar/validar RaceData e SubraceData de
## data/content/races e data/content/subraces; responder consultas do domÃ­nio.
## Regras de design NÃƒO sÃ£o inventadas aqui (RACES_AND_SUBRACES.md): efeitos
## mecÃ¢nicos de raÃ§a/sub-raÃ§a seguem pendentes.
##
## IntegraÃ§Ã£o:
##   - Emite (EventBus): catalog_loaded / catalog_invalid.
##   - Consumido via registry por: CharacterManager (criaÃ§Ã£o/validaÃ§Ã£o).
##   - Save: catÃ¡logo Ã© conteÃºdo do projeto, nÃ£o estado de save.
## ServiÃ§o: registro "Race" (criado por GameManager).

const KEY: StringName = SystemNames.RACE

## Expõe a chave constante (constantes não são sobrescíveis em GDScript).
func system_key() -> StringName:
	return KEY

const RACES_DIR := "res://data/content/races"
const SUBRACES_DIR := "res://data/content/subraces"

const EXPECTED_RACE_COUNT := 40
const EXPECTED_SUBRACE_COUNT := 80
const SUBRACES_PER_RACE := 2

var _races: Dictionary = {} # String(id) -> RaceData
var _subraces: Dictionary = {} # String(id) -> SubraceData

func initialize() -> void:
	super()
	load_catalog()

# --------------------------------------------------------------------- API --

func load_catalog() -> bool:
	_races.clear()
	_subraces.clear()
	var issues := PackedStringArray()
	_load_resources(RACES_DIR, _races, "raÃ§a", issues)
	_load_resources(SUBRACES_DIR, _subraces, "sub-raÃ§a", issues)
	_validate_links(issues)

	if issues.is_empty():
		log_info("CatÃ¡logo de raÃ§as carregado: %d raÃ§as, %d sub-raÃ§as." % [_races.size(), _subraces.size()])
		EventBus.catalog_loaded.emit(&"races", _races.size())
		EventBus.catalog_loaded.emit(&"subraces", _subraces.size())
		return true
	EventBus.catalog_invalid.emit(&"races", issues)
	return false

func has_race(race_id: StringName) -> bool:
	return _races.has(String(race_id))

func has_subrace(subrace_id: StringName) -> bool:
	return _subraces.has(String(subrace_id))

func get_race(race_id: StringName) -> RaceData:
	return _races.get(String(race_id)) as RaceData

func get_subrace(subrace_id: StringName) -> SubraceData:
	return _subraces.get(String(subrace_id)) as SubraceData

func races() -> Array[RaceData]:
	return _values(_races) as Array[RaceData]

func subraces() -> Array[SubraceData]:
	return _values(_subraces) as Array[SubraceData]

func subraces_of(race_id: StringName) -> Array[SubraceData]:
	var result: Array[SubraceData] = []
	for subrace in _values(_subraces):
		if subrace.parent_race_id == race_id:
			result.append(subrace)
	return result

## Valida o vÃ­nculo sub-raÃ§a â†’ raÃ§a-mÃ£e (usado na criaÃ§Ã£o de personagem).
func validate_link(subrace_id: StringName, race_id: StringName) -> bool:
	var subrace := get_subrace(subrace_id)
	return subrace != null and subrace.parent_race_id == race_id and has_race(race_id)

## Perfil visual MESCLADO (dados da raça + overrides da sub-raça) para o
## RaceVisualBuilder. Lança chaves da sub-raça sobre a raça.
func visual_profile_of(race_id: StringName, subrace_id: StringName) -> Dictionary:
	var race := get_race(race_id)
	var subrace := get_subrace(subrace_id)
	if race == null or subrace == null or not validate_link(subrace_id, race_id):
		return {}
	var profile := race.visual_profile.duplicate(true)
	for key: String in subrace.visual_overrides:
		profile[key] = subrace.visual_overrides[key]
	return profile

## Animações complementares mescladas (raça + sub-raça).
func animation_extras_of(race_id: StringName, subrace_id: StringName) -> Dictionary:
	var race := get_race(race_id)
	var subrace := get_subrace(subrace_id)
	if race == null or subrace == null or not validate_link(subrace_id, race_id):
		return {}
	var extras := race.animation_extras.duplicate(true)
	for key: String in subrace.animation_extras:
		extras[key] = subrace.animation_extras[key]
	return extras

## Compatibilidade com classes: raça com `compatible_class_groups` VAZIO é
## compatível com todas (estado PROVISÓRIO); caso preenchido, a classe deve
## pertencer a um dos grupos. Consulta o ClassManager via registry.
func can_use_class(race_id: StringName, class_id: StringName) -> bool:
	var race := get_race(race_id)
	if race == null:
		return false
	if race.compatible_class_groups.is_empty():
		return true
	var class_service := get_system(SystemNames.CLASS)
	if class_service == null:
		return false
	var class_data: ClassData = class_service.call("get_class_data", class_id)
	if class_data == null:
		return false
	return race.compatible_class_groups.has(String(class_data.group_id))

## Relatório de completude: {prototype: [], pending: [], complete: []}.
func completeness_report() -> Dictionary:
	var complete := PackedStringArray()
	var pending := PackedStringArray()
	var prototypes := PackedStringArray()
	for race_data: RaceData in _races.values():
		if race_data.is_prototype:
			prototypes.append(String(race_data.id))
		elif race_data.pending_fields.is_empty():
			complete.append(String(race_data.id))
		else:
			pending.append(String(race_data.id))
	return {"prototype": prototypes, "complete": complete, "pending": pending}

func all_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for id in _races.keys():
		ids.append(String(id))
	for id in _subraces.keys():
		ids.append(String(id))
	return ids

# ------------------------------------------------------------------ INTERNO --

func _load_resources(dir_path: String, target: Dictionary, label: String, issues: PackedStringArray) -> void:
	if not DirAccess.dir_exists_absolute(dir_path):
		issues.append("diretÃ³rio ausente: %s" % dir_path)
		return
	for file_name in DirAccess.get_files_at(dir_path):
		if not file_name.ends_with(".tres"):
			continue
		var resource: Resource = load(dir_path + "/" + file_name)
		if resource == null:
			issues.append("falha ao carregar %s" % file_name)
			continue
		if not (resource is Resource) or not resource.has_method("to_dict"):
			issues.append("recurso invÃ¡lido: %s" % file_name)
			continue
		var data_id := String(resource.get("id"))
		if data_id.is_empty():
			issues.append("id vazio em %s" % file_name)
			continue
		if target.has(data_id):
			issues.append("%s duplicado: %s" % [label, data_id])
			continue
		target[data_id] = resource

func _validate_links(issues: PackedStringArray) -> void:
	for subrace in _values(_subraces):
		if not has_race(subrace.parent_race_id):
			issues.append("sub-raÃ§a '%s' sem raÃ§a-mÃ£e '%s' no catÃ¡logo" % [subrace.id, subrace.parent_race_id])
	for race in _values(_races):
		for subrace_id in race.subrace_ids:
			if not has_subrace(StringName(subrace_id)):
				issues.append("raÃ§a '%s' referencia sub-raÃ§a ausente '%s'" % [race.id, subrace_id])

## Validação estrutural do catálogo completo (40 raças, 80 sub-raças, 2 por raça).
func _validate_catalog(issues: PackedStringArray) -> void:
	if _races.size() != EXPECTED_RACE_COUNT:
		issues.append("catálogo deve ter %d raças, tem %d" % [EXPECTED_RACE_COUNT, _races.size()])
		return
	if _subraces.size() != EXPECTED_SUBRACE_COUNT:
		issues.append("catálogo deve ter %d sub-raças, tem %d" % [EXPECTED_SUBRACE_COUNT, _subraces.size()])
	for number in range(1, EXPECTED_RACE_COUNT + 1):
		var expected_id := "RACE-%03d" % number
		if not _races.has(expected_id):
			issues.append("id esperado ausente: %s" % expected_id)
			continue
		var race_data := _races[expected_id] as RaceData
		var subs := race_data.subrace_ids
		if subs.size() != SUBRACES_PER_RACE:
			issues.append("%s deve ter exatamente %d sub-raças (tem %d)" % [
				expected_id, SUBRACES_PER_RACE, subs.size()])
		for subrace_id in subs:
			if not validate_link(StringName(subrace_id), race_data.id):
				issues.append("%s: sub-raça '%s' não vincula de volta" % [expected_id, subrace_id])
		if race_data.is_prototype:
			_validate_prototype(race_data, issues)
		elif race_data.pending_fields.is_empty():
			issues.append("%s não-protótipo sem campos pendentes declarados" % expected_id)

func _validate_prototype(race_data: RaceData, issues: PackedStringArray) -> void:
	if race_data.visual_profile.is_empty():
		issues.append("protótipo '%s' sem visual_profile" % race_data.id)
		return
	if String(race_data.visual_profile.get("model_glb", "")).is_empty():
		issues.append("protótipo '%s' sem modelo GLB do pipeline" % race_data.id)
	if not race_data.visual_profile.has("body_tint") or not race_data.visual_profile.has("head_tint"):
		issues.append("protótipo '%s' sem tintas de material" % race_data.id)
	var visual_variants := 0
	for subrace_id in race_data.subrace_ids:
		var subrace := get_subrace(StringName(subrace_id))
		if subrace == null:
			continue
		if not subrace.is_prototype:
			issues.append("sub-raça '%s' da raça protótipo deve ser protótipo" % subrace.id)
		if not subrace.visual_overrides.is_empty():
			visual_variants += 1
		else:
			issues.append("sub-raça protótipo '%s' sem diferenças visuais" % subrace.id)
	if visual_variants < 2:
		issues.append("protótipo '%s' precisa de 2 sub-raças com diferenças visuais" % race_data.id)

func _values(dictionary: Dictionary) -> Array:
	return dictionary.values()

func verify() -> PackedStringArray:
	var issues := super()
	if _races.is_empty():
		issues.append("catÃ¡logo de raÃ§as vazio")
	if _subraces.is_empty():
		issues.append("catÃ¡logo de sub-raÃ§as vazio")
	if not _races.is_empty() and _races.size() != EXPECTED_RACE_COUNT:
		issues.append("catálogo de raças incompleto: %d/%d" % [_races.size(), EXPECTED_RACE_COUNT])
	if not _subraces.is_empty() and _subraces.size() != EXPECTED_SUBRACE_COUNT:
		issues.append("catálogo de sub-raças incompleto: %d/%d" % [_subraces.size(), EXPECTED_SUBRACE_COUNT])
	return issues
