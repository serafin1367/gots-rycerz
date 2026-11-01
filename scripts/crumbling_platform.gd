extends AnimatableBody2D
## Platforma zapada się po wejściu rycerza, a potem wraca.
@export var collapse_delay := 0.55
@export var respawn_delay := 2.0
@export var bridge_style := false
var initial_collision_layer := 1
var triggered := false

func _ready() -> void:
	initial_collision_layer = collision_layer
	if bridge_style:
		_add_bridge_planks()
	var detector := Area2D.new()
	detector.name = "StepDetector"
	detector.collision_layer = 0
	detector.collision_mask = 2
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(28, 15)
	collider.position = Vector2(0, -8)
	collider.shape = shape
	detector.add_child(collider)
	add_child(detector)
	detector.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if triggered or not body.is_in_group("player"):
		return
	triggered = true
	modulate = Color("#ffb35a")
	await get_tree().create_timer(collapse_delay).timeout
	if not is_inside_tree():
		return
	visible = false
	collision_layer = 0
	await get_tree().create_timer(respawn_delay).timeout
	if not is_inside_tree():
		return
	visible = true
	collision_layer = initial_collision_layer
	modulate = Color.WHITE
	triggered = false

func _add_bridge_planks() -> void:
	# Własna dekoracja drewnianych desek: bez używania niepotwierdzonych kafelków atlasu.
	for i in range(3):
		var plank := Polygon2D.new()
		plank.name = "WoodPlank_%d" % i
		plank.z_index = 2
		plank.color = Color("#9e6840") if i % 2 == 0 else Color("#b7814d")
		var x := -15.0 + float(i) * 10.0
		plank.polygon = PackedVector2Array([
			Vector2(x, -5.0), Vector2(x + 9.0, -5.0),
			Vector2(x + 9.0, 0.0), Vector2(x, 0.0)
		])
		add_child(plank)
	var stripe := Line2D.new()
	stripe.name = "BridgeRope"
	stripe.z_index = 3
	stripe.width = 1.0
	stripe.default_color = Color("#e6c48b")
	stripe.points = PackedVector2Array([Vector2(-16, -6), Vector2(16, -6)])
	add_child(stripe)
