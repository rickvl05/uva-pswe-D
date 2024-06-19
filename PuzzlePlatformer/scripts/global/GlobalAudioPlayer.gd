extends AudioStreamPlayer

func play_music(music: AudioStream, volume: float = 0.0):
	if stream == music:
		return
	
	stream = music
	volume_db = volume
	play()

func play_SFX_local(stream: AudioStream, volume: float = 0.0):
	# Create a new audioplayer to play the sfx
	var sfx_local_player = AudioStreamPlayer.new()
	sfx_local_player.stream = stream
	sfx_local_player.name = "SFX_local_" + str(stream)
	sfx_local_player.volume_db = volume

	# Play the sfx and wait until it has finished
	add_child(sfx_local_player)
	sfx_local_player.play()
	await sfx_local_player.finished

	sfx_local_player.queue_free()

@rpc("reliable", "any_peer", "call_local")
func play_SFX(stream: AudioStream, source_pos: Vector2,
			  max_hearing_dist: int = 1000, volume: float = 0.0):
	# Each player calculates the distance of the SFX source to itself
	var player_self = get_tree().root.get_node("Game/Players/" + str(multiplayer.get_unique_id()))
	var distance = source_pos.distance_to(player_self.position)

	# Create a new audioplayer to play the sfx
	var sfx_player = AudioStreamPlayer.new()
	var subtract_vol = 80
	sfx_player.stream = stream
	sfx_player.name = "SFX_" + str(stream)
	sfx_player.volume_db = volume

	# Apply some audio dampening
	var volume_dist = subtract_vol * (distance / max_hearing_dist)
	sfx_player.volume_db -= volume_dist
	
	# Play the sfx and wait until it has finished
	add_child(sfx_player)
	sfx_player.play()
	await sfx_player.finished

	sfx_player.queue_free()
