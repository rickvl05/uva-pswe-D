extends Node

@rpc("call_local", "any_peer", "reliable")
func print_once_per_client(message: String):
	print(message)


func broadcast_message(message: String):
	print_once_per_client.rpc(message)


func broadcast_default_message():
	const message: String = "I will be printed to the console once per each connected client."

	broadcast_message(message)
