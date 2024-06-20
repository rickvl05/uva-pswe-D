extends TextureRect

@export var this_scene: PackedScene
@export var tile: bool = true
@export var tile_id = Vector2i(0, 2)

@onready var object_cursor = get_node("/root/main/Editor_Object")
@onready var cursor_sprite = object_cursor.get_node("Sprite2D")

func _ready():
	self.connect("gui_input", Callable(self, "_item_clicked"))

func _item_clicked(event):
	if event is InputEvent:
		if event.is_action_pressed("mb_left"):
			object_cursor.current_item = null
			object_cursor.current_rect = self
			print("thisrect:", object_cursor.current_rect)
			object_cursor.IsTile = true
			print(object_cursor.IsTile)
			cursor_sprite.texture = texture
			GlobalLevelEditor.current_tile = tile_id
