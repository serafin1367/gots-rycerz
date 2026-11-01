extends Node2D
## Zielone Wyspy — ręcznie rozplanowany poziom demo, bez losowości.
## Teren jest wizualizowany przez TileMapLayer (wyłącznie zatwierdzone kafelki).
## Kolizje pozostają na prostokątnych StaticBody2D, aby krawędzie były przewidywalne.
const PLATFORM = preload("res://scenes/platform_green.tscn")
const SLIME = preload("res://scenes/slime.tscn")
const COIN = preload("res://scenes/coin.tscn")
const KILL_ZONE = preload("res://scenes/kill_zone.tscn")
const TILE_CATALOG = preload("res://scripts/world_tile_catalog.gd")
const TILE_TEXTURE = preload("res://assets/sprites/world_tileset.png")
const MOVING_PLATFORM = preload("res://scripts/moving_platform.gd")
const CRUMBLING_PLATFORM = preload("res://scripts/crumbling_platform.gd")
const TILE_SIZE := 16
const TOP_Y := 96.0
const ISLAND_COUNT := 14
const EDGE_MARGIN := 26.0
const ISLAND_WIDTHS := [192, 224, 192, 256, 208, 240, 192, 256, 224, 240, 208, 256, 224, 288]
const HEIGHT_OFFSETS := [0, 0, -16, -16, 0, 16, 0, -16, -16, 0, 16, 0, -16, 0]
const ENEMY_ISLANDS := [2, 3, 5, 7, 8, 10, 12]
const BRIDGE_RISE := [24, 32, 24, 40, 24, 32, 28, 36, 24, 32, 24, 36, 28]
var islands: Array[Vector2] = []
var island_tops: Array[float] = []
var terrain: TileMapLayer
var generation_seed: int = 20261031 # Zachowane dla testów i starszych zapisów; układ jest stały.

func _ready() -> void:
	_build_layout()
	_draw_background()
	_create_terrain_layer()
	for i in range(islands.size()):
		_make_island(i)
	_make_bridges()
	_add_special_platforms()
	_spawn_collectibles()
	_spawn_enemies()
	_add_death_floor()
	$LevelPortal.position = Vector2(islands.back().y - 42.0, island_tops.back() - 42.0)
	$Player.position = Vector2(islands[0].x + 40.0, island_tops[0] - 27.0)
	$Player/Camera2D.limit_right = int(islands.back().y + 40.0)

func _build_layout() -> void:
	islands.clear()
	island_tops.clear()
	var cursor := 0.0
	for i in range(ISLAND_COUNT):
		var width := float(ISLAND_WIDTHS[i])
		islands.append(Vector2(cursor, cursor + width))
		island_tops.append(TOP_Y + float(HEIGHT_OFFSETS[i]))
		cursor += width + 32.0

func _create_terrain_layer() -> void:
	var tiles := TileSet.new()
	tiles.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	var atlas := TileSetAtlasSource.new()
	atlas.texture = TILE_TEXTURE
	atlas.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	for id in ["grass_top", "rock_a", "rock_b", "dirt"]:
		var coord: Vector2i = TILE_CATALOG.find_tile(id)
		if coord.x < 0:
			push_error("Zielone Wyspy: niepotwierdzony kafelek: " + id)
			return
		if not atlas.has_tile(coord):
			atlas.create_tile(coord)
	tiles.add_source(atlas, 0)
	terrain = TileMapLayer.new()
	terrain.name = "TerrainMap"
	terrain.tile_set = tiles
	terrain.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(terrain)

func _draw_background() -> void:
	var end_x: float = islands.back().y + 320.0
	_add_rect("Sky", -100, Color("#77d8ed"), -200, -520, end_x, 530)
	_add_rect("DistantHills", -90, Color("#95c9aa"), -200, 45, end_x, 310)
	_add_rect("Sea", -80, Color("#2487bb"), -200, 144, end_x, 450)
	_add_rect("SeaDepth", -79, Color("#185f98"), -200, 215, end_x, 450)
	# Sylwetki wysp w oddali, w pełni dekoracyjne, bez kolizji.
	for i in range(12):
		var x := float(i * 330 - 120)
		var hill := Polygon2D.new()
		hill.name = "FarIsland"
		hill.z_index = -85
		hill.color = Color("#5aa899")
		hill.polygon = PackedVector2Array([Vector2(x, 144), Vector2(x + 40, 98), Vector2(x + 115, 82), Vector2(x + 185, 105), Vector2(x + 230, 144)])
		add_child(hill)
	# Wodospady w wybranych przepaściach: tło, a nie nowa fizyka wody.
	for i in [3, 7, 11]:
		var x: float = islands[i].y + 12.0
		_add_rect("Waterfall", -70, Color("#8ce4f1", 0.65), x, 128, x + 10, 235)
	for i in range(12):
		var cx := float(150 + i * 310)
		_add_rect("Cloud", -95, Color("#effcff", 0.78), cx, -120 - float(i % 3) * 22.0, cx + 78, -106 - float(i % 3) * 22.0)

func _add_rect(label: String, depth: int, tint: Color, left: float, top: float, right: float, bottom: float) -> void:
	var poly := Polygon2D.new()
	poly.name = label
	poly.z_index = depth
	poly.color = tint
	poly.polygon = PackedVector2Array([Vector2(left, top), Vector2(right, top), Vector2(right, bottom), Vector2(left, bottom)])
	add_child(poly)

func _make_island(index: int) -> void:
	var span := islands[index]
	var top_y := island_tops[index]
	var width: float = span.y - span.x
	var ground := StaticBody2D.new()
	ground.name = "IslandGround_%02d" % index
	ground.position = Vector2((span.x + span.y) / 2.0, top_y + 32.0)
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, 64)
	var collider := CollisionShape2D.new()
	collider.shape = shape
	ground.add_child(collider)
	add_child(ground)
	# 16-pikselowa siatka atlasu pokrywa kształt gruntu.
	var grass := TILE_CATALOG.find_tile("grass_top")
	var rock_a := TILE_CATALOG.find_tile("rock_a")
	var rock_b := TILE_CATALOG.find_tile("rock_b")
	var dirt := TILE_CATALOG.find_tile("dirt")
	var first_x := int(span.x / float(TILE_SIZE))
	var rows := int(width / float(TILE_SIZE))
	var first_y := int(top_y / float(TILE_SIZE))
	for x in range(first_x, first_x + rows):
		terrain.set_cell(Vector2i(x, first_y), 0, grass)
		for y in range(first_y + 1, first_y + 4):
			var variant: Vector2i = rock_a if (x + y) % 3 == 0 else rock_b if (x + y) % 3 == 1 else dirt
			terrain.set_cell(Vector2i(x, y), 0, variant)
	# Rozrzucone kępy traw, kamienie i drewniane słupki: dekoracja proceduralnie NIElosowa.
	for j in range(1, int(width / 56.0)):
		var dx := span.x + 24.0 + float(j) * 51.0
		_add_rect("GrassTuft", 2, Color("#2c965b"), dx, top_y - 7, dx + 4, top_y)
	if index in [0, 4, 9, 13]:
		_add_rect("SignPost", 3, Color("#765138"), span.x + 34, top_y - 28, span.x + 38, top_y - 2)
		_add_rect("SignBoard", 3, Color("#e0bd75"), span.x + 22, top_y - 29, span.x + 51, top_y - 17)

func _make_bridges() -> void:
	for i in range(ISLAND_COUNT - 1):
		var middle: float = (islands[i].y + islands[i + 1].x) / 2.0
		var ledge := PLATFORM.instantiate()
		ledge.name = "GapBridge_%02d" % i
		ledge.position = Vector2(middle, minf(island_tops[i], island_tops[i + 1]) - float(BRIDGE_RISE[i]))
		add_child(ledge)
	# Podwyższone opcjonalne pomosty, z monetami na górnej ścieżce.
	for i in [1, 4, 6, 9, 11]:
		var span := islands[i]
		for j in range(2):
			var platform := PLATFORM.instantiate()
			platform.name = "HighRoute_%02d_%d" % [i, j]
			platform.position = Vector2(span.x + 65.0 + float(j) * 46.0, island_tops[i] - 64.0 - float(j) * 12.0)
			add_child(platform)

func _add_special_platforms() -> void:
	# Sekcja 2: bezpieczny pokaz ruchomych platform nad szerokim lądem.
	for i in [4, 9, 11]:
		var mover := PLATFORM.instantiate()
		mover.name = "MovingPlatform_%02d" % i
		mover.set_script(MOVING_PLATFORM)
		mover.position = Vector2(islands[i].x + 95.0, island_tops[i] - 93.0)
		mover.travel = Vector2(32.0, 0.0)
		mover.period = 2.6 + float(i % 3) * 0.5
		add_child(mover)
	# Sekcja 3: krótkie zapadające się pomosty, nie jedyna droga na następny brzeg.
	for i in [5, 8, 12]:
		var fragile := PLATFORM.instantiate()
		fragile.name = "CrumblingPlatform_%02d" % i
		fragile.set_script(CRUMBLING_PLATFORM)
		fragile.position = Vector2(islands[i].x + 115.0, island_tops[i] - 47.0)
		add_child(fragile)
	# Przejrzyste wskazówki wizualne dla nowych mechanik.
	for i in [4, 9, 11]:
		_add_rect("MovingPlatformMarker", 1, Color("#f0d96b"), islands[i].x + 47.0, island_tops[i] - 102.0, islands[i].x + 52.0, island_tops[i] - 94.0)
	for i in [5, 8, 12]:
		_add_rect("FragilePlatformMarker", 1, Color("#d77b54"), islands[i].x + 107.0, island_tops[i] - 52.0, islands[i].x + 123.0, island_tops[i] - 49.0)

func _spawn_collectibles() -> void:
	for i in range(ISLAND_COUNT):
		var span := islands[i]
		for j in range(4):
			var coin := COIN.instantiate()
			coin.position = Vector2(lerpf(span.x + 35.0, span.y - 35.0, float(j + 1) / 5.0), island_tops[i] - float([28, 37, 31, 44][j]))
			$Coins.add_child(coin)
	# Wyróżniona nagroda za wykorzystanie górnej ścieżki.
	for i in [1, 4, 6, 9, 11]:
		var bonus := COIN.instantiate()
		bonus.position = Vector2(islands[i].x + 112, island_tops[i] - 105)
		$Coins.add_child(bonus)

func _spawn_enemies() -> void:
	for i in ENEMY_ISLANDS:
		var span := islands[i]
		var enemy := SLIME.instantiate()
		enemy.name = "IslandSlime_%02d" % i
		enemy.position = Vector2((span.x + span.y) / 2.0, island_tops[i] - 12.0)
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
	collision.position = Vector2(0, 260)
	zone.add_child(collision)
