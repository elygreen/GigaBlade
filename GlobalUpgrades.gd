extends Node

const UPGRADES = {
	"speed_boost_1": {
		"title": "Minor Move Speed",
		"description": "+10% Move Speed",
		"stat": "speed",
		"value": 0.1
	},
	"health_boost_1": {
		"title": "Minor Health",
		"description": "+1 Max Health",
		"stat": "max_health",
		"value": 1
	},
	"damage_boost_1": {
		"title": "Minor Damage",
		"description": "5 Sword Damage",
		"stat": "sword_damage",
		"value": 5
	},
	"sword_size_1": {
		"title": "Sword Length Increase",
		"description": "Increases sword size by 20%",
		"stat": "sword_size",
		"value": .20
	}
}

var unlocked_upgrades = ["speed_boost_1", "health_boost_1", "sword_size_1", "damage_boost_1"]
var player_gold = 0

func get_random_upgrades(amount: int) -> Array:
	var choices = []
	var pool = unlocked_upgrades.duplicate()
	pool.shuffle()
	for i in range(min(amount, pool.size())):
		var upgrade_id = pool.pop_front()
		choices.append(UPGRADES[upgrade_id])
	return choices
