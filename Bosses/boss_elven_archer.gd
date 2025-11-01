extends Node2D

@export var damage_number_scene: PackedScene

@onready var attack_cooldown = $Attack_Cooldown
@onready var attack_duration = $Attack_Duration

@export var max_health: int = 500
var current_health: int = max_health
var room_area: Node2D = null
var player: Node2D = null
var xp_orb_container: Node2D = null

enum State {IDLE, CHASING, ATTACKING}
var current_state = State.IDLE


func _ready() -> void:
	print("boss spawned")
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")
	
func _process(delta: float) -> void:
	if player == null:
		return
	match current_state:
		State.IDLE:
			pass

func get_hit(damage, is_crit: bool = false):
	current_health -= damage
	spawn_damage_number(damage, is_crit)
	if current_health <= 0:
		die()

func get_random_point_in_room() -> Vector2:
	if room_area == null:
		printerr("Boss: room area not set!")
		return global_position 
	var collision_shape = room_area.get_node_or_null("CollisionShape2D")
	if collision_shape == null:
		printerr("Boss: room area has no 'CollisionShape2D' child.")
		return global_position
	if not collision_shape.shape is RectangleShape2D:
		printerr("Boss: room area's collision shape is not a RectangleShape2D.")
		return global_position
	var rect_shape: RectangleShape2D = collision_shape.shape
	var size = rect_shape.size
	var center_pos = collision_shape.global_position
	var top_left = center_pos - size / 2.0
	var random_x = randf() * size.x
	var random_y = randf() * size.y
	return top_left + Vector2(random_x, random_y)

func spawn_damage_number(damage, is_crit):
	if damage_number_scene and is_instance_valid(xp_orb_container):
		var damage_number = damage_number_scene.instantiate()
		xp_orb_container.call_deferred("add_child", damage_number)
		var spawn_pos = global_position + Vector2(randf_range(-8, 8), randf_range(-8, 8))
		damage_number.start(damage, spawn_pos, is_crit)

func die():
	emit_signal("boss_defeated")
	call_deferred("queue_free")
