extends PanelContainer

signal upgrade_purchased(id)

@onready var title_label = $VBoxContainer/Title_Label
@onready var description_label = $VBoxContainer/Description_Label
@onready var cost_label = $VBoxContainer/Cost_Label
@onready var buy_button = $VBoxContainer/Buy_Button

var upgrade_id: String

func _ready():
	buy_button.pressed.connect(_on_buy_pressed)

func set_upgrade(upgrade: Base_Shrine_Upgrade):
	upgrade_id = upgrade.id
	var display_data = upgrade.get_display_data()
	title_label.text = display_data.title
	description_label.text = display_data.description
	
	if display_data.is_purchased:
		buy_button.text = "Purchased"
		buy_button.disabled = true
		cost_label.visible = false
	else:
		buy_button.text = "Buy"
		var current_upgrade_items = SaveManager.data.upgrade_items
		buy_button.disabled = current_upgrade_items < display_data.cost
		cost_label.visible = true
		cost_label.text = "Cost: %s" % display_data.cost

func _on_buy_pressed():
	emit_signal("upgrade_purchased", upgrade_id)
