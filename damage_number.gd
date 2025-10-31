extends Label

func start(damage_amount: int, start_position: Vector2, is_crit: bool = false):
	text = str(damage_amount)
	global_position = start_position
	var horizontal_drift = randf_range(-15, 15)
	var bounce_height = -30
	var duration = 0.7
	if is_crit:
		modulate = Color.CRIMSON
		scale = Vector2(1.5, 1.5)
	else:
		modulate = Color.WHITE
		scale = Vector2(1, 1)
	var tween = create_tween().set_parallel(true)
	var target_pos = position + Vector2(horizontal_drift, bounce_height)
	tween.tween_property(self, "position", target_pos, duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, duration * 0.6).set_delay(duration * 0.4)
	tween.finished.connect(queue_free)
