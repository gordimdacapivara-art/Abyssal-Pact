extends TestCase
## Suite BESTIARY — 200 demônios regionais + 30 chefes, integração de dados,
## modelos pendentes/placeholders e runtime das 6 famílias + encontro de chefe.

const CREATURE_SCENE := "res://enemies/creature.tscn"
const BOSS_ENCOUNTER_SCENE := "res://enemies/boss_encounter.tscn"
const CONTINENTS: Array[String] = ["CONT-01", "CONT-02", "CONT-03", "CONT-04"]
const FAMILIES: Array[String] = ["brute", "stalker", "caster", "swarm", "flyer", "sentinel"]
const RARITY_COUNTS := {"common": 120, "uncommon": 40, "rare": 20, "elite": 20}
const BOSS_CONTINENT_COUNTS := {"CONT-01": 8, "CONT-02": 8, "CONT-03": 7, "CONT-04": 7}

var _runtime_root: Node = null

func system_label() -> String:
	return "bestiary"

func execute() -> void:
	await _test_demon_catalog()
	await _test_boss_catalog()
	await _test_family_runtime()
	await _test_creature_ai()
	await _test_boss_encounter_flow()
	await _test_monsters_independent_catalog()

# --------------------------------------------------------------- catálogo ---

func _test_demon_catalog() -> void:
	section("catálogo regional: 200 registros, 50 por continente, 5 por região")
	var demons := system(SystemNames.DEMONS) as DemonManager
	var world := system(SystemNames.WORLD) as WorldManager
	var class_service := system(SystemNames.CLASS) as ClassManager
	check_eq(demons.demons().size(), 200, "catálogo deve ter exatamente 200 demônios regionais")
	check_true(demons.catalog_issues().is_empty(),
		"carga sem issues estruturais: %s" % "; ".join(demons.catalog_issues().slice(0, 5)))
	for number in range(1, 201):
		check_true(demons.has_demon(StringName("DEMON-%03d" % number)),
			"id regional deve existir: DEMON-%03d" % number)
	for continent_id in CONTINENTS:
		check_eq(demons.demons_in_continent(StringName(continent_id)).size(), 50,
			"%s deve ter 50 criaturas regionais" % continent_id)

	var issues := PackedStringArray()
	var rarity_counts := {}
	for rarity in RARITY_COUNTS.keys():
		rarity_counts[rarity] = 0
	var region_counts := {}
	for demon in demons.demons():
		var label := String(demon.id)
		if not String(demon.id).begins_with("DEMON-"):
			issues.append("%s: prefixo regional inválido" % label)
		if String(demon.display_name).strip_edges().is_empty():
			issues.append("%s: nome vazio" % label)
		if not String(demon.display_name).contains("editorial"):
			issues.append("%s: nome sem marca editorial" % label)
		if String(demon.description).strip_edges().is_empty():
			issues.append("%s: descrição vazia" % label)
		if demon.category != &"regional":
			issues.append("%s: categoria '%s' (esperado regional)" % [label, demon.category])
		if not CONTINENTS.has(String(demon.continent_id)):
			issues.append("%s: continente inválido '%s'" % [label, demon.continent_id])
		if not world.has_region(demon.region_id):
			issues.append("%s: região ausente '%s'" % [label, demon.region_id])
		else:
			var region := world.get_region(demon.region_id)
			if region.continent_id != demon.continent_id:
				issues.append("%s: continente diverge da região %s" % [label, demon.region_id])
		if not FAMILIES.has(String(demon.family)):
			issues.append("%s: família inválida '%s'" % [label, demon.family])
		if not RARITY_COUNTS.has(String(demon.rarity)):
			issues.append("%s: raridade inválida '%s'" % [label, demon.rarity])
		else:
			rarity_counts[String(demon.rarity)] += 1
		for stat_key in ["max_health", "damage", "defense", "move_speed", "attack_range", "attack_cooldown"]:
			if not demon.stats.has(stat_key):
				issues.append("%s: atributo ausente '%s'" % [label, stat_key])
		if demon.health() <= 0.0:
			issues.append("%s: vida inválida" % label)
		if demon.resistances.is_empty():
			issues.append("%s: sem resistências" % label)
		if demon.ability_ids.is_empty():
			issues.append("%s: sem habilidades" % label)
		for ability_id in demon.ability_ids:
			if not class_service.has_ability(StringName(ability_id)):
				issues.append("%s: habilidade ausente '%s'" % [label, ability_id])
		if demon.xp_reward() <= 0 or demon.gold_reward() <= 0:
			issues.append("%s: recompensas inválidas" % label)
		if demon.animations.is_empty():
			issues.append("%s: sem animações" % label)
		for animation_key in ["idle", "walk", "attack", "hurt", "death"]:
			if not demon.animations.has(animation_key):
				issues.append("%s: animação ausente '%s'" % [label, animation_key])
		if demon.ai.is_empty():
			issues.append("%s: sem configuração de IA" % label)
		else:
			for ai_key in ["perception_radius", "aggro_radius", "deaggro_radius", "attack_range", "attack_cooldown", "respawn_enabled"]:
				if not demon.ai.has(ai_key):
					issues.append("%s: IA sem '%s'" % [label, ai_key])
		if demon.model_path.is_empty():
			issues.append("%s: caminho de modelo ausente" % label)
		elif not demon.model_path.begins_with("res://assets/models/demons/"):
			issues.append("%s: modelo fora da convenção do pipeline" % label)
		if not demon.model_pending:
			issues.append("%s: modelo declarado final sem GLB auditado" % label)
		if ResourceLoader.exists(demon.model_path):
			issues.append("%s: model_pending=true mas o GLB existe" % label)
		if not ResourceLoader.exists(demon.placeholder_scene):
			issues.append("%s: cena placeholder ausente" % label)
		region_counts[String(demon.region_id)] = int(region_counts.get(String(demon.region_id), 0)) + 1
	check_true(issues.is_empty(), "200 registros válidos (identidade/região/atributos): %s" % "; ".join(issues.slice(0, 6)))
	check_eq(region_counts.size(), 40, "as 40 regiões devem ter criaturas")
	var bad_regions := PackedStringArray()
	for region_id: String in region_counts.keys():
		if int(region_counts[region_id]) != 5:
			bad_regions.append("%s=%d" % [region_id, int(region_counts[region_id])])
	check_true(bad_regions.is_empty(), "5 criaturas por região: %s" % ", ".join(bad_regions.slice(0, 5)))
	for rarity: String in RARITY_COUNTS.keys():
		check_eq(int(rarity_counts[rarity]), int(RARITY_COUNTS[rarity]), "distribuição de raridade '%s'" % rarity)
	check_eq(demons.representatives().size(), 6, "um representante por família de combate")
	for family in FAMILIES:
		check_true(demons.demons_of_family(StringName(family)).size() >= 30,
			"família '%s' deve ter representantes no catálogo" % family)
	var counts := demons.count_by_continent()
	for continent_id in CONTINENTS:
		check_eq(int(counts.get(continent_id, 0)), 50, "contagem por continente '%s'" % continent_id)

# ------------------------------------------------------------- chefes ------

func _test_boss_catalog() -> void:
	section("catálogo de chefes: 30 registros, fases, arena, UI e recompensas")
	var bosses := system(SystemNames.BOSSES) as BossManager
	var world := system(SystemNames.WORLD) as WorldManager
	var class_service := system(SystemNames.CLASS) as ClassManager
	check_eq(bosses.bosses().size(), 30, "catálogo deve ter exatamente 30 chefes")
	check_true(bosses.catalog_issues().is_empty(),
		"carga sem issues estruturais: %s" % "; ".join(bosses.catalog_issues().slice(0, 5)))
	var issues := PackedStringArray()
	var continent_counts := {}
	for boss in bosses.bosses():
		var label := String(boss.id)
		if not String(boss.id).begins_with("BOSS-"):
			issues.append("%s: prefixo de chefe inválido" % label)
		if String(boss.display_name).strip_edges().is_empty() or not String(boss.display_name).contains("editorial"):
			issues.append("%s: nome editorial ausente" % label)
		if not String(boss.narrative_identity).contains("PENDENTE"):
			issues.append("%s: identidade narrativa não marcada como pendente" % label)
		if boss.category != &"boss":
			issues.append("%s: categoria '%s'" % [label, boss.category])
		if not BossData.RARITIES.has(String(boss.rarity)):
			issues.append("%s: raridade de chefe inválida" % label)
		if not CONTINENTS.has(String(boss.continent_id)):
			issues.append("%s: continente inválido" % label)
		else:
			continent_counts[String(boss.continent_id)] = int(continent_counts.get(String(boss.continent_id), 0)) + 1
		if not world.has_region(boss.region_id):
			issues.append("%s: região/arena ausente '%s'" % [label, boss.region_id])
		elif world.get_region(boss.region_id).continent_id != boss.continent_id:
			issues.append("%s: continente diverge da região" % label)
		if boss.arena.is_empty() or not boss.arena.has("name") or float(boss.arena.get("radius", 0.0)) <= 0.0:
			issues.append("%s: arena incompleta" % label)
		if boss.health() <= 0.0:
			issues.append("%s: vida inválida" % label)
		if boss.resistances.is_empty():
			issues.append("%s: sem resistências" % label)
		if boss.phases.size() != 3 or boss.phase_count != 3:
			issues.append("%s: deve ter 3 fases" % label)
		var expected_thresholds := [1.0, 0.66, 0.33]
		for phase_index in boss.phases.size():
			var phase: Dictionary = boss.phases[phase_index]
			var threshold := float(phase.get("at_health_pct", -1.0))
			if absf(threshold - float(expected_thresholds[phase_index])) > 0.001:
				issues.append("%s: limiar da fase %d incorreto" % [label, phase_index + 1])
			if String(phase.get("behavior", "")).is_empty():
				issues.append("%s: fase sem comportamento" % label)
			if Array(phase.get("abilities", [])).is_empty():
				issues.append("%s: fase sem habilidades" % label)
		if boss.special_abilities.is_empty():
			issues.append("%s: sem habilidades especiais" % label)
		for ability_id in boss.special_abilities:
			if not class_service.has_ability(StringName(ability_id)):
				issues.append("%s: habilidade especial ausente '%s'" % [label, ability_id])
			if not boss.ability_ids.has(ability_id):
				issues.append("%s: especial fora de ability_ids '%s'" % [label, ability_id])
		for animation_key in ["entrance", "phase_2", "phase_3", "cast", "death"]:
			if not boss.exclusive_animations.has(animation_key):
				issues.append("%s: animação exclusiva ausente '%s'" % [label, animation_key])
		for ui_key in ["bar_style", "name_color", "phase_markers", "show_cast_bar"]:
			if not boss.boss_ui.has(ui_key):
				issues.append("%s: UI de chefe sem '%s'" % [label, ui_key])
		if not bool(boss.entrance.get("cinematic", false)):
			issues.append("%s: entrada não cinematográfica" % label)
		if float(boss.entrance.get("duration_seconds", 0.0)) <= 0.0:
			issues.append("%s: entrada sem duração" % label)
		if not boss.defeat_conditions.has("health_zero"):
			issues.append("%s: condição de derrota health_zero ausente" % label)
		if int(boss.rewards.get("xp", 0)) <= 0 or int(boss.rewards.get("gold", 0)) <= 0:
			issues.append("%s: recompensas especiais inválidas" % label)
		if not boss.rewards.has("unlocks"):
			issues.append("%s: recompensas sem desbloqueios" % label)
		if bool(boss.ai.get("respawn_enabled", true)):
			issues.append("%s: chefe não pode ressurgir" % label)
		if not boss.model_pending or ResourceLoader.exists(boss.model_path):
			issues.append("%s: modelo de chefe deve estar pendente" % label)
		if not boss.model_path.begins_with("res://assets/models/bosses/"):
			issues.append("%s: modelo fora da convenção" % label)
		if not ResourceLoader.exists(boss.placeholder_scene):
			issues.append("%s: cena placeholder ausente" % label)
	check_true(issues.is_empty(), "30 chefes válidos (identidade/fases/UI/modelo): %s" % "; ".join(issues.slice(0, 6)))
	for number in range(1, 31):
		check_true(bosses.has_boss(StringName("BOSS-%03d" % number)), "id de chefe deve existir: BOSS-%03d" % number)
	for continent_id: String in BOSS_CONTINENT_COUNTS.keys():
		check_eq(bosses.bosses_in_continent(StringName(continent_id)).size(), int(BOSS_CONTINENT_COUNTS[continent_id]),
			"distribuição de chefes em %s" % continent_id)
	# Chefes e regionais não se sobrepõem.
	for boss in bosses.bosses():
		check_false(system(SystemNames.DEMONS).call("has_demon", boss.id), "chefe não pode estar no catálogo regional: %s" % boss.id)

# --------------------------------------------------------- runtime 6 famílias

func _test_family_runtime() -> void:
	section("runtime: 1 representante de cada família via cena compartilhada")
	var demons := system(SystemNames.DEMONS) as DemonManager
	var packed := load(CREATURE_SCENE) as PackedScene
	check_not_null(packed, "cena compartilhada de criatura carrega")
	if packed == null:
		return
	var root := Node3D.new()
	root.name = "BestiaryRuntime"
	host.add_child(root)
	_runtime_root = root
	var defeated_capture := capture(EventBus.creature_defeated)
	var respawn_capture := capture(EventBus.creature_respawned)
	var index := 0
	for demon in demons.representatives():
		var creature := packed.instantiate() as Creature
		creature.name = "Representative_%d" % index
		root.add_child(creature)
		creature.position = Vector3(index * 3.0, 0.0, 0.0)
		check_true(creature.setup(demon), "setup do representante %s" % demon.id)
		check_eq(String(creature.entity_id()), String(demon.id), "criatura expõe o id dos dados")
		check_true(creature.is_placeholder(), "%s usa placeholder identificado" % demon.id)
		check_true(not creature.find_children("*PLACEHOLDER*", "", true, false).is_empty(),
			"%s: nós do placeholder estão marcados" % demon.id)
		check_eq(creature.combatant().max_health, demon.health(), "%s: vida vem dos dados" % demon.id)
		check_eq(float(creature.combatant().resistances.get("physical", 0.0)), float(demon.resistances.get("physical", 0.0)),
			"%s: resistências vêm dos dados" % demon.id)
		var before := defeated_capture.count()
		creature.combatant().take_damage(demon.health() * 2.0, &"physical")
		check_true(creature.is_dead(), "%s morre com dano letal" % demon.id)
		if index == 0:
			check_eq(defeated_capture.count(), before + 1, "evento creature_defeated emitido")
			var args := defeated_capture.first()
			check_eq(String(args[0]), String(demon.id), "evento carrega o id da criatura")
			check_eq(int(args[2]), demon.xp_reward(), "evento carrega o xp dos dados")
			check_eq(int(args[3]), demon.gold_reward(), "evento carrega o ouro dos dados")
			creature.respawn_now()
			check_false(creature.is_dead(), "respawn configurável restaura a criatura")
			check_eq(respawn_capture.count(), 1, "evento creature_respawned emitido")
		index += 1
	await wait_frames(2)
	root.queue_free()
	_runtime_root = null

# ------------------------------------------------------------------ IA ------

func _test_creature_ai() -> void:
	section("IA data-driven: aggro, aproximação e ataque corpo a corpo")
	var demons := system(SystemNames.DEMONS) as DemonManager
	var packed := load(CREATURE_SCENE) as PackedScene
	if packed == null:
		return
	var root := Node3D.new()
	root.name = "BestiaryAIRuntime"
	host.add_child(root)
	_runtime_root = root
	var target := Node3D.new()
	target.name = "AITarget"
	root.add_child(target)
	var target_combatant := Combatant.new()
	target_combatant.name = "Combatant"
	target.add_child(target_combatant)
	target_combatant.max_health = 500.0
	target_combatant.health = 500.0
	var demon := demons.demons_of_family(&"brute")[0]
	var creature := packed.instantiate() as Creature
	creature.name = "AICreature"
	root.add_child(creature)
	creature.setup(demon)
	creature.position = Vector3(0.0, 0.0, 0.0)
	target.position = Vector3(0.0, 0.0, 2.0)
	var ai := CreatureAI.new()
	ai.name = "AI"
	creature.add_child(ai)
	ai.setup(creature, target)
	check_eq(String(ai.state()), "idle", "IA começa ociosa")
	check_true(creature.ai_config().has("aggro_radius"), "IA lê aggro_radius dos dados")
	await wait_frames(12)
	check_true(String(ai.state()) == "chase" or String(ai.state()) == "attack",
		"IA reage ao alvo dentro do raio de aggro (estado=%s)" % ai.state())
	check_true(target_combatant.health < target_combatant.max_health,
		"IA aplica dano do atributo stats.damage (%.0f/%.0f)" % [target_combatant.health, target_combatant.max_health])
	root.queue_free()
	_runtime_root = null
	await wait_frames(2)


# ------------------------------------------------------ encontro de chefe ---

func _test_boss_encounter_flow() -> void:
	section("fluxo de chefe: entrada, fases por vida, recompensas e encerramento")
	var bosses := system(SystemNames.BOSSES) as BossManager
	var packed := load(BOSS_ENCOUNTER_SCENE) as PackedScene
	check_not_null(packed, "cena de encontro de chefe carrega")
	if packed == null:
		return
	var root := Node3D.new()
	root.name = "BossEncounterRuntime"
	host.add_child(root)
	_runtime_root = root
	var encounter := packed.instantiate() as BossEncounter
	encounter.name = "Encounter"
	encounter.boss_id = &"BOSS-001"
	root.add_child(encounter)
	var entrance_capture := capture(EventBus.boss_entrance_started)
	var started_capture := capture(EventBus.boss_encounter_started)
	var phase_capture := capture(EventBus.boss_phase_changed)
	var rewards_capture := capture(EventBus.boss_rewards_granted)
	var ended_capture := capture(EventBus.boss_encounter_ended)
	check_err(encounter.start(PackedInt64Array([Invariants.HOST_PEER_ID]), true), OK,
		"encontro inicia com participante válido (entrada abreviada no teste)")
	check_eq(started_capture.count(), 1, "BossManager registra o início do encontro")
	check_eq(String(entrance_capture.first()[0]), "BOSS-001", "evento de entrada carrega o chefe")
	check_true(float(entrance_capture.first()[1]) > 0.0, "entrada tem duração dos dados")
	check_true(encounter.is_fighting(), "combate começa após a entrada")
	check_not_null(encounter.boss(), "cena compartilhada do chefe instanciada")
	check_not_null(encounter.ui(), "interface de chefe instanciada")
	var boss := encounter.boss()
	if boss == null:
		root.queue_free()
		_runtime_root = null
		return
	check_eq(String(boss.entity_id()), "BOSS-001", "chefe recebe o id dos dados")
	check_eq(boss.current_phase_index(), 1, "fase inicial = 1")
	check_eq(boss.boss_data().phases.size(), 3, "chefe tem 3 fases de dados")
	var maximum := boss.combatant().max_health
	# Tipo de dano sem resistência: limiares exatos de fase.
	# 50% de vida → fase 2.
	boss.combatant().take_damage(maximum * 0.5, &"direct")
	check_eq(boss.current_phase_index(), 2, "vida em 50% ativa a fase 2")
	check_eq(phase_capture.count(), 1, "evento boss_phase_changed emitido")
	check_eq(int(phase_capture.first()[1]), 2, "evento reporta a fase 2")
	# 20% de vida → fase 3.
	boss.combatant().take_damage(boss.combatant().health - maximum * 0.2, &"direct")
	check_eq(boss.current_phase_index(), 3, "vida em 20% ativa a fase 3")
	# Dano letal → recompensas e fim do encontro.
	boss.combatant().take_damage(boss.combatant().health + 10.0, &"direct")
	check_true(encounter.is_finished(), "derrota encerra o encontro")
	check_true(encounter.rewards_granted(), "recompensas especiais concedidas")
	check_eq(rewards_capture.count(), 1, "evento boss_rewards_granted emitido")
	check_eq(int(rewards_capture.first()[1]), int(boss.boss_data().rewards.get("xp", 0)), "xp de recompensa vem dos dados")
	check_eq(int(rewards_capture.first()[2]), int(boss.boss_data().rewards.get("gold", 0)), "ouro de recompensa vem dos dados")
	check_eq(ended_capture.count(), 1, "evento boss_encounter_ended emitido")
	check_true(bool(ended_capture.first()[1]), "evento reporta vitória")
	check_false(bosses.is_encounter_active(&"BOSS-001"), "encontro não fica ativo após a vitória")
	root.queue_free()
	_runtime_root = null
	await wait_frames(2)

func _test_monsters_independent_catalog() -> void:
	section("Monstros: categoria independente, 300 criaturas e 10 subcategorias")
	var monster_mgr_script := load("res://managers/monster_manager.gd")
	var mgr = monster_mgr_script.new()
	check_true(mgr.is_loaded(), "MonsterManager deve carregar o catálogo de monstros")
	check_eq(mgr.count(), 300, "devem existir exatamente 300 monstros no catálogo independente")

	# Verificar separação das 10 subcategorias
	var humanoids: Array = mgr.get_monsters_by_subcategory(&"humanoids")
	var beasts: Array = mgr.get_monsters_by_subcategory(&"beasts")
	var reptiles: Array = mgr.get_monsters_by_subcategory(&"reptiles_dragons")
	var undead: Array = mgr.get_monsters_by_subcategory(&"undead")
	var demons_abyssals: Array = mgr.get_monsters_by_subcategory(&"demons_abyssals")
	var giants: Array = mgr.get_monsters_by_subcategory(&"giants_colossi")
	var elementals: Array = mgr.get_monsters_by_subcategory(&"magical_elementals")
	var insects: Array = mgr.get_monsters_by_subcategory(&"insects_arachnids")
	var aquatic: Array = mgr.get_monsters_by_subcategory(&"aquatic")
	var rare: Array = mgr.get_monsters_by_subcategory(&"rare_anomalies")

	check_eq(humanoids.size(), 40, "humanoides monstruosos: 40 criaturas")
	check_eq(beasts.size(), 40, "feras e predadores: 40 criaturas")
	check_eq(reptiles.size(), 30, "répteis e dracônicos: 30 criaturas")
	check_eq(undead.size(), 35, "mortos-vivos: 35 criaturas")
	check_eq(demons_abyssals.size(), 40, "demônios e abissais (fauna): 40 criaturas")
	check_eq(giants.size(), 25, "gigantes e colossos: 25 criaturas")
	check_eq(elementals.size(), 30, "mágicas e elementais: 30 criaturas")
	check_eq(insects.size(), 25, "insetos e aracnídeos: 25 criaturas")
	check_eq(aquatic.size(), 20, "aquáticas: 20 criaturas")
	check_eq(rare.size(), 15, "raras e anomalias: 15 criaturas")

	# Testar pilotos
	var pilots: Array = mgr.get_pilot_monsters()
	check_eq(pilots.size(), 5, "devem existir 5 monstros no lote piloto 3D")
	check_true(mgr.has_monster(&"MONSTER_001"), "MONSTER_001 deve existir")
	check_true(mgr.has_monster(&"MONSTER_041"), "MONSTER_041 deve existir")
	check_true(mgr.has_monster(&"MONSTER_081"), "MONSTER_081 deve existir")
	check_true(mgr.has_monster(&"MONSTER_111"), "MONSTER_111 deve existir")
	check_true(mgr.has_monster(&"MONSTER_211"), "MONSTER_211 deve existir")

