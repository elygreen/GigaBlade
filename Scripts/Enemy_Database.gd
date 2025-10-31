extends Node

const ENEMY_LIST = {
	"basic": {
		"scene": preload("res://Enemies/basic_enemy.tscn"),
		"cost": 1
	}
}

var enemy_keys = []

func _ready():
	enemy_keys = ENEMY_LIST.keys()
