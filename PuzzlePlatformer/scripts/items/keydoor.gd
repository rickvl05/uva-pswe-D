"""
This file contains the logic for the door object in the game. The door object
is used to transition between levels in the game. The door object can be locked
or unlocked. If the door is locked, the player must find a key to unlock the
door. Once the door is unlocked, the player can enter the door to transition to
the next level. The door object also keeps track of the number of players that
have entered the door. Once all players have entered the door, the door will
transition to the next level.
"""
extends Area2D

## State for if door is locked or not
@export var locked = true
## Number that indicates next level
@export var next_level_number = 2
## Number that indicates the current level
@export var current_level_number: int

var entered_count = 0


func _ready() -> void:
	# Show correct sprite
	if not locked:
		update_door_state()


"""
Checks on the host if a key is in the door area. If a key is in the door area,
the door will unlock.
"""
func _on_body_entered(body) -> void:
	if multiplayer.is_server():
		if body is Player and body.held_item:
			if body.held_item.name == 'Key':
				update_door_state.rpc()

		if body.name == 'Key' and locked:
			update_door_state.rpc()


"""
Updates the state of the door on the host and all clients. Changes the door
sprite to the opened door sprite and sets the door to unlocked. Also hides the
key sprite and disables its collision.
"""
@rpc("authority", 'reliable', 'call_local')
func update_door_state() -> void:
	$OpenedDoor.visible = true
	$ClosedDoor.visible = false
	locked = false

	var key = get_tree().root.get_node('Game/Level/Key')
	var players = get_node("/root/Game/Players")

	for player in players.get_children():
		if player.held_item and player.held_item.name == 'Key' and player.is_multiplayer_authority():
			player.throw(true)

	if key:
		key.visible = false
		key.collision_layer = 0


"""
Sends a request to the host to enter the door. If the player is holding an item,
the player will drop the item before entering the door.
"""
func enter_door(player: Player) -> void:
	# Send request to enter door to host
	if player.held_item:
		player.throw(true)
	door_request.rpc_id(1, player.name, name, true)

"""
Sends a request to the host to exit the door.
"""
func exit_door(player: Player) -> void:
	# Send request to exit door to host
	door_request.rpc_id(1, player.name, name, false)

"""
Makes the source player enter or exit a door. Entering can only be done when
the door is unlocked. This is done by updating the player's door state and then
incrementing the entered count of the door. If the required amount of players
have entered the door, the game will transition to the next level.
"""
@rpc("reliable", "any_peer", "call_local")
func door_request(source_name, target_name, enter_action = true):
	var door = get_tree().root.get_node("Game/Level/" + target_name)

	# Enter door if door is unlocked
	if door.locked == false:
		door.entered_count = door.entered_count + (1 if enter_action else -1)
		update_player_door_state.rpc(source_name, enter_action)

		# Check if required amount of players entered the door
		if MultiplayerManager.player_count == entered_count:
			# Reset player door state
			var players = get_node("/root/Game/Players")
			for player in players.get_children():
				update_player_door_state.rpc(player.name, false)

			if current_level_number == 1:
				MultiplayerManager.leave_game()
				var main_menu = load("res://scenes/menus/main_menu.tscn").instantiate()
				get_tree().root.add_child(main_menu)
				get_tree().root.get_node("Game").queue_free()
			else:
				get_tree().root.get_node("Game").change_level(next_level_number)

"""
Updates the player's door state. If the player is entering the door, the player
will be hidden and the player's collision will be disabled. If the player is
exiting the door, the player will be shown and the player's collision will be
enabled.
"""
@rpc("reliable", "any_peer", "call_local")
func update_player_door_state(source_name, enter_action = true):
	var player = get_tree().root.get_node("Game/Players/" + source_name)

	if enter_action:
		player.is_in_door = true
		player.visible = false

		# Disable player collision
		player.helmet.get_node("CollisionShape2D").disabled = true
		player.collision_layer = 0
		player.collision_mask = 1
	else:
		player.is_in_door = false
		player.visible = true

		# Enable player collision
		player.helmet.get_node("CollisionShape2D").disabled = false
		player.collision_layer = 18 # Default collision layer
		player.collision_mask = 71 # Default collision mask
