extends TextureRect

@export var this_scene: PackedScene
@export var tile: bool = true
@export var tile_id = Vector2i(1,4)

func _ready():
	self.connect("gui_input", Callable(self, "_item_clicked"))

func _item_clicked(event):
	if event is InputEvent:
		if not tile:
			if event.is_action_pressed("mb_left"):
				Global.place_tile = false
		else:
			if event.is_action_pressed("mb_left"):
				Global.place_tile = true
				Global.current_tile = tile_id
