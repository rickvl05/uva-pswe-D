extends Node

# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 9999

# Max number of players.
const MAX_PEERS = 8

@export var players_node: Node:
	set(node):
		players_node = node

var peer = null
func _ready():
	multiplayer.peer_connected.connect(_add_player)

func host_game():
	peer = ENetMultiplayerPeer.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	multiplayer.set_multiplayer_peer(peer)
	_add_player(1)


func join_game(ip):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, DEFAULT_PORT)
	multiplayer.set_multiplayer_peer(peer)
	
func _add_player(id: int):
	if not multiplayer.is_server():
		return
		
	var player = load("res://scenes/player.tscn").instantiate()
	player.set("player_id", id)
	player.name = str(id)
	players_node.add_child(player, true)

