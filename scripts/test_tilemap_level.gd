extends Node2D
## Testowa scena TileMapLayer — oryginalny atlas world_tileset.png.
## Otworz scenes/test_tilemap_level.tscn i uruchom F6.
const ATLAS = preload("res://assets/sprites/world_tileset.png")
const PLAYER = preload("res://scenes/player.tscn")
const COIN = preload("res://scenes/coin.tscn")
const SLIME = preload("res://scenes/slime.tscn")
const PORTAL_SCRIPT = preload("res://scripts/level_portal.gd")
const TILE_SIZE := 16
const GRASS := Vector2i(0, 0)
const ROCK_A := Vector2i(1, 0)
const ROCK_B := Vector2i(1, 1)
const DIRT := Vector2i(0, 1)

var terrain: TileMapLayer
var background: TileMapLayer

func _ready() -> void:
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	var source := TileSetAtlasSource.new()
	source.texture = ATLAS
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	for tile in [GRASS, ROCK_A, ROCK_B, DIRT]:
		if not source.has_tile(tile):
			source.create_tile(tile)
	tileset.add_source(source, 0)
	background = TileMapLayer.new()
	background.name = "BackgroundMap"
	background.tile_set = tileset
	background.z_index = -20
	background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(background)
	terrain = TileMapLayer.new()
	terrain.name = "TerrainMap"
	terrain.tile_set = tileset
	terrain.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(terrain)
	_make_background()
	_make_ground(0, 16, 10, 17)
	_make_ground(19, 30, 10, 17)
	_make_ground(33, 46, 10, 17)
	_make_ground(12, 15, 7, 8)
	_make_ground(27, 30, 7, 8)
	_make_objects()

func _make_background() -> void:
	# Atlas coordinates 4:9 and 4:12 are patterned transition tiles.
	# They must not be repeated as full-screen background.
	# Use clean solid colors until the atlas background regions are mapped.
	var sky := Polygon2D.new()
	sky.name = "Sky"
	sky.z_index = -30
	sky.color = Color("#1597d5")
	sky.polygon = PackedVector2Array([
		Vector2(-200, -500), Vector2(1100, -500),
		Vector2(1100, 320), Vector2(-200, 320)
	])
	add_child(sky)
	var horizon := Polygon2D.new()
	horizon.name = "DistantBlue"
	horizon.z_index = -25
	horizon.color = Color("#1964c1")
	horizon.polygon = PackedVector2Array([
		Vector2(-200, 196), Vector2(1100, 196),
		Vector2(1100, 320), Vector2(-200, 320)
	])
	add_child(horizon)

func _make_ground(start_x: int, end_x: int, top_y: int, bottom_y: int) -> void:
	for x in range(start_x, end_x):
		terrain.set_cell(Vector2i(x, top_y), 0, GRASS)
		for y in range(top_y + 1, bottom_y):
			var choice := (x * 11 + y * 7) % 4
			var fill: Vector2i = ROCK_A if choice == 0 else ROCK_B if choice == 1 else DIRT
			terrain.set_cell(Vector2i(x, y), 0, fill)
	# Collision is on the entire solid landmass, not on background tiles.
	var width := float((end_x - start_x) * TILE_SIZE)
	var height := float((bottom_y - top_y) * TILE_SIZE)
	var body := StaticBody2D.new()
	body.name = "SolidTerrain"
	body.position = Vector2((start_x + end_x) * TILE_SIZE / 2.0, (top_y + bottom_y) * TILE_SIZE / 2.0)
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, height)
	var collider := CollisionShape2D.new()
	collider.shape = shape
	body.add_child(collider)
	add_child(body)

func _make_objects() -> void:
	var player := PLAYER.instantiate()
	player.name = "Player"
	player.position = Vector2(44, 135)
	add_child(player)
	var camera := Camera2D.new()
	camera.zoom = Vector2(2.0, 2.0)
	player.add_child(camera)
	var manager := Node.new()
	manager.name = "GameManager"
	manager.set_script(preload("res://scripts/game_manager.gd"))
	add_child(manager)
	var coins := Node2D.new()
	coins.name = "Coins"
	add_child(coins)
	for x in [96.0, 150.0, 233.0, 352.0, 457.0, 607.0]:
		var coin := COIN.instantiate()
		coin.position = Vector2(x, 124)
		coins.add_child(coin)
	var enemy := SLIME.instantiate()
	enemy.name = "Slime"
	enemy.position = Vector2(620, 148)
	enemy.patrol_left = 33 * TILE_SIZE + 26
	enemy.patrol_right = 46 * TILE_SIZE - 26
	add_child(enemy)
	var portal := Area2D.new()
	portal.name = "LevelPortal"
	portal.set_script(PORTAL_SCRIPT)
	portal.position = Vector2(704, 115)
	add_child(portal)
