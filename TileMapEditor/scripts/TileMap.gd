extends TileMap

# Tile ID you want to draw, change this to match your tileset
const TILE_ID = 3

# Starting position on the grid
var grid_position = Vector2i(0, 0)
@onready var marker = $ColorRect  # Reference to the ColorRect node
@onready var camera = $Camera2D   # Reference to the Camera2D node

func _ready():
	# Set the initial position of the marker
	update_marker_position()
	# Ensure the camera starts in the correct position
	update_camera_position()

func _input(event):
	if event is InputEventKey:
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
				set_cell(0, grid_position, TILE_ID, Vector2i(0, 0))

func update_marker_position():
	var cell_size = Vector2i(16, 16)  # Update to match your tile size
	marker.position = grid_position * cell_size

func update_camera_position():
	var cell_size = Vector2i(16, 16)  # Update to match your tile size
	camera.position = grid_position * cell_size + cell_size / 2  # Center the camera on the current cell

