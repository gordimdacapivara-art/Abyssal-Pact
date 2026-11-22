class_name ItemSlotUI
extends PanelContainer
## Célula de inventário ou slot de equipamento com indicador de raridade Dark Fantasy.

signal slot_clicked(slot_ui: ItemSlotUI)
signal slot_hovered(slot_ui: ItemSlotUI)

const RARITY_COLORS := {
	"common": Color(0.55, 0.52, 0.48),
	"uncommon": Color(0.28, 0.72, 0.35),
	"rare": Color(0.25, 0.55, 0.92),
	"epic": Color(0.68, 0.32, 0.88),
	"legendary": Color(0.95, 0.75, 0.22),
	"abyssal": Color(0.85, 0.18, 0.22),
}

var item_data: EquipmentData = null
var quantity: int = 0
var slot_name: StringName = &""
var is_selected: bool = false

var _label_name: Label
var _label_qty: Label
var _label_type: Label
var _style: StyleBoxFlat

func _init(p_item: EquipmentData = null, p_quantity: int = 1, p_slot_name: StringName = &"") -> void:
	item_data = p_item
	quantity = p_quantity
	slot_name = p_slot_name
	custom_minimum_size = Vector2(80, 80)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER

	_style = StyleBoxFlat.new()
	_style.bg_color = Color(0.07, 0.06, 0.08, 0.95)
	_style.set_border_width_all(2)
	_style.set_corner_radius_all(4)
	add_theme_stylebox_override("panel", _style)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 2)
	add_child(vbox)

	_label_name = Label.new()
	_label_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label_name.add_theme_font_size_override("font_size", 10)
	vbox.add_child(_label_name)

	_label_type = Label.new()
	_label_type.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label_type.add_theme_font_size_override("font_size", 9)
	_label_type.add_theme_color_override("font_color", Color(0.6, 0.55, 0.5))
	vbox.add_child(_label_type)

	_label_qty = Label.new()
	_label_qty.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_label_qty.add_theme_font_size_override("font_size", 10)
	_label_qty.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
	vbox.add_child(_label_qty)

	update_display()

func set_item(p_item: EquipmentData, p_quantity: int = 1) -> void:
	item_data = p_item
	quantity = p_quantity
	update_display()

func set_selected(selected: bool) -> void:
	is_selected = selected
	update_border()

func update_display() -> void:
	if item_data != null:
		_label_name.text = item_data.display_name
		_label_type.text = String(item_data.slot) if String(item_data.slot) != "none" else String(item_data.category)
		_label_qty.text = "x%d" % quantity if quantity > 1 else ""
		_label_qty.visible = quantity > 1
		tooltip_text = "%s\n[%s — %s]\n%s" % [
			item_data.display_name,
			String(item_data.rarity).to_upper(),
			String(item_data.category).capitalize(),
			item_data.description
		]
	else:
		_label_name.text = "Vazio" if slot_name.is_empty() else String(slot_name).capitalize()
		_label_type.text = ""
		_label_qty.text = ""
		_label_qty.visible = false
		tooltip_text = "Slot vazio (%s)" % String(slot_name) if not slot_name.is_empty() else "Slot vazio"

	update_border()

func update_border() -> void:
	if is_selected:
		_style.border_color = Color(1.0, 0.9, 0.3)
		_style.set_border_width_all(3)
	elif item_data != null:
		var rarity_key := String(item_data.rarity).to_lower()
		_style.border_color = RARITY_COLORS.get(rarity_key, Color(0.4, 0.35, 0.3))
		_style.set_border_width_all(2)
	else:
		_style.border_color = Color(0.25, 0.22, 0.2, 0.7)
		_style.set_border_width_all(1)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		slot_clicked.emit(self)
