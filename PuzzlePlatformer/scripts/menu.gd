extends CanvasLayer

@export var GameScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_host_pressed():
	var new_game = load("res://scenes/game.tscn").instantiate()
	get_tree().root.add_child(new_game)
	MultiplayerManager.host_game()
	get_tree().root.get_node("Menu").queue_free()


func _on_join_pressed():
	var new_game = load("res://scenes/game.tscn").instantiate()
	get_tree().root.add_child(new_game)
	MultiplayerManager.join_game()
	get_tree().root.get_node("Menu").queue_free()
