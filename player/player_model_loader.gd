class_name PlayerModelLoader
extends RefCounted
## Anexa um modelo GLB do pipeline ao controlador do personagem.
##
## Responsabilidades: instanciar o GLB no ModelSlot, ocultar o visual
## PROVISÓRIO (cápsula), descobrir o AnimationPlayer importado e ligar o
## PlayerAnimator a ele (AnimationTree padrão via AnimationTreeBuilder).
## NÃO altera física, colisões ou estados — só a apresentação e a animação.
##
## Uso: PlayerModelLoader.attach(player, caminho_do_glb) → raiz do modelo
## (null quando o modelo não existe — o controlador segue com o placeholder).

const REFERENCE_MODEL_PATH := "res://assets/models/characters/reference/char_ref_humanoid.glb"

## Nós do placeholder que são ocultados quando um modelo real entra.
const PLACEHOLDER_NODE_NAMES: PackedStringArray = ["Body", "FaceMark"]

static func attach(player: PlayerController, model_path: String) -> Node3D:
	if player == null:
		return null
	if not ResourceLoader.exists(model_path):
		return null
	var packed: PackedScene = load(model_path) as PackedScene
	if packed == null:
		push_warning("PlayerModelLoader: falha ao carregar %s" % model_path)
		return null
	var model := packed.instantiate() as Node3D
	if model == null:
		push_warning("PlayerModelLoader: raiz de %s não é Node3D" % model_path)
		return null

	var slot := player.model_slot()
	if slot == null:
		slot = player
	slot.add_child(model)
	_hide_placeholder(slot)

	var mixer := _find_mixer(model)
	if mixer != null:
		var animator := player.animator()
		if animator != null:
			animator.bind_animation_player(mixer)
	var skeleton := _find_skeleton(model)
	if skeleton == null:
		push_warning("PlayerModelLoader: %s sem Skeleton3D (esqueleto ausente)" % model_path)
	return model

# ------------------------------------------------------------------ INTERNO --

static func _hide_placeholder(slot: Node) -> void:
	for visual_name in PLACEHOLDER_NODE_NAMES:
		var placeholder := slot.get_node_or_null(NodePath(visual_name)) as Node3D
		if placeholder != null:
			placeholder.visible = false

static func _find_mixer(model: Node) -> AnimationPlayer:
	var candidates := model.find_children("*", "AnimationPlayer", true, false)
	for candidate in candidates:
		return candidate as AnimationPlayer
	return null

static func _find_skeleton(model: Node) -> Skeleton3D:
	var candidates := model.find_children("*", "Skeleton3D", true, false)
	for candidate in candidates:
		return candidate as Skeleton3D
	return null
