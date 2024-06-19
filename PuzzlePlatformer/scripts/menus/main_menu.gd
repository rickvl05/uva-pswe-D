extends Control

const menu_music = preload("res://audio/MainMenu.mp3")

func _ready():
	GlobalAudioPlayer.play_music(menu_music)


func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		$Connect/IPAddress.grab_focus()


func _on_host_pressed():
	GlobalAudioPlayer.stop()
	Click.play()
	MultiplayerManager.host_game()
	get_tree().root.get_node("MainMenu").queue_free()


func _on_join_pressed():
	GlobalAudioPlayer.stop()
	Click.play()
	var ip = $Connect/IPAddress.text

	# If no IP was supplied, use localhost
	if ip == "":
		ip = "127.0.0.1"

	# Check IP validity
	if not ip.is_valid_ip_address():
		$Connect/ErrorLabel.text = "Invalid IP address!"
		return

	# Check is IP is host and listening
	var error = MultiplayerManager.join_game(ip)
	if error != OK:
		get_tree().root.get_node("Game").queue_free()
		$Connect/ErrorLabel.text = "No host at this IP!"
		return

	get_tree().root.get_node("MainMenu").queue_free()


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
	_on_join_pressed()
