extends Area2D

@export var upgrade_quantity: int = 1

func collect(player):
	SaveManager.add_upgrade_items(upgrade_quantity)
	call_deferred("queue_free")
