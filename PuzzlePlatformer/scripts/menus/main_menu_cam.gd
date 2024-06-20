extends Camera2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var window_width = get_viewport_rect().size.x
	var target_zoom = window_width / 1152
	zoom = Vector2(target_zoom, target_zoom)
