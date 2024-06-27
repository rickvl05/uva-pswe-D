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
	save_test(path)


func save_test(path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	var saved_data = {"items": [], "tiles": [], "dark": false}
	var menu_container = get_node("/root/main/item_select/menu_container")
	saved_data["dark"] = menu_container.toggle_dark
	for coordinates in tile_map.placed_items.keys():
		var item = {
			"position:x": coordinates.x,
			"position:y": coordinates.y,
			"scene": tile_map.placed_items[coordinates].scene_name
		}
		saved_data["items"].append(item)

	for layer in [0, 1]:
		for coordinates in tile_map.get_used_cells(layer):
			var tile = {
				"position:x": coordinates.x,
				"position:y": coordinates.y,
				"atlas_coordinates:x": tile_map.get_cell_atlas_coords(layer, coordinates).x,
				"atlas_coordinates:y": tile_map.get_cell_atlas_coords(layer, coordinates).y,
				"layer": layer,
				"source": tile_map.get_cell_source_id(layer, coordinates)
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

		# automatically toggle the dark button
		var menu_container = get_node("/root/main/item_select/menu_container")
		var toggle_button = menu_container.get_node("HBoxContainer/dark_but")
		if saved_data["dark"]:
			toggle_button.button_pressed = true
		else:
			toggle_button.button_pressed = false

		# Load items
		for item in saved_data["items"]:
			var position = Vector2(item["position:x"], item["position:y"])
			tile_map.grid_position = position
			var scene = load("res://scenes/level_editor/objects/" + item["scene"] + ".tscn")
			tile_map.place_item(scene)

		# Load tiles
		for tile in saved_data["tiles"]:
			var layer_id = tile["layer"]
			var position = Vector2(tile["position:x"], tile["position:y"])
			var source_id = tile["source"]
			var atlas_coordinates = Vector2i(
				tile["atlas_coordinates:x"], tile["atlas_coordinates:y"]
			)
			tile_map.set_cell(layer_id, position, source_id, atlas_coordinates)
	file.close()


func _clear_existing_assets():
	# Clear placed items
	for coordinates in tile_map.placed_items.keys():
		var item = tile_map.placed_items[coordinates]
		item.queue_free()
	tile_map.placed_items.clear()
	tile_map.reserved_cells.clear()
	tile_map.clear()


func start_test(path):
	print("TEST RUN:::")
	var custom_level = load("res://scenes/custom_game.tscn")
	var custom_level_instance = custom_level.instantiate()
	var custom_level_node = custom_level_instance.get_node("Level")
	var load_tile_map = custom_level_instance.get_node("Level/TileMap")
	var lowest_point = Vector2i(0, 0)
	var highest_point = Vector2i(0, 0)
	var furthest_point_pos = Vector2i(0, 0)
	var furthest_point_neg = Vector2i(0, 0)
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
			var layer_id = tile["layer"]
			var position = Vector2(tile["position:x"], tile["position:y"])
			var source_id = tile["source"]
			var atlas_coordinates = Vector2i(
				tile["atlas_coordinates:x"], tile["atlas_coordinates:y"]
			)
			load_tile_map.set_cell(layer_id, position, source_id, atlas_coordinates)
			if position.y > lowest_point.y:
				lowest_point = position
			if position.y < highest_point.y:
				highest_point = position
			if position.x > furthest_point_pos.x:
				furthest_point_pos = position
			if position.x < furthest_point_neg.x:
				furthest_point_neg = position

		# load light physics
		if saved_data["dark"]:
			custom_level_node.dark_level = true
			var pointlight = load("res://scenes/level_editor/point_light_2d_custom.tscn")
			var new_pointlight = pointlight.instantiate()
			new_pointlight.name = "PointLight2D"
			var pos_x = furthest_point_neg.x + abs(furthest_point_neg.x - furthest_point_pos.x)
			var pos_y = lowest_point.y - abs(highest_point.y - lowest_point.y)
			new_pointlight.position = Vector2(pos_x, pos_y)
			var scale_x = abs(furthest_point_pos.x - furthest_point_neg.x) + 1000
			var scale_y = abs(highest_point.y - lowest_point.y) + 1000
			new_pointlight.scale = Vector2(scale_x, scale_y)
			custom_level_node.add_child(new_pointlight)

		# Load items
		for item in saved_data["items"]:
			var position = Vector2(item["position:x"], item["position:y"])
			if item["scene"] == "spawn_marker":
				var start_point = Marker2D.new()
				start_point.name = "StartPoint"
				start_point.position = position * 16 + (Vector2(0.5, 0.5) * 16)
				custom_level_node.add_child(start_point)
				print(start_point, " at: ", position)
				continue
			elif item["scene"] == "checkpoint":
				var scene = load("res://scenes/level_editor/objects/checkpoint_custom.tscn")
				custom_level_node.load_item(custom_level_instance, scene, position)
				continue
			var scene = load("res://scenes/items and objects/" + item["scene"] + ".tscn")
			custom_level_node.load_item(custom_level_instance, scene, position)

	place_death_zone(
		custom_level_node,
		custom_level_instance,
		lowest_point,
		furthest_point_neg,
		furthest_point_pos
	)
	Click.play()
	start_test_state(custom_level_instance)

	file.close()


func _on_fd_test_file_selected(path):
	start_test(path)


# Dynamically determines depth and width of level and places killzones accordingly
func place_death_zone(level, level_instance, lowest_point, furthest_point_neg, furthest_point_pos):
	var area2d_scene = load("res://scenes/killzone.tscn")
	if area2d_scene:
		#var area2d_instance = area2d_scene.instantiate()
		for x in range(furthest_point_neg.x - 30, furthest_point_pos.x + 30):
			var area2d_instance = level.load_item(
				level_instance, area2d_scene, Vector2(x, lowest_point.y + 20)
			)
	else:
		print("Failed to load the killzone.")


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


@rpc("authority", "unreliable", "call_local")
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
	var test_path = "res://custom_levels/test_file.json"
	save_test(test_path)
	start_test(test_path)
