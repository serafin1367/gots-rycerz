extends Node

const LEVELS: Array[String] = ["res://scenes/game.tscn", "res://scenes/level_02.tscn"]
const MAIN_MENU := "res://scenes/main_menu.tscn"
var level_index := 0
var paused := false
var overlay: CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		if get_tree().current_scene != null and get_tree().current_scene.scene_file_path in LEVELS:
			toggle_pause()
			get_viewport().set_input_as_handled()

func start_game() -> void:
	level_index = 0
	_open_level()

func _open_level() -> void:
	_clear_pause()
	get_tree().change_scene_to_file(LEVELS[level_index])

func complete_level() -> void:
	if paused:
		return
	paused = true
	get_tree().paused = true
	_show_overlay(true)

func next_level() -> void:
	level_index += 1
	if level_index >= LEVELS.size():
		to_menu()
	else:
		_open_level()

func toggle_pause() -> void:
	if paused:
		_clear_pause()
	else:
		paused = true
		get_tree().paused = true
		_show_overlay(false)

func retry_level() -> void:
	_open_level()

func to_menu() -> void:
	_clear_pause()
	get_tree().change_scene_to_file(MAIN_MENU)

func _clear_pause() -> void:
	paused = false
	get_tree().paused = false
	if is_instance_valid(overlay):
		overlay.queue_free()
	overlay = null

func _show_overlay(completed: bool) -> void:
	overlay = CanvasLayer.new()
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.layer = 100
	add_child(overlay)
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.04, 0.07, 0.85)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	center.add_child(box)
	var title := Label.new()
	title.text = "POZIOM UKONCZONY!" if completed else "PAUZA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	box.add_child(title)
	if completed:
		_add_button(box, "Nastepny poziom" if level_index + 1 < LEVELS.size() else "Menu glowne", next_level)
	else:
		_add_button(box, "Wznow", toggle_pause)
	_add_button(box, "Restart poziomu", retry_level)
	_add_button(box, "Menu glowne", to_menu)

func _add_button(parent: VBoxContainer, caption: String, action: Callable) -> void:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(220, 40)
	button.pressed.connect(action)
	parent.add_child(button)
