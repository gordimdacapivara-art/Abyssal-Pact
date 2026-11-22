class_name BossManager
extends ManagerBase
## BossManager — catálogo dos 30 chefes demoníacos + ciclo de encontro.
##
## Responsabilidade: carregar/validar BossData (data/content/bosses); fases,
## habilidades especiais, arena, interface, entrada cinematográfica e
## recompensas são DADOS lidos pela cena reutilizável enemies/boss.tscn e
## pelo componente BossEncounter. O combate em si é compartilhado.
##
## Integração:
##   - Emite (EventBus): catalog_loaded / catalog_invalid,
##     boss_encounter_started / boss_encounter_ended.
##   - Consome (registry): World/Class (verificação cruzada em verify()).
##   - Save: estado de derrotas ficará no domínio de progressão (pendente).
## Serviço: registro "Bosses" (criado por GameManager).

const KEY: StringName = SystemNames.BOSSES

## Expõe a chave constante (constantes não são sobrescíveis em GDScript).
func system_key() -> StringName:
	return KEY

const BOSSES_DIR := "res://data/content/bosses"
const EXPECTED_BOSS_COUNT := 30
const MIN_PHASES := 2

const WorldBossSystemScript := preload("res://core/world_boss_system.gd")
const WorldBossDataScript := preload("res://data/models/world_boss_data.gd")

var _bosses: Dictionary = {} # String(id) -> BossData
var _active_encounters: Dictionary = {} # String(boss_id) -> true
var _catalog_issues: PackedStringArray = PackedStringArray()
var _world_boss_system: Node = null

func initialize() -> void:
	super()
	load_catalog()
	_init_world_boss()

func _init_world_boss() -> void:
	if _world_boss_system == null:
		_world_boss_system = WorldBossSystemScript.new()
		_world_boss_system.name = "WorldBossSystem"
		add_child(_world_boss_system)

# --------------------------------------------------------------------- API --

func load_catalog() -> bool:
	_bosses.clear()
	_active_encounters.clear()
	var issues := PackedStringArray()
	if not DirAccess.dir_exists_absolute(BOSSES_DIR):
		issues.append("diretório ausente: %s" % BOSSES_DIR)
	else:
		for file_name in DirAccess.get_files_at(BOSSES_DIR):
			if not file_name.ends_with(".tres"):
				continue
			var resource := load(BOSSES_DIR + "/" + file_name) as BossData
			if resource == null:
				issues.append("recurso inválido (esperado BossData): %s" % file_name)
				continue
			var data_id := String(resource.id)
			if data_id.is_empty():
				issues.append("id vazio em %s" % file_name)
				continue
			if not data_id.begins_with(Invariants.BOSS_ID_PREFIX):
				issues.append("id fora do prefixo de chefes '%s': %s" % [Invariants.BOSS_ID_PREFIX, data_id])
				continue
			if _bosses.has(data_id):
				issues.append("chefe duplicado: %s" % data_id)
				continue
			_bosses[data_id] = resource
	_validate_structure(issues)
	_catalog_issues = issues

	if issues.is_empty():
		log_info("Catálogo de chefes carregado: %d chefes." % _bosses.size())
		EventBus.catalog_loaded.emit(&"bosses", _bosses.size())
		return true
	EventBus.catalog_invalid.emit(&"bosses", issues)
	return false

func has_boss(boss_id: StringName) -> bool:
	return _bosses.has(String(boss_id))

func get_boss(boss_id: StringName) -> BossData:
	return _bosses.get(String(boss_id)) as BossData

func bosses() -> Array[BossData]:
	var result: Array[BossData] = []
	for value in _bosses.values():
		result.append(value as BossData)
	return result

func bosses_in_region(region_id: StringName) -> Array[BossData]:
	var result: Array[BossData] = []
	for boss in bosses():
		if boss.region_id == region_id:
			result.append(boss)
	return result

func bosses_in_continent(continent_id: StringName) -> Array[BossData]:
	var result: Array[BossData] = []
	for boss in bosses():
		if boss.continent_id == continent_id:
			result.append(boss)
	return result

func phases_of(boss_id: StringName) -> Array:
	var boss := get_boss(boss_id)
	return [] if boss == null else boss.phases

func special_abilities_of(boss_id: StringName) -> PackedStringArray:
	var boss := get_boss(boss_id)
	return PackedStringArray() if boss == null else boss.special_abilities

func all_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for id in _bosses.keys():
		ids.append(String(id))
	return ids

## Definição de spawn do chefe (dados + cena reutilizável + status do modelo).
func spawn_definition(boss_id: StringName) -> Dictionary:
	var boss := get_boss(boss_id)
	if boss == null:
		return {}
	return {
		"boss_id": String(boss.id),
		"data": boss,
		"scene": boss.placeholder_scene,
		"model_path": boss.model_path,
		"model_pending": boss.model_pending,
		"is_placeholder": not boss.has_model(),
	}

func catalog_issues() -> PackedStringArray:
	return _catalog_issues

## Verificação CRUZADA (pós-boot): região/continente e habilidades existentes.
func integration_issues() -> PackedStringArray:
	var issues := PackedStringArray()
	var world := get_system(SystemNames.WORLD)
	var class_service := get_system(SystemNames.CLASS)
	for boss in bosses():
		if world != null:
			if not world.call("has_region", boss.region_id):
				issues.append("%s: região ausente '%s'" % [boss.id, boss.region_id])
			else:
				var region: RegionData = world.call("get_region", boss.region_id)
				if region != null and region.continent_id != boss.continent_id:
					issues.append("%s: continente '%s' diverge da região '%s' (%s)" % [
						boss.id, boss.continent_id, boss.region_id, region.continent_id])
		if class_service != null:
			for ability_id in boss.ability_ids:
				if not class_service.call("has_ability", StringName(ability_id)):
					issues.append("%s: habilidade ausente '%s'" % [boss.id, ability_id])
	return issues

## Inicia um encontro de chefe (interface; combate real na cena BossEncounter).
func begin_encounter(boss_id: StringName, participants: PackedInt64Array) -> Error:
	if not has_boss(boss_id):
		return ERR_DOES_NOT_EXIST
	if _active_encounters.has(String(boss_id)):
		return ERR_ALREADY_IN_USE
	if participants.size() > Invariants.MAX_PARTICIPANTS:
		log_warn("Encontro recusado: %d participantes > limite de %d." % [participants.size(), Invariants.MAX_PARTICIPANTS])
		return FAILED
	if participants.is_empty():
		return ERR_INVALID_PARAMETER
	_active_encounters[String(boss_id)] = true
	log_info("Encontro iniciado: %s (%d participantes)." % [boss_id, participants.size()])
	EventBus.boss_encounter_started.emit(boss_id, participants.size())
	return OK

## Encerra o encontro (vitória/derrota). Recompensas são dadas pelo
## BossEncounter (dados do BossData) antes de encerrar.
func end_encounter(boss_id: StringName, defeated: bool) -> Error:
	if not has_boss(boss_id):
		return ERR_DOES_NOT_EXIST
	if not _active_encounters.erase(String(boss_id)):
		return ERR_DOES_NOT_EXIST
	log_info("Encontro encerrado: %s (derrotado=%s)." % [boss_id, defeated])
	EventBus.boss_encounter_ended.emit(boss_id, defeated)
	return OK

func is_encounter_active(boss_id: StringName) -> bool:
	return _active_encounters.has(String(boss_id))

# ------------------------------------------------------------------ INTERNO --

func _validate_structure(issues: PackedStringArray) -> void:
	if _bosses.size() != EXPECTED_BOSS_COUNT:
		issues.append("catálogo deve ter %d chefes, tem %d" % [EXPECTED_BOSS_COUNT, _bosses.size()])
		return
	for number in range(1, EXPECTED_BOSS_COUNT + 1):
		var expected_id := "BOSS-%03d" % number
		if not _bosses.has(expected_id):
			issues.append("id esperado ausente: %s" % expected_id)
			continue
		var boss := _bosses[expected_id] as BossData
		if boss.category != &"boss":
			issues.append("%s: categoria deve ser 'boss'" % expected_id)
		if boss.health() <= 0.0:
			issues.append("%s: vida ausente/inválida" % expected_id)
		if boss.narrative_identity.strip_edges().is_empty():
			issues.append("%s: identidade narrativa ausente" % expected_id)
		if boss.arena.is_empty():
			issues.append("%s: arena ausente" % expected_id)
		if boss.phases.size() < MIN_PHASES:
			issues.append("%s: precisa de ao menos %d fases" % [expected_id, MIN_PHASES])
		if boss.phase_count != boss.phases.size():
			issues.append("%s: phase_count diverge das fases declaradas" % expected_id)
		if boss.special_abilities.is_empty():
			issues.append("%s: sem habilidades especiais" % expected_id)
		if boss.exclusive_animations.is_empty():
			issues.append("%s: sem animações exclusivas" % expected_id)
		if boss.boss_ui.is_empty():
			issues.append("%s: sem configuração de interface de chefe" % expected_id)
		if boss.entrance.is_empty():
			issues.append("%s: sem entrada cinematográfica" % expected_id)
		if boss.defeat_conditions.is_empty():
			issues.append("%s: sem condições de derrota" % expected_id)
		if boss.rewards.is_empty():
			issues.append("%s: sem recompensas" % expected_id)
		if boss.ai.is_empty():
			issues.append("%s: sem configuração de IA" % expected_id)
		if boss.model_path.is_empty():
			issues.append("%s: caminho de modelo ausente" % expected_id)
		elif ResourceLoader.exists(boss.model_path) == boss.model_pending:
			issues.append("%s: inconsistência model_pending vs arquivo '%s'" % [expected_id, boss.model_path])
		var previous_threshold := 1.01
		for phase: Dictionary in boss.phases:
			var threshold := float(phase.get("at_health_pct", -1.0))
			if threshold <= 0.0 or threshold > previous_threshold:
				issues.append("%s: limiar de fase inválido (%s)" % [expected_id, threshold])
			previous_threshold = threshold
			for ability_id: String in phase.get("abilities", []):
				if not boss.ability_ids.has(ability_id):
					issues.append("%s: fase usa habilidade fora do catálogo '%s'" % [expected_id, ability_id])

func verify() -> PackedStringArray:
	var issues := super()
	issues.append_array(_catalog_issues)
	if _bosses.is_empty():
		issues.append("catálogo de chefes vazio")
	if not _bosses.is_empty() and _bosses.size() != EXPECTED_BOSS_COUNT:
		issues.append("catálogo de chefes incompleto: %d/%d" % [_bosses.size(), EXPECTED_BOSS_COUNT])
	if not _active_encounters.is_empty():
		issues.append("encontros ativos após carga inicial (estado inconsistente)")
	issues.append_array(integration_issues())
	return issues

# ------------------------------------------------ WORLD BOSS: AZAROTH (PROMPT 01) --

func world_boss_system() -> Node:
	if _world_boss_system == null:
		_init_world_boss()
	return _world_boss_system

func world_boss_data() -> Resource:
	return world_boss_system().call("boss_data")

func world_boss_state() -> int:
	return int(world_boss_system().call("state"))

func world_boss_time_remaining() -> float:
	return float(world_boss_system().call("time_remaining_in_cycle"))

func is_world_boss_active() -> bool:
	return bool(world_boss_system().call("is_active"))

func is_world_boss_in_warning() -> bool:
	return bool(world_boss_system().call("is_warning"))

func collect_save_data() -> Dictionary:
	var payload: Dictionary = {}
	if _world_boss_system != null:
		payload["world_boss"] = _world_boss_system.call("collect_save_data")
	return payload

func apply_save_data(data: Dictionary) -> bool:
	if _world_boss_system != null and not data.is_empty():
		if data.has("world_boss"):
			_world_boss_system.call("apply_save_data", data.get("world_boss", {}))
		else:
			_world_boss_system.call("apply_save_data", data)
		return true
	return false
