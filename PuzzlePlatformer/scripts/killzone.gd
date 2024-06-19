extends Area2D


func _on_body_entered(body):
	await get_tree().create_timer(0.01).timeout # Process the collision.
	if body.is_in_group("Player"):
		body.kill()
	elif body.has_method("respawn"):
		body.respawn()
