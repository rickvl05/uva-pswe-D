extends Node2D

func _on_button_pressed():
	click.play()
	get_tree().change_scene_to_file("res://level_editor.tscn")
