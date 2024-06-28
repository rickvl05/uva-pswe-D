extends CanvasLayer

@onready var music_id = AudioServer.get_bus_index("music")
@onready var sfx_id = AudioServer.get_bus_index("Sound FX")

func _on_back_pressed():
	Click.play()
	queue_free()


func _on_music_scroll_value_changed(value):
	AudioServer.set_bus_volume_db(music_id, linear_to_db(value))
	AudioServer.set_bus_mute(music_id, value < 1)


func _on_sound_fx_scroll_value_changed(value):
	AudioServer.set_bus_volume_db(sfx_id, linear_to_db(value))
	AudioServer.set_bus_mute(sfx_id, value < 1)
