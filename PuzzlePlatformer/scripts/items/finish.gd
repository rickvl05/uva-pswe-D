extends Area2D


@export var next_level_number = 1


func _on_body_entered(body) -> void:
	if body.is_in_group("Player"):
		get_tree().root.get_node("Game").change_level(next_level_number)
