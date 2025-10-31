extends Node2D

@export var player: CharacterBody2D
@export var xp_orb_container: Node2D
@export var enemy_container: Node2D


func spawn_wave(budget: float):
	print("spawning wave")
	var current_budget = budget
	var enemy_keys = EnemyDatabase.enemy_keys
	
	while current_budget > 0:
		var affordable_enemies = []
		for key in enemy_keys:
			var enemy_data = EnemyDatabase.ENEMY_LIST[key] 
			if enemy_data.cost <= current_budget:
				affordable_enemies.append(key)
		if affordable_enemies.is_empty():
			break
		var random_key = affordable_enemies.pick_random()
		var enemy_data = EnemyDatabase.ENEMY_LIST[random_key]
		spawn_one_enemy(enemy_data.scene)
		current_budget -= enemy_data.cost



func spawn_one_enemy(enemy_scene: PackedScene):
	if not is_instance_valid(player) or not enemy_scene:
		return
	
	var screen_size = get_viewport_rect().size
	var spawn_radius = (screen_size.length() / 2.0) + 50.0
	var player_position = player.global_position
	var random_angle = randf_range(0, TAU)
	var direction = Vector2.from_angle(random_angle)
	var spawn_position = player_position + (direction * spawn_radius)
	var new_enemy = enemy_scene.instantiate()
	new_enemy.global_position = spawn_position
		
	new_enemy.player = self.player
	new_enemy.xp_orb_container = self.xp_orb_container
	enemy_container.call_deferred("add_child", new_enemy)
