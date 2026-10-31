extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const DECELERATION = 900.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_jump: AudioStreamPlayer = $AudioJump

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	var on_floor := is_on_floor()

	if not on_floor:
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and on_floor:
		velocity.y = JUMP_VELOCITY
		audio_jump.play()
		on_floor = false

	var direction := Input.get_axis("move_left", "move_right")
	if direction < 0:
		animated_sprite.flip_h = true
	elif direction > 0:
		animated_sprite.flip_h = false

	if on_floor:
		if is_zero_approx(direction):
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	if not is_zero_approx(direction):
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)

	move_and_slide()
