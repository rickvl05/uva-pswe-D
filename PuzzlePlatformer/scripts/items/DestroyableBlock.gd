extends StaticBody2D


func kill():
	if multiplayer.is_server():
		remove_block.rpc()


@rpc("authority", "reliable", "call_local")
func remove_block():
	queue_free()
