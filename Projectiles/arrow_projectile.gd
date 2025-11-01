extends Node2D

var direction: Vector2 = Vector2.ZERO
var projectile_speed: float = 175.0

func _process(delta):
	global_position += direction * projectile_speed * delta
	rotation = direction.angle()
