extends Node2D

var dragging: bool = false
var drag_start_position: Vector2
var camera_start_position: Vector2

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				dragging = true
				drag_start_position = get_global_mouse_position()
				camera_start_position = position
			else:
				dragging = false

	if event is InputEventMouseMotion and dragging:
		var mouse_position = get_global_mouse_position()
		var drag_offset = drag_start_position - mouse_position
		set_position(camera_start_position + drag_offset)
