extends Node


const DEFAULT_PORT = 7777
const DEFAULT_IP = "127.0.0.1"

var available_colors = [1, 2, 3, 4]
var player_count = 0


@export var GameScene: Node:
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


func host_game(max_players = 4, tutorial = false):
	# Reset player count
	player_count = 0
	
	# Set host peer
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(DEFAULT_PORT, max_players)
	if error != OK:
		print("Can't host")
		return error
	multiplayer.set_multiplayer_peer(peer)

	# Create level instance
	var new_game = load("res://scenes/lobby.tscn").instantiate()
	get_tree().root.add_child(new_game)
	#get_tree().root.get_node("Menu").queue_free()

	_on_player_connect(multiplayer.get_unique_id())
	if tutorial:
		get_tree().root.get_node("Game").change_level(1)
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
	if multiplayer.is_server():
		available_colors = [1, 2, 3, 4]
	multiplayer.multiplayer_peer.disconnect_peer(1)
	multiplayer.multiplayer_peer.close()
	multiplayer.set_multiplayer_peer(null)


func _on_player_connect(id):
	# Only the server manually adds the player, clients use the Multiplayer-
	# Spawner

	if not multiplayer.is_server():
		return

	player_count += 1

	var level = get_node("/root/Game/Level")
	if !level:
		_on_server_disconnect.rpc_id(id)
		return
	elif !level.has_method("is_lobby"):
		_on_server_disconnect.rpc_id(id)
		return
	elif get_node("/root/Game/Players").get_child_count() >= 4:
		_on_server_disconnect.rpc_id(id)
		return

	# Create new player instance
	var new_player = load("res://scenes/player.tscn")
	new_player = new_player.instantiate()
	new_player.name = str(id)
	new_player.color = available_colors.pop_front()
	GameScene.get_node("Players").add_child(new_player)

	# Set player attributes on all other clients
	set_player_attributes.rpc(str(id), new_player.get_settable_attributes())


func _on_player_disconnect(id):
	"""Removes a player from the Game scene when they disconnect.
	"""
	var player = GameScene.get_node("Players").get_node(str(id))
	if player:
		available_colors.append(player.color)
		player.queue_free()
	player_count -= 1


@rpc("authority", "reliable")
func _on_server_disconnect():
	"""On server disconnect, all remaining clients are kicked back to the main
	menu and receive an error of why they were kicked.
	"""
	# Remove invalid connection
	multiplayer.multiplayer_peer.close()
	multiplayer.set_multiplayer_peer(null)

	# Switch to main menu
	var main_menu = load("res://scenes/menus/main_menu.tscn").instantiate()
	get_tree().root.add_child(main_menu)
	main_menu.get_node("CanvasLayer/MainMenu").display_error_message("Host left!")
	get_tree().root.get_node("Game").queue_free()


@rpc ("authority", "unreliable", "call_local")
func set_player_attributes(target_name, attribute_dict):
	"""This function is used to sync a players attributes on join that
	are not synced through the MultiplayerSpawner.
	"""
	var target = GameScene.get_node("Players/" + target_name)
	for key in attribute_dict:
		target.set(key, attribute_dict[key])


@rpc("any_peer", "unreliable", "call_local")
func send_message(msg: String, duration = 5.0):
	"""Broadcasts a chat message to all clients and displays it in the player's
	chat box for 'duration' seconds.
	"""
	var player = get_tree().root.get_node("Game/Players/" + str(multiplayer.get_remote_sender_id()))
	assert(player, "Chat received from player that is not in the game")
	player.get_node("MessageDisplay").display_message(msg, duration)
