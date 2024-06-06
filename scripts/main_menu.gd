extends Control

func _ready():
	# Called every time the node is added to the scene.
	pass


func load_lobby():
	var lobby = load("res://scenes/lobby.tscn").instantiate()
	get_tree().get_root().add_child(lobby)
	get_tree().get_root().get_node("MainMenu").queue_free()
	
	MultiplayerManager.set("players_node", get_tree().get_root().get_node("Lobby").get_node("Players"))

func _on_host_pressed():
	load_lobby()
	MultiplayerManager.host_game()


func _on_join_pressed():
	var ip = $Connect/IPAddress.text
	if not ip.is_valid_ip_address():
		$Connect/ErrorLabel.text = "Invalid IP address!"
		return
		
	load_lobby()
	MultiplayerManager.join_game(ip)
