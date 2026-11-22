class_name DarkFantasyHeader
extends HBoxContainer
## Barra de cabeçalho padrão Dark Fantasy para telas de interface.

signal close_requested

var _title_label: Label
var _subtitle_label: Label
var _close_btn: Button

func _init(title_text: String = "TELA", subtitle_text: String = "") -> void:
	custom_minimum_size = Vector2(0, 48)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 12)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(title_box)

	_title_label = Label.new()
	_title_label.text = "❖  %s  ❖" % title_text.to_upper()
	_title_label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
	_title_label.add_theme_font_size_override("font_size", 20)
	title_box.add_child(_title_label)

	_subtitle_label = Label.new()
	_subtitle_label.text = subtitle_text
	_subtitle_label.add_theme_color_override("font_color", Color(0.7, 0.65, 0.6))
	_subtitle_label.add_theme_font_size_override("font_size", 12)
	_subtitle_label.visible = not subtitle_text.is_empty()
	title_box.add_child(_subtitle_label)

	_close_btn = Button.new()
	_close_btn.text = "  ✕  "
	_close_btn.custom_minimum_size = Vector2(36, 36)
	_close_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_close_btn.pressed.connect(func(): close_requested.emit())
	add_child(_close_btn)

func set_title(title_text: String) -> void:
	_title_label.text = "❖  %s  ❖" % title_text.to_upper()

func set_subtitle(subtitle_text: String) -> void:
	_subtitle_label.text = subtitle_text
	_subtitle_label.visible = not subtitle_text.is_empty()

func set_close_visible(visible_state: bool) -> void:
	_close_btn.visible = visible_state
