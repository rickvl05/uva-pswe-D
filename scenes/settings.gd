extends Node2D

@onready var Music_id = AudioServer.get_bus_index("Music")
@onready var SFX_id = AudioServer.get_bus_index("Sound FX")

func _on_back_pressed():
	Click.play()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_keybinds_pressed():
	Click.play()
	get_tree().change_scene_to_file("res://ui-menu/keybinds.tscn")


func _on_music_scroll_value_changed(value):
	AudioServer.set_bus_volume_db(Music_id, linear_to_db(value))
	AudioServer.set_bus_mute(Music_id, value < 1)


func _on_sound_fx_scroll_value_changed(value):
	AudioServer.set_bus_volume_db(SFX_id, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_id, value < 1)
	
