extends Area2D

# State for if door is locked or not
@export var locked = true
# Number that indicates next level
@export var next_level_number = 2

@export var current_level_number: int

var entered_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Show correct sprite
	if not locked:
		update_door_state()
	
# when a key enters this body, change the status to unlocked
func _on_body_entered(body):
	if multiplayer.is_server():
		if body.is_in_group("Player") and body.held_item:
			if body.held_item.name == 'Key':
				# Change door status
				update_door_state.rpc()
		
		if body.name == 'Key' and locked:
			# Change door status
			update_door_state.rpc()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if MultiplayerManager.player_count == entered_count:
		
		
		get_tree().root.get_node("Game").change_level(next_level_number)

# Update the door sprite
@rpc("authority", 'reliable', 'call_local')
func update_door_state():
	$OpenedDoor.visible = true
	$ClosedDoor.visible = false
	locked = false
	
	var key = get_tree().root.get_node('Game/Level/Key')
	var players = get_tree().get_nodes_in_group("Player")
	
	for player in players:
		if player.held_item:
			if player.held_item.name == 'Key' and player.is_multiplayer_authority():
				player.throw()
	
	if key:
		key.visible = false
		key.get_node("CollisionShape2D").disabled = true
