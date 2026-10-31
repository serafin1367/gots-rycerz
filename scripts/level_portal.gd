extends Area2D

const PORTAL_ATLAS = preload("res://assets/sprites/portal_atlas.png")
const FRAME_SIZE := Vector2(32, 64)
const FRAME_COUNT := 9

var activated := false
var animation: AnimatedSprite2D

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	var collision := CollisionShape2D.new()
	var shape := CapsuleShape2D.new()
	shape.radius = 12
	shape.height = 44
	collision.shape = shape
	add_child(collision)
	animation = AnimatedSprite2D.new()
	animation.name = "PortalAnimation"
	animation.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var frames := SpriteFrames.new()
	frames.add_animation("loop")
	frames.set_animation_speed("loop", 10.0)
	frames.set_animation_loop("loop", true)
	for i in range(FRAME_COUNT):
		var frame := AtlasTexture.new()
		frame.atlas = PORTAL_ATLAS
		frame.region = Rect2(i * int(FRAME_SIZE.x), 0, FRAME_SIZE.x, FRAME_SIZE.y)
		frames.add_frame("loop", frame)
	animation.sprite_frames = frames
	add_child(animation)
	animation.play("loop")

func _on_body_entered(body: Node2D) -> void:
	if not activated and body.is_in_group("player"):
		activated = true
		GameFlow.complete_level()
