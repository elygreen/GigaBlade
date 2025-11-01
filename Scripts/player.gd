extends CharacterBody2D

signal level_up_started
signal player_died
signal player_hit
signal health_changed(current, max)
signal experience_changed(current_xp, max_xp, level)

@onready var player_container = $Player_Container
@onready var player_sword = $Player_Container/Player_Sword
@onready var player_sword_hitbox = $Player_Container/Player_Sword/Sword_Sprite/Hitbox
@onready var player_sword_hitbox_collision = $Player_Container/Player_Sword/Sword_Sprite/Hitbox/CollisionShape2D
@onready var player_sprite = $Player_Container/Player_Sprite
@onready var attack_timer = $Attack_Timer
@onready var dash_timer = $Dash_Timer
@onready var dash_cooldown_timer = $Dash_Cooldown
@onready var pickup_area = $Pickup_Area

# Moment to moment stats
var current_player_speed: float = 100.0
var current_player_max_health: int = 3
var current_player_health: int = 3

@export var dash_speed_multiplier: float = 2.5

const STOP_DISTANCE = 5.0
const ATTACK_DURATION = .5
const LEVEL_UP_INCREMENT_MULTIPLIER = 2

var target_position = Vector2.ZERO
var current_xp: int = 0
var current_level = 1
var xp_to_next_level = 2

enum State {IDLE, ATTACK}
var current_state = State.IDLE
var is_dashing = false

var base_pickup_radius: float = 1.0

func _ready():
	target_position = global_position
	PlayerStats.stat_updated.connect(on_stat_updated)
	# Initialize Stats
	current_player_max_health = PlayerStats.get_stat("max_health")
	current_player_health = current_player_max_health
	player_sword_hitbox.damage = PlayerStats.get_stat("sword_damage")
	update_sword_scale()
	update_pickup_radius()
	emit_signal("health_changed", current_player_health, current_player_max_health)
	emit_signal("experience_changed", current_xp, xp_to_next_level, current_level)
	

func _physics_process(delta: float) -> void:
	handle_dash_input()
	player_movement()
	move_and_slide()


func on_stat_updated(stat_name: String, new_value):
	match stat_name:
		"sword_damage":
			player_sword_hitbox.damage = new_value
		"sword_size", "sword_length", "sword_width":
			update_sword_scale()
		"max_health":
			# Heal the player for the amount their max HP increased
			var health_increase = new_value - current_player_max_health
			current_player_max_health = new_value
			current_player_health = min(current_player_health + health_increase, current_player_max_health)
			emit_signal("health_changed", current_player_health, current_player_max_health)
		"speed":
			pass
		"dash_timer":
			dash_cooldown_timer.wait_time = max(0.3, new_value)
		"dash_duration":
			dash_timer.wait_time = max(0.1, new_value)
		"pickup_radius":
			update_pickup_radius()
	if attack_timer.is_stopped():
		attack_timer.start(ATTACK_DURATION)
		player_sword.rotation_degrees = 90

func handle_dash_input():
	if Input.is_action_just_pressed("player_dash"):
		if !is_dashing and dash_cooldown_timer.is_stopped():
			is_dashing = true
			var dash_duration = PlayerStats.get_stat("dash_duration")
			dash_timer.start(dash_duration)
			var dash_cooldown = PlayerStats.get_stat("dash_timer")
			dash_cooldown_timer.start(dash_cooldown)

func player_movement_old():
	target_position = get_global_mouse_position()
	var distance_to_target = global_position.distance_to(target_position)
	if distance_to_target > STOP_DISTANCE:
		var direction_vector = (target_position - global_position).normalized()
		velocity = direction_vector * current_player_speed
	else:
		velocity = Vector2.ZERO

func player_movement():
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var base_speed = PlayerStats.get_stat("speed")
	velocity = direction * current_player_speed
	player_sprite.flip_h = direction.x < 0
	if is_dashing:
		current_player_speed = base_speed * dash_speed_multiplier
	else:
		current_player_speed = base_speed
	if direction != Vector2(0, 0):
		#implement idle animation
		pass
	else:
		#implement moving animation
		pass
	move_and_slide()

func get_hit():
	current_player_health -= 1
	emit_signal("health_changed", current_player_health, current_player_max_health)
	emit_signal("player_hit")
	if current_player_health <= 0:
		die()

func die():
	emit_signal("player_died")
	call_deferred("queue_free")

func _on_attack_timer_timeout() -> void:
	current_state = State.IDLE
	player_sword.rotation_degrees = 0
	print("attack timer ended")

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hitbox"):
		get_hit()

func _on_dash_timer_timeout() -> void:
	is_dashing = false

func _on_pickup_area_area_entered(area: Area2D) -> void:
	if area.has_method("collect"):
		area.collect(self)

func update_sword_scale():
	var size = PlayerStats.get_stat("sword_size")
	var length = PlayerStats.get_stat("sword_length")
	var width = PlayerStats.get_stat("sword_width")
	player_sword.scale = Vector2(1, 1) * Vector2(width, length) * size

func update_pickup_radius():
	var radius_multiplier = PlayerStats.get_stat("pickup_radius")
	pickup_area.scale = Vector2(1, 1) * radius_multiplier

func add_experience(amount: int):
	var xp_modifier = PlayerStats.get_stat("experience_modifier")
	var modified_amount_float = amount * xp_modifier
	var base_amount = int(modified_amount_float)
	var fractional_part = modified_amount_float - base_amount
	if randf() < fractional_part:
		base_amount += 1
	current_xp += base_amount
	emit_signal("experience_changed", current_xp, xp_to_next_level, current_level)
	while current_xp >= xp_to_next_level:
		level_up()

func level_up():
	current_xp -= xp_to_next_level
	current_level += 1
	xp_to_next_level = int(xp_to_next_level * LEVEL_UP_INCREMENT_MULTIPLIER)
	emit_signal("experience_changed", current_xp, xp_to_next_level, current_level)
	emit_signal("level_up_started")
	get_tree().paused = true

func apply_upgrade(upgrade_data: Dictionary):
	PlayerStats.apply_run_upgrade(upgrade_data)
