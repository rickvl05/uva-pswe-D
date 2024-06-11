extends Node2D


func _enter_tree():
	MultiplayerManager.set("GameScene", self)
	Chat.set("GameScene", self)
	print(Chat.GameScene)
