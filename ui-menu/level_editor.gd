extends Node2D



func _on_keybinds_pressed():
	get_tree().change_scene_to_file("res://keybinds.tscn")


func _on_back_pressed():
	get_tree().change_scene_to_file("res://node_2d.tscn")
