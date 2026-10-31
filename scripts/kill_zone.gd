extends Area2D

@onready var timer: Timer = $Timer

var triggered := false

func _on_body_entered(body: Node2D) -> void:
	if triggered or not body.is_in_group("player"):
		return

	triggered = true
	set_deferred("monitoring", false)
	print("You died!")
	timer.start()

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
