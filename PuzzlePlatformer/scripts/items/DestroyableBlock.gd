extends StaticBody2D

"""
Makes sure that the block is destroyed across all peers.
"""
func kill():
	if multiplayer.is_server():
		remove_block.rpc()


@rpc("authority", "reliable", "call_local")
func remove_block():
	queue_free()
