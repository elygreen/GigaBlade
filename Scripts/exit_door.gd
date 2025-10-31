extends Node2D

signal player_entered_exit

@onready var collision_shape = $Area2D/CollisionShape2D

var is_locked = true


func _ready():
	print("im here")
	#global_position = get_tree().get_first_node_in_group("player").global_position
	print(global_position)
	lock_door()

func lock_door():
	is_locked = true
	collision_shape.set_deferred("disabled", true)

func unlock_door():
	is_locked = false
	collision_shape.set_deferred("disabled", false)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not is_locked and body.is_in_group("player"):
		emit_signal("player_entered_exit")
		lock_door()
