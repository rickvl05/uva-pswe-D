extends Control

func _ready():
	# Called every time the node is added to the scene.
	pass

func _input(event):
	if event.is_action_pressed("focus_on_input"):
		$Connect/IPAddress.grab_focus()

func load_lobby():
	var lobby = load("res://scenes/lobby.tscn").instantiate()
	get_tree().get_root().add_child(lobby)
	get_tree().get_root().get_node("MainMenu").queue_free()
	
	MultiplayerManager.set("players_node", get_tree().get_root().get_node("Lobby").get_node("Players"))

func _on_host_pressed():
	Click.play()
	load_lobby()
	MultiplayerManager.host_game()


func _on_join_pressed():
	Click.play()
	var ip = $Connect/IPAddress.text
	if not ip.is_valid_ip_address():
		$Connect/ErrorLabel.text = "Invalid IP address!"
		return
		
	load_lobby()
	MultiplayerManager.join_game(ip)


func _on_quit_pressed():
	Click.play()
	await Click.finished
	get_tree().quit()


func _on_settings_pressed():
	Click.play()
	get_tree().change_scene_to_file("res://scenes/settings.tscn")


func _on_level_editor_pressed():
	Click.play()
	get_tree().change_scene_to_file("res://scenes/level_editor.tscn")


