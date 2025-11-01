extends BasicEnemy

@onready var animation = $AnimationPlayer

var strafe_time: float = 0.0
var strafe_direction: float = 1.0

func chase_state(delta):
	play_chase_animation()
	strafe_time += delta
	if strafe_time > randf_range(0.8, 8):
		strafe_time = 0.0
		strafe_direction = -strafe_direction
	var direction_to_player = (player.global_position - global_position).normalized()
	var strafe_vector = direction_to_player.orthogonal() * strafe_direction
	var final_direction = (direction_to_player + strafe_vector).normalized()
	velocity = final_direction * speed

func custom_ready():
	var anim = animation.get_animation("Zombie_Chase")
	var anim_length = anim.length
	var random_time = randf_range(0.0, anim_length)
	animation.play("Zombie_Chase")
	animation.seek(random_time)
	animation.speed_scale = randf_range(0.2, 0.4)
	scale = Vector2(1, 1) * randf_range(1.2, 1.8)

func play_chase_animation():
	animation.play("Zombie_Chase")
