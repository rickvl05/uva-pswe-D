extends MarginContainer

@onready var object_cursor

func _ready():
	object_cursor = get_node("/root/main/Editor_Object")
	self.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	self.connect("mouse_exited", Callable(self, "_on_mouse_exited"))

	# Set mouse filter for this TabContainer and its children
	propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_PASS])

func _process(delta):
	if Input.is_action_just_pressed("toggle_editor"):
		toggle_playing_state()

func toggle_playing_state():
	GlobalLevelEditor.playing = !GlobalLevelEditor.playing


func _on_mouse_entered():
	toggle_playing_state()
	object_cursor.hide()

func _on_mouse_exited():
	toggle_playing_state()
	object_cursor.can_place = true
	object_cursor.show()
	

func _on_save_but_pressed():
	pass # Replace with function body.


func _on_load_but_pressed():
	pass # Replace with function body.


func _on_clear_but_pressed():
	pass # Replace with function body.

func _on_exit_but_pressed():
	Click.play()
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
