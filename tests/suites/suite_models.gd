extends TestCase
## Suite MODELS — pipeline GLB: política .blend, auditoria do modelo de
## referência e unit tests do AnimationTreeBuilder (compatibilidade 11).

var _tree_root: Node3D = null

func system_label() -> String:
	return "models"

func execute() -> void:
	await _test_blend_policy()
	await _test_model_audit()
	await _test_animation_tree_builder()

func _teardown() -> void:
	if _tree_root != null and is_instance_valid(_tree_root):
		_tree_root.queue_free()
		_tree_root = null
	await wait_frames(2)

# ---------------------------------------------------------------- políticas --

func _test_blend_policy() -> void:
	section("política de integração com Blender: projetos .blend organizados em assets/blender/")
	var blends := ModelAudit.find_blend_files()
	# Conforme Prompt 10: .blend salvos diretamente nas pastas do Abyssal Pact (assets/blender/)
	var non_blender_assets := PackedStringArray()
	for b in blends:
		if not b.begins_with("res://assets/blender/") and not b.begins_with("res://assets/3d/monsters/") and not b.begins_with("res://assets/3d/weapons/") and not b.begins_with("res://assets/3d/demons/"):
			non_blender_assets.append(b)
	check_eq(non_blender_assets.size(), 0, "arquivos .blend devem estar organizados em assets/blender/, assets/3d/monsters/ ou assets/3d/weapons/ (fora do padrão: %s)" % [non_blender_assets])
	check_true(blends.size() > 0, "deve conter projetos .blend organizados no repositório")

# ---------------------------------------------------------------- auditoria --

func _test_model_audit() -> void:
	section("auditoria do modelo de referência (checks 5–10)")
	var issues := PackedStringArray()
	var warnings := PackedStringArray()
	var summary := ModelAudit.audit_reference(issues, warnings)
	check_eq(issues.size(), 0, "auditoria deve aprovar o modelo de referência (issues: %s)" % [issues])
	check_eq(warnings.size(), 0, "modelo de referência deve estar limpo até de avisos (avisos: %s)" % [warnings])
	check_true(summary.get("bytes", 0) > 0 and summary.get("bytes", 0) <= ModelAudit.BUDGET_MAX_GLB_BYTES,
		"GLB dentro do orçamento de %d bytes" % ModelAudit.BUDGET_MAX_GLB_BYTES)
	check_true(summary.get("triangles", 0) > 0 and summary.get("triangles", 0) <= ModelAudit.BUDGET_MAX_TRIANGLES,
		"triângulos dentro do orçamento")
	check_true(summary.get("bones", 0) > 0, "esqueleto presente")
	check_true(summary.get("materials", 0) > 0, "materiais presentes")
	check_eq(summary.get("textures", 0), 0, "referência usa materiais sólidos (sem texturas)")
	check_true(float(summary.get("height", 0.0)) >= ModelAudit.HEIGHT_MIN
		and float(summary.get("height", 0.0)) <= ModelAudit.HEIGHT_MAX, "altura humana dentro da faixa")
	check_true(float(summary.get("origin_offset", 1.0)) <= ModelAudit.ORIGIN_TOLERANCE,
		"origem nos pés")

	section("clipes do contrato presentes no GLB importado")
	var clips: Array = summary.get("clips", [])
	for clip_name in ModelAudit.CONTRACT_CLIPS:
		check_true(PackedStringArray(clips).has(String(clip_name)),
			"clipe do contrato presente: %s" % clip_name)

	section("esqueleto validado na cena importada (critério do pedido)")
	var packed: PackedScene = load(ModelAudit.REFERENCE_MODEL_PATH) as PackedScene
	check_not_null(packed, "GLB importa como PackedScene")
	if packed != null:
		var model := packed.instantiate() as Node3D
		check_not_null(model, "cena do modelo instancia como Node3D")
		if model != null:
			var skeleton := model.find_children("*", "Skeleton3D", true, false)
			check_true(skeleton.size() > 0, "cena importada contém Skeleton3D")
			if skeleton.size() > 0:
				var bones := (skeleton[0] as Skeleton3D).get_bone_count()
				check_true(bones >= 8, "esqueleto com ossos animáveis (%d ossos)" % bones)
			var mixer := model.find_children("*", "AnimationPlayer", true, false)
			check_true(mixer.size() > 0, "cena importada contém AnimationPlayer")
			if mixer.size() > 0:
				var player := mixer[0] as AnimationPlayer
				check_true(player.has_animation("idle"), "AnimationPlayer tem clipe 'idle'")
				# Reproduz o clipe de fato (validação de playback).
				player.play("idle")
				check_eq(String(player.current_animation), "idle", "clipe idle entra em playback")
				check_true(player.is_playing(), "AnimationPlayer está tocando")
			model.queue_free()

# ------------------------------------------------------- AnimationTreeBuilder --

func _test_animation_tree_builder() -> void:
	section("AnimationTreeBuilder: máquina de estados sobre o mixer do GLB")
	var packed: PackedScene = load(ModelAudit.REFERENCE_MODEL_PATH) as PackedScene
	if packed == null:
		check_false(true, "modelo de referência deve carregar para o builder")
		return
	_tree_root = Node3D.new()
	host.add_child(_tree_root)
	var model := packed.instantiate() as Node3D
	_tree_root.add_child(model)
	var mixer := _first_mixer(model)
	if mixer == null:
		check_false(true, "modelo deve ter AnimationPlayer para o builder")
		return
	var tree := AnimationTreeBuilder.build(mixer, PlayerAnimator.LOOPING_CLIPS)
	check_not_null(tree, "builder produz AnimationTree")
	if tree == null:
		return
	_tree_root.add_child(tree)
	tree.active = true

	check_true(AnimationTreeBuilder.has_state(tree, "idle"), "estado idle existe")
	check_true(AnimationTreeBuilder.has_state(tree, "walk"), "estado walk existe")
	check_true(AnimationTreeBuilder.has_state(tree, "dodge"), "estado dodge existe")
	check_false(AnimationTreeBuilder.has_state(tree, "clip_inexistente"), "estado ausente → false")

	check_true(AnimationTreeBuilder.start(tree, "idle"), "start(idle) funciona")
	await wait_frames(2)
	check_eq(AnimationTreeBuilder.current_node(tree), "idle", "máquina inicia em idle")
	await wait_frames(3)
	check_eq(AnimationTreeBuilder.current_node(tree), "idle", "idle permanece (auto-loop AT_END)")

	# Esperas >= janela de crossfade (0,18 s ≈ 11 frames): travel emitido
	# durante fade ativo é descartado pelo playback da Godot.
	check_true(AnimationTreeBuilder.travel(tree, "run"), "travel(run) funciona")
	await wait_frames(16)
	check_eq(AnimationTreeBuilder.current_node(tree), "run", "máquina viaja para run")

	check_true(AnimationTreeBuilder.travel(tree, "jump"), "travel(jump) funciona")
	await wait_frames(16)
	check_eq(AnimationTreeBuilder.current_node(tree), "jump", "máquina viaja para jump")

	check_false(AnimationTreeBuilder.travel(tree, "clip_inexistente"), "travel para estado ausente → false")
	check_false(AnimationTreeBuilder.start(tree, "clip_inexistente"), "start para estado ausente → false")

func _first_mixer(model: Node) -> AnimationPlayer:
	for candidate in model.find_children("*", "AnimationPlayer", true, false):
		return candidate as AnimationPlayer
	return null
