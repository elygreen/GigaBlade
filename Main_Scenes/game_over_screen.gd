extends Control

signal return_to_main_menu_pressed

@onready var menu_button = $VBoxContainer/Main_Menu_Button

func _ready():
	menu_button.pressed.connect(_on_menu_button_pressed)

func _on_menu_button_pressed():
	emit_signal("return_to_main_menu_pressed")
