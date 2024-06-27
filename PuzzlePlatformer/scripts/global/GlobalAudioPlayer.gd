extends AudioStreamPlayer

# Load the sound effects.
const death_sfx = preload("res://assets/sounds/death.wav")
const throw_sfx = preload("res://assets/sounds/throw.wav")
const grab_sfx = preload("res://assets/sounds/pickup.wav")
const deny_sfx = preload("res://assets/sounds/nopickup.wav")
const explosion_sfx = preload("res://assets/sounds/explosion.wav")
const jump_sfx = preload("res://assets/sounds/jump.wav")
const bounce_sfx = preload("res://assets/sounds/bounce.wav")
const balloon_pop_sfx = preload("res://assets/sounds/balloon_pop.wav")

# Load the music tracks.
const menu_music = preload("res://assets/music/MainMenu.mp3")
const lobby_music = preload("res://assets/music/lobby.mp3")
const level_music = preload("res://assets/music/peacefulsong.mp3")
const scary_music = preload("res://assets/music/scarysong.mp3")
const editor_music = preload("res://assets/music/level_editor.mp3")
const blue_music = preload("res://assets/music/blue_level.mp3")
const pink_music = preload("res://assets/music/pink_level.mp3")

"""
Plays the music in the global audio player. If the same stream is called whilst
it is already playing, it is skipped.
"""
func _play_music(music: AudioStream, volume: float = 0.0):
	if stream == music:
		return
	
	stream = music
	volume_db = volume
	play()

"""
The play music method. See the wiki page on our github repo.
"""
@rpc("reliable", "any_peer", "call_local")
func play_music(music_string: String, volume: float = 0.0):
	var string_mapping = _string2stream()
	assert(music_string in string_mapping, 'Audio not in database!')
	_play_music(string_mapping[music_string], volume)

"""
Plays a sound effect only for the player who instantiated it. Creates a new
audio player to make the sound effect play over the music and other
sound effects.
"""
func _play_SFX_local(stream: AudioStream, volume: float = 0.0):
	# Create a new audioplayer to play the sfx
	var sfx_local_player = AudioStreamPlayer.new()
	sfx_local_player.stream = stream
	sfx_local_player.name = "SFX_local_" + str(stream)
	sfx_local_player.volume_db = volume
	sfx_local_player.bus = "Sound FX"

	# Play the sfx and wait until it has finished
	add_child(sfx_local_player)
	sfx_local_player.play()
	await sfx_local_player.finished

	sfx_local_player.queue_free()

"""
The initialize_SFX method. See the wiki page on our github repo.
"""
@rpc("unreliable", "any_peer", "call_local")
func initialize_SFX(sfx_name: String, source_pos: Vector2, local: bool = false, 
					max_hearing_dist: int = 1000, volume: float = 0.0):
		"""
		Wrapper function for 'play_SFX'. Is an rpc function so that the SFX
		can be played across all players.
		"""
		var string_mapping = _string2stream()
		assert(sfx_name in string_mapping, 'SFX not in database!')

		if local:
			_play_SFX_local(string_mapping[sfx_name], volume)
		else:
			_play_SFX(string_mapping[sfx_name], source_pos, max_hearing_dist,
				 	  volume)

"""
Plays a sound effect globally for all players. Each player calculates its 
distance from the sound effect to determine how loud it is for them. 
Creates a new audio player to make the sound effect play over the music 
and other sound effects.
"""
func _play_SFX(stream: AudioStream, source_pos: Vector2,
			  max_hearing_dist: int = 1000, volume: float = 0.0):
	# Each player calculates the distance of the SFX source to itself
	var player_self = get_tree().root.get_node("Game/Players/" + \
					  str(multiplayer.get_unique_id()))
	var distance = source_pos.distance_to(player_self.position)

	# Create a new audioplayer to play the sfx
	var sfx_player = AudioStreamPlayer.new()
	var subtract_vol = 80
	sfx_player.stream = stream
	sfx_player.name = "SFX_" + str(stream)
	sfx_player.volume_db = volume
	sfx_player.bus = "Sound FX"

	# Apply some audio dampening
	var volume_dist = subtract_vol * (distance / max_hearing_dist)
	sfx_player.volume_db -= volume_dist
	
	# Play the sfx and wait until it has finished
	add_child(sfx_player)
	sfx_player.play()
	await sfx_player.finished

	sfx_player.queue_free()

"""
Maps a string to the according audio stream.
"""
func _string2stream() -> Dictionary:
	return {
		"grab": grab_sfx,
		"explosion": explosion_sfx,
		"jump": jump_sfx,
		"deny": deny_sfx,
		"throw": throw_sfx,
		"death": death_sfx,
		"bounce": bounce_sfx,
		"balloon_pop": balloon_pop_sfx,
		"menu": menu_music,
		"lobby": lobby_music,
		"level": level_music,
		"scary": scary_music,
		"editor": editor_music,
		"blue": blue_music,
		"pink": pink_music
	}

"""
Loops the music if it finished playing.
"""
func _on_finished():
	play()
