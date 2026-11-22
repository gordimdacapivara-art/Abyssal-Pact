class_name ModelAudit
extends RefCounted
## Auditoria de modelos GLB do pipeline Abyssal Pact (verificações 5–10).
##
## Valida TUDO que a pipeline exige, com orçamentos calibrados para o alvo
## de hardware do projeto (PC 4 GB RAM, i3 11ª geração, gráficos integrados
## Intel UHD): malhas pequenas, texturas de até 1024 px, esqueletos enxutos.
##
## Usada por: runner standalone (`tools/audit_runner.gd`, sai com código de
## saída) e suíte de testes `suite_models`. Nunca modifica o modelo: só lê.

const REFERENCE_MODEL_PATH := "res://assets/models/characters/reference/char_ref_humanoid.glb"

# ------------------------------------------------------- orçamentos (4 GB) --
const BUDGET_MAX_GLB_BYTES := 5 * 1024 * 1024 # 5 MB por personagem
const BUDGET_MAX_TRIANGLES := 50000
const BUDGET_MAX_TEXTURE_SIZE := 1024
const BUDGET_MAX_TEXTURES := 8
const BUDGET_MAX_BONES := 96
const BUDGET_MAX_MESH_OBJECTS := 12

const HEIGHT_MIN := 1.2
const HEIGHT_MAX := 2.4
const ORIGIN_TOLERANCE := 0.15

const CORE_CLIPS: PackedStringArray = ["idle", "walk", "run", "jump"]
const CONTRACT_CLIPS: PackedStringArray = [
	"idle", "walk", "run", "sprint", "jump", "fall", "land", "dodge",
]

const TEXTURE_SLOTS: PackedStringArray = [
	"albedo_texture", "normal_texture", "orm_texture", "emission_texture",
	"rim_texture", "heightmap_texture", "clearcoat_texture", "ao_texture",
]

# ------------------------------------------------------------------ relatório --

static func audit_model(path: String, issues: PackedStringArray, warnings: PackedStringArray) -> Dictionary:
	var summary := {
		"bytes": 0, "triangles": 0, "meshes": 0, "bones": 0,
		"materials": 0, "textures": [], "clips": [], "missing_core": [],
		"missing_contract": [], "height": 0.0, "origin_offset": 0.0,
	}
	if not FileAccess.file_exists(path):
		issues.append("modelo ausente: %s" % path)
		return summary

	var bytes := FileAccess.open(path, FileAccess.READ).get_length()
	summary["bytes"] = bytes
	if bytes > BUDGET_MAX_GLB_BYTES:
		issues.append("GLB acima do orçamento: %d bytes (máx %d)" % [bytes, BUDGET_MAX_GLB_BYTES])

	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		issues.append("falha ao carregar cena: %s" % path)
		return summary
	var root := packed.instantiate()
	if root == null:
		issues.append("falha ao instanciar: %s" % path)
		return summary

	_audit_meshes_and_materials(root, summary, issues, warnings)
	_audit_skeleton(root, summary, issues)
	_audit_scale(root, summary, issues)
	_audit_clips(root, summary, issues, warnings)
	root.free()
	return summary

static func audit_reference(issues: PackedStringArray, warnings: PackedStringArray) -> Dictionary:
	return audit_model(REFERENCE_MODEL_PATH, issues, warnings)

## Política ABSOLUTA: nenhum .blend/.blend1 pode existir dentro do projeto.
static func find_blend_files() -> PackedStringArray:
	var found := PackedStringArray()
	_scan_blends("res://", found)
	return found

# ------------------------------------------------------------------ INTERNO --

static func _scan_blends(dir_path: String, found: PackedStringArray) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	for entry in dir.get_files():
		if entry.ends_with(".blend") or entry.ends_with(".blend1"):
			found.append(dir_path + entry)
	for sub_dir in dir.get_directories():
		if sub_dir.begins_with("."):
			continue
		_scan_blends(dir_path.path_join(sub_dir) + "/", found)

static func _audit_meshes_and_materials(root: Node, summary: Dictionary, issues: PackedStringArray, warnings: PackedStringArray) -> void:
	var mesh_instances := root.find_children("*", "MeshInstance3D", true, false)
	var triangles := 0
	var material_count := 0
	var texture_count := 0
	for node in mesh_instances:
		var instance := node as MeshInstance3D
		var mesh := instance.mesh
		if mesh == null:
			warnings.append("MeshInstance3D sem malha: %s" % instance.name)
			continue
		triangles += mesh.get_faces().size() / 3
		for surface in mesh.get_surface_count():
			var material := instance.get_active_material(surface)
			if material == null:
				warnings.append("superfície sem material: %s/%d" % [instance.name, surface])
				continue
			material_count += 1
			if material is BaseMaterial3D:
				texture_count += _count_base_material_textures(material as BaseMaterial3D, warnings)
			elif material is ShaderMaterial:
				warnings.append("ShaderMaterial em %s (pipeline prefere BaseMaterial3D no alvo 4 GB)" % instance.name)
	summary["triangles"] = triangles
	summary["meshes"] = mesh_instances.size()
	summary["materials"] = material_count
	summary["textures"] = texture_count
	if triangles > BUDGET_MAX_TRIANGLES:
		issues.append("triângulos acima do orçamento: %d (máx %d)" % [triangles, BUDGET_MAX_TRIANGLES])
	if mesh_instances.size() > BUDGET_MAX_MESH_OBJECTS:
		issues.append("objetos de malha acima do orçamento: %d (máx %d)" % [mesh_instances.size(), BUDGET_MAX_MESH_OBJECTS])
	if material_count == 0:
		issues.append("nenhum material no modelo")

static func _count_base_material_textures(material: BaseMaterial3D, warnings: PackedStringArray) -> int:
	var count := 0
	for slot_name in TEXTURE_SLOTS:
		var texture: Variant = material.get(slot_name)
		if texture is Texture2D:
			count += 1
			var texture_resource := texture as Texture2D
			var size := texture_resource.get_size()
			if size.x > BUDGET_MAX_TEXTURE_SIZE or size.y > BUDGET_MAX_TEXTURE_SIZE:
				warnings.append("textura acima de %d px: %s (%dx%d)" % [
					BUDGET_MAX_TEXTURE_SIZE, texture_resource.resource_name, int(size.x), int(size.y)])
			if not texture_resource.resource_path.is_empty():
				warnings.append("textura externa (não embutida) em slot %s: %s" % [slot_name, texture_resource.resource_path])
	return count

static func _audit_skeleton(root: Node, summary: Dictionary, issues: PackedStringArray) -> void:
	var skeletons := root.find_children("*", "Skeleton3D", true, false)
	var bones := 0
	for node in skeletons:
		var skeleton := node as Skeleton3D
		bones += skeleton.get_bone_count()
	summary["bones"] = bones
	if bones == 0:
		issues.append("esqueleto ausente (personagens exigem Skeleton3D)")
	elif bones > BUDGET_MAX_BONES:
		issues.append("esqueleto acima do orçamento: %d ossos (máx %d)" % [bones, BUDGET_MAX_BONES])

static func _audit_scale(root: Node, summary: Dictionary, issues: PackedStringArray) -> void:
	var merged := AABB()
	var has_bounds := false
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var instance := node as MeshInstance3D
		if instance.mesh == null:
			continue
		var relative := Transform3D.IDENTITY
		var walker: Node = instance
		while walker != null and walker != root:
			if walker is Node3D:
				relative = (walker as Node3D).transform * relative
			walker = walker.get_parent()
		var world_aabb := relative * instance.mesh.get_aabb()
		merged = world_aabb if not has_bounds else merged.merge(world_aabb)
		has_bounds = true
	if not has_bounds:
		issues.append("sem malhas para auditar escala")
		return
	var height := merged.size.y
	var origin_offset := absf(merged.position.y)
	summary["height"] = height
	summary["origin_offset"] = origin_offset
	if height < HEIGHT_MIN or height > HEIGHT_MAX:
		issues.append("altura fora da faixa: %.2f m (esperado %.1f–%.1f m)" % [height, HEIGHT_MIN, HEIGHT_MAX])
	if origin_offset > ORIGIN_TOLERANCE:
		issues.append("origem fora dos pés: min_y = %.3f (tolerância %.2f)" % [merged.position.y, ORIGIN_TOLERANCE])

static func _audit_clips(root: Node, summary: Dictionary, issues: PackedStringArray, warnings: PackedStringArray) -> void:
	var mixers := root.find_children("*", "AnimationPlayer", true, false)
	if mixers.is_empty():
		issues.append("AnimationPlayer ausente (clipes do contrato não podem tocar)")
		summary["missing_core"] = Array(CONTRACT_CLIPS)
		summary["missing_contract"] = Array(CONTRACT_CLIPS)
		return
	var mixer := mixers[0] as AnimationPlayer
	var clips := PackedStringArray()
	for clip_name in mixer.get_animation_list():
		clips.append(String(clip_name))
	summary["clips"] = Array(clips)
	var missing_core := PackedStringArray()
	for clip_name in CORE_CLIPS:
		if not clips.has(clip_name):
			missing_core.append(clip_name)
	var missing_contract := PackedStringArray()
	for clip_name in CONTRACT_CLIPS:
		if not clips.has(clip_name):
			missing_contract.append(clip_name)
	summary["missing_core"] = Array(missing_core)
	summary["missing_contract"] = Array(missing_contract)
	if not missing_core.is_empty():
		issues.append("clipes centrais ausentes: %s" % ", ".join(missing_core))
	if not missing_contract.is_empty():
		warnings.append("clipes do contrato ausentes: %s" % ", ".join(missing_contract))
