extends Area2D

## State for if door is locked or not
@export var locked = true
## Number that indicates next level
@export var next_level_number = 2

@export var current_level_number: int

var entered_count = 0

func _ready():
	# Show correct sprite
	if not locked:
		update_door_state()
	
# when a key enters this body, change the status to unlocked
func _on_body_entered(body):
	if multiplayer.is_server():
		if body is Player and body.held_item:
			if body.held_item.name == 'Key':
				update_door_state.rpc()
		
		if body.name == 'Key' and locked:
			update_door_state.rpc()

# Update the door sprite
@rpc("authority", 'reliable', 'call_local')
func update_door_state():
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
		key.get_node("CollisionShape2D").disabled = true

"""
Action for entering and leaving a level door
"""
func enter_door(player: Player) -> void:
	# Send request to enter door to host
	if player.held_item:
		player.throw(true)
	door_request.rpc_id(1, player.name, name, true)

func exit_door(player: Player) -> void:
	# Send request to exit door to host
	door_request.rpc_id(1, player.name, name, false)

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
			
			get_tree().root.get_node("Game").change_level(next_level_number)

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
