extends Node2D
## Ręcznie zaplanowany poziom demo — bez losowania.
const PLATFORM = preload("res://scenes/platform_green.tscn")
const SLIME = preload("res://scenes/slime.tscn")
const COIN = preload("res://scenes/coin.tscn")
const KILL_ZONE = preload("res://scenes/kill_zone.tscn")
const TOP_Y := 102.0
# Krótkie, przewidywalne skoki; każdy odcinek jest odtwarzalny.
const ISLAND_WIDTHS := [190, 210, 180, 225, 195, 235, 200, 215, 185, 240, 205, 220, 190, 245, 210, 260]
const GAPS := [33, 36, 40, 32, 39, 35, 41, 34, 38, 36, 42, 33, 39, 35, 40]
const ENEMY_ISLANDS := [1, 2, 4, 6, 7, 9, 11, 12, 14]
var islands: Array[Vector2] = []

func _build_layout() -> void:
	islands.clear()
	var cursor := 0.0
	for i in range(ISLAND_WIDTHS.size()):
		var width := float(ISLAND_WIDTHS[i])
		islands.append(Vector2(cursor, cursor + width))
		if i < GAPS.size():
			cursor += width + float(GAPS[i])

func _ready() -> void:
	_build_layout()
	_draw_background()
	for span in islands:
		_make_island(span.x, span.y)
	_make_step_platforms()
	_spawn_coins()
	_spawn_enemies()
	_add_death_floor()
	$Player.position = Vector2(40, TOP_Y - 28)
	$Player/Camera2D.limit_right = int(islands.back().y + 60)
	$LevelPortal.position = Vector2(islands.back().y - 48, TOP_Y - 40)

func _draw_background() -> void:
	var world_end := islands.back().y + 300.0
	var sky := Polygon2D.new()
	sky.name = "Sky"
	sky.z_index = -100
	sky.color = Color("#2379a8")
	sky.polygon = PackedVector2Array([Vector2(-200, -500), Vector2(world_end, -500), Vector2(world_end, 500), Vector2(-200, 500)])
	add_child(sky)
	var sea := Polygon2D.new()
	sea.name = "DistantWater"
	sea.z_index = -90
	sea.color = Color("#274e80")
	sea.polygon = PackedVector2Array([Vector2(-200, 154), Vector2(world_end, 154), Vector2(world_end, 500), Vector2(-200, 500)])
	add_child(sea)

func _make_island(start_x: float, end_x: float) -> void:
	var width := end_x - start_x
	var ground := StaticBody2D.new()
	ground.position = Vector2((start_x + end_x) / 2.0, TOP_Y + 26)
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, 52)
	var collider := CollisionShape2D.new()
	collider.shape = shape
	ground.add_child(collider)
	var soil := Polygon2D.new()
	soil.color = Color("#80583f")
	soil.polygon = PackedVector2Array([Vector2(-width / 2, -26), Vector2(width / 2, -26), Vector2(width / 2, 26), Vector2(-width / 2, 26)])
	ground.add_child(soil)
	add_child(ground)
	var x := start_x + 16
	while x < end_x - 10:
		var top := PLATFORM.instantiate()
		top.position = Vector2(x, TOP_Y - 5)
		add_child(top)
		x += 31

func _make_step_platforms() -> void:
	for i in range(islands.size() - 1):
		var middle: float = (islands[i].y + islands[i + 1].x) / 2.0
		var bridge := PLATFORM.instantiate()
		bridge.name = "Bridge"
		bridge.position = Vector2(middle, TOP_Y - float([28, 36, 30, 40][i % 4]))
		add_child(bridge)

func _spawn_coins() -> void:
	for i in range(islands.size()):
		var span := islands[i]
		for j in range(4):
			var coin := COIN.instantiate()
			coin.position = Vector2(lerpf(span.x + 30.0, span.y - 30.0, float(j + 1) / 5.0), TOP_Y - float([32, 40, 47, 35][j]))
			$Coins.add_child(coin)

func _spawn_enemies() -> void:
	for index in ENEMY_ISLANDS:
		var span: Vector2 = islands[index]
		var enemy := SLIME.instantiate()
		enemy.position = Vector2((span.x + span.y) / 2, TOP_Y - 12)
		enemy.patrol_left = span.x + 25
		enemy.patrol_right = span.y - 25
		add_child(enemy)

func _add_death_floor() -> void:
	var zone := KILL_ZONE.instantiate()
	zone.name = "DeathFloor"
	add_child(zone)
	var collider := CollisionShape2D.new()
	var boundary := WorldBoundaryShape2D.new()
	boundary.normal = Vector2.UP
	collider.shape = boundary
	collider.position = Vector2(0, 230)
	zone.add_child(collider)
