extends Node

signal upgrade_items_changed(new_total)

const SAVE_PATH = "user://save_data.res"
const UPGRADE_FOLDER = "res://Shrine_Upgrades/"

var data: Save_Data
var upgrades: Dictionary = {}

func _ready():
	load_all_upgrades()
	load_data()

func load_data():
	if FileAccess.file_exists(SAVE_PATH):
		data = ResourceLoader.load(SAVE_PATH)
	else:
		data = Save_Data.new()
		save_data()
	apply_save_data_to_upgrades()

func save_data():
	ResourceSaver.save(data, SAVE_PATH)

func load_all_upgrades():
	var dir = DirAccess.open(UPGRADE_FOLDER)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var path = UPGRADE_FOLDER.path_join(file_name)
				var upgrade = ResourceLoader.load(path) as Base_Shrine_Upgrade
				if upgrade:
					upgrades[upgrade.id] = upgrade
			file_name = dir.get_next()
	else:
		printerr("Could not find upgrade folder: ", UPGRADE_FOLDER)

func apply_save_data_to_upgrades():
	if data == null:
		printerr("SaveManager: data is null in apply_save_data_to_upgrades()")
		return
	for id in upgrades:
		var upgrade = upgrades[id]
		if data.purchased_upgrades.has(id):
			upgrade.is_purchased = true
		else:
			upgrade.is_purchased = false

func purchase_upgrade(id: String):
	if not upgrades.has(id):
		printerr("Unknown upgrade ID: ", id)
		return
	var upgrade = upgrades[id]
	if upgrade.is_purchased:
		print("Already purchased!")
		return
	if data.upgrade_items >= upgrade.cost:
		data.upgrade_items -= upgrade.cost
		upgrade.is_purchased = true
		data.purchased_upgrades.append(id)
		save_data()
	else:
		print("Not enough upgrade items")

func add_upgrade_items(amount: int):
	data.upgrade_items += amount
	save_data()
	emit_signal("upgrade_items_changed", data.upgrade_items)

func get_total_permanent_bonus(stat_id: String) -> float:
	var total_bonus: float = 0.0
	for upgrade in upgrades.values():
		if upgrade.is_purchased and upgrade.stat_to_modify == stat_id:
			total_bonus += upgrade.bonus_value
	return total_bonus
