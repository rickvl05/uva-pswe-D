extends Node2D
var cell_size = Vector2(16, 16)
var offset = Vector2(0.5, 0.5) # because of centered objects.

func load_item(parent_node, item_scene, grid_position):
	print("grid_pos item:", grid_position)
	var new_item = item_scene.instantiate()
	print("item scene trying to place: ", new_item.name)
	add_child(new_item)
	new_item.global_position = grid_position * cell_size + (offset * cell_size)
