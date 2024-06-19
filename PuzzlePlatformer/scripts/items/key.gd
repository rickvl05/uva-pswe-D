extends Item

# Called when the node enters the scene tree for the first time.
func _ready():
	setup() # Does pickup logic. Do not remove.

# Called when item has been picked up by a player.
func been_picked_up():
	pass

# Called when item has been thrown away by a player.
func been_thrown_away():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
