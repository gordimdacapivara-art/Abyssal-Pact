class_name RaceVisualBuilder
extends RefCounted
## Construtor visual modular de personagens por raça/sub-raça (data-driven).
##
## Estratégia: ESQUELETO COMPARTILHADO — anatomias humanoides reusam o mesmo
## GLB do pipeline (char_ref_humanoid.glb) com peças anexadas por BoneAttachment3D
## (chifres/antenas no osso `head`, cauda no `root`, asas no `chest`). Anatomias
## INCOMPATÍVEIS com o esqueleto humanoide (quadrúpedes, especiais) seriam
## GLBs com rig próprio (`body_type="specialized"`) — nenhum existe ainda;
## recebem aviso explícito e usam o manequim compartilhado como PROVISÓRIO.
##
## TODAS as peças são PROVISÓRIAS (primitivas de Godot com tinta da raça) e
## marcadas como tal no nome do nó — nunca passam por definitivas. Materiais,
## cabeças, corpos e acessórios definitivos virão de GLBs por peça no pipeline.

## Anexo dos acessórios por osso do esqueleto compartilhado.
const BONE_FOR_ACCESSORY := {
	&"horn": &"head",
	&"antler": &"head",
	&"antenna": &"head",
	&"tail": &"root",
	&"wing": &"chest",
	&"crystal": &"head",
}

## Aliases de osso: o GLB de referência exporta o osso da cabeça como `head_2`
## (colisão de nome no exportador Blender). Os dados continuam usando o nome
## canônico `head`; o resolvedor devolve o primeiro osso presente.
const BONE_ALIASES := {
	&"head": [&"head", &"head_2"],
	&"root": [&"root"],
	&"chest": [&"chest"],
}

## Nome real do osso no esqueleto para um nome canônico ("" quando ausente).
static func resolve_bone(skeleton: Skeleton3D, canonical: StringName) -> StringName:
	if skeleton == null:
		return &""
	var candidates: Array = BONE_ALIASES.get(canonical, [canonical])
	for candidate: StringName in candidates:
		if skeleton.find_bone(String(candidate)) >= 0:
			return candidate
	return &""

## true quando o osso canônico (ou um alias) existe no esqueleto.
static func has_bone(skeleton: Skeleton3D, canonical: StringName) -> bool:
	return resolve_bone(skeleton, canonical) != &""

const DEFAULT_MODEL := "res://assets/models/characters/reference/char_ref_humanoid.glb"

## Instancia o visual da raça/sub-raça em `slot` (Node3D). `appearance`
## (opcional) é a personalização do personagem (CharacterData.appearance):
## sobrepõe tintas e acrescenta peças. Retorna a raiz do modelo (null quando
## os dados não permitem construir).
static func build(slot: Node3D, race_id: StringName, subrace_id: StringName, race_manager: RaceManager, appearance: Dictionary = {}) -> Node3D:
	if slot == null or race_manager == null:
		return null
	var profile := race_manager.visual_profile_of(race_id, subrace_id)
	if profile.is_empty():
		push_warning("RaceVisualBuilder: perfil visual indisponível para %s/%s" % [race_id, subrace_id])
		return null
	_apply_appearance_overrides(profile, appearance)
	var model_path := String(profile.get("model_glb", DEFAULT_MODEL))
	if model_path.is_empty() or not ResourceLoader.exists(model_path):
		model_path = DEFAULT_MODEL
	var packed: PackedScene = load(model_path) as PackedScene
	if packed == null:
		push_warning("RaceVisualBuilder: modelo ausente: %s" % model_path)
		return null
	var model := packed.instantiate() as Node3D
	if model == null:
		return null
	model.name = "RaceVisual_%s_%s" % [race_id, subrace_id]
	slot.add_child(model)
	var scale := float(profile.get("scale", 1.0))
	if scale != 1.0:
		model.scale = Vector3.ONE * scale

	# Anatomia especializada ainda não tem GLB: aviso explícito (honestidade).
	if String(profile.get("body_type", "humanoid_shared")) != "humanoid_shared":
		push_warning("RaceVisualBuilder: corpo '%s' sem rig próprio ainda — usando esqueleto humanoide COMPARTILHADO como PROVISÓRIO" % String(profile.get("body_type", "?")))

	var skeleton := _find_skeleton(model)
	if skeleton != null:
		_apply_tints(skeleton, profile)
		_attach_accessories(skeleton, profile)
		_apply_personalization(skeleton, profile)
	else:
		push_warning("RaceVisualBuilder: modelo sem Skeleton3D — tintas e acessórios não aplicados")
	return model

# ------------------------------------------------------------------ INTERNO --

## Sobrepõe a personalização do personagem (CharacterData.appearance) sobre o
## perfil da raça: tintas individuais (pele/cabelo/olhos), estilo de cabelo,
## marca de rosto, acessórios extras (chifres/cauda/asas adicionais) e
## vestimenta. Nada aqui inventa lore — só composição visual de dados.
static func _apply_appearance_overrides(profile: Dictionary, appearance: Dictionary) -> void:
	if appearance.is_empty():
		return
	for color_key in ["skin_color", "hair_color", "eye_color"]:
		var hex := String(appearance.get(color_key, ""))
		if not hex.is_empty() and hex.is_valid_html_color():
			match color_key:
				"skin_color":
					# Pele define corpo e cabeça do manequim PROVISÓRIO.
					profile["body_tint"] = Color(hex)
					profile["head_tint"] = Color(hex)
				_:
					profile[color_key] = Color(hex)
	for style_key in ["hair_style", "face_mark", "vestiment"]:
		var value := String(appearance.get(style_key, ""))
		if not value.is_empty():
			profile[style_key] = value
	var extra: Variant = appearance.get("extra_accessories", [])
	var accessories := PackedStringArray()
	for accessory in profile.get("accessories", PackedStringArray()):
		accessories.append(String(accessory))
	for accessory_name: String in extra:
		if not accessories.has(accessory_name):
			accessories.append(accessory_name)
	profile["accessories"] = accessories
	var extra_scale := float(appearance.get("extra_scale", 1.0))
	if extra_scale != 1.0 and extra_scale > 0.0:
		profile["scale"] = float(profile.get("scale", 1.0)) * extra_scale

## Personalização INDIVIDUAL (peças PROVISÓRIAS): cabelo, marca de rosto,
## olhos e vestimenta sobre o manequim. Diferente dos acessórios raciais
## (que vêm de dados de raça/sub-raça), estas peças vêm da aparência.
static func _apply_personalization(skeleton: Skeleton3D, profile: Dictionary) -> void:
	var head_bone := resolve_bone(skeleton, &"head")
	var chest_bone := resolve_bone(skeleton, &"chest")
	var hair_style := String(profile.get("hair_style", ""))
	if hair_style != "" and hair_style != "none" and head_bone != &"":
		var hair_color: Color = profile.get("hair_color", Color(0.16, 0.11, 0.07))
		var hair := BoneAttachment3D.new()
		hair.name = "Personal_Hair_PROV"
		hair.bone_name = String(head_bone)
		skeleton.add_child(hair)
		match hair_style:
			"short":
				var cap := _sphere(0.13, hair_color)
				cap.position.y = 0.06
				hair.add_child(cap)
			"long":
				var cap_long := _sphere(0.135, hair_color)
				cap_long.position.y = 0.05
				hair.add_child(cap_long)
				var fall := _box(0.2, 0.42, 0.08, hair_color)
				fall.position.y = -0.02
				fall.position.z = -0.1
				hair.add_child(fall)
	var eye_color: Color = profile.get("eye_color", Color())
	if eye_color != Color() and head_bone != &"":
		var eyes := BoneAttachment3D.new()
		eyes.name = "Personal_Eyes_PROV"
		eyes.bone_name = String(head_bone)
		skeleton.add_child(eyes)
		for side in 2:
			var eye := _sphere(0.024, eye_color)
			eye.position = Vector3(0.05 if side == 0 else -0.05, 0.02, 0.12)
			eyes.add_child(eye)
	var face_mark := String(profile.get("face_mark", ""))
	if face_mark != "" and face_mark != "none" and head_bone != &"":
		var mark := BoneAttachment3D.new()
		mark.name = "Personal_FaceMark_PROV"
		mark.bone_name = String(head_bone)
		skeleton.add_child(mark)
		var mark_color := Color(0.75, 0.1, 0.1) if face_mark == "scar" else Color(0.85, 0.72, 0.3)
		var stripe := _box(0.015, 0.11, 0.012, mark_color)
		stripe.position = Vector3(0, 0.02, 0.125)
		mark.add_child(stripe)
	var vestiment := String(profile.get("vestiment", ""))
	if vestiment != "" and vestiment != "none" and chest_bone != &"":
		var vest := BoneAttachment3D.new()
		vest.name = "Personal_Vestiment_PROV"
		vest.bone_name = String(chest_bone)
		skeleton.add_child(vest)
		var vest_color := Color(0.28, 0.14, 0.16) if vestiment == "robe" else Color(0.35, 0.36, 0.4)
		var torso := _box(0.34, 0.34, 0.24, vest_color)
		torso.position.y = 0.05
		vest.add_child(torso)

static func _find_skeleton(model: Node) -> Skeleton3D:
	for candidate in model.find_children("*", "Skeleton3D", true, false):
		return candidate as Skeleton3D
	return null

## Tintas de material (corpo/cabeça) — substituição de cor em TODOS os
## materiais por superfície marcada como corpo/cabeça do manequim PROVISÓRIO.
static func _apply_tints(skeleton: Skeleton3D, profile: Dictionary) -> void:
	var body_tint: Color = profile.get("body_tint", Color(0.16, 0.15, 0.2))
	var head_tint: Color = profile.get("head_tint", Color(0.5, 0.44, 0.38))
	var skin_names := PackedStringArray(["mat_body", "mat_head", "mat_accent"])
	for mesh_child in skeleton.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := mesh_child as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		for surface in mesh_instance.mesh.get_surface_count():
			var material := mesh_instance.get_active_material(surface)
			if material == null:
				continue
			var base := material.duplicate() as BaseMaterial3D
			if base == null:
				continue
			# Cabeça = mesh de nome "head"; corpo = o resto (convenção do manequim).
			var tint := head_tint if String(mesh_instance.name).contains("head") else body_tint
			base.albedo_color = tint
			mesh_instance.set_surface_override_material(surface, base)

## Anexa peças PROVISÓRIAS (primitivas) por osso. Cada peça se declara como
## provisória no nome do nó e no material.
static func _attach_accessories(skeleton: Skeleton3D, profile: Dictionary) -> void:
	var accessories: Variant = profile.get("accessories", PackedStringArray())
	for accessory_name: String in accessories:
		var canonical := StringName(BONE_FOR_ACCESSORY.get(StringName(accessory_name), &"head"))
		var bone := resolve_bone(skeleton, canonical)
		if bone == &"":
			push_warning("RaceVisualBuilder: osso '%s' ausente para acessório '%s'" % [canonical, accessory_name])
			continue
		var attachment := BoneAttachment3D.new()
		attachment.name = "Accessory_%s_PROV" % accessory_name
		attachment.bone_name = String(bone)
		skeleton.add_child(attachment)
		match accessory_name:
			"horn":
				attachment.add_child(_cone(0.035, 0.24, Color(0.72, 0.66, 0.52), 0.0, 0.18))
				var horn2 := _cone(0.035, 0.24, Color(0.72, 0.66, 0.52), 0.0, 0.18)
				horn2.position.x = -0.14
				attachment.get_child(0).position.x = 0.14
				attachment.add_child(horn2)
			"antler":
				attachment.add_child(_cone(0.02, 0.3, Color(0.6, 0.5, 0.36), 0.0, 0.16))
			"antenna":
				for side in 2:
					var antenna := _cylinder(0.008, 0.3, Color(0.35, 0.4, 0.38))
					antenna.position.x = 0.09 if side == 0 else -0.09
					antenna.position.z = 0.05
					antenna.rotation.x = -0.5
					attachment.add_child(antenna)
			"tail":
				var tail := _cylinder(0.045, 0.6, Color(0.2, 0.19, 0.24))
				tail.rotation.x = 1.9
				tail.position.y = 0.1
				tail.position.z = -0.18
				attachment.add_child(tail)
			"wing":
				for side in 2:
					var wing := _box(0.06, 0.5, 0.34, Color(0.45, 0.28, 0.5, 0.85))
					wing.position.x = 0.22 if side == 0 else -0.22
					wing.position.y = 0.12
					wing.rotation.z = 0.6 if side == 0 else -0.6
					attachment.add_child(wing)
			"crystal":
				var crystal := _box(0.09, 0.16, 0.09, Color(0.55, 0.75, 0.9, 0.9))
				crystal.rotation = Vector3(0.4, 0.0, 0.5)
				crystal.position.y = 0.2
				attachment.add_child(crystal)
			_:
				push_warning("RaceVisualBuilder: acessório '%s' sem peça provisória definida (registro editorial mantido)" % accessory_name)

static func _cone(radius: float, height: float, color: Color, _tilt_x: float = 0.0, _unused: float = 0.0) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = radius
	cone.height = height
	mesh_instance.mesh = cone
	mesh_instance.material_override = _material(color)
	return mesh_instance

static func _cylinder(radius: float, height: float, color: Color) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius * 0.6
	cylinder.height = height
	mesh_instance.mesh = cylinder
	mesh_instance.material_override = _material(color)
	return mesh_instance

static func _box(w: float, h: float, d: float, color: Color) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(w, h, d)
	mesh_instance.mesh = box
	mesh_instance.material_override = _material(color)
	return mesh_instance

static func _sphere(radius: float, color: Color) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	sphere.radial_segments = 10
	sphere.rings = 5
	mesh_instance.mesh = sphere
	mesh_instance.material_override = _material(color)
	return mesh_instance

static func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material
