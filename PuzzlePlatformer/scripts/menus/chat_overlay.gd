extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if Input.is_action_pressed("open_chat"):
		open_chat()


func open_chat():
	if !get_tree().root.has_node("Game"):
		return

	var game_scene = get_tree().root.get_node("Game")
	if game_scene.paused:
		return

	self.show()
	$ChatInput.grab_focus()
	game_scene.paused = true
	game_scene.chatting = true


func close_chat():
	self.hide()
	$ChatInput.clear()
	get_tree().root.get_node("Game").chatting = false
