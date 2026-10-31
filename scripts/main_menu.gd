extends Control

@onready var box: VBoxContainer = $Center/Buttons

func _ready() -> void:
	var heading := Label.new()
	heading.text = "RYCERZ"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 38)
	heading.add_theme_color_override("font_color", Color.WHITE)
	box.add_child(heading)
	_button("Nowa gra", Callable(GameFlow, "start_game"))
	var continue_button := _button("Kontynuuj", Callable(GameFlow, "continue_game"))
	continue_button.disabled = not GameFlow.has_save()
	_button("Wyjscie", Callable(get_tree(), "quit"))

func _button(caption: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(240, 48)
	button.pressed.connect(callback)
	box.add_child(button)
	return button
