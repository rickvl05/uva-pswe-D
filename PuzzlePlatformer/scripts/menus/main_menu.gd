extends Control


func _ready():
	pass


func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		$Connect/IPAddress.grab_focus()


func _on_host_pressed():
	Click.play()
	get_tree().change_scene_to_file("res://scenes/menus/pause_menu.tscn")
	MultiplayerManager.host_game()
	self.hide()


func _on_join_pressed():
	Click.play()
	var ip = $Connect/IPAddress.text
	if ip == "":
		ip = "127.0.0.1"
	if not ip.is_valid_ip_address():
		$Connect/ErrorLabel.text = "Invalid IP address!"
		return

	get_tree().change_scene_to_file("res://scenes/menus/pause_menu.tscn")
	MultiplayerManager.join_game(ip)
	self.hide()


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

