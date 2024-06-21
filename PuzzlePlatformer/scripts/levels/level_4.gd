extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalAudioPlayer.play_music.rpc("scary")
	var players_node = get_node("/root/Game/Players")
	for player in players_node.get_children():
		player.get_node("PlayerLight").visible = true

func _exit_tree():
	var players_node = get_node("/root/Game/Players")
	for player in players_node.get_children():
		player.get_node("PlayerLight").visible = false
