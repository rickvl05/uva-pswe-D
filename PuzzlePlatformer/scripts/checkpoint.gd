extends Area2D


func _on_body_entered(body):
	if body.is_in_group("Player"):
		var checkpoint = Vector2(global_position.x, global_position.y - 25)
		body.set_checkpoint(checkpoint)
