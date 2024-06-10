extends Camera2D

@export var darkmode = false
@onready var dark_camera = $DarkMode


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if darkmode:
		dark_camera.visible = true
	else:
		dark_camera.visible = false
