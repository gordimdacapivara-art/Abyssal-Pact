extends Node3D
## Playtest do protótipo racial (RACE-001 + SUBRACE-001/002) — playground neutro.
##
## Constrói o visual via RaceVisualBuilder (esqueleto compartilhado do pipeline
## GLB + peças PROVISÓRIAS por osso) e valida seleção racial, carregamento de
## modelos e características. O player opcionalmente usa a classe Arcanista
## (compatibilidade racial com classes: RACE-001 compatível com todos).
##
## Controles de protótipo:
##   1 — troca para SUBRACE-001 (chifres, tinta marrom, escala 1.06)
##   2 — troca para SUBRACE-002 (antenas + cauda, tinta verde, escala 0.94)
##   R — reconstrói o visual da sub-raça corrente
##   T — alterna exibição do player de movimento

const PROTOTYPE_RACE := &"RACE-001"
const SUBRACES := ["SUBRACE-001", "SUBRACE-002"]

@onready var _preview: Node3D = get_node("Preview") as Node3D
@onready var _player: PlayerController = get_node("Player") as PlayerController
@onready var _hud: Label = get_node("HUD/Status") as Label

var _race_manager: RaceManager = null
var _current_subrace := 0
var _visual: Node3D = null
var _visual_root: Node3D = null

func _ready() -> void:
	_race_manager = Game.registry().get_system(SystemNames.RACE) as RaceManager
	if _race_manager == null:
		push_error("race_playtest: RaceManager indisponível")
		return
	if not _race_manager.has_race(PROTOTYPE_RACE):
		push_error("race_playtest: protótipo RACE-001 ausente no catálogo")
		return
	_visual_root = Node3D.new()
	_visual_root.name = "VisualRoot"
	_visual_root.position = Vector3(0, 0, 0)
	_preview.add_child(_visual_root)
	_rebuild()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		var key := (event as InputEventKey).physical_keycode
		if key == KEY_1:
			_select(0)
		elif key == KEY_2:
			_select(1)
		elif key == KEY_R:
			_rebuild()
		elif key == KEY_T:
			_player.visible = not _player.visible

func _select(subrace_index: int) -> void:
	_current_subrace = clampi(subrace_index, 0, SUBRACES.size() - 1)
	_rebuild()

## Reconstrói o visual (prova de carregamento de modelo + características).
func _rebuild() -> void:
	if _visual_root == null or _race_manager == null:
		return
	if _visual != null and is_instance_valid(_visual):
		_visual.queue_free()
	_visual = null
	await get_tree().process_frame
	_visual = RaceVisualBuilder.build(_visual_root, PROTOTYPE_RACE, StringName(SUBRACES[_current_subrace]), _race_manager)
	if _visual == null:
		push_error("race_playtest: falha ao construir visual %s/%s" % [PROTOTYPE_RACE, SUBRACES[_current_subrace]])

func _process(_delta: float) -> void:
	if _hud == null or _race_manager == null:
		return
	var race := _race_manager.get_race(PROTOTYPE_RACE)
	var subrace := _race_manager.get_subrace(StringName(SUBRACES[_current_subrace]))
	var profile := _race_manager.visual_profile_of(PROTOTYPE_RACE, StringName(SUBRACES[_current_subrace]))
	var lines := PackedStringArray()
	lines.append("[Raça] %s (%s) — protótipo visual" % [race.display_name, race.id])
	lines.append("[Sub-raça %d/2] %s (%s)" % [_current_subrace + 1, subrace.display_name, subrace.id])
	lines.append("[Corpo] tipo=%s escala=%.2f" % [
		String(profile.get("body_type", "?")), float(profile.get("scale", 1.0))])
	var accessories := PackedStringArray()
	for accessory in profile.get("accessories", PackedStringArray()):
		accessories.append(String(accessory))
	lines.append("[Acessórios] %s (peças PROVISÓRIAS)" % (", ".join(accessories) if accessories.size() > 0 else "—"))
	lines.append("[Estruturas especiais] %s" % (", ".join(profile.get("special_structures", PackedStringArray())) or "—"))
	var class_groups := race.compatible_class_groups
	lines.append("[Classes] %s" % ("grupos %s" % ", ".join(class_groups) if class_groups.size() > 0 else "compatível com TODAS (provisório)"))
	lines.append("[Modelo] %s" % String(profile.get("model_glb", "—")))
	lines.append("1/2 = trocar sub-raça | R = reconstruir visual | T = mostrar/ocultar player")
	_hud.text = "\n".join(lines)
