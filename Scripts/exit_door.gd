extends Node2D

signal player_entered_exit

@onready var collision_shape = $Area2D/CollisionShape2D

var is_locked = true


func _ready():
	lock_door()

func lock_door():
	is_locked = true

func unlock_door():
	is_locked = false
	print("door unlocked")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if !is_locked:
		if body.is_in_group("player"):
			emit_signal("player_entered_exit")
			lock_door()
