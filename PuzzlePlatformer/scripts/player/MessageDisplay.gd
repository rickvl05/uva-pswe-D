extends Label


func display_message(msg: String, duration=5.0):
	$DisplayTimer.stop()
	text = msg
	$DisplayTimer.wait_time = duration
	$DisplayTimer.start()


func _on_display_timer_timeout():
	text = ""
