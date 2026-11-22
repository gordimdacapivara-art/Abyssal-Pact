class_name DarkFantasyTheme
extends RefCounted
## Tema visual Dark Fantasy (gerado por código para evitar parse fragile em .tres):
## elementos medievais, rúnicos, metais antigos e fundo escuro.

static func create() -> Theme:
	var theme := Theme.new()
	var font_size := 16
	theme.default_font_size = font_size

	# Estilos de painel (pedra escura com borda metálica / rúnica)
	var panel_bg := StyleBoxFlat.new()
	panel_bg.bg_color = Color(0.08, 0.07, 0.1, 0.95)
	panel_bg.border_color = Color(0.35, 0.3, 0.22, 1.0)
	panel_bg.set_border_width_all(2)
	panel_bg.set_corner_radius_all(4)
	theme.set_stylebox("panel", "Panel", panel_bg)

	var button_normal := StyleBoxFlat.new()
	button_normal.bg_color = Color(0.14, 0.12, 0.16, 1.0)
	button_normal.border_color = Color(0.45, 0.38, 0.28, 1.0)
	button_normal.set_border_width_all(2)
	button_normal.set_corner_radius_all(3)
	button_normal.content_margin_left = 12
	button_normal.content_margin_right = 12
	button_normal.content_margin_top = 8
	button_normal.content_margin_bottom = 8
	theme.set_stylebox("normal", "Button", button_normal)

	var button_hover := button_normal.duplicate() as StyleBoxFlat
	button_hover.bg_color = Color(0.22, 0.19, 0.26, 1.0)
	button_hover.border_color = Color(0.7, 0.58, 0.38, 1.0)
	theme.set_stylebox("hover", "Button", button_hover)

	var button_pressed := button_normal.duplicate() as StyleBoxFlat
	button_pressed.bg_color = Color(0.09, 0.08, 0.11, 1.0)
	button_pressed.border_color = Color(0.5, 0.4, 0.25, 1.0)
	theme.set_stylebox("pressed", "Button", button_pressed)

	var button_disabled := button_normal.duplicate() as StyleBoxFlat
	button_disabled.bg_color = Color(0.06, 0.05, 0.07, 0.6)
	button_disabled.border_color = Color(0.18, 0.16, 0.15, 0.5)
	theme.set_stylebox("disabled", "Button", button_disabled)

	# Cores de texto
	theme.set_color("font_color", "Button", Color(0.85, 0.8, 0.72))
	theme.set_color("font_hover_color", "Button", Color(1.0, 0.94, 0.8))
	theme.set_color("font_pressed_color", "Button", Color(0.9, 0.75, 0.45))
	theme.set_color("font_disabled_color", "Button", Color(0.4, 0.38, 0.35))
	theme.set_color("font_color", "Label", Color(0.82, 0.78, 0.7))
	theme.set_color("font_color", "LineEdit", Color(0.9, 0.88, 0.82))

	var line_normal := StyleBoxFlat.new()
	line_normal.bg_color = Color(0.05, 0.04, 0.06, 1.0)
	line_normal.border_color = Color(0.38, 0.32, 0.24, 1.0)
	line_normal.set_border_width_all(2)
	line_normal.set_corner_radius_all(3)
	line_normal.content_margin_left = 10
	line_normal.content_margin_right = 10
	line_normal.content_margin_top = 6
	line_normal.content_margin_bottom = 6
	theme.set_stylebox("normal", "LineEdit", line_normal)
	theme.set_stylebox("focus", "LineEdit", line_normal)

	return theme
