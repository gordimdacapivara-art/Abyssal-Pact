class_name AnimationTreeBuilder
extends RefCounted
## Construtor de AnimationTree PADRÃO para qualquer modelo do pipeline GLB.
##
## Garante a regra de compatibilidade: TODO modelo exportado cujos clipes
## seguem o contrato de nomes (PlayerAnimator.ANIM) é operável por uma
## AnimationTree idêntica, construída em runtime sobre a biblioteca do
## AnimationPlayer importado (biblioteca compartilhada, sem duplicação).
##
## Estrutura gerada: máquina de estados com um nó por clipe disponível,
## transição automática entre todos os nós (crossfade) e auto-loop
## (AT_END) nos clipes de locomoção/queda. Estados ausentes no modelo
## simplesmente não existem — o driver avisa e continua.

const XFADE_TIME := 0.18
const LOOP_XFADE_TIME := 0.12

## Constrói a AnimationTree (NÃO ativa: o chamador adiciona à árvore e
## define active = true). Bibliotecas são COMPARTILHADAS com o player.
static func build(anim_player: AnimationPlayer, looping_clips: PackedStringArray = PackedStringArray()) -> AnimationTree:
	if anim_player == null:
		return null
	var tree := AnimationTree.new()
	tree.name = "AnimationTree"
	for library_name in anim_player.get_animation_library_list():
		var library := anim_player.get_animation_library(library_name)
		tree.add_animation_library(library_name, library)
	var available := _available_clips(anim_player)
	var machine := AnimationNodeStateMachine.new()
	var column := 0.0
	for clip_name in available:
		var node := AnimationNodeAnimation.new()
		node.animation = StringName(clip_name)
		machine.add_node(StringName(clip_name), node, Vector2(column, 0.0))
		column += 150.0
	for i in available.size():
		for j in available.size():
			if i == j:
				continue
			var transition := AnimationNodeStateMachineTransition.new()
			transition.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE
			transition.xfade_time = XFADE_TIME
			machine.add_transition(StringName(available[i]), StringName(available[j]), transition)
	for clip_name in available:
		if not looping_clips.has(clip_name):
			continue
		# No Godot 4, o loop de animação é configurado no recurso Animation e
		# transições de nó para si mesmo (p_from == p_to) são proibidas pela engine C++.
		if anim_player.has_animation(clip_name):
			var anim := anim_player.get_animation(clip_name)
			if anim != null and anim.loop_mode == Animation.LOOP_NONE:
				anim.loop_mode = Animation.LOOP_LINEAR
	tree.tree_root = machine
	return tree

static func _available_clips(anim_player: AnimationPlayer) -> PackedStringArray:
	var available := PackedStringArray()
	for clip_name in anim_player.get_animation_list():
		available.append(String(clip_name))
	return available

## Nó de estado existe na máquina construída.
static func has_state(tree: AnimationTree, clip: String) -> bool:
	if tree == null or tree.tree_root == null:
		return false
	var machine := tree.tree_root as AnimationNodeStateMachine
	return machine != null and machine.has_node(StringName(clip))

## Inicia a máquina em um clipe (reset). false se o estado não existe.
static func start(tree: AnimationTree, clip: String) -> bool:
	if not has_state(tree, clip):
		return false
	var playback := _playback(tree)
	if playback == null:
		return false
	playback.start(StringName(clip), true)
	return true

## Viaja para um clipe (com crossfade). false se o estado não existe.
static func travel(tree: AnimationTree, clip: String) -> bool:
	if not has_state(tree, clip):
		return false
	var playback := _playback(tree)
	if playback == null:
		return false
	if playback.get_current_node() != StringName(clip):
		playback.travel(StringName(clip), true)
	return true

## Nó corrente da máquina ("" quando indisponível).
static func current_node(tree: AnimationTree) -> String:
	var playback := _playback(tree)
	if playback == null:
		return ""
	return String(playback.get_current_node())

static func _playback(tree: AnimationTree) -> AnimationNodeStateMachinePlayback:
	if tree == null or tree.tree_root == null:
		return null
	var value: Variant = tree.get("parameters/playback")
	return value as AnimationNodeStateMachinePlayback
