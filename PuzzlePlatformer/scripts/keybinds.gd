extends Node2D


func _on_button_pressed():
	Click.play()
	get_tree().change_scene_to_file("res://scenes/settings.tscn")
