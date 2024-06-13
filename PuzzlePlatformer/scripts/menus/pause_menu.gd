extends CanvasLayer


var paused : bool = false


func _enter_tree():
	self.hide()


func _process(delta):
	if Input.is_action_pressed("pause"):
		pause_game()


func pause_game():
	if !get_tree().root.has_node("Game"):
		return

	var game_scene = get_tree().root.get_node("Game")
	# Do nothing if already paused
	if game_scene.paused:
		return

	game_scene.paused = true

	# Show the menu
	self.show()
	$Resume.grab_focus()


func unpause_game():
	get_tree().root.get_node("Game").paused = false
	self.hide()
