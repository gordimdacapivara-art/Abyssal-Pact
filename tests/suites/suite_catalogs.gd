extends TestCase
## Suite CATALOGS — catálogos de raças, classes, demônios, chefes e mundo.

const CANONICAL_CONTINENTS: Array[String] = ["Veyrath", "Sylvaran", "Khar-Duum", "Nhal'Kora"]

func system_label() -> String:
	return "catalogs"

func execute() -> void:
	await _test_race_catalog()
	await _test_class_catalog()
	await _test_demon_catalog()
	await _test_boss_catalog()
	await _test_world_catalog()
	await _test_pact_resource()

func _test_race_catalog() -> void:
	section("RaceManager: raças, sub-raças e vínculo")
	var race_service := system(SystemNames.RACE)
	check_true(race_service.call("has_race", &"RACE-001"), "RACE-001 deve estar no catálogo")
	check_null(race_service.call("get_race", &"RACE-999"), "id inexistente retorna null")
	check_true(race_service.call("has_subrace", &"SUBRACE-001"), "SUBRACE-001 deve estar no catálogo")
	check_true(race_service.call("validate_link", &"SUBRACE-001", &"RACE-001"), "vínculo sub-raça→raça válido")
	check_false(race_service.call("validate_link", &"SUBRACE-001", &"RACE-999"), "vínculo com raça inexistente é inválido")
	var subraces: Array = race_service.call("subraces_of", &"RACE-001")
	check_eq(subraces.size(), 2, "raça deve ter 2 sub-raças (decisão desta fase)")
	var race: Resource = race_service.call("get_race", &"RACE-001")
	check_eq(race.display_name, "Raça RACE-001 (protótipo visual)", "nome do protótipo visual preservado")

func _test_class_catalog() -> void:
	section("ClassManager: classes e habilidades")
	var class_service := system(SystemNames.CLASS)
	check_true(class_service.call("has_class", &"CLASS-001"), "CLASS-001 deve estar no catálogo")
	check_not_null(class_service.call("get_class_data", &"CLASS-001"), "get_class retorna ClassData")
	check_true(class_service.call("has_ability", &"ABILITY-001"), "ABILITY-001 deve estar no catálogo")
	var abilities: Array = class_service.call("abilities_of", &"CLASS-001")
	check_eq(abilities.size(), 4, "protótipo Arcanista deve expor 4 habilidades (2 ativas + 2 passivas)")
	check_null(class_service.call("get_class_data", &"CLASS-999"), "classe inexistente retorna null")

func _test_demon_catalog() -> void:
	section("DemonManager: criaturas regionais (sem chefes)")
	var demons := system(SystemNames.DEMONS)
	check_true(demons.call("has_demon", &"DEMON-001"), "DEMON-001 deve estar no catálogo")
	var region_demons: Array = demons.call("demons_in_region", &"REG-001")
	check_eq(region_demons.size(), 5, "filtro por região deve funcionar (5 criaturas por região)")
	check_eq((demons.call("demons") as Array).size(), 200, "catálogo regional completo")
	var all_demons: Array = demons.call("demons")
	for demon in all_demons:
		check_false(String(demon.id).begins_with("BOSS-"), "catálogo regional não pode conter id de chefe")
	check_false(demons.call("register_discovery", &"CHAR-INEXISTENTE", &"DEMON-001"),
		"descoberta exige personagem existente")

func _test_boss_catalog() -> void:
	section("BossManager: chefes e ciclo de encontro")
	var bosses := system(SystemNames.BOSSES)
	check_true(bosses.call("has_boss", &"BOSS-001"), "BOSS-001 deve estar no catálogo")
	check_eq((bosses.call("bosses") as Array).size(), 30, "catálogo de chefes completo")
	check_false(bosses.call("is_encounter_active", &"BOSS-001"), "nenhum encontro ativo na carga")
	var waiter_start := capture(EventBus.boss_encounter_started)
	var waiter_end := capture(EventBus.boss_encounter_ended)
	check_err(bosses.call("begin_encounter", &"BOSS-001", PackedInt64Array([Invariants.HOST_PEER_ID, 2, 3])), OK,
		"encontro deve iniciar com participantes válidos")
	var started_args: Array = waiter_start.first()
	check_eq(int(started_args[1]), 3, "evento de início deve reportar 3 participantes")
	check_err(bosses.call("begin_encounter", &"BOSS-001", PackedInt64Array([1])), ERR_ALREADY_IN_USE,
		"encontro duplicado deve falhar")
	check_err(bosses.call("end_encounter", &"BOSS-001", true), OK, "encontro deve encerrar com vitória")
	var ended_args: Array = waiter_end.first()
	check_true(bool(ended_args[1]), "evento de fim deve reportar derrota do chefe")
	check_err(bosses.call("begin_encounter", &"BOSS-001", PackedInt64Array(range(9))), FAILED,
		"encontro com 9 participantes deve falhar (limite de 8)")

func _test_world_catalog() -> void:
	section("WorldManager: continentes canônicos e regiões")
	var world := system(SystemNames.WORLD)
	var continents: Array = world.call("continents")
	check_eq(continents.size(), 4, "exatamente 4 continentes confirmados")
	var names: Array[String] = []
	for continent in continents:
		names.append(continent.display_name)
	for canonical in CANONICAL_CONTINENTS:
		check_true(names.has(canonical), "continente canônico presente: %s" % canonical)
	check_true(world.call("has_region", &"REG-001"), "REG-001 placeholder registrado")
	var region: Resource = world.call("get_region", &"REG-001")
	check_eq(region.continent_id, &"CONT-01", "placeholder vinculado a continente catalogado")

func _test_pact_resource() -> void:
	section("PactData: estrutura preparada (sem gerenciador — pendente de design)")
	var pact := load("res://data/content/pacts/pact_001.tres") as PactData
	check_not_null(pact, "PactData placeholder carrega como Resource")
	check_eq(String(pact.id), "PACT-001", "id editorial preservado")
	check_true(pact.effects is Dictionary, "efeitos abertos (dicionário) até o design")
