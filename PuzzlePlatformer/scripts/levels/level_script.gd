extends Node2D


@export var dark_level: bool = false


func _ready():
	if dark_level:
		GlobalAudioPlayer.play_music.rpc("scary")
		var players_node = get_node("/root/Game/Players")
		for player in players_node.get_children():
			player.get_node("PlayerLight").visible = true
	else:
		GlobalAudioPlayer.play_music.rpc("level")


func _exit_tree():
	if dark_level:
		var players_node = get_node("/root/Game/Players")
		for player in players_node.get_children():
			player.get_node("PlayerLight").visible = false
