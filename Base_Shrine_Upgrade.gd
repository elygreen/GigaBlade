extends Resource
class_name Base_Shrine_Upgrade

@export var id: String = "default_id"
@export_enum(StatTypes)

@export_multiline var title: String = "New Upgrade"
@export_multiline var description: String = "Gives a one time bonus"

@export var cost: int = 10
@export var bonus_value: float = 1.0

var is_purchased: bool = false

func get_display_data() -> Dictionary:
	return {
		"title": title,
		"description": description,
		"cost": cost,
		"is_purchased": is_purchased
	}
	
func get_total_bonus() -> float:
	if is_purchased:
		return bonus_value
	else:
		return 0.0
