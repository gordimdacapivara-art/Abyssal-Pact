class_name PlayerAnimator
extends Node
## Driver de animação do personagem.
##
## Dois caminhos, com prioridade:
##   1. MODELO DO PIPELINE (GLB): quando um modelo é anexado
##      (PlayerModelLoader), este driver é ligado ao AnimationPlayer do GLB
##      e opera uma AnimationTree PADRÃO construída por AnimationTreeBuilder
##      (máquina de estados com auto-loop e crossfades).
##   2. CONTRATO ESTÁTICO (cena player.tscn): AnimationPlayer/AnimationTree
##      declarados na cena (futuro GLB embutido na cena); sem clipes, avisa
##      uma vez por nome e nunca quebra o controlador.
##
## CONTRATO DE NOMES (estável — renomear aqui exige renomear os clipes):
##   idle, walk, run, sprint, jump, fall, land, dodge.

const TREE_PLAYBACK_PARAM := "parameters/playback"
const DEFAULT_BLEND := 0.15

## Clipes que devem rodar em loop contínuo (locomoção + queda).
const LOOPING_CLIPS: PackedStringArray = ["idle", "walk", "run", "sprint", "fall"]

## Âncora estado → nome de clipe.
const ANIM := {
	MovementStates.State.IDLE: "idle",
	MovementStates.State.WALK: "walk",
	MovementStates.State.RUN: "run",
	MovementStates.State.SPRINT: "sprint",
	MovementStates.State.RISE: "jump",
	MovementStates.State.FALL: "fall",
	MovementStates.State.LAND: "land",
	MovementStates.State.DODGE: "dodge",
}

@export var animation_player_path: NodePath = ^"../AnimationPlayer"
@export var animation_tree_path: NodePath = ^"../AnimationTree"
@export var build_tree_from_model := true

var _player: AnimationPlayer = null
var _tree: AnimationTree = null
var _model_mixer: AnimationPlayer = null
var _model_tree: AnimationTree = null
var _warned: Dictionary = {}
var _current_clip := ""

func _ready() -> void:
	_player = get_node_or_null(animation_player_path) as AnimationPlayer
	_tree = get_node_or_null(animation_tree_path) as AnimationTree
	if _player == null and _tree == null:
		_warn_once("nenhum AnimationPlayer/AnimationTree atribuído")

## Liga o driver ao AnimationPlayer de um modelo GLB anexado
## (PlayerModelLoader). Constrói a AnimationTree padrão quando possível.
func bind_animation_player(mixer: AnimationPlayer, use_tree: bool = build_tree_from_model) -> void:
	_model_mixer = mixer
	if mixer == null:
		_warn_once("modelo sem AnimationPlayer; sem animação")
		return
	_tree = null # cenário estático perde prioridade
	if use_tree:
		var tree := AnimationTreeBuilder.build(mixer, LOOPING_CLIPS)
		if tree != null and mixer.get_parent() != null:
			mixer.get_parent().add_child(tree)
			tree.active = true
			_model_tree = tree
			AnimationTreeBuilder.start(tree, String(ANIM[MovementStates.State.IDLE]))

func update(state: int, speed_ratio: float = 0.0) -> void:
	var clip := String(ANIM.get(state, ""))
	if clip.is_empty():
		return
	if uses_tree():
		if _model_tree != null:
			# Reemite o travel enquanto a máquina não chegar ao destino: um
			# travel emitido durante crossfade ativo é descartado pelo
			# playback, e o update seguinte (chamado todo frame pelo
			# controlador) retoma a viagem até o nó corrente ser o pedido.
			if AnimationTreeBuilder.current_node(_model_tree) != clip:
				if not AnimationTreeBuilder.travel(_model_tree, clip):
					_warn_once("estado ausente no AnimationTree do modelo: %s" % clip)
		elif _tree != null:
			_travel_tree(clip)
		return
	_play_player(clip)

## true quando uma máquina de estados está no comando (modelo ou cena).
func uses_tree() -> bool:
	if _model_tree != null:
		return _model_tree.active and _model_tree.tree_root != null
	if _tree == null or _tree.tree_root == null or not _tree.active:
		return false
	var playback: Variant = _tree.get(TREE_PLAYBACK_PARAM)
	return playback is AnimationNodeStateMachinePlayback

func has_clip(clip_name: String) -> bool:
	var mixer := _active_mixer()
	return mixer != null and mixer.has_animation(clip_name)

## Clipe corrente no caminho direto ("" quando usa AnimationTree).
func current_clip() -> String:
	return _current_clip

## Estado corrente da máquina (modelo ou cena; "" quando indisponível).
func current_node() -> String:
	if _model_tree != null:
		return AnimationTreeBuilder.current_node(_model_tree)
	if _tree != null:
		var playback: Variant = _tree.get(TREE_PLAYBACK_PARAM)
		if playback is AnimationNodeStateMachinePlayback:
			return String((playback as AnimationNodeStateMachinePlayback).get_current_node())
	return ""

# ------------------------------------------------------------------ INTERNO --

func _active_mixer() -> AnimationPlayer:
	if _model_mixer != null:
		return _model_mixer
	return _player

func _travel_tree(clip: String) -> void:
	var playback: Variant = _tree.get(TREE_PLAYBACK_PARAM)
	if playback is AnimationNodeStateMachinePlayback:
		var sm := playback as AnimationNodeStateMachinePlayback
		if sm.get_current_node() != StringName(clip):
			sm.travel(StringName(clip), true)
		_current_clip = clip
	else:
		_warn_once("AnimationTree sem playback de máquina de estados")

func _play_player(clip: String) -> void:
	var mixer := _active_mixer()
	if mixer == null:
		_warn_once("sem AnimationPlayer")
		return
	if not mixer.has_animation(clip):
		_warn_once("clipe ausente: %s" % clip)
		return
	# Fallback sem AnimationTree: garante loop dos clipes contínuos.
	if LOOPING_CLIPS.has(clip):
		mixer.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
	if _current_clip == clip:
		return
	mixer.play(clip, DEFAULT_BLEND)
	_current_clip = clip

func _warn_once(message: String) -> void:
	if _warned.has(message):
		return
	_warned[message] = true
	push_warning("PlayerAnimator: %s" % message)
