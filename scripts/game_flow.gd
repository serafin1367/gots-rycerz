extends Node

const LEVELS: Array[String] = ["res://scenes/game.tscn", "res://scenes/level_02.tscn", "res://scenes/level_03.tscn"]
const MAIN_MENU := "res://scenes/main_menu.tscn"
const SAVE_PATH := "user://rycerz_progress.cfg"
var save_path := SAVE_PATH
var level_index := 0
var level_seed: int = 0
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
	level_seed = randi_range(1, 2147483647)
	_save_progress(level_index)
	_open_level()

func has_save() -> bool:
	return _read_progress() >= 0

func continue_game() -> void:
	var saved := _read_progress()
	if saved < 0:
		return
	level_index = saved
	_open_level()

func _read_progress() -> int:
	if not FileAccess.file_exists(save_path):
		return -1
	var config := ConfigFile.new()
	if config.load(save_path) != OK:
		return -1
	var version: int = config.get_value("progress", "version", -1)
	if version != 1 and version != 2:
		return -1
	var value: Variant = config.get_value("progress", "level_index", -1)
	if typeof(value) != TYPE_INT:
		return -1
	if value < 0 or value >= LEVELS.size():
		return -1
	level_seed = int(config.get_value("progress", "seed", 0)) if version == 2 else 0
	if level_seed <= 0:
		level_seed = randi_range(1, 2147483647)
	return value

func _save_progress(index: int) -> bool:
	if index < 0 or index >= LEVELS.size():
		return false
	var config := ConfigFile.new()
	if level_seed <= 0:
		level_seed = randi_range(1, 2147483647)
	config.set_value("progress", "version", 2)
	config.set_value("progress", "seed", level_seed)
	config.set_value("progress", "level_index", index)
	var err := config.save(save_path)
	if err != OK:
		push_warning("Nie udalo sie zapisac postepu: %s" % err)
		return false
	return true

func _open_level() -> void:
	_clear_pause()
	get_tree().change_scene_to_file(LEVELS[level_index])

func complete_level() -> void:
	if paused:
		return
	_save_progress(mini(level_index + 1, LEVELS.size() - 1))
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
