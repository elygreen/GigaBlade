extends Node

const ENEMY_LIST = {
	"basic": {
		"scene": preload("res://Enemies/basic_enemy.tscn"),
		"cost": 1
	},
	"zombie": {
		"scene": preload("res://Enemies/zombie.tscn"),
		"cost": 3
	},
}

var enemy_keys = []

func _ready():
	enemy_keys = ENEMY_LIST.keys()
