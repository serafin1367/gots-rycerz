extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game_flow := root.get_node("/root/GameFlow")
	var original_path: String = game_flow.save_path
	game_flow.save_path = "user://progress_ci_test.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game_flow.save_path))
	if game_flow.has_save():
		push_error("Missing save must be detected")
		quit(1)
		return
	var menu: Control = load("res://scenes/main_menu.tscn").instantiate()
	root.add_child(menu)
	await process_frame
	var background := menu.get_node_or_null("MenuBackground") as TextureRect
	if background == null or background.texture == null or background.anchor_right != 1.0 or background.anchor_bottom != 1.0 or background.texture.get_width() < 384:
		push_error("Main menu background texture is missing")
		quit(1)
		return
	if menu.get_child_count() == 0:
		push_error("Main menu is empty")
		quit(1)
		return
	var continue_button: Button = null
	for button in menu.find_children("*", "Button", true, false):
		if button.text == "Kontynuuj":
			continue_button = button
	if continue_button == null or not continue_button.disabled:
		push_error("Continue must be disabled without save")
		quit(1)
		return
	menu.queue_free()
	if not game_flow._save_progress(1) or not game_flow.has_save() or game_flow._read_progress() != 1:
		push_error("Valid progress must be persisted")
		quit(1)
		return
	var resumed_menu: Control = load("res://scenes/main_menu.tscn").instantiate()
	root.add_child(resumed_menu)
	await process_frame
	var enabled := false
	for button in resumed_menu.find_children("*", "Button", true, false):
		if button.text == "Kontynuuj" and not button.disabled:
			enabled = true
	if not enabled:
		push_error("Continue must be enabled after save")
		quit(1)
		return
	resumed_menu.queue_free()
	var config := ConfigFile.new()
	config.set_value("progress", "version", 1)
	config.set_value("progress", "level_index", 999)
	config.save(game_flow.save_path)
	if game_flow.has_save():
		push_error("Invalid progress must be rejected")
		quit(1)
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(game_flow.save_path))
	game_flow.save_path = original_path
	var level: Node2D = load("res://scenes/level_02.tscn").instantiate()
	root.add_child(level)
	await process_frame
	var portal := level.get_node_or_null("LevelPortal") as Area2D
	if not level.has_node("Player") or portal == null or portal.collision_mask != 2:
		push_error("Level 2 must have player and portal")
		quit(1)
		return
	var animated := portal.get_node_or_null("PortalAnimation") as AnimatedSprite2D
	if animated == null or animated.sprite_frames.get_frame_count("loop") != 9:
		push_error("Portal needs 9 animated frames")
		quit(1)
		return
	level.queue_free()
	print("PASS: main menu and second level portal")
	quit(0)
