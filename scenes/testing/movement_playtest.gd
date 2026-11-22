extends Node3D
## Playground provisório de testes manuais do controlador do personagem.
## SEM LORE: geometria neutra para validar caminhada, corrida, sprint, salto,
## queda, aterrissagem, esquiva, colisões, câmera e interação.
##
## Execução (console):
##   Godot_v4.7.2_console.exe --path "<projeto>" res://scenes/testing/movement_playtest.tscn
##
## Controles: WASD mover · Mouse olhar · Roda zoom · Espaço saltar ·
## Shift correr (segure movendo → sprint) · Ctrl esquiva · E interagir ·
## R voltar ao spawn · ESC mostrar/ocultar mouse.
##
## Layout de prova:
##   - parede frontal (colisão de corpo), degraus + plataforma (subida/queda
##     de borda), pilar alto (variedade visual), bloco ATRÁS do spawn
##     (colisão de câmera: a câmera deve recuar aproximando-se dele).

const RESPAWN_KEY_PHYSICAL := 82 # tecla R (layout-independente)

@onready var _player: PlayerController = $Player
@onready var _spawn: Node3D = $SpawnPoint
@onready var _hud: Label = $HUD/Status

func _ready() -> void:
	var missing := PlayerInputMap.missing_actions()
	if not missing.is_empty():
		push_warning("Playtest: ações ausentes no InputMap: %s" % ", ".join(missing))
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_orient_sun()
	print("[playtest] Playground de movimentação iniciado. ESC libera o mouse.")
	_refresh_hud()

## Sol orientado por script (evita matriz de rotação manual no .tscn).
func _orient_sun() -> void:
	var sun := $SunLight as DirectionalLight3D
	if sun == null:
		return
	sun.rotation_degrees = Vector3(-50.0, -30.0, 0.0)
	sun.shadow_enabled = true

func _process(_delta: float) -> void:
	_refresh_hud()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventKey:
		var key := event as InputEventKey
		if key.pressed and not key.echo and key.physical_keycode == RESPAWN_KEY_PHYSICAL:
			_respawn()

# ------------------------------------------------------------------ INTERNO --

func _respawn() -> void:
	_player.rotation.y = 0.0
	_player.teleport_to(_spawn.global_position + Vector3.UP * 0.2)
	print("[playtest] personagem devolvido ao spawn.")

func _refresh_hud() -> void:
	if _player == null or _hud == null:
		return
	var sprint_line := "Sprint: %d%%" % int(round(_player.sprint_hold_ratio() * 100.0))
	var target := _player.interaction_target()
	var prompt := ""
	if target != null and target.has_method("interaction_prompt"):
		var value: Variant = target.call("interaction_prompt")
		prompt = String(value)
	var lines := [
		"ABYSSAL PACT — playground de movimentação (provisório, sem lore)",
		"WASD mover · Mouse olhar · Roda zoom · Espaço saltar · Shift correr (segure → sprint)",
		"Ctrl esquiva · E interagir · R spawn · ESC mouse",
		"",
		"Estado: %s" % _player.debug_summary(),
		sprint_line,
		"Alvo: %s" % (prompt if not prompt.is_empty() else "—"),
	]
	_hud.text = "\n".join(lines)
