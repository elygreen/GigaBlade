extends Control

signal back_pressed

@export var upgrade_card_scene: PackedScene
@onready var upgrade_item_label = $Upgrade_Item_Label
@onready var back_button = $Back_Button
@onready var upgrade_container = $ScrollContainer/Upgrade_Container

func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	build_ui()
	update_upgrade_item_count()

func build_ui():
	for child in upgrade_container.get_children():
		child.queue_free()
	var all_upgrades = SaveManager.upgrades.values()
	for upgrade in all_upgrades:
		var card = upgrade_card_scene.instantiate()
		upgrade_container.add_child(card)
		card.set_upgrade(upgrade)
		card.upgrade_purchased.connect(_on_upgrade_purchased)

func update_upgrade_item_count():
	upgrade_item_label.text = "Upgrade items: %s" % SaveManager.data.upgrade_items

func _on_upgrade_purchased(upgrade_id: String):
	SaveManager.purchase_upgrade(upgrade_id)
	build_ui()
	update_upgrade_item_count()

func _on_back_button_pressed():
	emit_signal("back_pressed")
