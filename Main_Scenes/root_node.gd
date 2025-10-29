extends Node

@export var main_menu_scene: PackedScene
@export var game_screen_scene: PackedScene
@export var game_over_scene: PackedScene
@export var shrine_scene: PackedScene

var current_scene_instance: Node


func _ready() -> void:
	show_main_menu()

func show_main_menu():
	if is_instance_valid(current_scene_instance):
		current_scene_instance.queue_free()
	current_scene_instance = main_menu_scene.instantiate()
	add_child(current_scene_instance)
	current_scene_instance.start_game_pressed.connect(start_game)
	current_scene_instance.shrine_button_pressed.connect(go_to_shrine)

func start_game():
	if is_instance_valid(current_scene_instance):
		current_scene_instance.queue_free()
	current_scene_instance = game_screen_scene.instantiate()
	add_child(current_scene_instance)
	current_scene_instance.player.player_died.connect(show_game_over)

func go_to_shrine():
	if is_instance_valid(current_scene_instance):
		current_scene_instance.queue_free()
	current_scene_instance = shrine_scene.instantiate()
	add_child(current_scene_instance)
	current_scene_instance.back_button.pressed.connect(show_main_menu)

func show_game_over():
	if is_instance_valid(current_scene_instance):
		current_scene_instance.queue_free()
	current_scene_instance = game_over_scene.instantiate()
	add_child(current_scene_instance)
	current_scene_instance.return_to_main_menu_pressed.connect(show_main_menu)
