extends Area2D

@export var xp_value: int = 1

func collect(player):
	player.add_experience(xp_value)
	call_deferred("queue_free")
