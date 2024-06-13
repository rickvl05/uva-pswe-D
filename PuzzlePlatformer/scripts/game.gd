extends Node2D


var paused : bool = false


func _enter_tree():
	MultiplayerManager.set("GameScene", self)
