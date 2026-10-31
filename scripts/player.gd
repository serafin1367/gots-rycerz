extends CharacterBody2D

signal health_changed(current: int, maximum: int)

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const DECELERATION = 900.0
const SWORD_SHEET = preload("res://assets/sprites/knight_attack_32x32.png")
const ATTACK_TIME = 0.6

@export_range(1, 20) var max_health: int = 3
@export var invulnerability_seconds: float = 1.2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_jump: AudioStreamPlayer = $AudioJump
@onready var audio_hurt: AudioStreamPlayer = $AudioHurt

var health: int = 3
var invulnerability_left: float = 0.0
var dead := false
const HEART_FULL = preload("res://assets/ui/heart_full.png")
const HEART_EMPTY = preload("res://assets/ui/heart_empty.png")
const COIN_SHEET = preload("res://assets/sprites/coin.png")

var heart_icons: Array[TextureRect] = []
var coin_label: Label
var sword_sprite: AnimatedSprite2D
var sword_area: Area2D
var attacking := false
var attack_time := 0.0
var struck: Array[Node] = []

func _ready() -> void:
	add_to_group("player")
	health = max_health
	_create_sword()
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

func _create_sword() -> void:
	sword_sprite = AnimatedSprite2D.new()
	sword_sprite.name = "SwordAnimation"
	sword_sprite.position = Vector2(0, -12)
	sword_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var frames := SpriteFrames.new()
	frames.add_animation("swing")
	frames.set_animation_speed("swing", 10.0)
	frames.set_animation_loop("swing", false)
	for i in range(6):
		var texture := AtlasTexture.new()
		texture.atlas = SWORD_SHEET
		texture.region = Rect2(i * 32, 0, 32, 32)
		frames.add_frame("swing", texture)
	sword_sprite.sprite_frames = frames
	sword_sprite.visible = false
	add_child(sword_sprite)
	sword_area = Area2D.new()
	sword_area.name = "SwordArea"
	sword_area.collision_layer = 0
	sword_area.collision_mask = 1
	sword_area.monitoring = true
	var shape := RectangleShape2D.new()
	shape.size = Vector2(20, 20)
	var collision := CollisionShape2D.new()
	collision.shape = shape
	sword_area.add_child(collision)
	add_child(sword_area)
	_sync_sword_facing()

func _sync_sword_facing() -> void:
	if sword_sprite == null:
		return
	sword_sprite.flip_h = animated_sprite.flip_h
	sword_area.position = Vector2(-15 if animated_sprite.flip_h else 15, -12)

func begin_attack() -> bool:
	if dead or attacking:
		return false
	attacking = true
	attack_time = 0.0
	struck.clear()
	_sync_sword_facing()
	animated_sprite.visible = false
	sword_sprite.visible = true
	sword_sprite.play("swing")
	return true

func _tick_attack(delta: float) -> void:
	if not attacking:
		return
	attack_time += delta
	if attack_time >= 0.2 and attack_time < 0.5:
		for area in sword_area.get_overlapping_areas():
			var enemy := area.get_parent()
			if enemy.is_in_group("enemies") and enemy.has_method("take_damage") and not struck.has(enemy):
				struck.append(enemy)
				enemy.take_damage(1)
	if attack_time >= ATTACK_TIME:
		attacking = false
		sword_sprite.visible = false
		animated_sprite.visible = true

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
		var heart := TextureRect.new()
		heart.name = "Heart%d" % (i + 1)
		heart.custom_minimum_size = Vector2(24, 24)
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		heart.texture = HEART_FULL
		row.add_child(heart)
		heart_icons.append(heart)

	var coin_icon := TextureRect.new()
	coin_icon.name = "CoinIcon"
	coin_icon.custom_minimum_size = Vector2(20, 24)
	coin_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var coin_frame := AtlasTexture.new()
	coin_frame.atlas = COIN_SHEET
	coin_frame.region = Rect2(0, 0, 16, 16)
	coin_icon.texture = coin_frame
	row.add_child(coin_icon)

	coin_label = Label.new()
	coin_label.name = "CoinCounter"
	coin_label.text = "0"
	coin_label.add_theme_font_size_override("font_size", 16)
	coin_label.add_theme_color_override("font_color", Color("#f7d45c"))
	row.add_child(coin_label)

func update_coin_count(count: int) -> void:
	if coin_label != null:
		coin_label.text = str(count)

func _update_health_display() -> void:
	for i in range(heart_icons.size()):
		heart_icons[i].texture = HEART_FULL if i < health else HEART_EMPTY

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
	if Input.is_action_just_pressed("attack"):
		begin_attack()
	_tick_attack(delta)
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

	if not attacking:
		_sync_sword_facing()
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
