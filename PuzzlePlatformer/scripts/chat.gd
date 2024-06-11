extends LineEdit

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
