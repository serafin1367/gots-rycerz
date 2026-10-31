extends Area2D

@export_range(1, 20) var damage: int = 1

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
