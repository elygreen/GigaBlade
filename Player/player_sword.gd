extends Node2D

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.owner and area.owner.is_in_group("enemy"):
		if area.owner.has_method("get_hit"):
			var base_damage = PlayerStats.get_stat("sword_damage")
			var total_damage = base_damage
			var crit_chance = PlayerStats.get_stat("crit_chance")
			if randf() * 100 < crit_chance:
				var crit_mult = PlayerStats.get_stat("crit_modifier")
				total_damage = base_damage + (base_damage * crit_mult)
			area.owner.get_hit(total_damage)
