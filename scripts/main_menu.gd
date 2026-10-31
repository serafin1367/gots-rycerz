extends Control

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#121b26")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	center.add_child(box)
	var heading := Label.new()
	heading.text = "RYCERZ"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 38)
	box.add_child(heading)
	_button(box, "Nowa gra", Callable(GameFlow, "start_game"))
	_button(box, "Wyjscie", Callable(get_tree(), "quit"))

func _button(box: VBoxContainer, caption: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(240, 48)
	button.pressed.connect(callback)
	box.add_child(button)
