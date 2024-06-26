extends Node2D
var cell_size = Vector2(16, 16)
var offset = Vector2(0.5, 0.5) # because of centered objects.

@onready var editor_object = get_node("/root/main/Editor_Object")

func load_item(parent_node, item_scene, grid_position):
	print("grid_pos item:", grid_position)
	var new_item = item_scene.instantiate()
	print("item scene trying to place: ", new_item.name)
	add_child(new_item)
	new_item.global_position = grid_position * cell_size + (offset * cell_size)

func _input(event):
	if GlobalLevelEditor.playing:
		if event is InputEventKey:
			if event.is_action_pressed("dark"):
				if editor_object.dark_level == true:
					editor_object.dark_level = false
				else:
					editor_object.dark_level = true
func _ready():
	print("kijk of hij hier ook komt", editor_object.dark_level)
	if editor_object.dark_level: 
		print("hier is ie true ", editor_object.dark_level)
		print("Dit komt niet hier")
		GlobalAudioPlayer.play_music.rpc("scary")
		var players_node = get_node("/root/Game/Players")
		for player in players_node.get_children():
			player.get_node("PlayerLight").visible = true
	else:
		GlobalAudioPlayer.play_music.rpc("level")

func _exit_tree():
	print("Kijk of deze werkt")
	if editor_object.dark_level:
		print("Wat gebeurt hier")
		var players_node = get_node("/root/Game/Players")
		for player in players_node.get_children():
			player.get_node("PlayerLight").visible = false
