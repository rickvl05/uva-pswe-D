extends Node2D
var cell_size = Vector2(16, 16)
var offset = Vector2(0.5, 0.5) # because of centered objects.
@export var dark_level: bool = false

func load_item(parent_node, item_scene, grid_position):
	#print("grid_pos item:", grid_position)
	var new_item = item_scene.instantiate()
	#print("item scene trying to place: ", new_item.name)
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
