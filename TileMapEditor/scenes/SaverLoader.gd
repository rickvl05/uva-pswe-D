class_name SaverLoader
extends Node
#@onready var tile_map = %TileMap 
var door_position:Array[Vector2] = []
var king_position:Array[Vector2] = []
@onready var tile_map = $"../../World/TileMap"


func _on_save_but_pressed():
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	var saved_data = {"items": []}
	
	for coordinates in tile_map.placed_items.keys():
		var item = {
			"position": coordinates,
			"type": tile_map.placed_items[coordinates]
		}
		saved_data["items"].append(item)

	var json = JSON.stringify(saved_data)
	file.store_string(json)
	file.close()
	

func _on_load_but_pressed():
	var file = FileAccess.open("user://savegame.json", FileAccess.READ)
	var json = file.get_as_text()
	file.close()
	
	var saved_data = JSON.parse_string(json)
	if saved_data.error != OK:
		print("error parsing:", saved_data.error_string)
		return
		
	var items = saved_data.result["items"]
	if items == null:
		print("no items found")
		return
		
	tile_map.clear_items()
	for item in items:
		var position = Vector2(item["position"].x, item["position"].y) 
		var type = item["type"]
		var resource_path = "res://items/" + type + ".tscn"
		var item_scene = load(resource_path)
		
		if item_scene == null:
			print("failed")
			continue
			
		var item_instance = item_scene.instance()
		item_instance.position = position
		tile_map.add_child(item_instance)
		print("Loaded item of type", type, "at position", position)

