extends Area2D


@rpc("any_peer", "call_local", "reliable")
func change_level() -> void:
	var players = get_tree().get_nodes_in_group("Player")
	var new_game = load("res://scenes/test.tscn").instantiate()
	get_tree().root.add_child(new_game)
	get_tree().root.get_node("Game").queue_free()


func _on_body_entered(body) -> void:
	if body.is_in_group("Player"):
		change_level.rpc()
