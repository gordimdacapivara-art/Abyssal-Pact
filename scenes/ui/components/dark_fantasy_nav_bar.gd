class_name DarkFantasyNavBar
extends HBoxContainer
## Barra de navegação unificada Dark Fantasy para transição rápida entre telas in-game.

signal tab_selected(screen_id: StringName)

const TABS: Array[Dictionary] = [
	{"id": &"inventory", "label": "Inventário"},
	{"id": &"equipment", "label": "Equipamentos"},
	{"id": &"abilities", "label": "Habilidades"},
	{"id": &"class_tree", "label": "Árvore"},
	{"id": &"pacts", "label": "Pactos"},
	{"id": &"world_map", "label": "Mapa Mundial"},
	{"id": &"regional_map", "label": "Mapa Regional"},
	{"id": &"codex", "label": "Códice"},
	{"id": &"bestiary", "label": "Bestiário"},
	{"id": &"quests", "label": "Missões"},
	{"id": &"party", "label": "Grupo"},
	{"id": &"settings", "label": "Opções"},
]

var _buttons: Dictionary = {} # StringName -> Button

func _init(active_screen_id: StringName = &"") -> void:
	custom_minimum_size = Vector2(0, 42)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 6)

	for tab in TABS:
		var tab_id: StringName = tab["id"]
		var btn := Button.new()
		btn.text = " " + tab["label"] + " "
		btn.custom_minimum_size = Vector2(0, 34)
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		btn.pressed.connect(func(): _on_tab_pressed(tab_id))
		add_child(btn)
		_buttons[tab_id] = btn

	set_active_tab(active_screen_id)

func set_active_tab(active_id: StringName) -> void:
	for id: StringName in _buttons.keys():
		var btn: Button = _buttons[id]
		if id == active_id:
			btn.add_theme_color_override("font_color", Color(1.0, 0.9, 0.45))
			btn.flat = false
		else:
			btn.remove_theme_color_override("font_color")
			btn.flat = true

func _on_tab_pressed(target_screen_id: StringName) -> void:
	tab_selected.emit(target_screen_id)
	var ui := Game.get_system(SystemNames.UI) as UIManager
	if ui != null:
		ui.open_screen(target_screen_id)
