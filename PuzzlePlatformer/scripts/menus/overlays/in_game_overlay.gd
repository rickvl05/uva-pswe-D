extends Control

enum States {
	NO_OVERLAY,
	PAUSE_OVERLAY,
	CHAT_OVERLAY
}

var GameScene = null
var state = States.NO_OVERLAY


func _ready():
	$ChatOverlay.hide()
	$PauseOverlay.hide()
	GameScene = get_parent()


func _input(event):

	if state == States.NO_OVERLAY:

		if event.is_action_pressed("pause"):
			$PauseOverlay.show_pause_overlay()
			state = States.PAUSE_OVERLAY
			GameScene.paused = true
			accept_event()

		elif event.is_action_pressed("open_chat"):
			$ChatOverlay.show_chat_overlay()
			state = States.CHAT_OVERLAY
			GameScene.paused = true
			accept_event()

	elif state == States.PAUSE_OVERLAY:

		if event.is_action_pressed("pause"):
			$PauseOverlay.hide_pause_overlay()
			state = States.NO_OVERLAY
			GameScene.paused = false
			accept_event()

	elif state == States.CHAT_OVERLAY:
		
		if event.is_action_pressed("open_chat"):
			if Input.is_key_pressed(KEY_T):
				# Ignore the "t" input for open chat when typing
				return
			$ChatOverlay.broadcast_message()
			state = States.NO_OVERLAY
			GameScene.paused = false
			accept_event()

		elif event.is_action_pressed("pause"):
			$ChatOverlay.hide_chat_overlay()
			state = States.NO_OVERLAY
			GameScene.paused = false
			accept_event()


func _external_close_pause_menu():
	"""Function that is called when the resume button in the pause overlay
	is pressed. This keeps the state and GameScene.paused updated."""

	assert(state == States.PAUSE_OVERLAY, "Resume button pressed while not in pause menu")

	$PauseOverlay.hide_pause_overlay()
	state = States.NO_OVERLAY
	GameScene.paused = false
