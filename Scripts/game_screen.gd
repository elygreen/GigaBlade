extends Node2D

signal game_over

@export var player: CharacterBody2D
@export var level_up_screen: Control
@export var hud: CanvasLayer
@export var spawn_manager: Node2D
@export var exit_door: Node2D
@export var level_weight: float = 2.0

@onready var run_timer = $Run_Timer
@onready var enemy_container = $Enemy_Container

var current_run_time: int = 0
var difficulty_score = 1
var difficulty_adder = 5
var current_room = 1

func _ready() -> void:
	PlayerStats.stat_updated.connect(hud.on_player_stat_updated)
	player.level_up_started.connect(on_player_level_up)
	player.health_changed.connect(hud.set_health)
	player.experience_changed.connect(hud.set_experience)
	player.player_died.connect(on_player_died)
	level_up_screen.upgrade_selected.connect(on_upgrade_selected)
	exit_door.player_entered_exit.connect(on_player_entered_exit)
	SaveManager.upgrade_items_changed.connect(hud.set_upgrade_items)

	PlayerStats.reset_run_stats()
	PlayerStats.apply_permanent_bonuses()

	hud.set_experience(player.current_xp, player.xp_to_next_level, player.current_level)
	var initial_score = current_run_time + (player.current_level * level_weight)
	hud.set_score(int(initial_score)) 
	hud.set_upgrade_items(SaveManager.data.upgrade_items)
	start_new_room()

func _process(delta: float) -> void:
	if exit_door.is_locked and enemy_container.get_child_count() == 0:
		print("all enemies killed, unlocking door")
		exit_door.unlock_door()

func start_new_room():
	exit_door.lock_door()
	difficulty_score += difficulty_adder
	hud.set_score(int(difficulty_score))
	spawn_manager.spawn_wave(difficulty_score)

func on_player_entered_exit():
	current_room += 1
	if current_room > 9:
		start_boss_room()
	else:
		start_new_room()

func start_boss_room():
	exit_door.lock_door()
	exit_door.hide()
	difficulty_score += difficulty_adder
	if spawn_manager.has_method("spawn_boss"):
		spawn_manager.spawn_boss(difficulty_score)
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
