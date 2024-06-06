extends Node2D



func _on_keybinds_pressed():
	click.play()
	get_tree().change_scene_to_file("res://keybinds.tscn")


func _on_back_pressed():
	click.play()
	get_tree().change_scene_to_file("res://node_2d.tscn")


func _on_h_scroll_bar_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
