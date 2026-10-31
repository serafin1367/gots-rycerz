extends Area2D

@export var glow_color := Color("#6ce5ec")
var activated := false
var phase := 0.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	var collision := CollisionShape2D.new()
	var shape := CapsuleShape2D.new()
	shape.radius = 13
	shape.height = 38
	collision.shape = shape
	add_child(collision)

func _process(delta: float) -> void:
	phase += delta
	queue_redraw()

func _draw() -> void:
	var pulse := 1.0 + 0.10 * sin(phase * 3.0)
	draw_circle(Vector2.ZERO, 10.0 * pulse, Color(0.15, 0.7, 0.95, 0.20))
	draw_arc(Vector2.ZERO, 14.0 * pulse, phase, phase + PI * 1.6, 32, glow_color, 3.0, true)
	draw_arc(Vector2.ZERO, 19.0 * pulse, -phase * 0.65, -phase * 0.65 + PI * 1.3, 32, Color("#b879fb"), 2.0, true)
	for i in range(4):
		var angle := phase * 1.4 + i * TAU / 4.0
		draw_circle(Vector2(cos(angle), sin(angle)) * (19.0 * pulse), 2.0, Color("#f9eea2"))

func _on_body_entered(body: Node2D) -> void:
	if not activated and body.is_in_group("player"):
		activated = true
		GameFlow.complete_level()
