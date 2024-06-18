class_name SaverLoader
extends Node

@onready var tile_map = $"../../World/TileMap"
@onready var fd_load = $"../../CanvasLayer/MarginContainer/HBoxContainer/FD_load"
@onready var fd_save = $"../../CanvasLayer/MarginContainer/HBoxContainer/FD_save"

func _ready():
	fd_save.current_dir = "/"

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
		var json_text = file.get_as_text()
		var saved_data = JSON.parse_string(json_text)
		for item in saved_data["items"]:
			var position = Vector2(item["position:x"], item["position:y"])
			tile_map.grid_position = position
			var scene = load("res://objects/" + item["scene"] + ".tscn")
			tile_map.place_item(scene)

		for tile in saved_data["tiles"]:
			var layer_id = -1
			var position = Vector2(tile["position:x"], tile["position:y"])
			var source_id = 0
			var atlas_coordinates = Vector2i(tile["atlas_coordinates:x"], tile["atlas_coordinates:y"])
			tile_map.set_cell(layer_id, position, source_id, atlas_coordinates)
	file.close()

func _on_save_but_pressed():
	fd_save.visible = true

func _on_load_but_pressed():
	fd_load.visible = true
