extends LineEdit


func _on_ready():
	#hide()
	pass

func _on_focus_exited():
	#hide()
	pass


func _input(event):
	if event.is_action_pressed("type_message"):
		#show()
		#grab_focus.call_deferred()
		#grab_focus()
		grab_click_focus()


# Print the given message to Godot's logger.
@rpc("call_local", "any_peer", "reliable")
func print_message(message: String):
	print(message)


# Broadcast the given message to all players.
func broadcast_message(message: String):
	print_message.rpc(message)


# Broadcast text from message editor to all players.
func _on_message_editor_text_submitted(new_text):
	broadcast_message(new_text)
	clear()


# Broadcast the default message to all players.
func broadcast_default_message():
	const message: String = "Hello, world!"

	broadcast_message(message)



