extends TextureRect

# Add a property to hold the current item
var current_item: PackedScene


# Declare an exported variable for the scene
@export var this_scene: PackedScene

# Use the onready keyword to initialize nodes once the scene is ready
@onready var object_cursor = get_node("/root/main/Editor_Object")
@onready var cursor_sprite = object_cursor.get_node("Sprite")

# Called when the node enters the scene tree for the first time
func _ready():
	connect("gui_input", Callable(self, "_item_clicked"))

# Function to handle item click events
func _item_clicked(event):
	if(event is InputEvent):
		# Check if the event is an action press event
		if event.is_action_pressed("mb_left"):
			object_cursor.current_item = this_scene
			cursor_sprite.texture = texture
