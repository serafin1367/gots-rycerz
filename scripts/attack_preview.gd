extends Node2D

const ATTACK_SHEET = preload("res://assets/sprites/knight_attack_32x32.png")
const FRAME_SIZE = Vector2i(32, 32)
const FRAME_COUNT = 6

func _ready() -> void:
	var animation := AnimatedSprite2D.new()
	animation.name = "AttackPreview"
	animation.position = Vector2(160, 100)
	animation.scale = Vector2(4, 4)
	animation.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var frames := SpriteFrames.new()
	frames.add_animation("attack")
	frames.set_animation_speed("attack", 10.0)
	frames.set_animation_loop("attack", true)
	for i in range(FRAME_COUNT):
		var frame := AtlasTexture.new()
		frame.atlas = ATTACK_SHEET
		frame.region = Rect2(i * FRAME_SIZE.x, 0, FRAME_SIZE.x, FRAME_SIZE.y)
		frames.add_frame("attack", frame)
	animation.sprite_frames = frames
	add_child(animation)
	animation.play("attack")
