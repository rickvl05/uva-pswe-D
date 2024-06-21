extends Camera2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var view_size = get_viewport_rect().size
	zoom = view_size / Vector2(280, 170)
