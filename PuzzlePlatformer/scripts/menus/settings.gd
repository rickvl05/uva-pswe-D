extends CanvasLayer

@onready var Music_id = AudioServer.get_bus_index("Music")
@onready var SFX_id = AudioServer.get_bus_index("Sound FX")

func _on_back_pressed():
	Click.play()
	queue_free()


func _on_music_scroll_value_changed(value):
	AudioServer.set_bus_volume_db(Music_id, linear_to_db(value))
	AudioServer.set_bus_mute(Music_id, value < 1)


func _on_sound_fx_scroll_value_changed(value):
	AudioServer.set_bus_volume_db(SFX_id, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_id, value < 1)
	
