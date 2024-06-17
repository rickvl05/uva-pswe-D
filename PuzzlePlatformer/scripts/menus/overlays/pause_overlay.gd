extends CanvasLayer


func show_pause_overlay():
	"""Shows the menu and grabs focus on the resume button."""
	self.show()
	$Resume.grab_focus()


func hide_pause_overlay():
	"""Hides the pause menu. Identical to calling .hide()"""
	self.hide()


func _on_quit_game_pressed():
	"""Quits the game"""
	Click.play()
	await Click.finished
	get_tree().quit()


func _on_quit_menu_pressed():
	"""Takes the player back to the main menu. As of yet, the host is not
	allowed to leave"""

	# Server cannot leave
	if multiplayer.is_server():
		return

	MultiplayerManager.leave_game()
	var main_menu = load("res://scenes/menus/main_menu.tscn").instantiate()
	get_tree().root.add_child(main_menu)
	get_tree().root.get_node("Game").queue_free()
	self.queue_free()
