class_name UIManager
extends ManagerBase
## UIManager â€” camada de interface persistente + router de telas.
##
## Responsabilidade: hospedar camadas de UI que sobrevivem a trocas de cena
## (Screens/Overlay/Hud) e gerenciar uma tela ativa por vez. ConteÃºdo visual
## canÃ´nico ainda nÃ£o existe (UI_AND_MENUS.md): telas atuais sÃ£o placeholders
## arquiteturais registradas em DEFAULT_SCREENS.
##
## IntegraÃ§Ã£o:
##   - Emite (EventBus): screen_opened / screen_closed.
##   - Escuta (EventBus): game_state_changed (MENU â†’ abre tela principal),
##     notification_requested (stub de notificaÃ§Ãµes).
##   - Consome (registry): nenhum nesta etapa.
## Autoload: "UI" (cena: autoload/ui_manager.tscn).

const KEY: StringName = SystemNames.UI

## Expõe a chave constante (constantes não são sobrescíveis em GDScript).
func system_key() -> StringName:
	return KEY

## Telas reutilizáveis registradas por padrão (nome → PackedScene).
## Var (não const): registro dinâmico via register_screen() é permitido.
var _screen_scenes: Dictionary = {
	&"main_menu": preload("res://scenes/ui/screens/main_menu_screen.tscn"),
	&"character_creation": preload("res://scenes/ui/screens/character_creation_screen.tscn"),
	&"create_world": preload("res://scenes/ui/screens/create_world_screen.tscn"),
	&"join_world": preload("res://scenes/ui/screens/join_world_screen.tscn"),
	&"inventory": preload("res://scenes/ui/screens/inventory_screen.tscn"),
	&"equipment": preload("res://scenes/ui/screens/equipment_screen.tscn"),
	&"abilities": preload("res://scenes/ui/screens/abilities_screen.tscn"),
	&"class_tree": preload("res://scenes/ui/screens/class_tree_screen.tscn"),
	&"pacts": preload("res://scenes/ui/screens/pacts_screen.tscn"),
	&"world_map": preload("res://scenes/ui/screens/world_map_screen.tscn"),
	&"regional_map": preload("res://scenes/ui/screens/regional_map_screen.tscn"),
	&"codex": preload("res://scenes/ui/screens/codex_screen.tscn"),
	&"bestiary": preload("res://scenes/ui/screens/bestiary_screen.tscn"),
	&"quests": preload("res://scenes/ui/screens/quests_screen.tscn"),
	&"party": preload("res://scenes/ui/screens/party_screen.tscn"),
	&"settings": preload("res://scenes/ui/screens/settings_screen.tscn"),
	&"pause_menu": preload("res://scenes/ui/screens/pause_menu_screen.tscn"),
}

@onready var _screens: Control = $Screens
@onready var _overlay: Control = $Overlay
@onready var _hud: Control = $Hud

var _active_screen: Control = null
var _active_screen_id: StringName = &""
var _minimap_hud: Control = null
var _world_boss_widget: Control = null
var _azaroth_cinematic_alert: Control = null

func get_minimap() -> Control:
	if _minimap_hud == null:
		var packed := preload("res://scenes/ui/hud/minimap_hud.tscn") as PackedScene
		if packed != null:
			_minimap_hud = packed.instantiate() as Control
			if _hud != null:
				_hud.add_child(_minimap_hud)
	return _minimap_hud

func show_minimap() -> void:
	var m := get_minimap()
	if m != null:
		m.visible = true

func hide_minimap() -> void:
	if _minimap_hud != null:
		_minimap_hud.visible = false

func get_world_boss_widget() -> Control:
	if _world_boss_widget == null:
		var packed := preload("res://scenes/ui/hud/world_boss_widget.tscn") as PackedScene
		if packed != null:
			_world_boss_widget = packed.instantiate() as Control
			if _hud != null:
				_hud.add_child(_world_boss_widget)
	return _world_boss_widget

func show_world_boss_widget() -> void:
	var w := get_world_boss_widget()
	if w != null:
		w.visible = true

func hide_world_boss_widget() -> void:
	if _world_boss_widget != null:
		_world_boss_widget.visible = false

func get_azaroth_cinematic_alert() -> Control:
	if _azaroth_cinematic_alert == null:
		var packed := preload("res://scenes/ui/hud/azaroth_cinematic_alert.tscn") as PackedScene
		if packed != null:
			_azaroth_cinematic_alert = packed.instantiate() as Control
			if _overlay != null:
				_overlay.add_child(_azaroth_cinematic_alert)
			elif _hud != null:
				_hud.add_child(_azaroth_cinematic_alert)
	return _azaroth_cinematic_alert

func show_azaroth_cinematic_alert(region_id: StringName, region_name: String, continent_name: String, remaining_seconds: float, pos: Vector3 = Vector3.ZERO) -> void:
	var alert := get_azaroth_cinematic_alert()
	if alert != null and alert.has_method("setup_alert"):
		alert.call("setup_alert", region_id, region_name, continent_name, remaining_seconds, pos)

func hide_azaroth_cinematic_alert() -> void:
	if _azaroth_cinematic_alert != null and _azaroth_cinematic_alert.has_method("play_exit_animation"):
		_azaroth_cinematic_alert.call("play_exit_animation", false)

func initialize() -> void:
	super()
	EventBus.game_state_changed.connect(_on_game_state_changed)
	EventBus.notification_requested.connect(_on_notification_requested)
	EventBus.ui_action_requested.connect(_on_ui_action_requested)
	EventBus.world_boss_one_hour_warning.connect(_on_world_boss_one_hour_warning)
	log_info("Router de telas pronto (%d telas registradas)." % _screen_scenes.size())

# --------------------------------------------------------------------- API --

## Abre uma tela registrada, fechando a ativa. Retorno: OK / ERR_DOES_NOT_EXIST /
## ERR_UNAVAILABLE (id vazio).
func open_screen(screen_id: StringName, params: Dictionary = {}) -> Error:
	var packed: PackedScene = _screen_scenes.get(screen_id)
	if packed == null:
		log_error("Tela nÃ£o registrada: %s" % screen_id)
		return ERR_DOES_NOT_EXIST
	if _active_screen_id == screen_id and _active_screen != null:
		return ERR_ALREADY_IN_USE
	_close_active_screen()

	var screen := packed.instantiate() as Control
	if screen == null:
		log_error("Tela '%s' nÃ£o Ã© Control." % screen_id)
		return ERR_INVALID_PARAMETER
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_screens.add_child(screen)
	_active_screen = screen
	_active_screen_id = screen_id
	if screen.has_method("open"):
		screen.call("open", params)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	log_info("Tela aberta: %s." % screen_id)
	EventBus.screen_opened.emit(screen_id)
	return OK

func close_screen(screen_id: StringName) -> Error:
	if _active_screen_id != screen_id or _active_screen == null:
		return ERR_DOES_NOT_EXIST
	_close_active_screen()
	EventBus.screen_closed.emit(screen_id)
	return OK

func close_all_screens() -> void:
	_close_active_screen()

func current_screen_id() -> StringName:
	return _active_screen_id

func current_screen() -> Control:
	return _active_screen

func active_screen() -> Control:
	return _active_screen

func is_screen_open(screen_id: StringName) -> bool:
	return _active_screen_id == screen_id and _active_screen != null

## Registro dinÃ¢mico (extensÃ£o sem editar DEFAULT_SCREENS).
func register_screen(screen_id: StringName, screen_scene: PackedScene) -> Error:
	if screen_id == &"" or screen_scene == null:
		return ERR_INVALID_PARAMETER
	if _screen_scenes.has(screen_id):
		return ERR_ALREADY_EXISTS
	_screen_scenes[screen_id] = screen_scene
	return OK

## IDs registrados no router (para diagnÃ³stico/testes).
func registered_screen_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for id: StringName in _screen_scenes.keys():
		ids.append(id)
	return ids

# ------------------------------------------------------------------ INTERNO --

func _close_active_screen() -> void:
	if _active_screen == null:
		return
	if _active_screen.has_method("close"):
		_active_screen.call("close")
	_active_screen.queue_free()
	_active_screen = null
	_active_screen_id = &""

func _on_game_state_changed(from_state: int, to_state: int) -> void:
	if to_state == GameStates.State.MENU and not is_screen_open(&"main_menu"):
		open_screen(&"main_menu")

func _on_notification_requested(text: String) -> void:
	# NotificaÃ§Ãµes visuais aguardam design de UI (UI_AND_MENUS.md).
	log_info("NotificaÃ§Ã£o (stub): %s" % text)

## Fluxo de UI: o menu principal pede a criação de personagem; a tela é a
## mesma registrada no router (nada de lógica de fluxo dentro do menu).
func _on_ui_action_requested(action: StringName) -> void:
	if action == &"start_new_game":
		if not is_screen_open(&"character_creation"):
			open_screen(&"character_creation")

func _on_world_boss_one_hour_warning(remaining: float, reg_id: StringName, pos: Vector3, reg_name: String, cont_name: String) -> void:
	show_azaroth_cinematic_alert(reg_id, reg_name, cont_name, remaining, pos)

func verify() -> PackedStringArray:
	var issues := super()
	if _screens == null or _overlay == null or _hud == null:
		issues.append("camadas de UI ausentes (Screens/Overlay/Hud)")
	if _screen_scenes.is_empty():
		issues.append("nenhuma tela registrada no router")
	return issues
