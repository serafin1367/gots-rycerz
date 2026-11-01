extends Node2D

# Reproducible, bounded procedural stage; layout is safe for 130 px/s and 300 px/s jump.
const PLATFORM = preload("res://scenes/platform_green.tscn")
const SLIME = preload("res://scenes/slime.tscn")
const COIN = preload("res://scenes/coin.tscn")
const KILL_ZONE = preload("res://scenes/kill_zone.tscn")
const ISLAND_COUNT := 14
const TOP_Y := 102.0
const GAP_MIN := 28.0
const GAP_MAX := 43.0
const EDGE_MARGIN := 24.0
var generation_seed: int = 0
var islands: Array[Vector2] = []

func _ready() -> void:
	generation_seed = 20261031 # Stała wersja demo; bez zmiany układu pomiędzy rozgrywkami
	var rng := RandomNumberGenerator.new()
	rng.seed = generation_seed
	_generate_layout(rng)
	_draw_background()
	for span in islands:
		_make_island(span.x, span.y)
	_make_bridges(rng)
	_spawn_collectibles(rng)
	_spawn_enemies()
	_add_death_floor()
	$LevelPortal.position = Vector2(islands.back().y - 38.0, TOP_Y - 40.0)
	$Player.position = Vector2(islands[0].x + 38.0, TOP_Y - 25.0)
	$Player/Camera2D.limit_right = int(islands.back().y + 40.0)

func _generate_layout(rng: RandomNumberGenerator) -> void:
	islands.clear()
	var cursor := 0.0
	for i in range(ISLAND_COUNT):
		var width := float([190, 220, 185, 245, 205, 230, 180, 250, 210, 235, 195, 240, 205, 270][i])
		islands.append(Vector2(cursor, cursor + width))
		cursor += width + float([32, 38, 35, 40, 33, 42, 34, 39, 36, 41, 33, 38, 35, 32][i])

func _draw_background() -> void:
	var width: float = islands.back().y + 300.0
	var sky := Polygon2D.new()
	sky.name = "Sky"
	sky.z_index = -100
	sky.color = Color("#1597d5")
	sky.polygon = PackedVector2Array([Vector2(-200, -500), Vector2(width, -500), Vector2(width, 500), Vector2(-200, 500)])
	add_child(sky)
	var water := Polygon2D.new()
	water.name = "Water"
	water.z_index = -90
	water.color = Color("#1855b2")
	water.polygon = PackedVector2Array([Vector2(-200, 135), Vector2(width, 135), Vector2(width, 500), Vector2(-200, 500)])
	add_child(water)

func _make_island(start_x: float, end_x: float) -> void:
	var width := end_x - start_x
	var ground := StaticBody2D.new()
	ground.name = "Ground"
	ground.position = Vector2((start_x + end_x) / 2.0, TOP_Y + 26.0)
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, 52)
	var collision := CollisionShape2D.new()
	collision.shape = shape
	ground.add_child(collision)
	var soil := Polygon2D.new()
	soil.color = Color("#9b633e")
	soil.polygon = PackedVector2Array([Vector2(-width / 2, -26), Vector2(width / 2, -26), Vector2(width / 2, 26), Vector2(-width / 2, 26)])
	ground.add_child(soil)
	add_child(ground)
	var x := start_x + 16.0
	while x < end_x - 10.0:
		var top := PLATFORM.instantiate()
		top.position = Vector2(x, TOP_Y - 5.0)
		add_child(top)
		x += 31.0

func _make_bridges(rng: RandomNumberGenerator) -> void:
	for i in range(ISLAND_COUNT - 1):
		var gap_middle: float = (islands[i].y + islands[i + 1].x) / 2.0
		var bridge := PLATFORM.instantiate()
		bridge.name = "GapBridge"
		bridge.position = Vector2(gap_middle, TOP_Y - float(rng.randi_range(26, 38)))
		add_child(bridge)

func _spawn_collectibles(rng: RandomNumberGenerator) -> void:
	for i in range(ISLAND_COUNT):
		var span := islands[i]
		for j in range(4):
			var coin := COIN.instantiate()
			coin.position = Vector2(lerpf(span.x + 32.0, span.y - 32.0, float(j + 1) / 5.0), TOP_Y - float(rng.randi_range(26, 48)))
			$Coins.add_child(coin)

func _spawn_enemies() -> void:
	for i in [1, 3, 4, 6, 8, 10, 12]:
		var span := islands[i]
		var enemy := SLIME.instantiate()
		enemy.position = Vector2((span.x + span.y) / 2.0, TOP_Y - 12.0)
		enemy.patrol_left = span.x + EDGE_MARGIN
		enemy.patrol_right = span.y - EDGE_MARGIN
		add_child(enemy)

func _add_death_floor() -> void:
	var zone := KILL_ZONE.instantiate()
	zone.name = "DeathFloor"
	add_child(zone)
	var collision := CollisionShape2D.new()
	var boundary := WorldBoundaryShape2D.new()
	boundary.normal = Vector2.UP
	collision.shape = boundary
	collision.position = Vector2(0, 230)
	zone.add_child(collision)
