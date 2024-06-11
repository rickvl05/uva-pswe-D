extends CanvasLayer

@export var GameScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_host_pressed():
	MultiplayerManager.host_game()



func _on_join_pressed():
	MultiplayerManager.join_game()
