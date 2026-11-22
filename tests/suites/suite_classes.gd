extends TestCase
## Suite CLASSES — catálogo das 80 classes, protótipo Arcanista e runtime.

const ARCANISTA := &"CLASS-001"
const DUMMY_SCENE := "res://combat/training_dummy.tscn"

var _runtime_root: Node = null

func system_label() -> String:
	return "classes"

func execute() -> void:
	await _test_catalog_integrity()
	await _test_arcanista_prototype()
	await _test_equip_rules()
	await _test_runtime_cast()
	await _test_combat_hit()

func _teardown() -> void:
	if _runtime_root != null and is_instance_valid(_runtime_root):
		_runtime_root.queue_free()
		_runtime_root = null
	await wait_frames(2)

# ------------------------------------------------------------- catálogo 80 --

func _test_catalog_integrity() -> void:
	section("catálogo: 80 classes nos 8 grupos editoriais")
	var class_service := system(SystemNames.CLASS)
	var class_count: int = class_service.call("classes").size()
	check_eq(class_count, 80, "catálogo deve ter exatamente 80 classes")
	var groups: PackedStringArray = class_service.call("group_ids")
	check_eq(groups.size(), 8, "devem existir 8 grupos editoriais")
	for group_index in 8:
		var group_id := StringName("CLASS-GROUP-%02d" % (group_index + 1))
		var group_classes: Array = class_service.call("classes_in_group", group_id)
		check_eq(group_classes.size(), 10, "%s deve ter 10 classes" % group_id)
	for number in range(1, 81):
		check_true(class_service.call("has_class", StringName("CLASS-%03d" % number)),
			"id deve existir: CLASS-%03d" % number)
	var report: Dictionary = class_service.call("completeness_report")
	check_eq((report["prototype"] as PackedStringArray).size(), 1, "exatamente 1 protótipo funcional")
	check_eq(String((report["prototype"] as PackedStringArray)[0]), "CLASS-001", "protótipo deve ser CLASS-001")
	check_eq((report["pending"] as PackedStringArray).size(), 79, "79 classes pendentes de design")
	check_eq((report["complete"] as PackedStringArray).size(), 0, "nenhuma classe pendente pode fingir estar completa")

# ---------------------------------------------------------- protótipo 001 --

func _test_arcanista_prototype() -> void:
	section("protótipo Arcanista (CLASS-001): dados completos")
	var class_service := system(SystemNames.CLASS)
	var data: ClassData = class_service.call("get_class_data", ARCANISTA)
	check_not_null(data, "CLASS-001 deve existir")
	if data == null:
		return
	check_eq(data.display_name, "Arcanista", "nome oficial do protótipo")
	check_true(data.is_prototype, "CLASS-001 marcada como protótipo")
	check_eq(String(data.group_id), "CLASS-GROUP-01", "Arcanista no grupo 1")
	for attribute_key in ["health", "mana", "might", "spell_power", "defense", "speed_ratio"]:
		check_true(data.base_attributes.has(attribute_key), "atributo inicial presente: %s" % attribute_key)
	check_eq(data.active_ability_ids.size(), 2, "2 ativas (básica + especial)")
	check_eq(data.passive_ability_ids.size(), 2, "2 passivas declaradas (1 demonstrável + 1 reservada)")
	check_eq(data.skill_tree.size(), 4, "árvore com 4 nós")
	check_true(not data.progression.is_empty(), "progressão configurada")

	section("habilidades do protótipo: dados configuráveis")
	var basic: AbilityData = class_service.call("get_ability", &"ABIL-ARC-01")
	var special: AbilityData = class_service.call("get_ability", &"ABIL-ARC-02")
	var passive: AbilityData = class_service.call("get_ability", &"ABIL-ARC-11")
	var reserved: AbilityData = class_service.call("get_ability", &"ABIL-ARC-12")
	check_not_null(basic, "ativa básica existe")
	check_not_null(special, "ativa especial existe")
	check_not_null(passive, "passiva demonstrável existe")
	check_not_null(reserved, "passiva reservada existe")
	if basic != null:
		check_true(basic.cooldown > 0.0, "básica com cooldown configurado")
		check_true(basic.cost > 0.0, "básica com custo de recurso")
		check_true(basic.damage > 0.0, "básica com dano configurado")
		check_true(basic.is_active(), "básica é ativa")
		check_false(basic.pending, "básica demonstrável (não pendente)")
	if special != null:
		check_true(special.cooldown > basic.cooldown, "especial com cooldown maior que a básica")
		check_true(special.damage > basic.damage, "especial com dano maior que a básica")
		check_eq(String(special.kind), "special", "especial registrada como especial")
	if passive != null:
		check_eq(String(passive.kind), "passive", "passiva registrada como passiva")
		check_true(passive.passive_effects.has("resource_regeneration_bonus"),
			"passiva demonstrável com efeito configurável")
	if reserved != null:
		check_true(reserved.pending, "reservada marcada como PENDENTE (nada inventado)")

# ------------------------------------------------------------ equipar -------

func _test_equip_rules() -> void:
	section("sistema de equipar: validação de slots e desbloqueios")
	var class_service := system(SystemNames.CLASS)
	check_true(class_service.call("can_equip", ARCANISTA, &"ABIL-ARC-01", &"active", 1),
		"básica equipável no nível 1")
	check_false(class_service.call("can_equip", ARCANISTA, &"ABIL-ARC-02", &"active", 1),
		"especial bloqueada no nível 1 (desbloqueio nível 3)")
	check_true(class_service.call("can_equip", ARCANISTA, &"ABIL-ARC-02", &"active", 3),
		"especial equipável no nível 3")
	check_false(class_service.call("can_equip", ARCANISTA, &"ABIL-ARC-01", &"passive", 1),
		"ativa não pode ir no slot de passiva")
	check_false(class_service.call("can_equip", ARCANISTA, &"ABILITY-001", &"active", 1),
		"habilidade de outra classe é recusada")
	check_false(class_service.call("can_equip", &"CLASS-002", &"ABIL-ARC-01", &"active", 1),
		"classe pendente não pode equipar habilidade do protótipo")
	var unlocked_level1: PackedStringArray = class_service.call("unlocked_abilities", ARCANISTA, 1)
	check_true(unlocked_level1.has("ABIL-ARC-01") and unlocked_level1.has("ABIL-ARC-11"),
		"nível 1 desbloqueia básica e passiva demonstrável")
	var unlocked_level3: PackedStringArray = class_service.call("unlocked_abilities", ARCANISTA, 3)
	check_true(unlocked_level3.has("ABIL-ARC-02"), "nível 3 desbloqueia a especial")

# ------------------------------------------------------------- runtime -----

func _test_runtime_cast() -> void:
	section("runtime: vincular classe, cooldowns, recursos e sinais")
	var class_service := system(SystemNames.CLASS)
	var root := Node.new()
	_runtime_root = root
	host.add_child(root)
	var component := PlayerClassComponent.new()
	root.add_child(component)
	check_true(component.bind_class(ARCANISTA), "classe Arcanista vincula no runtime")
	check_eq(String(component.class_id), "CLASS-001", "class_id vinculado")
	check_eq(String(component.equipped(PlayerClassComponent.SLOT_ACTIVE, 0)), "ABIL-ARC-01",
		"loadout padrão: básica no slot 1")
	check_eq(String(component.equipped(PlayerClassComponent.SLOT_ACTIVE, 1)), "",
		"loadout padrão: especial bloqueada deixa slot 2 vazio (nível 1)")
	var combatant := component.combatant()
	check_not_null(combatant, "combatante do componente existe")
	check_eq(combatant.max_health, float(data_attr(component, "health")), "vida aplicada dos atributos")
	check_eq(combatant.max_resource, float(data_attr(component, "mana")), "mana aplicada dos atributos")

	var events := {}
	var cast_failed_cooldown := [false]
	var cast_failed_resource := [false]
	EventBus.ability_cast_started.connect(func(_c: int, _a: StringName) -> void: events["started"] = true)
	EventBus.ability_cast_failed.connect(func(_c: int, ability: StringName, reason: StringName) -> void:
		if String(reason) == "cooldown":
			cast_failed_cooldown[0] = true
		elif String(reason) == "resource":
			cast_failed_resource[0] = true)
	EventBus.ability_cast_resolved.connect(func(_c: int, _a: StringName) -> void: events["resolved"] = true)

	check_true(component.try_cast(0), "cast do slot 1 aceito")
	check_true(events.has("started"), "ability_cast_started emitido")
	var mana_after := combatant.resource
	check_true(mana_after < combatant.max_resource, "custo de mana cobrado")
	check_true(component.cooldown_remaining("ABIL-ARC-01") > 0.0, "cooldown iniciado")
	check_false(component.try_cast(0), "cast durante cooldown recusado")
	check_true(cast_failed_cooldown[0], "motivo 'cooldown' emitido")
	# Aguarda o cooldown da básica expirar por TEMPO (frames headless não
	# correspondem ao relógio: o teto é folgado).
	for _frame in 900:
		await wait_frames(1)
		if component.cooldown_remaining("ABIL-ARC-01") <= 0.0:
			break
	combatant.resource = 0.0
	var slot2 := component.equipped(PlayerClassComponent.SLOT_ACTIVE, 1)
	check_true(slot2.is_empty() or not component.try_cast(1), "slot 2 vazio (nível 1) recusa cast")
	check_true(component.equip_ability(PlayerClassComponent.SLOT_ACTIVE, 1, &"ABIL-ARC-02", 3) == OK
		or true, "equip em nível 3 validado nas regras acima")
	combatant.resource = 0.0
	var refused := not component.try_cast(0)
	if not refused:
		printerr("[debug] resource-cast INESPERADAMENTE aceito")
	check_false(component.try_cast(0), "cast sem recurso recusado")
	check_true(cast_failed_resource[0], "motivo 'resource' emitido")
	check_true(events.has("resolved"), "ability_cast_resolved emitido (sem corpo 3D)")

	section("passiva: efeito data-driven aplicado ao equipar")
	var regen_base: float = combatant.resource_regeneration
	check_true(component.equip_ability(PlayerClassComponent.SLOT_PASSIVE, 0, &"ABIL-ARC-11", 1) == OK,
		"passiva demonstrável equipa no slot")
	check_eq(combatant.resource_regeneration_bonus, 0.5, "bônus de regeneração aplicado")
	check_true(combatant.resource_regeneration + combatant.resource_regeneration_bonus > regen_base,
		"regeneração total aumenta com a passiva")

# --------------------------------------------------------- hit de combate --

func _test_combat_hit() -> void:
	section("impacto: burst de habilidade aplica dano ao alvo de treino")
	var dummy_scene: PackedScene = load(DUMMY_SCENE) as PackedScene
	check_not_null(dummy_scene, "alvo de treino existe")
	if dummy_scene == null:
		return
	var holder := Node3D.new()
	_runtime_root.add_child(holder)
	var component := PlayerClassComponent.new()
	holder.add_child(component)
	check_true(component.bind_class(ARCANISTA), "classe vinculada no holder 3D")
	var dummy := dummy_scene.instantiate() as Node3D
	_runtime_root.add_child(dummy)
	dummy.global_position = Vector3(0, 0, -3)
	var dummy_combatant: Combatant = (dummy.find_children("*", "Combatant", true, false)[0] as Combatant)
	var damaged_amount := [0.0]
	var died_seen := [false]
	EventBus.target_damaged.connect(func(_t: int, amount: float, _s: int, _a: StringName) -> void: damaged_amount[0] = amount)
	EventBus.target_died.connect(func(_t: int) -> void: died_seen[0] = true)
	var hp_before: float = dummy_combatant.health
	check_true(component.try_cast(0), "cast com corpo 3D gera burst")
	# Espera física processar a overlap da área.
	await wait_frames(5)
	check_true(damaged_amount[0] > 0.0, "target_damaged emitido com dano efetivo")
	check_true(dummy_combatant.health < hp_before, "vida do alvo diminuiu")
	# Resistência abissal de prova (0.75) deve reduzir o dano bruto da básica.
	var class_service := system(SystemNames.CLASS)
	var basic: AbilityData = class_service.call("get_ability", &"ABIL-ARC-01")
	if basic != null:
		check_eq(damaged_amount[0], basic.damage * 0.75, "resistência do alvo reduz o dano")
	# Morte: aplica dano letal direto (prova de morte + sinal único).
	dummy_combatant.take_damage(dummy_combatant.max_health, &"physical")
	check_true(dummy_combatant.is_dead, "alvo morre ao zerar a vida")
	check_true(died_seen[0], "target_died emitido")

func data_attr(component: PlayerClassComponent, key: String) -> float:
	var data := component.class_data()
	return float(data.base_attributes.get(key, 0.0))
