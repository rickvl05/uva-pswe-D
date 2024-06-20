extends Node2D


var paused : bool = false
var number_players_loaded = 0
var current_level_number = 0


func _enter_tree():
	MultiplayerManager.set("GameScene", self)

func reset_level():
	change_level(current_level_number)

func change_level(new_level_number):
	if !multiplayer.is_server():
		return
	
	number_players_loaded = 0
	current_level_number = new_level_number
	var level_path = "res://scenes/levels/level_" + str(new_level_number) + ".tscn"
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
		for player in $Players.get_children():
			player.position = new_level.get_node("StartPoint").position
			player.velocity = Vector2(0, 0)
			player.set_checkpoint(new_level.get_node("StartPoint").position)
			player.visible = true
			player.is_in_door = false
			player.collision_layer = 18
		
	_scene_loaded_callback.rpc_id(1)


@rpc("any_peer", "reliable", "call_local")
func _scene_loaded_callback():
	number_players_loaded += 1

	if number_players_loaded < len(multiplayer.get_peers()):
		return

	print("All players loaded")


func should_pause():
	return paused
