extends Node2D

signal game_over

@export var player: CharacterBody2D
@export var level_up_screen: Control
@export var hud: CanvasLayer
@export var spawn_manager: Node2D

@export var level_weight: float = 2.0

@onready var run_timer = $Run_Timer
@onready var spawn_timer = $Spawn_Timer

var current_run_time: int = 0
var difficulty_score = 1

func _ready() -> void:
	PlayerStats.stat_updated.connect(hud.on_player_stat_updated)
	player.level_up_started.connect(on_player_level_up)
	player.health_changed.connect(hud.set_health)
	player.experience_changed.connect(hud.set_experience)
	player.player_died.connect(on_player_died)
	level_up_screen.upgrade_selected.connect(on_upgrade_selected)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	SaveManager.upgrade_items_changed.connect(hud.set_upgrade_items)

	PlayerStats.reset_run_stats()
	PlayerStats.apply_permanent_bonuses()

	hud.set_experience(player.current_xp, player.xp_to_next_level, player.current_level)
	var initial_score = current_run_time + (player.current_level * level_weight)
	hud.set_score(int(initial_score)) 
	hud.set_upgrade_items(SaveManager.data.upgrade_items)

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

func _on_spawn_timer_timeout() -> void:
	difficulty_score = current_run_time + (player.current_level * level_weight)
	hud.set_score(int(difficulty_score))
	spawn_manager.spawn_wave(difficulty_score)
	# This will speed up the timer as difficulty increase but we dont want that right now
	# var new_wait_time = 3.0 - (difficulty_score / 200.0) # 3s, gets faster
	# spawn_timer.wait_time = max(0.5, new_wait_time)
