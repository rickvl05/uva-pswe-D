extends Node

var playing = true
var current_tile = 0
var place_tile = false
var game_scene: Node = null


func set_game_scene(scene: Node):
	game_scene = scene

func get_game_scene() -> Node:
	return game_scene

	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
