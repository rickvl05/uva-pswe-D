extends Node


const DEFAULT_PORT = 7777
const DEFAULT_IP = "127.0.0.1"

var available_colors = [1, 2, 3, 4]

@export var GameScene : Node:
	set(node):
		GameScene = node

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_on_player_connect)
	multiplayer.peer_disconnected.connect(_on_player_disconnect)
	multiplayer.server_disconnected.connect(_on_server_disconnect)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func host_game():
	# Set host peer
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(DEFAULT_PORT, 4)
	multiplayer.set_multiplayer_peer(peer)

	if error != OK:
		print("Can't host")
		multiplayer.set_multiplayer_peer(null)
		return error

	# Create level instance
	var new_game = load("res://scenes/lobby.tscn").instantiate()
	get_tree().root.add_child(new_game)
	#get_tree().root.get_node("Menu").queue_free()

	_on_player_connect(multiplayer.get_unique_id())
	return error


func join_game(ip = DEFAULT_IP):
	# Set client peer
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, DEFAULT_PORT)
	multiplayer.set_multiplayer_peer(peer)

	if error != OK:
		print("Can't join")

	return error


func _on_connected_to_server():
	# Create level instance
		var new_game = load("res://scenes/lobby.tscn").instantiate()
		get_tree().root.add_child(new_game)
		get_node("/root/MainMenu").queue_free()


func _on_connection_failed():
	print("Connection failed")
	get_node("/root/MainMenu/CanvasLayer/MainMenu").join_failed()


func leave_game():
	multiplayer.multiplayer_peer.disconnect_peer(1)
	multiplayer.multiplayer_peer.close()
	multiplayer.set_multiplayer_peer(null)
	available_colors = [1, 2, 3, 4]


func _on_player_connect(id):
	if not multiplayer.is_server():
		return

	var new_player = load("res://scenes/player.tscn")
	new_player = new_player.instantiate()
	new_player.name = str(id)
	new_player.color = available_colors.pop_front()
	GameScene.get_node("Players").add_child(new_player)

	
	set_player_attributes.rpc(str(id), new_player.get_settable_attributes())


func _on_player_disconnect(id):
	var player = GameScene.get_node("Players").get_node(str(id))
	available_colors.append(player.color)
	player.queue_free()


func _on_server_disconnect():
	multiplayer.multiplayer_peer.close()
	multiplayer.set_multiplayer_peer(null)
	var main_menu = load("res://scenes/menus/main_menu.tscn").instantiate()
	main_menu.get_node("Connect/ErrorLabel").text = "Host left!"
	get_tree().root.add_child(main_menu)
	get_tree().root.get_node("Game").queue_free()


@rpc ("authority", "unreliable", "call_local")
func set_player_attributes(target_name, attribute_dict):
	var target = GameScene.get_node("Players/" + target_name)
	for key in attribute_dict:
		target.set(key, attribute_dict[key])


# Sends player hold statuses to newly joined player
func send_player_details():
	pass


@rpc("any_peer", "unreliable", "call_local")
func send_message(msg: String, duration = 5.0):
	var player = get_tree().root.get_node("Game/Players").get_node(str(multiplayer.get_remote_sender_id()))
	player.get_node("MessageDisplay").display_message(msg, duration)
