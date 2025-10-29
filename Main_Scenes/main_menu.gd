extends Control

signal start_game_pressed
signal shrine_button_pressed

@onready var start_button = $VBoxContainer/Start_Button
@onready var shrine_button = $VBoxContainer/Shrine_Button


func _on_start_button_pressed() -> void:
	emit_signal("start_game_pressed")

func _on_shrine_button_pressed() -> void:
	emit_signal("shrine_button_pressed")
