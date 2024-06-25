# SaverLoader.gd

class_name SaverLoader
extends Node

@onready var tile_map = $"../../World/TileMap"
@onready var fd_load = $"../../item_select/menu_container/HBoxContainer/FD_load"
@onready var fd_save = $"../../item_select/menu_container/HBoxContainer/FD_save"
@onready var fd_test = $"../../item_select/menu_container/HBoxContainer/FD_test"

const DEFAULT_PORT = 7777
const DEFAULT_IP = "127.0.0.1"

var available_colors = [1, 2, 3, 4]
var player_count = 0

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
	# Clear placed items
	for coordinates in tile_map.placed_items.keys():
		var item = tile_map.placed_items[coordinates]
		item.queue_free()
	tile_map.placed_items.clear()
	tile_map.clear()

func _on_fd_test_file_selected(path):
	print("TEST RUN:::")
	var custom_level = load("res://scenes/custom_game.tscn")
	var custom_level_instance = custom_level.instantiate()
	var custom_level_node = custom_level_instance.get_node("Level")
	var load_tile_map = custom_level_instance.get_node("Level/TileMap")
	print("saverloader:", self)
	print("tile map:", load_tile_map)

	var file = FileAccess.open(path, FileAccess.READ)
	if file.file_exists(path):
		# Clear existing items and tiles
		_clear_existing_assets()
		
		# Load the saved data
		var json_text = file.get_as_text()
		var saved_data = JSON.parse_string(json_text)
		
				# Load tiles
		for tile in saved_data["tiles"]:
			var layer_id = 0
			var position = Vector2(tile["position:x"], tile["position:y"])
			var source_id = 0
			var atlas_coordinates = Vector2i(tile["atlas_coordinates:x"], tile["atlas_coordinates:y"])
			load_tile_map.set_cell(layer_id, position, source_id, atlas_coordinates)

		# Load items
		for item in saved_data["items"]:
			var position = Vector2(item["position:x"], item["position:y"])
			if item["scene"] == "spawn_marker":
				var start_point = Marker2D.new()
				start_point.name = "StartPoint"
				start_point.position = position
				custom_level_instance.add_child(start_point)
				print(start_point, " at: ", position)
				continue
			var scene = load("res://scenes/items and objects/" + item["scene"] + ".tscn")
			custom_level_node.load_item(custom_level_instance, scene, position)
			
	Click.play()
	start_test_state(custom_level_instance)

	file.close()

func start_test_state(level_instance):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(DEFAULT_PORT, 4)
	if error != OK:
		print("Can't host")
		return error
	multiplayer.set_multiplayer_peer(peer)

	# Create level instance
	get_tree().root.add_child(level_instance)
	get_tree().root.get_node("main").queue_free()

	_on_player_connect(multiplayer.get_unique_id())
	return error

func _on_player_connect(id):
	if not multiplayer.is_server():
		return
	
	player_count += 1

	var new_player = load("res://scenes/player.tscn")
	new_player = new_player.instantiate()
	new_player.name = str(id)
	new_player.color = available_colors.pop_front()
	print("Attempting to add player to gamescene: ", GlobalLevelEditor.get_game_scene())

	var game_scene = GlobalLevelEditor.get_game_scene()
	if game_scene:
		print("Gamescene is available: ", game_scene)
		game_scene.get_node("Players").add_child(new_player)
	else:
		print("Gamescene is not set")

	set_player_attributes.rpc(str(id), new_player.get_settable_attributes())

@rpc ("authority", "unreliable", "call_local")
func set_player_attributes(target_name, attribute_dict):
	var target = GlobalLevelEditor.get_game_scene().get_node("Players/" + target_name)
	for key in attribute_dict:
		target.set(key, attribute_dict[key])

func _on_save_but_pressed():
	fd_save.visible = true

func _on_load_but_pressed():
	fd_load.visible = true

func _on_clear_but_pressed():
	_clear_existing_assets()

func _on_test_but_pressed():
	fd_test.visible = true
