extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var collected := false

func _find_game_manager() -> Node:
	var current: Node = get_parent()
	while current != null:
		var manager := current.get_node_or_null("GameManager")
		if manager != null:
			return manager
		current = current.get_parent()
	return null

func _on_body_entered(body: Node2D) -> void:
	if collected or not body.is_in_group("player"):
		return

	var game_manager := _find_game_manager()
	if game_manager == null or not game_manager.has_method("add_point"):
		push_error("Coin: GameManager not found in scene ancestry")
		return

	collected = true
	set_deferred("monitoring", false)
	game_manager.add_point()
	animation_player.play("pickup")
