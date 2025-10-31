extends CharacterBody2D

class_name BasicEnemy

@export var damage_number_scene: PackedScene

@export var current_health: int = 10
@export var max_health: int = 10
@export var health_modifier: float = 1.0
@export var speed: float = 50.0
@export var speed_modifier: float = 1.0
@export var xp_orb_scene: PackedScene
@export var upgrade_item_scene: PackedScene
@export var upgrade_item_drop_chance: float = 0.1
@export var hit_sound: AudioStream
@export var death_sound: AudioStream

@onready var health_bar = $TextureProgressBar


enum State {CHASE}
var current_state = State.CHASE


var player: Node2D = null
var xp_orb_container: Node2D = null


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	current_health = int(max_health * health_modifier)
	speed_modifier = randf_range(0.7, 1.3)
	scale = scale * randf_range(0.7, 1.3)
	speed = speed * speed_modifier
	health_bar.max_value = max_health
	health_bar.value = current_health
	health_bar.visible = false


func _physics_process(delta: float) -> void:
	if player == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	match current_state:
		State.CHASE:
			chase_state()
	move_and_slide()


func chase_state():
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed


func get_hit(damage, is_crit: bool = false):
	current_health -= damage
	if damage_number_scene and is_instance_valid(xp_orb_container):
		var damage_number = damage_number_scene.instantiate()
		xp_orb_container.call_deferred("add_child", damage_number)
		var spawn_pos = global_position + Vector2(randf_range(-8, 8), randf_range(-8, 8))
		damage_number.start(damage, spawn_pos, is_crit)
	if !health_bar.visible:
		health_bar.visible = true
	health_bar.value = current_health
	if current_health <= 0:
		die()


func die():
	AudioManager.play_sfx(death_sound)
	if xp_orb_scene and is_instance_valid(xp_orb_container):
		var xp_orb = xp_orb_scene.instantiate()
		xp_orb.global_position = self.global_position
		xp_orb_container.call_deferred("add_child", xp_orb)
	if randf() < upgrade_item_drop_chance:
		if upgrade_item_scene and is_instance_valid(xp_orb_container):
			var upgrade_item = upgrade_item_scene.instantiate()
			upgrade_item.global_position = self.global_position
			xp_orb_container.call_deferred("add_child", upgrade_item)
	call_deferred("queue_free")
