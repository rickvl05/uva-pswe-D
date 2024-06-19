extends Area2D

# State for if door is locked or not
@export var locked = true
# Number that indicates next level
@export var next_level_number = 1

var entered_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Show correct sprite
	if not locked:
		open_door()
	
# when a key enters this body, change the status to unlocked
func _on_body_entered(body):
	if body.name == 'Key' and locked:
		# Change status
		locked = false
		
		open_door()
		
		# Remove the key
		body.queue_free()
	
	if body.is_in_group("Player") and not locked and multiplayer.is_server():
		entered_count += 1
		
		if MultiplayerManager.player_count == entered_count:
			get_tree().root.get_node("Game").change_level(next_level_number)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Update the door sprite
func open_door():
	$OpenedDoor.visible = true
	$ClosedDoor.visible = false
	
