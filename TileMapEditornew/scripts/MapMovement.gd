extends TileMap

@onready var marker = $ColorRect
@onready var camera: Node2D = get_node("/root/main/cam_container/Camera2D")
@onready var editor_object = get_node("/root/main/Editor_Object")

var cell_size = Vector2(16, 16)  # Update to match your tile size
var grid_position = Vector2(0, 0)
var grid_size: Vector2 = Vector2.ZERO  # will be calculated dynamically
var placed_items = {}
var using_mouse_input = false

func _ready():
	update_grid_size()
	update_marker_position()
	update_camera_position()
	get_tree().connect("input_event", Callable(self, "_on_input_event"))
	get_tree().get_root().connect("size_changed", Callable(self, "_on_viewport_resized"))
	#editor_object.connect("move_editor_finished", Callable(self, "update_marker_position"))

func _on_viewport_resized():
	update_grid_size()
	update_marker_position()
	update_camera_position()
	
func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseMotion:
	# Update the marker position based on the mouse position
		marker.position = get_local_mouse_position()

func _input(event):
	if Global.playing:
		if event is InputEventKey:
			if event.is_action_pressed("place"):
				delete_obj()
				print("item deleted")
			
		elif event is InputEventMouseMotion:
			using_mouse_input = true
			handle_mouse_motion(event)
		elif event is InputEventMouseButton:
			handle_mouse_button(event)

func handle_mouse_motion(event):
	if using_mouse_input:
		grid_position = snap_to_grid(event.position / cell_size)
		update_marker_position()

func handle_mouse_button(event):
	if Input.is_action_just_pressed("mb_left") or event.is_pressed():
		place_item(editor_object.current_item)
		using_mouse_input = true

func place_item(item_scene):
	if item_scene and not is_item_already_placed(grid_position):
		var new_item = item_scene.instantiate()
		add_child(new_item)
		
		# for item
		print("item ", editor_object.current_item)
		print("tile ", editor_object.current_rect)
		if editor_object.IsTile == false:
			if get_cell_source_id(0, grid_position) == -1:
				new_item.global_position = grid_position * cell_size
				placed_items[grid_position] = new_item
				print(placed_items[grid_position])
				print("placed: ", item_scene, "at: ", grid_position)
			else:
				print("cell already occupied")
		
		# for tile
		elif editor_object.IsTile == true:
			new_item.global_position = grid_position * cell_size
			set_cell(0, grid_position, 0, editor_object.current_tile_id, 0)
			print("placed tile at: ", grid_position)

func is_item_already_placed(position: Vector2) -> bool:
	return placed_items.has(position)

func update_grid_size():
	grid_size = Vector2(floor(get_viewport_rect().size.x / cell_size.x),
						floor(get_viewport_rect().size.y / cell_size.y))

func update_marker_position():
	marker.position = grid_position * cell_size

func update_camera_position():
	# Center the camera on the middle of the grid
	camera.position = (grid_size * cell_size) / 2
	print("grid pos and cell size:", grid_position, cell_size)
	print("cam pos:", camera.position)

func snap_to_grid(position: Vector2) -> Vector2:
	return Vector2(floor(position.x), floor(position.y))

func delete_obj():
	if is_item_already_placed(grid_position):
		var removed_item = placed_items[grid_position]
		remove_child(removed_item)
		placed_items[grid_position] = null
	else:
		set_cell(0, grid_position, 0, Vector2i(3,2))
		print("cell deleted")
