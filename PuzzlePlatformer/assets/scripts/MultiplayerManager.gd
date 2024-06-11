extends Node2D

## Default port
@export var PORT = 7000
## Default ip
@export var DEFAULT_IP = "127.0.0.1"
## Player Scene
@export var PlayerScene : PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func host_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, 10)
	if error != OK:
		print("Error hosting server")
		return
	multiplayer.multiplayer_peer = peer
	print("Hosting and waiting")
	get_tree().call_group("buttons", "hide")
	_on_peer_connected(multiplayer.get_unique_id())


func join_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(DEFAULT_IP, PORT)
	if error != OK:
		print("Couldn't connect")
		return
	multiplayer.multiplayer_peer = peer
	print("Joined Server")
	get_tree().call_group("buttons", "hide")


func _on_peer_connected(new_id: int):
	print(new_id, " connected")
	var new_player = PlayerScene.instantiate()
	new_player.name = str(new_id)
	$"../Players".call_deferred("add_child", new_player)


func _on_peer_disconnected():
	pass
