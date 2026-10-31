extends SceneTree

var passed := 0
var failed := 0

func _initialize() -> void:
	call_deferred("_run_tests")

func check(condition: bool, message: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", message)
	else:
		failed += 1
		push_error("FAIL: " + message)

func _run_tests() -> void:
	await _test_player()
	await _test_health()
	await _test_damage_zone()
	await _test_kill_zone()
	await _test_coins()
	print("TEST RESULTS: %d passed, %d failed" % [passed, failed])
	quit(1 if failed > 0 else 0)

func _test_player() -> void:
	var player := preload("res://scenes/player.tscn").instantiate() as CharacterBody2D
	root.add_child(player)
	await process_frame
	check(player.is_in_group("player"), "Player is registered in player group")
	player.velocity.x = 130.0
	player._physics_process(0.1)
	check(is_equal_approx(player.velocity.x, 40.0), "Horizontal deceleration uses delta")
	player.queue_free()
	await process_frame

func _test_kill_zone() -> void:
	var zone := preload("res://scenes/kill_zone.tscn").instantiate()
	root.add_child(zone)
	await process_frame
	var timer := zone.get_node("Timer") as Timer
	var other := Node2D.new()
	zone._on_body_entered(other)
	check(timer.is_stopped(), "Non-player cannot trigger death")
	var player := Node2D.new()
	player.add_to_group("player")
	zone._on_body_entered(player)
	check(not timer.is_stopped(), "Player starts death timer")
	var first_time := timer.time_left
	zone._on_body_entered(player)
	check(timer.time_left <= first_time, "Repeated entry does not restart death timer")
	timer.stop()
	other.free()
	player.free()
	zone.queue_free()
	await process_frame

func _test_coins() -> void:
	var level := preload("res://scenes/game.tscn").instantiate()
	root.add_child(level)
	await process_frame
	var coins := level.find_children("*", "Area2D", true, false)
	var coin: Area2D = null
	for candidate in coins:
		if candidate.name == "Coin" and candidate.has_method("_on_body_entered"):
			coin = candidate
			break
	check(coin != null, "Game level contains a collectible coin")
	if coin != null:
		var manager := coin.get_node_or_null("%GameManager")
		check(manager != null, "Coin can reach game manager")
		if manager != null:
			var initial_score: int = manager.score
			var other := Node2D.new()
			coin._on_body_entered(other)
			check(manager.score == initial_score, "Non-player cannot collect coin")
			var player := Node2D.new()
			player.add_to_group("player")
			coin._on_body_entered(player)
			check(manager.score == initial_score + 1, "Player collects exactly one point")
			coin._on_body_entered(player)
			check(manager.score == initial_score + 1, "Coin cannot be collected twice")
			player.free()
			other.free()
	level.queue_free()
	await process_frame

func _test_health() -> void:
	var player := preload("res://scenes/player.tscn").instantiate()
	root.add_child(player)
	await process_frame
	check(player.health == 3 and not player.dead, "Player begins with three HP")
	check(player.heart_labels.size() == 3, "HUD shows three hearts")
	check(player.heart_labels[0].text == "♥", "HUD uses heart symbols")
	check(player.audio_hurt.stream != null, "Damage sound resource is loaded")
	check(player.take_damage(), "First damage is accepted")
	check(player.health == 2, "Damage removes one HP")
	check(player.audio_hurt.playing, "Damage plays hurt sound")
	check(player.heart_labels[2].get_theme_color("font_color") == Color("#4b4653"), "Lost heart is dimmed")
	check(player.heart_labels[0].get_theme_color("font_color") == Color("#ed344f"), "Remaining hearts are red")
	check(not player.take_damage() and player.health == 2, "Invulnerability blocks repeat hits")
	player.invulnerability_left = 0.0
	check(player.take_damage() and player.health == 1, "Damage after invulnerability is accepted")
	player.invulnerability_left = 0.0
	check(player.take_damage() and player.health == 0 and player.dead, "Last HP causes death")
	check(player.heart_labels[0].get_theme_color("font_color") == Color("#4b4653"), "All hearts dim when HP reaches zero")
	check(not player.take_damage(), "Dead player cannot take more damage")
	player.queue_free()
	await process_frame

func _test_damage_zone() -> void:
	var zone := Area2D.new()
	zone.set_script(load("res://scripts/damage_zone.gd"))
	root.add_child(zone)
	var player := preload("res://scenes/player.tscn").instantiate()
	root.add_child(player)
	await process_frame
	var other := Node2D.new()
	zone._on_body_entered(other)
	check(player.health == 3, "Non-player in enemy damage area is ignored")
	zone._on_body_entered(player)
	check(player.health == 2, "Enemy contact removes one HP")
	zone._on_body_entered(player)
	check(player.health == 2, "Repeated enemy contact respects invulnerability")
	other.free()
	player.queue_free()
	zone.queue_free()
	await process_frame
