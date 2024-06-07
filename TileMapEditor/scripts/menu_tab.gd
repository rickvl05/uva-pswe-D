extends TabContainer

@onready var object_cursor

func _ready():
	#object_cursor = get_node("/root/main/Editor_Object")
	#self.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	#self.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	#print("menu_tab signals connected")
	pass

func _process(delta):
	if Input.is_action_just_pressed("toggle_editor"):
		Global.playing = !Global.playing
		visible = !Global.playing
	pass

func _on_mouse_entered():
	object_cursor.can_place = false
	object_cursor.hide()


func _on_mouse_exited():
	object_cursor.can_place = true
	object_cursor.show()

