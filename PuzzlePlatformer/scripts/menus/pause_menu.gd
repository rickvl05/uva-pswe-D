extends CanvasLayer


var paused : bool = false


func _enter_tree():
	self.hide()


func _process(delta):
	if get_tree().root.get_node("Game").chatting:
		return
	if Input.is_action_pressed("pause"):
		pause_game()


func pause_game():
	assert(get_tree().root.has_node("Game"))

	var game_scene = get_tree().root.get_node("Game")

	if game_scene.chatting:
		game_scene.get_node("ChatOverlay").close_chat()
	elif game_scene.paused:
		return
		

	game_scene.paused = true

	# Show the menu
	self.show()
	$Resume.grab_focus()


func unpause_game():
	get_tree().root.get_node("Game").paused = false
	self.hide()


func _on_quit_game_pressed():
	Click.play()
	await Click.finished
	get_tree().quit()


func _on_quit_menu_pressed():
	# Server cannot leave
	if multiplayer.is_server():
		return

	MultiplayerManager.leave_game()
	var main_menu = load("res://scenes/menus/main_menu.tscn").instantiate()
	get_tree().root.add_child(main_menu)
	get_tree().root.get_node("Game").queue_free()
	self.queue_free()
