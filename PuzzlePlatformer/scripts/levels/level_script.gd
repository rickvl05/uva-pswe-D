extends Node2D


@export var dark_level: bool = false


func _ready():
	get_node("../InGameOverlay").toggle_reset_button(false)

	if dark_level:
		GlobalAudioPlayer.play_music.rpc("scary")
		var players_node = get_node("/root/Game/Players")
		for player in players_node.get_children():
			player.get_node("PlayerLight").visible = true
	else:
		GlobalAudioPlayer.play_music.rpc("level")


func _exit_tree():
	get_node("../InGameOverlay").toggle_reset_button(true)

	if dark_level:
		var players_node = get_node("/root/Game/Players")
		for player in players_node.get_children():
			player.get_node("PlayerLight").visible = false
