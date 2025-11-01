extends CharacterBody2D

@export var damage_number_scene: PackedScene
@export var projectile: PackedScene
@export var max_health: int = 500
@export var speed: float = 150.0

@onready var attack_cooldown = $Attack_Cooldown
@onready var attack_duration = $Attack_Duration
@onready var bow = $Bow

var current_health: int = max_health
var room_area: Node2D = null
var player: Node2D = null
var entity_container: Node2D = null
var attack_target_position: Vector2 = Vector2.ZERO
const MOVEMENT_STOP_DISTANCE: float = 10.0
var attack_patterns: Array[Callable] = []
var last_attack = null
var second_last_attack = null

enum State {IDLE, CHASING, ATTACKING}
var current_state = State.IDLE


func _ready() -> void:
	print("boss spawned")
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")
	attack_patterns = [
		corner_shoot,
		center_spin_shoot,
		burst_shot,
		shotgun_shot,
		wall_strafe,
		heavy_shot
	]
	attack_loop()

func _process(delta: float) -> void:
	if player == null:
		return
	match current_state:
		State.IDLE:
			pass

func get_hit(damage, is_crit: bool = false):
	current_health -= damage
	spawn_damage_number(damage, is_crit)
	if current_health <= 0:
		die()

func attack_loop():
	while true:
		var available_attacks = attack_patterns.duplicate()
		if last_attack != null and available_attacks.has(last_attack):
			available_attacks.erase(last_attack)
		if second_last_attack != null and available_attacks.has(second_last_attack):
			available_attacks.erase(second_last_attack)
		var chosen_attack: Callable = available_attacks.pick_random()
		print(chosen_attack)
		second_last_attack = last_attack
		last_attack = chosen_attack
		print("Boss starting attack: ", chosen_attack.get_method())
		await chosen_attack.call()
		print("Boss attack finished. Waiting 3 seconds...")
		await get_tree().create_timer(randf_range(0.5, 2)).timeout

func corner_shoot():
	var corner = get_random_corner()
	# Run to corner
	while global_position.distance_to(corner) > 5:
		global_position = global_position.move_toward(corner, speed * get_process_delta_time())
		await get_tree().process_frame
	# Shoot 10 times
	for i in range(7):
		var player_direction = (player.global_position - global_position).normalized()
		var new_projectile = projectile.instantiate()
		new_projectile.global_position = global_position
		new_projectile.direction = player_direction
		get_parent().add_child(new_projectile)
		await get_tree().create_timer(.5).timeout

func center_spin_shoot():
	if room_area == null:
		printerr("Boss: room area not set!")
		return
	var collision_shape = room_area.get_node_or_null("CollisionShape2D")
	if collision_shape == null:
		printerr("Boss: room area has no 'CollisionShape2D' child.")
		return
	var center_pos = collision_shape.global_position
	while global_position.distance_to(center_pos) > 5.0:
		global_position = global_position.move_toward(center_pos, speed * get_process_delta_time())
		await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	if bow == null:
		printerr("Boss: $Bow node not found!")
		return

	# Randomly choose 1, 2, or 3 full rotations
	var num_rotations = randi_range(1, 3)
	var shots_per_rotation = 12
	var total_steps = num_rotations * shots_per_rotation
	var shot_delay = 0.1
	var visual_angle = 180.0
	bow.rotation_degrees = visual_angle

	for i in range(total_steps):
		var current_shoot_angle_deg = i * 30.0
		var shoot_direction = Vector2.RIGHT.rotated(deg_to_rad(current_shoot_angle_deg))
		var new_projectile = projectile.instantiate()
		new_projectile.global_position = global_position
		new_projectile.direction = shoot_direction
		get_parent().add_child(new_projectile)
		visual_angle = (i + 1) * 30.0 + 180.0
		var tween = create_tween()
		tween.tween_property(bow, "rotation_degrees", visual_angle, shot_delay)
		await tween.finished

	bow.rotation_degrees = 0  # Reset bow rotation at the end

func shotgun_shot():
	if room_area == null:
		printerr("Boss: room area not set!")
		return
	var collision_shape = room_area.get_node_or_null("CollisionShape2D")
	if collision_shape == null:
		printerr("Boss: room area has no 'CollisionShape2D' child.")
		return
	var random_pos = get_random_point_in_room()
	while global_position.distance_to(random_pos) > 5.0:
		global_position = global_position.move_toward(random_pos, speed * get_process_delta_time())
		await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	if bow == null:
		printerr("Boss: $Bow node not found!")
		return
	var total_steps = 12
	var shot_delay = 0.1
	bow.rotation_degrees = 180.0
	
	for i in range(total_steps):
		var current_angle_deg = i * 30.0
		var shoot_direction = Vector2.RIGHT.rotated(deg_to_rad(current_angle_deg))
		var new_projectile = projectile.instantiate()
		new_projectile.global_position = global_position
		new_projectile.direction = shoot_direction
		get_parent().add_child(new_projectile)
		await get_tree().create_timer(shot_delay)
	bow.rotation_degrees = 0

func wall_strafe():
	var strafe_speed = 100
	# --- 1. Boilerplate checks (matches other functions) ---
	if room_area == null:
		printerr("Boss: room area not set!")
		return
	var collision_shape = room_area.get_node_or_null("CollisionShape2D")
	if collision_shape == null:
		printerr("Boss: room area has no 'CollisionShape2D' child.")
		return
	if not collision_shape.shape is RectangleShape2D:
		printerr("Boss: room area's collision shape is not a RectangleShape2D.")
		return
	var rect_shape: RectangleShape2D = collision_shape.shape
	var size = rect_shape.size
	var center_pos = collision_shape.global_position
	var half_size = size / 2.0
	var corners = {
		"top_left": center_pos - half_size,
		"top_right": center_pos + Vector2(half_size.x, -half_size.y),
		"bottom_left": center_pos + Vector2(-half_size.x, half_size.y),
		"bottom_right": center_pos + half_size
	}
	var adjacent_corners = {
		"top_left": [corners.top_right, corners.bottom_left],
		"top_right": [corners.top_left, corners.bottom_right],
		"bottom_left": [corners.top_left, corners.bottom_right],
		"bottom_right": [corners.top_right, corners.bottom_left]
	}
	var start_corner_name = corners.keys().pick_random()
	var start_pos = corners[start_corner_name]
	var target_pos = adjacent_corners[start_corner_name].pick_random()
	while global_position.distance_to(start_pos) > 5.0:
		global_position = global_position.move_toward(start_pos, speed * get_process_delta_time())
		await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	var travel_direction = (target_pos - global_position).normalized()
	var shoot_direction = travel_direction.orthogonal() 
	var vec_to_center = (center_pos - global_position).normalized()
	if shoot_direction.dot(vec_to_center) < 0:
		shoot_direction = -shoot_direction 
	var shoot_timer = 0.0
	var shoot_interval = 0.3
	var new_projectile = projectile.instantiate()
	new_projectile.global_position = global_position
	new_projectile.direction = shoot_direction
	get_parent().add_child(new_projectile)
	while global_position.distance_to(target_pos) > 5.0:
		var delta = get_process_delta_time()
		# Move towards the target corner
		global_position = global_position.move_toward(target_pos, strafe_speed * delta)
		shoot_timer += delta
		if shoot_timer >= shoot_interval:
			shoot_timer -= shoot_interval
			new_projectile = projectile.instantiate()
			new_projectile.global_position = global_position
			new_projectile.direction = shoot_direction
			get_parent().add_child(new_projectile)
		await get_tree().process_frame

func burst_shot():
	if room_area == null:
		printerr("Boss: room area not set!")
		return
	var collision_shape = room_area.get_node_or_null("CollisionShape2D")
	if collision_shape == null:
		printerr("Boss: room area has no 'CollisionShape2D' child.")
		return
	if player == null:
		printerr("Boss: Player not found for burst shot!")
		return
	var random_pos = get_random_point_in_room()
	while global_position.distance_to(random_pos) > 5.0:
		global_position = global_position.move_toward(random_pos, speed * get_process_delta_time())
		await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	var shot_delay = .2
	for i in range(randi_range(2, 5)):
		var player_direction = (player.global_position - global_position).normalized()
		var new_projectile = projectile.instantiate()
		new_projectile.global_position = global_position
		new_projectile.direction = player_direction
		get_parent().add_child(new_projectile)
		await get_tree().create_timer(shot_delay).timeout
	if bow:
		bow.rotation_degrees = 0

func heavy_shot():
	if room_area == null:
		printerr("Boss: room area not set!")
		return
	var collision_shape = room_area.get_node_or_null("CollisionShape2D")
	if collision_shape == null:
		printerr("Boss: room area has no 'CollisionShape2D' child.")
		return
	if player == null:
		printerr("Boss: Player not found for burst shot!")
		return
	var random_pos = get_random_point_in_room()
	while global_position.distance_to(random_pos) > 5.0:
		global_position = global_position.move_toward(random_pos, speed * get_process_delta_time())
		await get_tree().process_frame
	await get_tree().create_timer(1).timeout
	var shot_delay = .2
	var player_direction = (player.global_position - global_position).normalized()
	var new_projectile = projectile.instantiate()
	new_projectile.global_position = global_position
	new_projectile.direction = player_direction
	new_projectile.scale = Vector2(2, 1.5)
	new_projectile.projectile_speed = new_projectile.projectile_speed * 2
	get_parent().add_child(new_projectile)
	await get_tree().create_timer(shot_delay).timeout
	
	if bow:
		bow.rotation_degrees = 0

func get_random_point_in_room() -> Vector2:
	if room_area == null:
		printerr("Boss: room area not set!")
		return global_position 
	var collision_shape = room_area.get_node_or_null("CollisionShape2D")
	if collision_shape == null:
		printerr("Boss: room area has no 'CollisionShape2D' child.")
		return global_position
	if not collision_shape.shape is RectangleShape2D:
		printerr("Boss: room area's collision shape is not a RectangleShape2D.")
		return global_position
	var rect_shape: RectangleShape2D = collision_shape.shape
	var size = rect_shape.size
	var center_pos = collision_shape.global_position
	var top_left = center_pos - size / 2.0
	var random_x = randf() * size.x
	var random_y = randf() * size.y
	return top_left + Vector2(random_x, random_y)

func get_random_corner() -> Vector2:
	if room_area == null:
		printerr("Boss room area not set!")
		return global_position
	var collision_shape = room_area.get_node_or_null("CollisionShape2D")
	if collision_shape == null:
		printerr("Boss room area has no 'CollisionShape2D' child.")
		return global_position
	if not collision_shape.shape is RectangleShape2D:
		printerr("Boss room area's collision shape is not a RectangleShape2D.")
		return global_position
	var rect_shape: RectangleShape2D = collision_shape.shape
	var size = rect_shape.size
	var center_pos = collision_shape.global_position
	var half_size = size / 2.0
	var top_left = center_pos - half_size
	var top_right = center_pos + Vector2(half_size.x, -half_size.y)
	var bottom_left = center_pos + Vector2(-half_size.x, half_size.y)
	var bottom_right = center_pos + half_size
	var corners = [top_left, top_right, bottom_left, bottom_right]
	return corners.pick_random()

func spawn_damage_number(damage, is_crit):
	if damage_number_scene and is_instance_valid(entity_container):
		var damage_number = damage_number_scene.instantiate()
		entity_container.call_deferred("add_child", damage_number)
		var spawn_pos = global_position + Vector2(randf_range(-8, 8), randf_range(-8, 8))
		damage_number.start(damage, spawn_pos, is_crit)

func die():
	emit_signal("boss_defeated")
	call_deferred("queue_free")
