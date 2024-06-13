extends TextureRect

@export var this_scene: PackedScene
@export var tile: bool = false
@export var tile_id = 0

@onready var object_cursor = get_node("/root/main/Editor_Object")
@onready var cursor_sprite = object_cursor.get_node("Sprite")

func _ready():
	self.connect("gui_input", Callable(self, "_item_clicked"))

func _item_clicked(event):
	if event is InputEvent:
		if not tile:
			if event.is_action_pressed("mb_left"):
				object_cursor.current_rect = null
				object_cursor.current_item = this_scene
				#cursor_sprite.texture = texture
				Global.place_tile = false
		else:
			if event.is_action_pressed("mb_left"):
				Global.place_tile = true
				Global.current_tile = tile_id
