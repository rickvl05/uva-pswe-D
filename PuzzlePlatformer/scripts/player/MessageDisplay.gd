extends Label


func _enter_tree():
	hide()


func display_message(msg: String, duration=5.0):
	text = msg
	show()

	if "taco" in msg.to_lower():
		get_parent().get_node("Taco").show()

	$DisplayTimer.wait_time = duration
	$DisplayTimer.start()


func _on_display_timer_timeout():
	text = ""
	hide()
	get_parent().get_node("Taco").hide()
