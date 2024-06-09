extends TileMap

@onready var marker = $ColorRect
@onready var camera: Node2D = get_node("/root/main/cam_container/Camera2D")
@onready var editor_object = get_node("/root/main/Editor_Object")

var cell_size = Vector2i(16, 16)  # Update to match your tile size
var grid_position = Vector2i(0, 0)

func _ready():
	update_marker_position()
	update_camera_position()

func _input(event):
	if Global.playing and (event is InputEventKey):
		if event.is_pressed():
			var moved = false
			if event.keycode == KEY_UP:
				grid_position.y -= 1
				moved = true
			elif event.keycode == KEY_DOWN:
				grid_position.y += 1
				moved = true
			elif event.keycode == KEY_LEFT:
				grid_position.x -= 1
				moved = true
			elif event.keycode == KEY_RIGHT:
				grid_position.x += 1
				moved = true

			if moved:
				update_marker_position()
				update_camera_position()

		if Input.is_action_just_pressed("place"):
			var item_scene = editor_object.current_item
			print("placed: ", item_scene)
			if item_scene:
				var new_item = item_scene.instantiate() as Node2D
				add_child(new_item)
				new_item.global_position = grid_position * cell_size
				set_cell(0, grid_position, Global.current_tile)

func update_marker_position():
	marker.position = grid_position * cell_size

func update_camera_position():
	camera.position = grid_position * cell_size + cell_size / 2  # Center the camera on the current cell

