extends CanvasLayer


## Variable to store the button that the host pressed to open the confirmation
## panel. Can be either 'menu' or 'quit'
var _host_action: String


func show_pause_overlay():
	"""Shows the menu and grabs focus on the resume button."""
	self.show()
	$Resume.grab_focus()


func hide_pause_overlay():
	"""Hides the pause menu and the host confirm panel"""
	$HostConfirmPanel.hide()
	self.hide()


func _on_reset_pressed():
	# Reset the current game
	if multiplayer.is_server():
		var game = get_tree().root.get_node("Game")
		game.reset_level()
		game.paused = false


func _on_quit_game_pressed(host_confirmed=false):
	"""Quits the game.  Host is prompted with a notification that they're
	host"""

	# Host first goes through prompt
	if multiplayer.is_server() and !host_confirmed:
		_host_action = "quit"
		$HostConfirmPanel.show()
		$HostConfirmPanel/HostEscape.grab_focus()
		return

	Click.play()
	await Click.finished
	get_tree().quit()


func _on_quit_menu_pressed(host_confirmed=false):
	"""Takes the player back to the main menu. Host is prompted with a
	notification that they're host"""

	# Host first goes through prompt
	if multiplayer.is_server() and !host_confirmed:
		_host_action = "menu"
		$HostConfirmPanel.show()
		$HostConfirmPanel/HostEscape.grab_focus()
		return

	MultiplayerManager.leave_game()
	var main_menu = load("res://scenes/menus/main_menu.tscn").instantiate()
	get_tree().root.add_child(main_menu)
	get_tree().root.get_node("Game").queue_free()
	self.queue_free()


func _on_host_escape_pressed():
	$HostConfirmPanel.hide()
	$Resume.grab_focus()


func _on_host_confirm_pressed():
	# Should only be callable if _host_action was set
	assert(_host_action)

	if _host_action == "quit":
		_on_quit_game_pressed(true)
	elif _host_action == "menu":
		_on_quit_menu_pressed(true)
