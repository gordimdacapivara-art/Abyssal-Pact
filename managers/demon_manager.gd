class_name DemonManager
extends ManagerBase
## DemonManager — catálogo das 200 criaturas demoníacas REGIONAIS.
##
## Responsabilidade: carregar/validar DemonData (data/content/demons, 50 por
## continente); consultas por região/continente/família; definição de spawn
## (dados prontos para a cena compartilhada enemies/creature.tscn); descobertas.
## Nenhuma IA ou combate vive aqui: a criatura é uma CENA reutilizável que lê
## DemonData (percepção, fases, resistências e recompensas são dados).
##
## Integração:
##   - Emite (EventBus): catalog_loaded / catalog_invalid, demon_spawn_requested.
##   - Consome (registry): Character (descobertas), World/Class (verificação
##     cruzada em verify(), após o boot de todos os sistemas).
##   - Save: descobertas pertencem ao CharacterManager (CharacterData).
## Serviço: registro "Demons" (criado por GameManager).

const KEY: StringName = SystemNames.DEMONS

## Expõe a chave constante (constantes não são sobrescíveis em GDScript).
func system_key() -> StringName:
	return KEY

const DEMONS_DIR := "res://data/content/demons"
const REGIONS_DIR := "res://data/content/regions"
const EXPECTED_DEMON_COUNT := 200
const DEMONS_PER_CONTINENT := 50
const CONTINENT_IDS: PackedStringArray = ["CONT-01", "CONT-02", "CONT-03", "CONT-04"]
const FAMILIES: PackedStringArray = DemonData.FAMILIES

var _demons: Dictionary = {} # String(id) -> DemonData
var _catalog_issues: PackedStringArray = PackedStringArray()

func initialize() -> void:
	super()
	load_catalog()

# --------------------------------------------------------------------- API --

func load_catalog() -> bool:
	_demons.clear()
	var issues := PackedStringArray()
	if not DirAccess.dir_exists_absolute(DEMONS_DIR):
		issues.append("diretório ausente: %s" % DEMONS_DIR)
	else:
		for file_name in DirAccess.get_files_at(DEMONS_DIR):
			if not file_name.ends_with(".tres"):
				continue
			var resource := load(DEMONS_DIR + "/" + file_name) as DemonData
			if resource == null:
				issues.append("recurso inválido (esperado DemonData): %s" % file_name)
				continue
			var data_id := String(resource.id)
			if data_id.is_empty():
				issues.append("id vazio em %s" % file_name)
				continue
			if not data_id.begins_with(Invariants.DEMON_ID_PREFIX):
				issues.append("id fora do prefixo regional '%s': %s" % [Invariants.DEMON_ID_PREFIX, data_id])
				continue
			if _demons.has(data_id):
				issues.append("demônio duplicado: %s" % data_id)
				continue
			_demons[data_id] = resource
	_validate_structure(issues)
	_catalog_issues = issues

	if issues.is_empty():
		log_info("Catálogo regional carregado: %d demônios." % _demons.size())
		EventBus.catalog_loaded.emit(&"demons", _demons.size())
		return true
	EventBus.catalog_invalid.emit(&"demons", issues)
	return false

func has_demon(demon_id: StringName) -> bool:
	return _demons.has(String(demon_id))

func get_demon(demon_id: StringName) -> DemonData:
	return _demons.get(String(demon_id)) as DemonData

func demons() -> Array[DemonData]:
	var result: Array[DemonData] = []
	for value in _demons.values():
		result.append(value as DemonData)
	return result

func demons_in_region(region_id: StringName) -> Array[DemonData]:
	var result: Array[DemonData] = []
	for demon in demons():
		if demon.region_id == region_id:
			result.append(demon)
	return result

func demons_in_continent(continent_id: StringName) -> Array[DemonData]:
	var result: Array[DemonData] = []
	for demon in demons():
		if demon.continent_id == continent_id:
			result.append(demon)
	return result

func demons_of_family(family: StringName) -> Array[DemonData]:
	var result: Array[DemonData] = []
	for demon in demons():
		if demon.family == family:
			result.append(demon)
	return result

## Contagem por continente: {"CONT-01": 50, ...}.
func count_by_continent() -> Dictionary:
	var counts := {}
	for continent_id in CONTINENT_IDS:
		counts[continent_id] = demons_in_continent(StringName(continent_id)).size()
	return counts

## Um representante por família (para testes/arena).
func representatives() -> Array[DemonData]:
	var result: Array[DemonData] = []
	for family in FAMILIES:
		var members := demons_of_family(StringName(family))
		if not members.is_empty():
			result.append(members[0])
	return result

func all_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for id in _demons.keys():
		ids.append(String(id))
	return ids

## Definição de spawn (dados + cena reutilizável + status do modelo).
func spawn_definition(demon_id: StringName) -> Dictionary:
	var demon := get_demon(demon_id)
	if demon == null:
		return {}
	return {
		"demon_id": String(demon.id),
		"data": demon,
		"scene": demon.placeholder_scene,
		"model_path": demon.model_path,
		"model_pending": demon.model_pending,
		"is_placeholder": not demon.has_model(),
	}

## Issues estruturais detectados na carga (para diagnóstico/testes).
func catalog_issues() -> PackedStringArray:
	return _catalog_issues

## Verificação CRUZADA (roda depois do boot, com World/Class disponíveis):
## região catalogada, continente coerente e habilidades existentes.
func integration_issues() -> PackedStringArray:
	var issues := PackedStringArray()
	var world := get_system(SystemNames.WORLD)
	var class_service := get_system(SystemNames.CLASS)
	for demon in demons():
		if world != null:
			if not world.call("has_region", demon.region_id):
				issues.append("%s: região ausente '%s'" % [demon.id, demon.region_id])
			else:
				var region: RegionData = world.call("get_region", demon.region_id)
				if region != null and region.continent_id != demon.continent_id:
					issues.append("%s: continente '%s' diverge da região '%s' (%s)" % [
						demon.id, demon.continent_id, demon.region_id, region.continent_id])
		if class_service != null:
			for ability_id in demon.ability_ids:
				if not class_service.call("has_ability", StringName(ability_id)):
					issues.append("%s: habilidade ausente '%s'" % [demon.id, ability_id])
	return issues

## Registra descoberta de criatura para um personagem (delegação ao domínio
## de personagem, onde o log vive). Retorna true quando é uma NOVA descoberta.
func register_discovery(character_id: StringName, demon_id: StringName) -> bool:
	if not has_demon(demon_id):
		log_warn("Descoberta de demônio desconhecido: %s" % demon_id)
		return false
	var character := require_system(SystemNames.CHARACTER)
	if character == null or not character.has_method("record_discovery"):
		return false
	return character.call("record_discovery", character_id, &"demon", demon_id)

## Pedido de spawn: dados prontos para a cena compartilhada de criatura.
func request_spawn(demon_id: StringName, region_id: StringName) -> Error:
	if not has_demon(demon_id):
		return ERR_DOES_NOT_EXIST
	EventBus.demon_spawn_requested.emit(demon_id, region_id)
	log_info("Spawn solicitado: %s em %s." % [demon_id, region_id])
	return OK

# ------------------------------------------------------------------ INTERNO --

func _validate_structure(issues: PackedStringArray) -> void:
	if _demons.size() != EXPECTED_DEMON_COUNT:
		issues.append("catálogo deve ter %d criaturas regionais, tem %d" % [EXPECTED_DEMON_COUNT, _demons.size()])
		return
	for number in range(1, EXPECTED_DEMON_COUNT + 1):
		var expected_id := "DEMON-%03d" % number
		if not _demons.has(expected_id):
			issues.append("id esperado ausente: %s" % expected_id)
			continue
		var demon := _demons[expected_id] as DemonData
		if demon.category != &"regional":
			issues.append("%s: categoria deve ser 'regional'" % expected_id)
		if not CONTINENT_IDS.has(String(demon.continent_id)):
			issues.append("%s: continente inválido '%s'" % [expected_id, demon.continent_id])
		if not String(demon.region_id).begins_with(Invariants.REGION_ID_PREFIX):
			issues.append("%s: região fora do prefixo '%s'" % [expected_id, Invariants.REGION_ID_PREFIX])
		if not FAMILIES.has(String(demon.family)):
			issues.append("%s: família inválida '%s'" % [expected_id, demon.family])
		if not DemonData.RARITIES.has(String(demon.rarity)):
			issues.append("%s: raridade inválida '%s'" % [expected_id, demon.rarity])
		if demon.health() <= 0.0:
			issues.append("%s: vida ausente/inválida" % expected_id)
		if demon.ability_ids.is_empty():
			issues.append("%s: sem habilidades" % expected_id)
		if demon.rewards.is_empty():
			issues.append("%s: sem recompensas" % expected_id)
		if demon.ai.is_empty() or not demon.ai.has("perception_radius"):
			issues.append("%s: configuração de IA incompleta" % expected_id)
		if demon.animations.is_empty():
			issues.append("%s: sem animações declaradas" % expected_id)
		if demon.model_path.is_empty():
			issues.append("%s: caminho de modelo ausente" % expected_id)
		elif ResourceLoader.exists(demon.model_path) == demon.model_pending:
			issues.append("%s: inconsistência model_pending vs arquivo '%s'" % [expected_id, demon.model_path])
	for continent_id in CONTINENT_IDS:
		var count := demons_in_continent(StringName(continent_id)).size()
		if count != DEMONS_PER_CONTINENT:
			issues.append("%s deve ter %d criaturas (tem %d)" % [continent_id, DEMONS_PER_CONTINENT, count])

func verify() -> PackedStringArray:
	var issues := super()
	issues.append_array(_catalog_issues)
	if _demons.is_empty():
		issues.append("catálogo regional vazio")
	if not _demons.is_empty() and _demons.size() != EXPECTED_DEMON_COUNT:
		issues.append("catálogo regional incompleto: %d/%d" % [_demons.size(), EXPECTED_DEMON_COUNT])
	issues.append_array(integration_issues())
	return issues
