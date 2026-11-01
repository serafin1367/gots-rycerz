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
	var manager := level.get_node_or_null("GameManager")
	var coins := level.get_node_or_null("Coins")
	var enemy_count := level.find_children("*", "AnimatedSprite2D", true, false).filter(func(n): return n.is_in_group("enemies")).size()
	if manager == null or coins == null or coins.get_child_count() != 61 or enemy_count != 7 or level.islands.size() != 14:
		push_error("Green Islands must contain 14 sections, 61 coins and seven enemies")
		quit(1)
		return
	var first_coin: Area2D = coins.get_child(0) as Area2D
	var player: CharacterBody2D = level.get_node("Player")
	if first_coin == null or first_coin._find_game_manager() != manager:
		push_error("Procedurally spawned coin must resolve GameManager")
		quit(1)
		return
	var score_before: int = manager.score
	first_coin._on_body_entered(player)
	if manager.score != score_before + 1 or not first_coin.collected:
		push_error("Collecting a procedural coin must increment score")
		quit(1)
		return
	if not level.has_node("Player") or portal == null or portal.collision_mask != 2:
		push_error("Level 2 must have player and portal")
		quit(1)
		return
	var animated := portal.get_node_or_null("PortalAnimation") as AnimatedSprite2D
	if animated == null or animated.sprite_frames.get_frame_count("loop") != 9:
		push_error("Portal needs 9 animated frames")
		quit(1)
		return
	for i in range(level.islands.size() - 1):
		var gap: float = level.islands[i + 1].x - level.islands[i].y
		if not is_equal_approx(gap, 144.0 if i == 6 else 32.0):
			push_error("Procedural gap outside safe bounds")
			quit(1)
			return
	var shuttle := level.get_node_or_null("GapShuttle") as AnimatableBody2D
	if shuttle == null or level.has_node("GapBridge_06"):
		push_error("Wide gap must use shuttle instead of a fixed bridge")
		quit(1)
		return
	var left_edge: float = level.islands[6].y
	var right_edge: float = level.islands[7].x
	var shuttle_travel: Vector2 = shuttle.get("travel")
	if shuttle.position.x <= left_edge or shuttle.position.x >= right_edge or absf(shuttle_travel.x - 54.0) > 0.01:
		push_error("Gap shuttle must travel inside the crossing")
		quit(1)
		return
	var tilemap := level.get_node_or_null("TerrainMap") as TileMapLayer
	if tilemap == null or tilemap.get_used_cells().size() < 600:
		push_error("Green Islands must render verified terrain in TileMapLayer")
		quit(1)
		return
	if level.island_tops.size() != level.islands.size() or level.island_tops[2] == level.island_tops[0]:
		push_error("Green Islands needs deliberately varied elevations")
		quit(1)
		return
	if level.find_children("HighRoute_*", "AnimatableBody2D", true, false).size() != 10:
		push_error("Green Islands must include ten elevated route platforms")
		quit(1)
		return
	if level.find_children("MovingPlatform_*", "AnimatableBody2D", true, false).size() != 3:
		push_error("Green Islands needs three moving platforms")
		quit(1)
		return
	if level.find_children("CrumblingPlatform_*", "AnimatableBody2D", true, false).size() != 3:
		push_error("Green Islands needs three crumbling platforms")
		quit(1)
		return
	var mover: Node2D = level.get_node("MovingPlatform_04")
	var movement: Vector2 = mover.get("travel")
	if movement.x < 1.0 or float(mover.get("period")) <= 0.0:
		push_error("Moving platform requires nonzero travel and valid period")
		quit(1)
		return
	var fragile: Node = level.get_node("CrumblingPlatform_05")
	var test_bystander := Node2D.new()
	fragile._on_body_entered(test_bystander)
	if fragile.triggered:
		push_error("Only player can trigger crumbling platform")
		quit(1)
		return
	test_bystander.free()
	for enemy in level.get_children():
		if enemy.is_in_group("enemies") and (enemy.patrol_left >= enemy.position.x or enemy.patrol_right <= enemy.position.x):
			push_error("Slime patrol bounds are invalid")
			quit(1)
			return
	level.queue_free()
	await process_frame
	var finale: Node2D = load("res://scenes/level_03.tscn").instantiate()
	root.add_child(finale)
	await process_frame
	if finale.islands.size() != 16 or finale.get_node("Coins").get_child_count() != 64:
		push_error("Final demo level needs 16 fixed islands and 64 coins")
		quit(1)
		return
	if finale.get_node_or_null("LevelPortal") == null:
		push_error("Final demo level needs a completion portal")
		quit(1)
		return
	finale.queue_free()
	print("PASS: menu and three demo levels")
	quit(0)
