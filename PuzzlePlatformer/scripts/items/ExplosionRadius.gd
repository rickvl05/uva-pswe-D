extends Area2D

func _on_bomb_timer_timeout():
	for body in get_overlapping_bodies():
		if body.has_method("kill"):
			body.kill()
	queue_free()
