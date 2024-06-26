extends Control


@export var logo_animator: AnimationPlayer


func _ready():
	GlobalAudioPlayer.play_music("menu")
	logo_animator.play("move_in_logo")


func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		$Connect/IPAddress.grab_focus()
		accept_event()


func _on_host_pressed():
	Click.play()
	set_buttons_disabled(true)
	logo_animator.play("move_out_logo")
	await logo_animator.animation_finished
	
	if MultiplayerManager.host_game():
		display_error_message("Cannot host on this device")
		logo_animator.play("move_in_logo")
		set_buttons_disabled(false)
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
		display_error_message("Invalid IP address!")
		return

	set_buttons_disabled(true)
	logo_animator.play("move_out_logo")
	await logo_animator.animation_finished

	# Check if connection can be made
	if MultiplayerManager.join_game(ip):
		display_error_message("Can't start connection")
		set_buttons_disabled(false)
		logo_animator.play("move_in_logo")
		return


func _on_quit_pressed():
	Click.play()
	await Click.finished
	get_tree().quit()


func _on_settings_pressed():
	Click.play()
	get_node("/root/MainMenu").queue_free()
	var settings_menu = load("res://scenes/menus/settings.tscn").instatiate()
	get_tree().root.add_child(settings_menu)


func _on_level_editor_pressed():
	Click.play()
	get_node("/root/MainMenu").queue_free()
	var level_editor = load("res://scenes/level_editor/level_editor_main.tscn").instantiate()
	get_tree().root.add_child(level_editor)


func _on_ip_address_text_submitted(_new_text):
	if !$Connect/Join.disabled:
		_on_join_pressed()


func join_failed():
	display_error_message("Cannot connect to host at this IP")
	set_buttons_disabled(false)
	logo_animator.play("move_in_logo")


func set_buttons_disabled(new_disabled: bool):
	for button in get_tree().get_nodes_in_group("Buttons"):
		button.disabled = new_disabled


func display_error_message(msg: String, duration: float = 5.0):
	"""Displays the first 35 characters of 'msg' for 'duration' seconds
	in the ErrorLabel. If 'duration' == 0, the msg is permanent.
	"""
	if msg.length() > 35:
		msg = msg.left(35)
	$Connect/ErrorLabel.text = msg
	if duration > 0:
		$Connect/ErrorMessageTimer.start(duration)


func _on_error_message_timer_timeout():
	$Connect/ErrorLabel.text = ""
	#$Connect/ErrorMessageTimer.stop()


func _on_tutorial_pressed():
	Click.play()
	await Click.finished
	MultiplayerManager.host_game(1, true)
	get_tree().root.get_node("MainMenu").queue_free()
