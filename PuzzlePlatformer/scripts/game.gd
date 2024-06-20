extends Node2D


var paused : bool = false
var number_players_loaded = 0
var level_number = 1


func _enter_tree():
	MultiplayerManager.set("GameScene", self)


func change_level():
	if !multiplayer.is_server():
		return
	level_number += 1
	number_players_loaded = 0
	var level_path = "res://scenes/levels/level_" + str(level_number) + ".tscn"
	assert(ResourceLoader.exists(level_path))
	
	
	_switch_level_scene.rpc(level_path, true)
	

@rpc("authority", "reliable", "call_local")
func _switch_level_scene(scene_path, respawn_player : bool):
	assert(ResourceLoader.exists(scene_path))
	var old_level = $Level
	old_level.name = "RemoveMe"
	old_level.queue_free()
	var new_level = load(scene_path).instantiate()
	add_child.call_deferred(new_level)
	new_level.name = "Level"
	
	if respawn_player:
		var player = $Players.get_node(str(multiplayer.get_unique_id()))
		player.position = new_level.get_node("StartPoint").position
		player.velocity = Vector2(0, 0)
		player.set_checkpoint(new_level.get_node("StartPoint").position)
	
	_scene_loaded_callback.rpc_id(1)


@rpc("any_peer", "reliable", "call_local")
func _scene_loaded_callback():
	number_players_loaded += 1

	if number_players_loaded < len(multiplayer.get_peers()):
		return

	print("All players loaded")


func should_pause():
	return paused
