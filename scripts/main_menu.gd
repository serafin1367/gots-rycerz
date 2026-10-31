extends Control

const MENU_BACKGROUND = preload("res://assets/ui/menu_background.png")

func _ready() -> void:
	var bg := TextureRect.new()
	bg.name = "MenuBackground"
	bg.texture = MENU_BACKGROUND
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var shade := ColorRect.new()
	shade.name = "MenuShade"
	shade.color = Color(0.02, 0.08, 0.15, 0.38)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	center.add_child(box)
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.02, 0.07, 0.12, 0.68)
	panel.set_corner_radius_all(12)
	box.add_theme_stylebox_override("panel", panel)
	var heading := Label.new()
	heading.text = "RYCERZ"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 38)
	box.add_child(heading)
	_button(box, "Nowa gra", Callable(GameFlow, "start_game"))
	var continue_button := _button(box, "Kontynuuj", Callable(GameFlow, "continue_game"))
	continue_button.disabled = not GameFlow.has_save()
	_button(box, "Wyjscie", Callable(get_tree(), "quit"))

func _button(box: VBoxContainer, caption: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(240, 48)
	button.pressed.connect(callback)
	box.add_child(button)
	return button
