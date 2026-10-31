extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var menu: Control = load("res://scenes/main_menu.tscn").instantiate()
	root.add_child(menu)
	await process_frame
	if menu.get_child_count() == 0:
		push_error("Main menu is empty")
		quit(1)
		return
	menu.queue_free()
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
