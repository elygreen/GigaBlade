extends Node2D

@onready var animation = $AnimationPlayer

var counter = 0
var is_attacking = false
var parry_ready = false


func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	if Input.is_action_pressed("attack"):
		if not is_attacking:
			if parry_ready:
				parry_ready = false
				if animation.current_animation != "Special_Attack":
					animation.play("Special_Attack")
					is_attacking = true
			else:
				animation.play("Combo_Swing")
				is_attacking = true
	else:
		is_attacking = false
		animation.play("Idle")

func fire_projectile():
	pass

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.owner and area.owner.is_in_group("enemy"):
		if area.owner.has_method("get_hit"):
			var base_damage = PlayerStats.get_stat("sword_damage")
			var total_damage = base_damage
			var crit_chance = PlayerStats.get_stat("crit_chance")
			var is_crit = false
			if randf() * 100 < crit_chance:
				var crit_mult = PlayerStats.get_stat("crit_modifier")
				total_damage = base_damage + (base_damage * crit_mult)
				is_crit = true
			area.owner.get_hit(total_damage, is_crit)
