class_name SaverLoader
extends Node

@onready var level: Node = get_node("/root/World")
@onready var tile_map = $"../../World/TileMap"
@onready var fd_load = $"../../item_select/menu_container/HBoxContainer/FD_load"
@onready var fd_save = $"../../item_select/menu_container/HBoxContainer/FD_save"
@onready var fd_test = $"../../item_select/menu_container/HBoxContainer/FD_test"

func _ready():
	fd_load.add_filter("*.json ; JSON Files")
	fd_save.add_filter("*.json ; JSON Files")
	fd_test.add_filter("*.json ; JSON Files")
	fd_save.current_dir = "/custom_levels"

func _on_fd_save_file_selected(path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	var saved_data = {
		"items": [],
		"tiles": []
	}

	for coordinates in tile_map.placed_items.keys():
		var item = {
			"position:x": coordinates.x,
			"position:y": coordinates.y,
			"scene": tile_map.placed_items[coordinates].scene_name
		}
		saved_data["items"].append(item)

	for coordinates in tile_map.get_used_cells(0):
		var tile = {
			"position:x": coordinates.x,
			"position:y": coordinates.y,
			"atlas_coordinates:x": tile_map.get_cell_atlas_coords(0, coordinates).x,
			"atlas_coordinates:y": tile_map.get_cell_atlas_coords(0, coordinates).y
		}
		saved_data["tiles"].append(tile)
	var json = JSON.stringify(saved_data)
	file.store_string(json)
	file.close()

func _on_fd_load_file_selected(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if file.file_exists(path):
		# Clear existing items and tiles
		_clear_existing_assets()

		# Load the saved data
		var json_text = file.get_as_text()
		var saved_data = JSON.parse_string(json_text)
		
		# Load items
		for item in saved_data["items"]:
			var position = Vector2(item["position:x"], item["position:y"])
			tile_map.grid_position = position
			var scene = load("res://scenes/level_editor/objects/" + item["scene"] + ".tscn")
			tile_map.place_item(scene)

		# Load tiles
		for tile in saved_data["tiles"]:
			var layer_id = 0
			var position = Vector2(tile["position:x"], tile["position:y"])
			var source_id = 0
			var atlas_coordinates = Vector2i(tile["atlas_coordinates:x"], tile["atlas_coordinates:y"])
			tile_map.set_cell(layer_id, position, source_id, atlas_coordinates)
	file.close()

func _clear_existing_assets():
	pass
	## Clear placed items in the TileMap
	#for coordinates in tile_map.placed_items.keys():
		#var item = tile_map.placed_items[coordinates]
		#item.queue_free()
	#tile_map.placed_items.clear()
	#tile_map.clear()
#
	## Clear all RigidBody nodes in the scene
	#print("root node:", get_tree().get_root())
	#_clear_rigid_bodies(get_tree().get_root())

# Function to clear all RigidBody nodes under a given parent
func _clear_rigid_bodies(parent):
	for child in parent.get_children():
		if child is RigidBody2D:
			child.queue_free()
		elif child.has_node():  # Check if the child can have children (e.g., is a node)
			_clear_rigid_bodies(child)  # Recursively clear RigidBodies in children



func _on_fd_test_file_selected(path):
	print("TEST RUN:::")
	var custom_level = load("res://scenes/level_editor/custom_level.tscn")
	var custom_level_instance = custom_level.instantiate()
	custom_level_instance.print_tree_pretty()
	print(custom_level_instance)
	var load_tile_map = custom_level_instance.get_node("TileMap")

	var file = FileAccess.open(path, FileAccess.READ)

	if file.file_exists(path):
		# Clear existing items and tiles 
		_clear_existing_assets()
		# TODO clear rigid bodies--

		# Load the saved data
		var json_text = file.get_as_text()
		var saved_data = JSON.parse_string(json_text)
		
		# Load items
		for item in saved_data["items"]:
			var position = Vector2(item["position:x"], item["position:y"])
			if(item["scene"] == "spawn_marker"):
				pass
				#var start_point = Marker2D.new()
				#start_point.name = "StartPoint"
				#start_point.position = tile_map.grid_position
				#level.add_child(start_point)
				#print(start_point, "marker at: ", tile_map.grid_position)
				#pass
			var scene = load("res://scenes/items and objects/" + item["scene"] + ".tscn")
			print("attempting to add scene: ", item["scene"], "at: ", position)
			load_tile_map.load_item(custom_level_instance, scene, position)

		# Load tiles
		for tile in saved_data["tiles"]:
			var layer_id = 0
			var position = Vector2(tile["position:x"], tile["position:y"])
			var source_id = 0
			var atlas_coordinates = Vector2i(tile["atlas_coordinates:x"], tile["atlas_coordinates:y"])
			load_tile_map.set_cell(layer_id, position, source_id, atlas_coordinates)
	Click.play()
	start_test_state(custom_level_instance)

	file.close()
	pass # Replace with function body.

func start_test_state(level_instance):
	const DEFAULT_PORT = 7777
	const DEFAULT_IP = "127.0.0.1"

	var available_colors = [1, 2, 3, 4]
	# Set host peer
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(DEFAULT_PORT, 4)
	multiplayer.set_multiplayer_peer(peer)

	# Create level instance
	#var new_game = load("res://scenes/level_editor/custom_level.tscn").instantiate()
	get_tree().root.get_node("main").queue_free()
	get_tree().root.add_child(level_instance)

	#if error != OK:
		#print("Can't host")
	#_on_player_connect(multiplayer.get_unique_id())


func _on_save_but_pressed():
	fd_save.visible = true

func _on_load_but_pressed():
	fd_load.visible = true

func _on_clear_but_pressed():
	_clear_existing_assets()

func _on_test_but_pressed():
	fd_test.visible = true

