extends Node2D


@export var dark_level: bool = false
var cell_size = Vector2(16, 16)
var offset = Vector2(0.5, 0.5)  # because of centered objects.


func load_item(_parent_node, item_scene, grid_position):
	var new_item = item_scene.instantiate()
	add_child(new_item)
	new_item.global_position = grid_position * cell_size + (offset * cell_size)

func _ready():
	get_node("../InGameOverlay").toggle_reset_button(false)

	if dark_level:
		GlobalAudioPlayer.play_music.rpc("scary")
		var players_node = get_node("/root/Game/Players")
		print(players_node)
		for player in players_node.get_children():
			player.get_node("PlayerLight").visible = true
			print(player.get_node("PlayerLight"))
	else:
		GlobalAudioPlayer.play_music.rpc("level")


func _exit_tree():
	get_node("../InGameOverlay").toggle_reset_button(true)

	if dark_level:
		var players_node = get_node("/root/Game/Players")
		for player in players_node.get_children():
			player.get_node("PlayerLight").visible = false
