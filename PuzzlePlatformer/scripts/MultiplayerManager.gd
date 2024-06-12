extends Node


const DEFAULT_PORT = 7777
const DEFAULT_IP = "127.0.0.1t"
# Victor: 145.109.28.168

var available_colors = [1, 2, 3, 4, 5, 6, 7, 8]

@export var GameScene : Node:
	set(node):
		GameScene = node

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_on_player_connect)
	multiplayer.peer_disconnected.connect(_on_player_disconnect)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func host_game():
	# Set host peer
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(DEFAULT_PORT, 10)
	multiplayer.set_multiplayer_peer(peer)
	
	# Create level instance
	var new_game = load("res://scenes/game.tscn").instantiate()
	get_tree().root.add_child(new_game)
	get_tree().root.get_node("Menu").queue_free()
	
	if error != OK:
		print("Can't host")
	_on_player_connect(multiplayer.get_unique_id())


func join_game():
	# Set client peer
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	multiplayer.set_multiplayer_peer(peer)
	
	# Create level instance
	var new_game = load("res://scenes/game.tscn").instantiate()
	get_tree().root.add_child(new_game)
	get_tree().root.get_node("Menu").queue_free()
	
	if error != OK:
		print("Can't join")


func _on_player_connect(id):
	if not multiplayer.is_server():
		return
	
	var new_player = load("res://scenes/player.tscn").instantiate()
	new_player.name = str(id)
	GameScene.get_node("Players").add_child(new_player)
	
	_set_player_color.rpc(str(id), available_colors.pop_front())
	
@rpc ("authority", "reliable", "call_local")
func _set_player_color(target_name, color):
	var target = GameScene.get_node("Players").get_node(target_name)
	target.color = color

func _on_player_disconnect(id):
	GameScene.get_node("Players").get_node(str(id)).queue_free()
