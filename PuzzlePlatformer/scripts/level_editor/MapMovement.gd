extends TileMap

@onready var marker = $ColorRect
@onready var camera: Node2D = get_node("/root/main/cam_container")
@onready var editor_object = get_node("/root/main/Editor_Object")

var cell_size = Vector2(16, 16)  # Update to match your tile size
var grid_position = Vector2(0, 0)
var grid_size: Vector2 = Vector2.ZERO  # will be calculated dynamically
var placed_items = {}
var reserved_cells: Dictionary = {}
var limited_items = {
	"spawn_marker": {"count": 0, "limit": 1},
	"key": {"count": 0, "limit": 1},
	"leveldoor": {"count": 0, "limit": 1}
}


func _ready():
	update_grid_size()
	update_marker_position()
	update_camera_position()

func _on_viewport_resized():
	update_grid_size()
	update_marker_position()
	update_camera_position()
	
func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseMotion:
	# Update the marker position based on the mouse position
		marker.position = get_local_mouse_position()

func _input(event):
	if GlobalLevelEditor.playing:
		if event is InputEventMouseMotion:
			handle_mouse_motion(event)
		elif event is InputEventMouseButton:
			handle_mouse_button(event)

func handle_mouse_motion(event):
	#grid_position = snap_to_grid(event.position / cell_size)
	grid_position = snap_to_grid(get_global_mouse_position() / cell_size)
	update_marker_position()

func handle_mouse_button(event):
	if Input.is_action_just_pressed("mb_left"):
		if editor_object.toggle_eraser:
			delete_obj()
		else:
			place_item(editor_object.current_item)

func place_item(item_scene):
	if item_scene:
		var new_item = item_scene.instantiate()
		# for item
		if !is_item_already_placed(grid_position):
			if new_item.IsTile == false:
				if !check_if_reserved(grid_position, new_item.dimensions):
					if get_cell_source_id(1, grid_position) == -1:
						add_child(new_item)
						new_item.global_position = grid_position * cell_size
						# Add the item to placed items and reserve cells
						placed_items[grid_position] = new_item
						assign_reserved_cells(new_item)
						print(placed_items[grid_position])
						print("placed: ", item_scene, "at: ", grid_position)
						print(reserved_cells)
					else:
						print("cell already occupied by tile")
				else:
					new_item.queue_free()
			# for tile
			elif new_item.IsTile == true and new_item.layer == 1:
				if !reserved_cells.has(grid_position):
					print(item_scene)
					new_item.global_position = grid_position * cell_size
					set_cell(1, grid_position, 0, editor_object.current_tile_id, 0)
					new_item.queue_free()
		elif new_item.IsTile and new_item.layer == 0:
			place_background_tile()
		else:
			new_item.queue_free()
			print("cell already occupied by item")

func place_background_tile():
	if get_cell_source_id(0, grid_position):
		set_cell(0, grid_position, 3, editor_object.current_tile_id, 0)
		print("Background tile placed at:", grid_position)
	else:
		print("Background cell already occupied")


func is_item_already_placed(position: Vector2) -> bool:
	return placed_items.has(position)

func update_grid_size():
	grid_size = Vector2(floor(get_viewport_rect().size.x / cell_size.x),
						floor(get_viewport_rect().size.y / cell_size.y))

func update_marker_position():
	marker.position = grid_position * cell_size

func update_camera_position():
	# Center the camera on the middle of the grid
	camera.set_position((grid_size * cell_size) / 2)
	#camera.set_position(Vector2i(600,333))
	#camera.position = grid_position
	#print("grid pos and cell size:", grid_position, cell_size)
	#print("cam pos:", camera.position)

func snap_to_grid(position: Vector2) -> Vector2:
	return Vector2(floor(position.x), floor(position.y))

func delete_obj():
	if is_item_already_placed(grid_position):
		var removed_item = placed_items[grid_position]
		unreserve_cells(removed_item, grid_position)
		remove_child(removed_item)
		placed_items.erase(grid_position)
		removed_item.queue_free()
	else:
		#set_cell(0, grid_position, -1, Vector2i(-1,-1))
		print(get_cell_source_id(1, grid_position))
		if get_cell_source_id(1, grid_position) == 0:
			erase_cell(1, grid_position)
		else:
			erase_cell(0, grid_position)
		print("tile deleted")
	
func clear_items():
	for child in get_children():
		remove_child(child)
		child.queue_free()

func generate_top_right_cell(pos, dimensions):
	var dim_modified = dimensions - Vector2i(1, 1)
	var top_right: Vector2i
	top_right.x = pos.x + dim_modified.x
	top_right.y = pos.y - dim_modified.y
	return top_right

func unreserve_cells(item, item_position):
	var top_right = generate_top_right_cell(item_position, item.dimensions)
	for y in range(item_position.y, top_right.y-1, -1):
		for x in range(item_position.x, top_right.x+1):
			if reserved_cells.has(Vector2(x,y)):
				reserved_cells.erase(Vector2(x,y))

func check_if_reserved(item_grid_position, dimensions):
	var top_right = generate_top_right_cell(item_grid_position, dimensions)
	for y in range(item_grid_position.y, top_right.y-1, -1):
		for x in range(item_grid_position.x, top_right.x+1):
			if reserved_cells.has(Vector2(x,y)) or get_cell_tile_data(1, Vector2(x,y)):
				print("cell indirectly occupied")
				return true
	return false

func assign_reserved_cells(item):
	var item_grid_position = Vector2i(item.global_position / cell_size)
	var top_right = generate_top_right_cell(item_grid_position, item.dimensions)
	for y in range(item_grid_position.y, top_right.y-1, -1):
		for x in range(item_grid_position.x, top_right.x+1):
			print("reserved: ", Vector2(x,y))
			reserved_cells[Vector2(x,y)] = item_grid_position
	pass

func check_limited_items(grid_position, item) -> bool:
	var item_name = item.name  # Adjust based on how you identify items
	
	if item_name in limited_items:
		var item_info = limited_items[item_name]
		if item_info["count"] >= item_info["limit"]:
			print("Cannot place more ", item_name)
			return true
	return false

