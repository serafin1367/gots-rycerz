extends CharacterBody2D

signal health_changed(current: int, maximum: int)

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const DECELERATION = 900.0

@export_range(1, 20) var max_health: int = 3
@export var invulnerability_seconds: float = 1.2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_jump: AudioStreamPlayer = $AudioJump
@onready var audio_hurt: AudioStreamPlayer = $AudioHurt

var health: int = 3
var invulnerability_left: float = 0.0
var dead := false
var heart_labels: Array[Label] = []

func _ready() -> void:
	add_to_group("player")
	health = max_health
	_create_hearts_hud()
	_update_health_display()
	health_changed.emit(health, max_health)

func take_damage(amount: int = 1) -> bool:
	if dead or invulnerability_left > 0.0 or amount <= 0:
		return false
	health = maxi(health - amount, 0)
	audio_hurt.play()
	health_changed.emit(health, max_health)
	_update_health_display()
	if health == 0:
		_die()
	else:
		invulnerability_left = invulnerability_seconds
		animated_sprite.play("hit")
	return true

func _create_hearts_hud() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "HealthHUD"
	canvas.layer = 10
	add_child(canvas)
	var row := HBoxContainer.new()
	row.name = "Hearts"
	row.position = Vector2(12, 8)
	row.add_theme_constant_override("separation", 3)
	canvas.add_child(row)
	for i in range(max_health):
		var heart := Label.new()
		heart.name = "Heart%d" % (i + 1)
		heart.text = "♥"
		heart.add_theme_font_size_override("font_size", 24)
		row.add_child(heart)
		heart_labels.append(heart)

func _update_health_display() -> void:
	for i in range(heart_labels.size()):
		heart_labels[i].add_theme_color_override("font_color", Color("#ed344f") if i < health else Color("#4b4653"))

func _die() -> void:
	if dead:
		return
	dead = true
	velocity = Vector2.ZERO
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	animated_sprite.play("hit")
	var tree := get_tree()
	if tree != null and current_scene_is_available():
		tree.create_timer(0.7).timeout.connect(func() -> void:
			if is_instance_valid(self):
				tree.reload_current_scene()
		)

func current_scene_is_available() -> bool:
	return get_tree().current_scene != null

func _physics_process(delta: float) -> void:
	if dead:
		return
	if invulnerability_left > 0.0:
		invulnerability_left = maxf(invulnerability_left - delta, 0.0)
		animated_sprite.modulate = Color(1.0, 0.5, 0.5) if int(invulnerability_left * 10.0) % 2 == 0 else Color.WHITE
	else:
		animated_sprite.modulate = Color.WHITE

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

	if invulnerability_left > maxf(invulnerability_seconds - 0.25, 0.0):
		animated_sprite.play("hit")
	elif on_floor:
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
