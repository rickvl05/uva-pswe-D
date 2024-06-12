extends CanvasLayer


func _enter_tree():
	self.hide()


func _process(delta):
	if Input.is_action_pressed("pause"):
		pause_game()


func pause_game():
	# Do nothing if already paused, or game has not started
	if get_tree().paused or !get_tree().root.has_node("Game"):
		return

	get_tree().paused = true

	# Show the menu
	self.show()
	$Resume.grab_focus()


func unpause_game():
	get_tree().paused = false
	self.hide()
