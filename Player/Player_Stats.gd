extends Node

signal stat_updated(stat_name, new_value)

const STATS = {
	"speed": {"base": 75.0, "type": "multiplicative"},
	"max_health": {"base": 3, "type": "additive"},
	"sword_damage": {"base": 10, "type": "additive"},
	"sword_size": {"base": 0.0, "type": "multiplicative"},
	"sword_length": {"base": 0.0, "type": "multiplicative"},
	"sword_width": {"base": 0.0, "type": "multiplicative"},
	"crit_chance": {"base": 0, "type": "additive"},
	"crit_modifier": {"base": 0.0, "type": "multiplicative"},
	"dash_timer": {"base": 5, "type": "additive"},
	"dash_duration": {"base": 2, "type": "additive"},
	"luck": {"base": 0, "type": "additive"},
	"experience_modifier": {"base": 0.0, "type": "multiplicative"},
	"projectile_count": {"base": 0, "type": "additive"},
	"projectile_speed": {"base": 0.0, "type": "multiplicative"},
	"immunity_duration": {"base": 0, "type": "additive"},
	"pickup_radius": {"base": 0.0, "type": "multiplicative"},
	"execution_threshold": {"base": 0, "type": "additive"},
}

var perm_bonuses: Dictionary = {}
var run_modifiers: Dictionary = {}

func _ready():
	for stat in STATS:
		perm_bonuses[stat] = 0.0
	_initialize_run_stats()

func _initialize_run_stats():
	for stat in STATS:
		if (STATS[stat].type == "multiplicative"):
			run_modifiers[stat] = 1.0
		else:
			run_modifiers[stat] = 0

func apply_permanent_bonuses():
	for stat in STATS:
		perm_bonuses[stat] = SaveManager.get_total_permanent_bonus(stat)
	emit_all_stats()

func reset_run_stats():
	_initialize_run_stats()
	emit_all_stats()

func emit_all_stats():
	for stat in STATS:
		emit_signal("stat_updated", stat, get_stat(stat))

func get_stat(stat_name: String):
	if not STATS.has(stat_name):
		printerr("PlayerStats: Unknown stat %s" % stat_name)
		return 0
	var config = STATS[stat_name]
	var base = config.base
	var permanent_value = perm_bonuses[stat_name]
	var run_value = run_modifiers[stat_name]
	if config.type == "multiplicative":
		return base * (1.0 + permanent_value) + run_value
	else:
		return int(base + permanent_value + run_value)

func apply_run_upgrade(upgrade_data: Dictionary):
	var stat = upgrade_data["stat"]
	var value = upgrade_data["value"]
	if not STATS.has(stat):
		printerr("PlayerStats: Unknown upgrade stat %s" % stat)
		return
	run_modifiers[stat] += value
	emit_signal("stat_updated", stat, get_stat(stat))
	
