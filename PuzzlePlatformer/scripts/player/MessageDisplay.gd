extends Label


func _enter_tree():
	hide()


func display_message(msg: String, duration=5.0):
	# Possibly show the easter eggs
	_hide_tacos()
	_show_tacos(msg)

	# Update the message and show the 'speech bubble'
	text = msg
	show()

	# Start the timer
	$DisplayTimer.start(duration)


func _on_display_timer_timeout():
	# Remove easter eggs and hide text
	text = ""
	hide()
	_hide_tacos()


func _show_tacos(msg: String):
	# Show the correct easter egg
	var lower = msg.to_lower()
	if "taco" in lower:
		get_parent().get_node("Taco").show()
	elif "telegram" in lower:
		get_parent().get_node("Taco2").show()
	elif "json" in lower:
		get_parent().get_node("Taco3").show()


func _hide_tacos():
	# Hide all the easter eggs
	for taco in get_parent().find_children("Taco*"):
		taco.hide()
