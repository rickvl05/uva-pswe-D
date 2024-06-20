extends Area2D


@export var next_level_number = 1


func _on_body_entered(body) -> void:
	if body.is_in_group("Player"):
		get_tree().root.get_node("Game").change_level(next_level_number)
		# tp player to 25, 50
		body.global_position = Vector2(25, 50)
