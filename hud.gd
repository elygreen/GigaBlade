extends CanvasLayer

@onready var xp_bar = $MarginContainer/VBoxContainer/XP_Bar
@onready var level_label = $MarginContainer/VBoxContainer/Level_Label
@onready var damage_label = $MarginContainer/VBoxContainer/Damage_Label
@onready var movespeed_label = $MarginContainer/VBoxContainer/Movespeed_Label
@onready var time_label = $MarginContainer/VBoxContainer/Time_Label
@onready var health_label = $MarginContainer/VBoxContainer/Health_Label
@onready var score_label = $MarginContainer/VBoxContainer/Score_Label
@onready var upgrade_items_label = $MarginContainer/VBoxContainer/Upgrade_Items_Label

func set_health(current_health: int, max_health: int):
	health_label.text = "Health: %s / %s" % [current_health, max_health]

func set_experience(current: int, max: int, level: int):
	xp_bar.max_value = max
	xp_bar.value = current
	level_label.text = "Level: %s" % level

func set_time(time_in_seconds: int):
	var minutes = time_in_seconds / 60
	var seconds = time_in_seconds % 60
	time_label.text = "Time: %02d:%02d" % [minutes, seconds]

func set_score(score: int):
	score_label.text = "Challenge Rating: %s" % score

func set_upgrade_items(upgrade_items_quantity: int):
	upgrade_items_label.text = "Upgrade Items: %s" % upgrade_items_quantity

func on_player_stat_updated(stat_name: String, new_value):
	match stat_name:
		"speed":
			movespeed_label.text = "Speed: %s" % int(new_value)
		"sword_damage":
			damage_label.text = "Damage: %s" % new_value
