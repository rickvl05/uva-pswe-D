extends Area2D

@export var check: NodePath
func _on_body_entered(body):
	if body.is_in_group("Player"):
		var check = Vector2(position.x, 0)
		body.checkpoint.rpc(check)
