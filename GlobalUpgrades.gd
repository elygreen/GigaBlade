extends Node

const UPGRADES = {
	"speed_boost_1": {
		"title": "Minor Move Speed",
		"description": "+10% Move Speed",
		"stat": "speed",
		"value": 0.1,
		"icon": preload("res://Test_Image.png"),
	},
	"speed_boost_2": {
		"title": "Major Move Speed",
		"description": "+20% Move Speed",
		"stat": "speed",
		"value": 0.2,
		"icon": preload("res://Test_Image.png"),
	},
	"health_boost_1": {
		"title": "Minor Health",
		"description": "+1 Max Health",
		"stat": "max_health",
		"value": 1,
		"icon": preload("res://Test_Image.png"),
	},
	"health_boost_2": {
		"title": "Major Health",
		"description": "+2 Max Health",
		"stat": "max_health",
		"value": 2,
		"icon": preload("res://Test_Image.png"),
	},
	"damage_boost_1": {
		"title": "Minor Damage",
		"description": "2 Sword Damage",
		"stat": "sword_damage",
		"value": 2,
		"icon": preload("res://Test_Image.png"),
	},
	"damage_boost_2": {
		"title": "Major Damage",
		"description": "5 Sword Damage",
		"stat": "sword_damage",
		"value": 5,
		"icon": preload("res://Test_Image.png"),
	},
	"sword_size_1": {
		"title": "Sword Size Increase",
		"description": "Increases sword size by 15%",
		"stat": "sword_size",
		"value": .15,
		"icon": preload("res://Test_Image.png"),
	},
	"sword_length_1": {
		"title": "Sword Length Increase",
		"description": "Increases sword length by 10%",
		"stat": "sword_length",
		"value": .10,
		"icon": preload("res://Test_Image.png"),
	},
	"sword_width_1": {
		"title": "Sword Width Increase",
		"description": "Increases sword width by 10%",
		"stat": "sword_width",
		"value": .10,
		"icon": preload("res://Test_Image.png"),
	},
	"crit_chance_1": {
		"title": "Critical Chance",
		"description": "+5% Crit Chance",
		"stat": "crit_chance",
		"value": 5,
		"icon": preload("res://Test_Image.png"),
	},
	"crit_modifier_1": {
		"title": "Improved Critical Damage",
		"description": "Increases critical strike damage by 25%",
		"stat": "crit_modifier",
		"value": .25,
		"icon": preload("res://Test_Image.png"),
	},
	"dash_cooldown_1": {
		"title": "Dash Cooldown",
		"description": "-1s Dash Cooldown",
		"stat": "dash_timer",
		"value": -1,
		"icon": preload("res://Test_Image.png"),
	},
	"dash_duration_1": {
		"title": "Dash Duration",
		"description": "+1s Dash Duration",
		"stat": "dash_duration",
		"value": 1,
		"icon": preload("res://Test_Image.png"),
	},
	"luck_1": {
		"title": "Luck",
		"description": "+10 Luck",
		"stat": "luck",
		"value": 10,
		"icon": preload("res://Test_Image.png"),
	},
	"xp_boost_1": {
		"title": "Wisdom",
		"description": "+20% XP Gained",
		"stat": "experience_modifier",
		"value": .20,
		"icon": preload("res://Test_Image.png"),
	},
	"pickup_radius_1": {
		"title": "Pickup Radius",
		"description": "+20% Pickup Radius",
		"stat": "pickup_radius",
		"value": .20,
		"icon": preload("res://Test_Image.png"),
	},
	"execution_1": {
		"title": "Executor",
		"description": "+5% Execution Threshold",
		"stat": "execution_threshold",
		"value": 5,
		"icon": preload("res://Test_Image.png"),
	},
}

var unlocked_upgrades = [
	"speed_boost_1", "speed_boost_2",
	"health_boost_1", "health_boost_2",
	"damage_boost_1", "damage_boost_2",
	"sword_size_1", "sword_length_1", "sword_width_1",
	"crit_chance_1", "crit_modifier_1",
	"dash_cooldown_1", "dash_duration_1",
	"luck_1", "xp_boost_1", "pickup_radius_1", "execution_1"
]

var player_gold = 0

func get_random_upgrades(amount: int) -> Array:
	var choices = []
	var pool = unlocked_upgrades.duplicate()
	pool.shuffle()
	for i in range(min(amount, pool.size())):
		var upgrade_id = pool.pop_front()
		choices.append(UPGRADES[upgrade_id])
	return choices
