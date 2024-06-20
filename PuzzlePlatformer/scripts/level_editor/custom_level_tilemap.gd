extends TileMap
var cell_size = Vector2(16, 16)

func load_item(parent_node, item_scene, grid_position):
	print("trying to place ", item_scene, "at ", grid_position)
	var new_item = item_scene.instantiate()
	print(name)
	print(self)
	add_child(new_item)
	#print_tree_pretty()
	new_item.global_position = grid_position * cell_size

