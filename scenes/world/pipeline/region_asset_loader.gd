class_name RegionAssetLoader
extends RefCounted
## Sistema 12: Sistema de Carregamento de Assets 3D de Ambiente.
## Gerencia o carregamento de arquivos GLB importados do pipeline Blender,
## faz cache em memória e provê placeholders identificados para assets ausentes.

const ENVIRONMENT_MODELS_PATH := "res://assets/models/environment/"

static var _cache: Dictionary = {}

static func load_model(category: String, model_name: String) -> PackedScene:
	var key := "%s/%s" % [category.to_lower(), model_name.get_basename()]
	if _cache.has(key):
		return _cache[key]

	var full_path := "%s%s/%s.glb" % [ENVIRONMENT_MODELS_PATH, category.to_lower(), model_name.get_basename()]
	if ResourceLoader.exists(full_path):
		var packed := load(full_path) as PackedScene
		if packed != null:
			_cache[key] = packed
			return packed

	# Placeholder fallback se modelo não existir
	var placeholder := _create_placeholder_scene(category, model_name)
	_cache[key] = placeholder
	return placeholder

static func instantiate_model(category: String, model_name: String) -> Node3D:
	var packed := load_model(category, model_name)
	if packed != null:
		var inst := packed.instantiate() as Node3D
		if inst != null:
			return inst
	# Retorna nó 3D vazio caso falhe
	var fallback := Node3D.new()
	fallback.name = "Fallback_" + model_name
	return fallback

static func _create_placeholder_scene(category: String, model_name: String) -> PackedScene:
	var root := Node3D.new()
	root.name = "Placeholder_" + model_name

	var mesh_inst := MeshInstance3D.new()
	mesh_inst.name = "PlaceholderMesh"
	var box := BoxMesh.new()
	box.size = Vector3(1.5, 1.5, 1.5)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.6, 0.4, 0.2, 0.8)
	box.material = mat
	mesh_inst.mesh = box
	root.add_child(mesh_inst)

	var packed := PackedScene.new()
	packed.pack(root)
	return packed
