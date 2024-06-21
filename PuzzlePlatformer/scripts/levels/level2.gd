extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalAudioPlayer.play_music.rpc("level")
