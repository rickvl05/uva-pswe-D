class_name SaverLoader
extends Node
#@onready var tile_map = %TileMap 
@onready var tile_map = $"../../World/TileMap"
var packed_scenes = {
	"door": preload("res://objects/door.tscn"),
	"entity": preload("res://objects/entity.tscn"),
	#"TileGrass": preload("res://objects/tile_grass.tscn"),
	"king": preload("res://objects/king.tscn")
}

func _on_save_but_pressed():
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	var saved_data = {"items": []}
	for coordinates in tile_map.placed_items.keys():
		var item = {
			"position:x": coordinates.x,
			"position:y": coordinates.y,
			"scene": tile_map.placed_items[coordinates].scene_name
		}
		saved_data["items"].append(item)

	var json = JSON.stringify(saved_data)
	file.store_string(json)
	file.close()
	

func _on_load_but_pressed():
	var file = FileAccess.open("user://savegame.json", FileAccess.READ)
	if file.file_exists("user://savegame.json"):
		var json_text = file.get_as_text()
		var saved_data = JSON.parse_string(json_text)
		for item in saved_data["items"]:
			var position = Vector2(item["position:x"], item["position:y"])
			tile_map.grid_position = position

			var scene = load("res://objects/" + item["scene"] + ".tscn")
			tile_map.place_item(scene)
		file.close()
