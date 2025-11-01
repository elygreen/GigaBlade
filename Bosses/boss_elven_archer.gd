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

enum State {IDLE, CHASING, ATTACKING}
var current_state = State.IDLE


func _ready() -> void:
	print("boss spawned")
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")
	center_spin_shoot()
	
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

func corner_shoot():
	var corner = get_random_corner()
	# Run to corner
	while global_position.distance_to(corner) > 5:
		global_position = global_position.move_toward(corner, speed * get_process_delta_time())
		await get_tree().process_frame
	await get_tree().create_timer(5).timeout
	# Shoot 10 times
	for i in range(7):
		var player_direction = (player.global_position - global_position).normalized()
		var new_projectile = projectile.instantiate()
		new_projectile.global_position = global_position
		new_projectile.direction = player_direction
		get_parent().add_child(new_projectile)
		await get_tree().create_timer(.5).timeout

func center_spin_shoot():
	# --- All of your checks are perfect, no changes here ---
	if room_area == null:
		printerr("Boss: room area not set!")
		return
	var collision_shape = room_area.get_node_or_null("CollisionShape2D")
	if collision_shape == null:
		printerr("Boss: room area has no 'CollisionShape2D' child.")
		return
	var center_pos = collision_shape.global_position

	# --- Movement code is also fine ---
	while global_position.distance_to(center_pos) > 5.0:
		global_position = global_position.move_toward(center_pos, speed * get_process_delta_time())
		await get_tree().process_frame
	
	await get_tree().create_timer(0.5).timeout
	
	if bow == null:
		printerr("Boss: $Bow node not found!")
		return

	# --- Start of Tween Logic ---
	var total_steps = 12
	var shot_delay = 0.35 # This is now the duration of the tween
	
	# Set the initial rotation (angle 0 + 180 degree offset)
	var visual_angle = 180.0
	bow.rotation_degrees = visual_angle

	for i in range(total_steps):
		# 1. Calculate the angle to SHOOT at
		var current_shoot_angle_deg = i * 30.0
		var shoot_direction = Vector2.RIGHT.rotated(deg_to_rad(current_shoot_angle_deg))
		
		# 2. Spawn the projectile
		var new_projectile = projectile.instantiate()
		new_projectile.global_position = global_position
		new_projectile.direction = shoot_direction
		get_parent().add_child(new_projectile)
		
		# 3. Calculate the NEXT visual angle
		# We add (i + 1) to get the *next* 30-degree step
		visual_angle = (i + 1) * 30.0 + 180.0
		
		# 4. Create a tween to smoothly rotate to that next angle
		var tween = create_tween()
		tween.tween_property(bow, "rotation_degrees", visual_angle, shot_delay)
		
		# 5. Wait for the tween to finish before the next loop
		await tween.finished

	# --- End of Tween Logic ---
	
	# After the loop, smoothly tween the bow back to 0
	var reset_tween = create_tween()
	reset_tween.tween_property(bow, "rotation_degrees", 0, 0.5) # 0.5s to reset

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
