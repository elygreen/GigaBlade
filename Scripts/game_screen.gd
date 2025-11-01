extends Node2D

signal game_over

@export var player: CharacterBody2D
@export var level_up_screen: CanvasLayer
@export var hud: CanvasLayer
@export var spawn_manager: Node2D
@export var exit_door: Node2D
@export var level_weight: float = 2.0
@export var camera_mouse_influence: float = 0.1
@export var camera_smoothing_speed: float = 5.0

@onready var player_camera = $Camera2D
@onready var run_timer = $Run_Timer
@onready var enemy_container = $Enemy_Container
@onready var camera_shake_timer = $Camera_Shake_Timer
@onready var current_room = $Room_1

var current_run_time: int = 0
var difficulty_score = 1
var difficulty_adder = 5
var current_room_number = 11
var shake_strength: float = 0.0

func _ready() -> void:
	PlayerStats.stat_updated.connect(hud.on_player_stat_updated)
	player.level_up_started.connect(on_player_level_up)
	player.health_changed.connect(hud.set_health)
	player.experience_changed.connect(hud.set_experience)
	player.player_died.connect(on_player_died)
	level_up_screen.upgrade_selected.connect(on_upgrade_selected)
	exit_door.player_entered_exit.connect(on_player_entered_exit)
	player.player_hit.connect(on_player_hit)
	SaveManager.upgrade_items_changed.connect(hud.set_upgrade_items)
	if player:
		player_camera.global_position = player.global_position

	PlayerStats.reset_run_stats()
	PlayerStats.apply_permanent_bonuses()

	hud.set_experience(player.current_xp, player.xp_to_next_level, player.current_level)
	var initial_score = current_run_time + (player.current_level * level_weight)
	hud.set_score(int(initial_score)) 
	hud.set_upgrade_items(SaveManager.data.upgrade_items)
	if current_room_number > 9:
		start_boss_room()
	else:
		start_new_room()

func _process(delta: float) -> void:
	if exit_door.is_locked and enemy_container.get_child_count() == 0:
		print("all enemies killed, unlocking door")
		exit_door.unlock_door()
	camera_process(delta)

func start_new_room():
	exit_door.lock_door()
	difficulty_score += difficulty_adder
	hud.set_score(int(difficulty_score))
	player.global_position = $Room_1/Player_Spawn.global_position
	spawn_manager.set_spawn_area($Room_1.get_node("Spawn_Area"))
	spawn_manager.spawn_wave(difficulty_score)

func camera_process(delta):
	var player_pos = player.global_position
	var mouse_pos = get_global_mouse_position()
	var direction_to_mouse = (mouse_pos - player_pos)
	var mouse_offset = direction_to_mouse * camera_mouse_influence
	var target_pos = player_pos + mouse_offset
	player_camera.global_position = player_camera.global_position.lerp(target_pos, camera_smoothing_speed * delta)
	if shake_strength > 0:
		var offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_strength
		player_camera.offset = offset
	else:
		player_camera.offset = Vector2.ZERO

func on_player_entered_exit():
	current_room_number += 1
	if current_room_number > 9:
		start_boss_room()
	else:
		start_new_room()

func start_boss_room():
	exit_door.lock_door()
	exit_door.hide()
	difficulty_score += difficulty_adder
	if spawn_manager.has_method("spawn_boss"):
		spawn_manager.set_spawn_area($Room_1/Spawn_Area)
		spawn_manager.spawn_boss()
	else:
		print("ERROR: spawn_manager is missing spawn_boss() method")

func on_player_level_up():
	var choices = GlobalUpgrades.get_random_upgrades(3)
	level_up_screen.show_upgrades(choices)

func on_upgrade_selected(upgrade_data: Dictionary):
	player.apply_upgrade(upgrade_data)
	level_up_screen.hide()
	get_tree().paused = false

func _on_run_timer_timeout() -> void:
	current_run_time += 1
	hud.set_time(current_run_time)

func on_player_died():
	emit_signal("game_over")

func camera_shake(strength:float, duration: float):
	shake_strength = strength
	camera_shake_timer.wait_time = duration
	camera_shake_timer.start()

func on_player_hit():
	camera_shake(2.5, 0.10)

func _on_camera_shake_timer_timeout() -> void:
	shake_strength = 0.0

func get_current_room():
	return current_room
