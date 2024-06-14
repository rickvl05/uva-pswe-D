extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


func _process(delta):
	if Input.is_action_just_pressed("open_chat"):
		if get_tree().root.get_node("Game").chatting:
			_on_submit()
		else:
			open_chat()


func open_chat():
	print("Opening Chat")
	if !get_tree().root.has_node("Game"):
		return

	var game_scene = get_tree().root.get_node("Game")
	if game_scene.paused:
		return

	self.show()
	$ChatInput.show()
	$SendButton.show()
	$ChatInput.grab_focus()
	game_scene.chatting = true


func close_chat():
	print("Closing Chat")
	$ChatInput.clear()
	self.hide()

	get_tree().root.get_node("Game").chatting = false


func _on_submit():
	if $ChatInput.text:
		MultiplayerManager.send_message.rpc($ChatInput.text)
	close_chat()
