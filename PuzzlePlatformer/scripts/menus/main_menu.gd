extends Control

func _ready():
	GlobalAudioPlayer.play_music("menu")
	MultiplayerManager.set_accept_new_connections(true)


func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		$Connect/IPAddress.grab_focus()


func _on_host_pressed():
	Click.play()
	if MultiplayerManager.host_game():
		$Connect/ErrorLabel.text = "Cannot host on this device"
	else:
		get_tree().root.get_node("MainMenu").queue_free()


func _on_join_pressed():
	Click.play()
	var ip = $Connect/IPAddress.text

	# If no IP was supplied, use localhost
	if ip == "":
		ip = "127.0.0.1"

	# Check IP validity
	if not ip.is_valid_ip_address():
		$Connect/ErrorLabel.text = "Invalid IP address!"
		return

	# Check if connection can be made
	if MultiplayerManager.join_game(ip):
		$Connect/ErrorLabel.text = "Can't start connection"
		return

	for button in get_tree().get_nodes_in_group("Buttons"):
		button.disabled = true


func _on_quit_pressed():
	Click.play()
	await Click.finished
	get_tree().quit()


func _on_settings_pressed():
	Click.play()
	get_tree().change_scene_to_file("res://scenes/menus/settings.tscn")


func _on_level_editor_pressed():
	Click.play()
	get_tree().change_scene_to_file("res://scenes/menus/level_editor.tscn")


func _on_ip_address_text_submitted(_new_text):
	if !$Connect/Join.disabled:
		_on_join_pressed()


func join_failed():
	$Connect/ErrorLabel.text = "Cannot connect to host at this IP"
	for button in get_tree().get_nodes_in_group("Buttons"):
		button.disabled = false
