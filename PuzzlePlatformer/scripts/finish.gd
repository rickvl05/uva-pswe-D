extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		var players = get_tree().get_nodes_in_group("Player")
		for player in players:
			print('hey')
			var new_game = load("res://scenes/test.tscn").instantiate()
			print(new_game)
			get_tree().root.add_child(new_game)
			get_tree().root.get_node("Game").queue_free()
			print('finish')
		#get_tree().change_scene_to_file("res://scenes/test.tscn")
