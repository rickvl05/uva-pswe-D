extends TileMap

@onready var marker = $ColorRect
@onready var camera: Node2D = get_node("/root/main/cam_container/Camera2D")
@onready var editor_object = get_node("/root/main/Editor_Object")

var cell_size = Vector2(16, 16)  # Update to match your tile size
var grid_position = Vector2(0, 0)
var grid_size: Vector2 = Vector2.ZERO  # Define the size of your grid in cells, will be calculated dynamically
var placed_items = {}

func _ready():
	update_grid_size()
	update_marker_position()
	update_camera_position()

func _input(event):
	if Global.playing and (event is InputEventKey):
		if event.is_pressed():
			var moved = false
			if event.keycode == KEY_UP and grid_position.y > 0:
				grid_position.y -= 1
				moved = true
			elif event.keycode == KEY_DOWN and grid_position.y < grid_size.y - 1:
				grid_position.y += 1
				moved = true
			elif event.keycode == KEY_LEFT and grid_position.x > 0:
				grid_position.x -= 1
				moved = true
			elif event.keycode == KEY_RIGHT and grid_position.x < grid_size.x - 1:
				grid_position.x += 1
				moved = true

			if moved:
				update_marker_position()

		if Input.is_action_just_pressed("place"):
			var item_scene = editor_object.current_item
			place_item(item_scene)

func place_item(item_scene):
	print("placed: ", item_scene, "at: ", grid_position)
	if item_scene and not is_item_already_placed(grid_position):
		var new_item = item_scene.instantiate()
		add_child(new_item)
		new_item.global_position = grid_position * cell_size
		set_cell(0, grid_position, Global.current_tile)
		placed_items[grid_position] = new_item


func is_item_already_placed(position: Vector2) -> bool:
	return placed_items.has(position)

func update_grid_size():
	grid_size = Vector2(floor(get_viewport_rect().size.x / cell_size.x),
						floor(get_viewport_rect().size.y / cell_size.y))

func update_marker_position():
	marker.position = grid_position * cell_size

func update_camera_position():
	# Center the camera on the middle of the grid
	camera.position = (grid_position * cell_size) + (grid_size * cell_size) / 2
