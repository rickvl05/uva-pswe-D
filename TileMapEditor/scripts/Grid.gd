extends Node2D

var grid_size = 16  # Align with your tile size
var grid_color = Color(1, 1, 1, 0.2)  # White color with some transparency

func _ready():
	# Request a redraw
	queue_redraw()
	# Connect the viewport's size_changed signal
	self.connect("size_changed", Callable(self, "_on_size_changed"))

func _process(delta):
	pass

func _draw():
	var view_size = get_viewport_rect().size
	
	# Draw vertical lines
	for x in range(0, view_size.x, grid_size):
		draw_line(Vector2(x, 0), Vector2(x, view_size.y), grid_color)
	
	# Draw horizontal lines
	for y in range(0, view_size.y, grid_size):
		draw_line(Vector2(0, y), Vector2(view_size.x, y), grid_color)

func _on_size_changed():
	# Request a redraw when the viewport size changes
	queue_redraw()

# Helper function to snap a position to the grid
func snap_to_grid(position: Vector2) -> Vector2:
	return Vector2(floor(position.x / grid_size) * grid_size, floor(position.y / grid_size) * grid_size)
