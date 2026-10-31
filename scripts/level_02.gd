extends Node2D

# Level 2 uses the same art palette and platform sprite as level 1.
const PLATFORM = preload("res://scenes/platform_green.tscn")
const SLIME = preload("res://scenes/slime.tscn")
const KILL_ZONE = preload("res://scenes/kill_zone.tscn")

const ISLANDS := [
	Vector2(0, 228), Vector2(276, 508),
	Vector2(552, 744), Vector2(792, 1000)
]

func _ready() -> void:
	_draw_background()
	for i in range(0, ISLANDS.size(), 2):
		_make_island(ISLANDS[i].x, ISLANDS[i + 1].x, 102.0)
	_add_stepping_stones()
	_add_enemies()
	_add_death_floor()

func _draw_background() -> void:
	var sky := Polygon2D.new()
	sky.name = "Sky"
	sky.z_index = -100
	sky.color = Color("#1597d5")
	sky.polygon = PackedVector2Array([
		Vector2(-200, -500), Vector2(1200, -500),
		Vector2(1200, 500), Vector2(-200, 500)
	])
	add_child(sky)
	var water := Polygon2D.new()
	water.name = "Water"
	water.z_index = -90
	water.color = Color("#1855b2")
	water.polygon = PackedVector2Array([
		Vector2(-200, 135), Vector2(1200, 135),
		Vector2(1200, 500), Vector2(-200, 500)
	])
	add_child(water)

func _make_island(start_x: float, end_x: float, top_y: float) -> void:
	var width := end_x - start_x
	var ground := StaticBody2D.new()
	ground.name = "Ground"
	ground.position = Vector2((start_x + end_x) / 2.0, top_y + 26)
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, 52)
	var collision := CollisionShape2D.new()
	collision.shape = shape
	ground.add_child(collision)
	var soil := Polygon2D.new()
	soil.color = Color("#9b633e")
	soil.polygon = PackedVector2Array([
		Vector2(-width / 2, -26), Vector2(width / 2, -26),
		Vector2(width / 2, 26), Vector2(-width / 2, 26)
	])
	ground.add_child(soil)
	add_child(ground)
	var x := start_x + 16.0
	while x < end_x - 10.0:
		var top := PLATFORM.instantiate()
		top.position = Vector2(x, top_y - 5)
		add_child(top)
		x += 31.0

func _add_stepping_stones() -> void:
	for point in [
		Vector2(212, 60), Vector2(255, 38), Vector2(297, 60),
		Vector2(475, 54), Vector2(524, 26), Vector2(572, 54),
		Vector2(720, 56), Vector2(765, 36), Vector2(809, 58),
		Vector2(394, 40), Vector2(646, 18)
	]:
		var platform := PLATFORM.instantiate()
		platform.name = "FloatingPlatform"
		platform.position = point
		add_child(platform)

func _add_enemies() -> void:
	for point in [Vector2(370, 84), Vector2(655, 84), Vector2(877, 84)]:
		var enemy := SLIME.instantiate()
		enemy.position = point
		add_child(enemy)

func _add_death_floor() -> void:
	var zone := KILL_ZONE.instantiate()
	zone.name = "DeathFloor"
	add_child(zone)
	var collision := CollisionShape2D.new()
	var boundary := WorldBoundaryShape2D.new()
	boundary.normal = Vector2.UP
	collision.shape = boundary
	collision.position = Vector2(500, 230)
	zone.add_child(collision)
