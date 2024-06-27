extends Node2D


# Cursed variable needed to fix bug where clients can join while game is
# active
func is_lobby():
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalAudioPlayer.play_music.rpc("lobby")
