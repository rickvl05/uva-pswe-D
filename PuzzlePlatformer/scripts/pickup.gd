extends State

@onready var rayleft = $Rayleft
@onready var rayright = $Rayright

func _process(delta):
 	# pickup function, check the area2d in the raycast for a pickup 
	if Input.is_action_just_pressed("pickup"):
		var pickup = null
	# if the look_direction of player is 1, then the player is facing right
		if look_direction == 1:
			pickup = rayright.get_collider()
		else:
			pickup = rayleft.get_collider()	
			
		if pickup:
			print("Picked up item")
			# set item location on top of player
			pickup.position = Vector2(self.position.x, self.position.y - 50)

		else:
			print("No item")


