extends Control

enum States {
	NO_OVERLAY,
	PAUSE_OVERLAY,
	CHAT_OVERLAY
}


var GameScene = null
var state = States.NO_OVERLAY


func _ready():
	$PauseOverlay/Reset.disabled = true
	if !multiplayer.is_server():
		$PauseOverlay/Reset.hide()
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


func external_close_pause_menu():
	"""Function that is called when another node needs to close the pause menu.
	This keeps the state and GameScene.paused updated.
	"""
	if state != States.PAUSE_OVERLAY:
		return

	$PauseOverlay.hide_pause_overlay()
	state = States.NO_OVERLAY
	GameScene.paused = false


func toggle_reset_button(new_disabled: bool):
	"""Toggles the 'disabled' of the reset button. Should be enabled during game
	levels, disabled elsewhere. Only sets 'disabled' on the server, as clients
	can't reset.
	"""

	if !multiplayer.is_server():
		return

	$PauseOverlay/Reset.disabled = new_disabled
