extends Node

var score: int = 0
@onready var player: CharacterBody2D = $"../Player"

func _ready() -> void:
	player.update_coin_count(score)

func add_point() -> void:
	score += 1
	player.update_coin_count(score)
