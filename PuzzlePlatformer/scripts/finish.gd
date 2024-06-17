extends Area2D


@rpc("any_peer", "call_local", "reliable")
func change_level() -> void:
	#var players = get_tree().get_nodes_in_group("Player")
	#get_tree().change_scene_to_file("res://scenes/level_2.tscn")
	var children = ["MultiplayerSpawner", "Players"]
	for child in get_tree().root.get_node("Game").get_children():
		if child.name not in children:
			child.queue_free()
			print(child)
	var new_game = load("res://scenes/level_2.tscn").instantiate()
	get_tree().root.add_child(new_game)
	
	for child in get_tree().root.get_node("Game").get_children():
		#print(child)
		if child.name == "Players":
			child.z_index = 1
			#print(child)
	for child in get_tree().root.get_node("Players").get_children():
		child.new_level.rpc()

@rpc("any_peer", "call_local", "reliable")
func printer() -> void:
	print('hello')

func _on_body_entered(body) -> void:
	if body.is_in_group("Player"):
		change_level.rpc()
		#body.new_level.rpc()
