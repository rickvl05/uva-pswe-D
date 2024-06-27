extends MarginContainer

@onready var object_cursor
@export var toggle_dark: bool = false

func _ready():
	object_cursor = get_node("/root/main/Editor_Object")
	self.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	self.connect("mouse_exited", Callable(self, "_on_mouse_exited"))

	# Set mouse filter for this TabContainer and its children
	propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_PASS])

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
	get_node("/root/main").queue_free()
	var main_menu = load("res://scenes/menus/main_menu.tscn").instantiate()
	get_tree().root.add_child(main_menu)

func _on_dark_but_toggled(toggled_on):
	toggle_dark = !toggle_dark
	print(toggle_dark)
