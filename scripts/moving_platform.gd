extends AnimatableBody2D
## Odtwarzalna platforma patrolująca nad krótką przepaścią.
@export var travel := Vector2(42.0, 0.0)
@export var period := 3.0
var origin := Vector2.ZERO
var clock := 0.0

func _ready() -> void:
	origin = position
	sync_to_physics = true

func _physics_process(delta: float) -> void:
	clock += delta
	var phase := TAU * clock / maxf(period, 0.5)
	position = origin + travel * sin(phase)
