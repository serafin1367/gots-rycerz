extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var image := Image.load_from_file("res://assets/sprites/knight_attack_32x32.png")
	if image == null or image.get_width() != 192 or image.get_height() != 32:
		push_error("Attack spritesheet must be 192x32")
		quit(1)
		return
	var preview: Node = load("res://scenes/attack_preview.tscn").instantiate()
	root.add_child(preview)
	await process_frame
	var sprite := preview.get_node_or_null("AttackPreview") as AnimatedSprite2D
	if sprite == null or sprite.sprite_frames.get_frame_count("attack") != 6:
		push_error("Attack preview needs six frames")
		quit(1)
		return
	print("PASS: attack spritesheet 192x32, six frames")
	quit(0)
