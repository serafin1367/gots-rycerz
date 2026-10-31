extends AnimatedSprite2D

const SPEED = 50
@export_range(1, 10) var max_health: int = 1
var health: int = 1
# Optional safe patrol bounds set by the procedural level.
var patrol_left: float = -INF
var patrol_right: float = INF

func _ready() -> void:
	add_to_group("enemies")
	health = max_health

func take_damage(amount: int = 1) -> void:
	if amount <= 0 or health <= 0:
		return
	health = maxi(0, health - amount)
	if health == 0:
		queue_free()

var direction = 1

@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var slime: AnimatedSprite2D = $"."


func _process(delta: float) -> void:
	if position.x >= patrol_right:
		direction = -1
		slime.flip_h = true
	elif position.x <= patrol_left:
		direction = 1
		slime.flip_h = false
	elif ray_cast_right.is_colliding():
		direction = -1
		slime.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		slime.flip_h = false
	position.x = clampf(position.x + direction * SPEED * delta, patrol_left, patrol_right)
