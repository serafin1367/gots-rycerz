extends Node2D
## Ręcznie zaplanowany poziom demo — bez losowania.
const PLATFORM = preload("res://scenes/platform_green.tscn")
const SLIME = preload("res://scenes/slime.tscn")
const COIN = preload("res://scenes/coin.tscn")
const KILL_ZONE = preload("res://scenes/kill_zone.tscn")
const TOP_Y := 102.0
# Krótkie, przewidywalne skoki; każdy odcinek jest odtwarzalny.
const ISLANDS := [
	Vector2(0, 190),
	Vector2(222, 400),
	Vector2(436, 625),
	Vector2(661, 855),
	Vector2(891, 1110),
	Vector2(1145, 1390)
]
const COIN_X := [60, 110, 160, 265, 315, 365, 480, 540, 595, 705, 755, 810, 940, 1000, 1060, 1195, 1270, 1340]
const ENEMY_ISLANDS := [1, 2, 3, 4]

func _ready() -> void:
	_draw_background()
	for span in ISLANDS:
		_make_island(span.x, span.y)
	_make_step_platforms()
	_spawn_coins()
	_spawn_enemies()
	_add_death_floor()
	$Player.position = Vector2(40, TOP_Y - 28)
	$Player/Camera2D.limit_right = 1450
	$LevelPortal.position = Vector2(1340, TOP_Y - 40)

func _draw_background() -> void:
	var sky := Polygon2D.new()
	sky.name = "Sky"
	sky.z_index = -100
	sky.color = Color("#2379a8")
	sky.polygon = PackedVector2Array([Vector2(-200, -500), Vector2(1650, -500), Vector2(1650, 500), Vector2(-200, 500)])
	add_child(sky)
	var sea := Polygon2D.new()
	sea.name = "DistantWater"
	sea.z_index = -90
	sea.color = Color("#274e80")
	sea.polygon = PackedVector2Array([Vector2(-200, 154), Vector2(1650, 154), Vector2(1650, 500), Vector2(-200, 500)])
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
	for p in [Vector2(206, 73), Vector2(418, 63), Vector2(643, 70), Vector2(873, 66), Vector2(1127, 70)]:
		var bridge := PLATFORM.instantiate()
		bridge.position = p
		add_child(bridge)

func _spawn_coins() -> void:
	for x in COIN_X:
		var coin := COIN.instantiate()
		coin.position = Vector2(x, TOP_Y - 31)
		$Coins.add_child(coin)

func _spawn_enemies() -> void:
	for index in ENEMY_ISLANDS:
		var span: Vector2 = ISLANDS[index]
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
