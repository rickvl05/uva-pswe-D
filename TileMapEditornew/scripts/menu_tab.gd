extends TabContainer

@onready var object_cursor

func _ready():
	object_cursor = get_node("/root/main/Editor_Object")
	self.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	self.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	print("menu_tab signals connected")

func _process(delta):
	if Input.is_action_just_pressed("toggle_editor"):
		toggle_playing_state()

func toggle_playing_state():
	Global.playing = !Global.playing
	#visible = !Global.playing

func _on_mouse_entered():
	toggle_playing_state()

	#object_cursor.can_place = false
	#print(object_cursor.can_place)
	object_cursor.hide()

func _on_mouse_exited():
	toggle_playing_state()

	# Additional logic if needed
	object_cursor.can_place = true
	object_cursor.show()
