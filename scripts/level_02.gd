extends Node2D

const PLAYER = preload("res://scenes/player.tscn")
const PORTAL = preload("res://scripts/level_portal.gd")

func _ready() -> void:
	_make_floor(Vector2(180, 100), Vector2(410, 20))
	_make_floor(Vector2(490, 65), Vector2(160, 20))
	_make_floor(Vector2(740, 25), Vector2(190, 20))
	var player := PLAYER.instantiate()
	player.name = "Player"
	player.position = Vector2(35, 60)
	add_child(player)
	var camera := Camera2D.new()
	camera.zoom = Vector2(2.5, 2.5)
	player.add_child(camera)
	var portal := Area2D.new()
	portal.name = "LevelPortal"
	portal.set_script(PORTAL)
	portal.position = Vector2(810, -18)
	add_child(portal)
	var label := Label.new()
	label.text = "POZIOM 2 — DOTRZYJ DO PORTALU"
	label.position = Vector2(16, 0)
	add_child(label)

func _make_floor(position_value: Vector2, size_value: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = position_value
	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = size_value
	collision.shape = rectangle
	body.add_child(collision)
	var tile := Polygon2D.new()
	tile.color = Color("#529264")
	tile.polygon = PackedVector2Array([
		Vector2(-size_value.x / 2, -size_value.y / 2),
		Vector2(size_value.x / 2, -size_value.y / 2),
		Vector2(size_value.x / 2, size_value.y / 2),
		Vector2(-size_value.x / 2, size_value.y / 2)
	])
	body.add_child(tile)
	add_child(body)
