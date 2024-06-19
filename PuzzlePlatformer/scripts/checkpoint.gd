extends Area2D

@export var check: Vector2
func _on_body_entered(body):
	if body.is_in_group("Player"):
		check = Vector2(position.x, 0)
		body.set_checkpoint(check)
