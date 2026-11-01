extends AnimatableBody2D
## Platforma zapada się po wejściu rycerza, a potem wraca.
@export var collapse_delay := 0.55
@export var respawn_delay := 2.0
var triggered := false

func _ready() -> void:
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
	collision_layer = 1
	modulate = Color.WHITE
	triggered = false
