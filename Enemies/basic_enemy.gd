extends CharacterBody2D

class_name BasicEnemy

@export var current_health: int = 10
@export var max_health: int = 10
@export var health_modifier: float = 1.0
@export var speed: float = 75.0
@export var speed_modifier: float = 1.0
@export var xp_orb_scene: PackedScene
@export var upgrade_item_scene: PackedScene
@export var upgrade_item_drop_chance: float = 0.1

@onready var health_bar = $ProgressBar


enum State {CHASE}
var current_state = State.CHASE
var player_node: Node2D = null


var player: Node2D = null
var xp_orb_container: Node2D = null


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	current_health = int(max_health * health_modifier)
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


func get_hit(damage):
	current_health -= damage
	if !health_bar.visible:
		health_bar.visible = true
	health_bar.value = current_health
	if current_health <= 0:
		die()


func die():
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


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("ally_hitbox"):
		get_hit(area.damage)
