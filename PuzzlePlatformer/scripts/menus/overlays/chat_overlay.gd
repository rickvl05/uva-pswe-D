extends CanvasLayer


func show_chat_overlay():
	"""Opens the chat overlay and grabs focus on the input line"""
	self.show()
	$ChatInput.grab_focus()


func hide_chat_overlay(clear=true):
	"""Closes the chat overlay. Clears the input line if clear=true"""
	if clear:
		$ChatInput.clear()
	self.hide()


func broadcast_message(close_after_send=true):
	"""Broadcasts the text in the ChatInput. Does not send anything if
	ChatInput is empty. If close_after_send=true, chat overlay is closed
	after broadcasting"""
	if $ChatInput.text:
		MultiplayerManager.send_message.rpc($ChatInput.text)
	if close_after_send:
		hide_chat_overlay()
