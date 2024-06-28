class_name SaverLoader
extends Node
#@onready var tile_map = %TileMap 
@onready var tile_map = $"../../World/TileMap"


func _on_save_but_pressed():
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	var saved_data = {"items": []}
	
	for coordinates in tile_map.placed_items.keys():
		var item = {
			"position:x": coordinates.x,
			"position:y": coordinates.y,
			"type": tile_map.placed_items[coordinates]
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
		print(saved_data)
		if saved_data:
			#saved_data = saved_data.result
			print("Komt hij hier")
			tile_map.clear_items()
				
			for item in saved_data["items"]:
				var position = Vector2(floor(item["position:x"]), floor(item["position:y"]))
				var item_type = item["type"]
				tile_map.place_item(item)
				print("Dit is hier", item)
		else:
			print("Failed", saved_data.error_string)
		file.close()
	else:
		print("save file not found")
