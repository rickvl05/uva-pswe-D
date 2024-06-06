extends Node2D

func _on_quit_pressed():
	click.play()
	get_tree().quit()

func _on_play_pressed():
	click.play()
	get_tree().change_scene_to_file("res://world.tscn")
	

func _on_settings_pressed():
	click.play()
	get_tree().change_scene_to_file("res://level_editor.tscn")


func _on_level_editor_pressed():
	click.play()
