extends Node


const DEFAULT_PORT = 7777
const DEFAULT_IP = "127.0.0.1"

var players = {}
@export var GameScene : Node:
	set(node):
		GameScene = node

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_on_player_connect)
	multiplayer.peer_disconnected.connect(_on_player_disconnect)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func host_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(DEFAULT_PORT, 10)
	if error != OK:
		print("Can't host")
	multiplayer.set_multiplayer_peer(peer)
	_on_player_connect(multiplayer.get_unique_id())


func join_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	if error != OK:
		print("Can't join")
	multiplayer.set_multiplayer_peer(peer)


func _on_player_connect(id):
	if not multiplayer.is_server():
		return
	
	var new_player = load("res://scenes/player.tscn").instantiate()
	new_player.name = str(id)
	print(GameScene)
	GameScene.get_node("Players").add_child(new_player)
	
func _on_player_disconnect(id):
	GameScene.get_node("Players").get_node(str(id)).queue_free()
