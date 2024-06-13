extends CanvasLayer

@export var GameScene: PackedScene

func _on_host_pressed():
	var new_game = load("res://scenes/levels/lobby.tscn").instantiate()
	get_tree().root.add_child(new_game)
	MultiplayerManager.host_game()
	get_tree().root.get_node("Menu").queue_free()


func _on_join_pressed():
	var new_game = load("res://scenes/levels/lobby.tscn").instantiate()
	get_tree().root.add_child(new_game)
	MultiplayerManager.join_game()
	get_tree().root.get_node("Menu").queue_free()
