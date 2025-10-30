extends Control

signal upgrade_selected(upgrade_data)

@onready var button_1 = $VBoxContainer/Upgrade_1
@onready var button_2 = $VBoxContainer/Upgrade_2
@onready var button_3 = $VBoxContainer/Upgrade_3

var current_choices: Array = []

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	button_1.pressed.connect(_on_button_1_pressed)
	button_2.pressed.connect(_on_button_2_pressed)
	button_3.pressed.connect(_on_button_3_pressed)
	self.hide()

func show_upgrades(choices: Array):
	if choices.size() < 3:
		print("Not enough upgrades to show!")
		return
	current_choices = choices
	button_1.text = "%s\n%s" % [choices[0].title, choices[0].description]
	button_1.icon = choices[0].icon
	button_2.text = "%s\n%s" % [choices[1].title, choices[1].description]
	button_2.icon = choices[1].icon
	button_3.text = "%s\n%s" % [choices[2].title, choices[2].description]
	button_3.icon = choices[2].icon
	self.show()

func _on_button_1_pressed():
	emit_signal("upgrade_selected", current_choices[0])

func _on_button_2_pressed():
	emit_signal("upgrade_selected", current_choices[1])

func _on_button_3_pressed():
	emit_signal("upgrade_selected", current_choices[2])
