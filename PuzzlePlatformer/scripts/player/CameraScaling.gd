extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().size_changed.connect(recalculate_scale)
	recalculate_scale()


func recalculate_scale():
	var window_width = get_viewport_rect().size.x
	var target_zoom = window_width / 288
	zoom = Vector2(target_zoom, target_zoom)
