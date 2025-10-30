extends Node2D

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass


func _on_hitbox_area_entered(area: Area2D) -> void:
	print("detected sword collision")
	if area.owner and area.owner.is_in_group("enemy"):
		print("area is enemy")
		if area.owner.has_method("get_hit"):
			area.owner.get_hit(PlayerStats.get_stat("sword_damage"))
