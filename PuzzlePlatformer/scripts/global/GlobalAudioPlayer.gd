extends AudioStreamPlayer

func play_music(music: AudioStream, volume: float = 0.0):
	if stream == music:
		return
	
	stream = music
	volume_db = volume
	play()

func play_SFX(stream: AudioStream, volume: float = 0.0):
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = stream
	sfx_player.name = "SFX_" + str(stream)
	sfx_player.volume_db = volume
	add_child(sfx_player)
	
	sfx_player.play()
	await sfx_player.finished
	sfx_player.queue_free()
