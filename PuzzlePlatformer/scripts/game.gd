extends Node2D


var paused : bool = false
var chatting : bool = false


func _enter_tree():
	MultiplayerManager.set("GameScene", self)


func should_pause():
	return paused or chatting
