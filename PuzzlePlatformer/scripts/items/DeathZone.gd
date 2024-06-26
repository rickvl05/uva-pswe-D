extends Area2D


func _on_body_entered(body):
	# Check if the body can die.
	if body.has_method("kill"):
		await get_tree().create_timer(0.01).timeout # Process the collision.
		body.kill()
