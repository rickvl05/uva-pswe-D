extends Node2D


var paused : bool = false
var number_players_loaded = 0
var current_level_number = 0


func _enter_tree():
	print("hi we are in game now haa")
	print("gamescene is : ", self)
	GlobalLevelEditor.set_game_scene(self)
	MultiplayerManager.GameScene = self


func reset_level():
	change_level(current_level_number)


func change_level(level_number: int):
	if !multiplayer.is_server():
		return

	# Remove all player items
	var players_node = get_node("/root/Game/Players")
	for player in players_node.get_children():
		if player.held_item != null:
			player.throw()

	number_players_loaded = 0
	var level_path = "res://scenes/levels/custom_level.tscn"
	assert(ResourceLoader.exists(level_path))

	GlobalAudioPlayer.play_music.rpc("level")
	_switch_level_scene.rpc(level_path, true)


@rpc("authority", "reliable", "call_local")
func _switch_level_scene(scene_path, respawn_player : bool):
	assert(ResourceLoader.exists(scene_path))
	var old_level = $Level
	remove_child(old_level)
	old_level.queue_free()
	var new_level = load(scene_path).instantiate()
	add_child.call_deferred(new_level)
	new_level.name = "Level"

	if respawn_player:
		for player in $Players.get_children():
			player.global_position = new_level.get_node("StartPoint").position
			player.velocity = Vector2(0, 0)
			player.set_checkpoint(new_level.get_node("StartPoint").position)
			if player.is_multiplayer_authority() and player.is_in_door == true:
				player.update_player_door_state.rpc(player.name, false)

	$InGameOverlay.external_close_pause_menu()
	_scene_loaded_callback.rpc_id(1)


@rpc("any_peer", "reliable", "call_local")
func _scene_loaded_callback():
	number_players_loaded += 1

	if number_players_loaded < len(multiplayer.get_peers()):
		return

	print("All players loaded")


func should_pause():
	return paused
