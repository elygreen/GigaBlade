extends Node2D

@export var player: CharacterBody2D
@export var xp_orb_container: Node2D
@export var enemy_container: Node2D

var current_spawn_area: Area2D = null
const MIN_SPAWN_DISTANCE = 100

func set_spawn_area(area: Area2D):
	current_spawn_area = area

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
	var spawn_position = _get_random_spawn_position()
	if spawn_position == Vector2.INF:
		printerr("SpawnManager: Could not find a valid spawn position.")
		return
	var new_enemy = enemy_scene.instantiate()
	new_enemy.global_position = spawn_position
	new_enemy.xp_orb_container = self.xp_orb_container
	enemy_container.call_deferred("add_child", new_enemy)

func _get_random_spawn_position() -> Vector2:
	if current_spawn_area == null:
		printerr("SpawnManager: current_spawn_area is not set!")
		return Vector2.INF # Return an "invalid" vector
	var shape_node = current_spawn_area.get_node_or_null("CollisionShape2D")
	if not shape_node:
		printerr("SpawnManager: No 'CollisionShape2D' child found in spawn area.")
		return Vector2.INF
	var shape = shape_node.shape as RectangleShape2D
	if not shape:
		printerr("SpawnManager: Spawn area's shape is not a RectangleShape2D.")
		return Vector2.INF
	var rect = shape.get_rect()
	var shape_global_pos = shape_node.global_position
	for i in 10:
		var rand_x = randf_range(rect.position.x, rect.end.x)
		var rand_y = randf_range(rect.position.y, rect.end.y)
		var spawn_pos = shape_global_pos + Vector2(rand_x, rand_y)
		if spawn_pos.distance_to(player.global_position) > MIN_SPAWN_DISTANCE:
			return spawn_pos # Found a good spot!
	var rand_x = randf_range(rect.position.x, rect.end.x)
	var rand_y = randf_range(rect.position.y, rect.end.y)
	return shape_global_pos + Vector2(rand_x, rand_y)
