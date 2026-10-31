extends RefCounted
## Single source of truth for known atlas tiles; no guessing in generators.
const PATH := "res://assets/data/world_tile_catalog.json"

static func load_catalog() -> Dictionary:
	var file := FileAccess.open(PATH, FileAccess.READ)
	if file == null:
		push_error("Missing tile catalog: " + PATH)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid tile catalog JSON")
		return {}
	return parsed

static func find_tile(id: String, allow_unconfirmed: bool = false) -> Vector2i:
	var catalog := load_catalog()
	for tile in catalog.get("tiles", []):
		if tile.get("id", "") != id:
			continue
		if not allow_unconfirmed and tile.get("confidence", "") != "confirmed":
			push_warning("Tile requires confirmation: " + id)
			return Vector2i(-1, -1)
		var coordinates: Array = tile.get("atlas", [])
		if coordinates.size() != 2:
			break
		return Vector2i(int(coordinates[0]), int(coordinates[1]))
	push_warning("Unknown atlas tile: " + id)
	return Vector2i(-1, -1)
