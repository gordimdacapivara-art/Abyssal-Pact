extends TestCase
## Suite RACES — catálogo 40 raças / 80 sub-raças, protótipo visual, builder.

const PROTOTYPE_RACE := &"RACE-001"
const PROTOTYPE_SUBS := ["SUBRACE-001", "SUBRACE-002"]

var _runtime_root: Node = null

func system_label() -> String:
	return "races"

func execute() -> void:
	await _test_catalog_integrity()
	await _test_prototype_profile()
	await _test_class_compatibility()
	await _test_visual_builder()

func _teardown() -> void:
	if _runtime_root != null and is_instance_valid(_runtime_root):
		_runtime_root.queue_free()
		_runtime_root = null
	await wait_frames(2)

# ------------------------------------------------------- catálogo 40/80 -----

func _test_catalog_integrity() -> void:
	section("catálogo: 40 raças, 80 sub-raças, 2 por raça")
	var race_service := system(SystemNames.RACE)
	check_eq((race_service.call("races") as Array).size(), 40, "catálogo deve ter exatamente 40 raças")
	check_eq((race_service.call("subraces") as Array).size(), 80, "catálogo deve ter exatamente 80 sub-raças")
	for number in range(1, 41):
		check_true(race_service.call("has_race", StringName("RACE-%03d" % number)),
			"id de raça deve existir: RACE-%03d" % number)
	for number in range(1, 81):
		check_true(race_service.call("has_subrace", StringName("SUBRACE-%03d" % number)),
			"id de sub-raça deve existir: SUBRACE-%03d" % number)
	# 2 sub-raças por raça (decisão desta fase), com vínculo bidirecional.
	for number in range(1, 41):
		var race_id := StringName("RACE-%03d" % number)
		var subraces: Array = race_service.call("subraces_of", race_id)
		check_eq(subraces.size(), 2, "%s deve ter 2 sub-raças" % race_id)
		for subrace: SubraceData in subraces:
			check_true(race_service.call("validate_link", subrace.id, race_id),
				"%s deve vincular de volta a %s" % [subrace.id, race_id])
	var report: Dictionary = race_service.call("completeness_report")
	check_eq((report["prototype"] as PackedStringArray).size(), 1, "exatamente 1 protótipo visual")
	check_eq(String((report["prototype"] as PackedStringArray)[0]), "RACE-001", "protótipo deve ser RACE-001")
	check_eq((report["pending"] as PackedStringArray).size(), 39, "39 raças pendentes de design")

# ------------------------------------------------------- protótipo visual ---

func _test_prototype_profile() -> void:
	section("protótipo RACE-001: perfil visual e diferenças de sub-raças")
	var race_service := system(SystemNames.RACE)
	var race: RaceData = race_service.call("get_race", PROTOTYPE_RACE)
	check_not_null(race, "RACE-001 deve existir")
	if race == null:
		return
	check_eq(race.display_name, "Raça RACE-001 (protótipo visual)", "nome do protótipo")
	check_true(race.is_prototype, "RACE-001 marcada como protótipo")
	check_false(race.visual_profile.is_empty(), "visual_profile presente")
	check_eq(String(race.visual_profile.get("body_type", "?")), "humanoid_shared",
		"esqueleto compartilhado do pipeline")
	check_eq(String(race.visual_profile.get("model_glb", "")),
		"res://assets/models/characters/reference/char_ref_humanoid.glb", "GLB do pipeline referenciado")
	check_true(race.racial_attributes.is_empty(), "atributos raciais NÃO presumidos (vazio)")
	check_true(race.animation_extras.is_empty(), "animações complementares pendentes (honestidade)")

	var profile_a: Dictionary = race_service.call("visual_profile_of", PROTOTYPE_RACE, &"SUBRACE-001")
	var profile_b: Dictionary = race_service.call("visual_profile_of", PROTOTYPE_RACE, &"SUBRACE-002")
	check_false(profile_a.is_empty(), "perfil da sub-raça A mesclado")
	check_false(profile_b.is_empty(), "perfil da sub-raça B mesclado")
	check_eq(StringName("horn"), StringName(Array(profile_a.get("accessories", [])).pop_front()),
		"sub-raça A: chifres no perfil mesclado")
	var accessories_b := Array(profile_b.get("accessories", []))
	check_true(accessories_b.has("antenna") and accessories_b.has("tail"),
		"sub-raça B: antenas + cauda no perfil mesclado")
	check_true(float(profile_a.get("scale", 1.0)) != float(profile_b.get("scale", 1.0)),
		"escalas distintas entre as sub-raças")
	var tint_a: Color = profile_a.get("head_tint", Color.WHITE)
	var tint_b: Color = profile_b.get("head_tint", Color.WHITE)
	check_true(tint_a != tint_b, "tintas de cabeça distintas entre as sub-raças")
	# Overrides da sub-raça NÃO alteram os dados da raça-mãe (mescla, não mutação).
	check_true(race.visual_profile.get("accessories", PackedStringArray()).is_empty(),
		"visual_profile da raça permanece sem acessórios (overrides não mutam)")

# ------------------------------------------------ compatibilidade com classes

func _test_class_compatibility() -> void:
	section("compatibilidade com classes (dados, sem restrições inventadas)")
	var race_service := system(SystemNames.RACE)
	var class_service := system(SystemNames.CLASS)
	check_true(race_service.call("can_use_class", PROTOTYPE_RACE, &"CLASS-001"),
		"protótipo compatível com o Arcanista")
	# compatible_class_groups vazio = compatível com TODAS (estado provisório).
	for number in [2, 25, 80]:
		check_true(race_service.call("can_use_class", PROTOTYPE_RACE, StringName("CLASS-%03d" % number)),
			"RACE-001 (sem restrição) deve aceitar CLASS-%03d" % number)
	check_false(race_service.call("can_use_class", &"RACE-999", &"CLASS-001"),
		"raça inexistente recusa qualquer classe")
	var class_manager: ClassManager = class_service
	check_not_null(class_manager.get_class_data(&"CLASS-001"),
		"ClassManager consultável pela API racial")

# ------------------------------------------------------------- builder ------

func _test_visual_builder() -> void:
	section("RaceVisualBuilder: modelo compartilhado + peças provisórias por osso")
	var race_service := system(SystemNames.RACE)
	var root := Node3D.new()
	_runtime_root = root
	host.add_child(root)
	for subrace_id in PROTOTYPE_SUBS:
		var slot := Node3D.new()
		slot.name = "Slot_" + subrace_id
		root.add_child(slot)
		var visual: Node3D = RaceVisualBuilder.build(slot, PROTOTYPE_RACE, StringName(subrace_id), race_service)
		check_not_null(visual, "visual construído para %s" % subrace_id)
		if visual == null:
			continue
		var skeleton := _first_skeleton(visual)
		check_not_null(skeleton, "%s: esqueleto compartilhado instanciado" % subrace_id)
		if skeleton == null:
			continue
		check_true(RaceVisualBuilder.has_bone(skeleton, &"head") and RaceVisualBuilder.has_bone(skeleton, &"root"),
			"%s: ossos do contrato presentes (com aliases)" % subrace_id)
		var attachments := 0
		for attachment in visual.find_children("*", "BoneAttachment3D", true, false):
			attachments += 1
			check_true(String(attachment.name).contains("PROV"),
				"peça anexada identificada como PROVISÓRIA: %s" % attachment.name)
		var expected := (Array((race_service.call("visual_profile_of",
			PROTOTYPE_RACE, StringName(subrace_id)) as Dictionary).get("accessories", [])).size())
		check_true(attachments >= expected,
			"%s: peças anexadas por osso (%d ≥ %d)" % [subrace_id, attachments, expected])
	# Diferença demonstrável: A tem chifres, B não tem; B tem cauda, A não.
	var slot_a := root.get_node("Slot_SUBRACE-001") as Node3D
	var slot_b := root.get_node("Slot_SUBRACE-002") as Node3D
	check_true(_has_horn_like(slot_a), "SUBRACE-001 exibe chifres (diferença demonstrável)")
	check_true(_has_attachment_named(slot_b, "tail"), "SUBRACE-002 exibe cauda (diferença demonstrável)")
	check_true(not _has_attachment_named(slot_a, "tail"), "SUBRACE-001 não tem cauda")
	# Raça sem vínculo → builder recusa (validação de seleção racial).
	var slot_bad := Node3D.new()
	root.add_child(slot_bad)
	var invalid: Node3D = RaceVisualBuilder.build(slot_bad, PROTOTYPE_RACE, &"SUBRACE-080", race_service)
	check_null(invalid, "builder recusa sub-raça que não pertence à raça")

func _first_skeleton(model: Node) -> Skeleton3D:
	for candidate in model.find_children("*", "Skeleton3D", true, false):
		return candidate as Skeleton3D
	return null

func _has_attachment_named(slot: Node3D, fragment: String) -> bool:
	return not slot.find_children("Accessory_" + fragment + "*", "BoneAttachment3D", true, false).is_empty()

func _has_horn_like(slot: Node3D) -> bool:
	return not slot.find_children("Accessory_horn*", "BoneAttachment3D", true, false).is_empty()
