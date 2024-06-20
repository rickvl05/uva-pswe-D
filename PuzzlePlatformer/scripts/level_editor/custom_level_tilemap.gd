extends TileMap
var cell_size = Vector2(16, 16)

func load_item(parent_node, item_scene, grid_position):
	print("item scene trying to place: ", item_scene)
	var new_item = item_scene.instantiate()
	add_child(new_item)
	new_item.global_position = grid_position * cell_size

