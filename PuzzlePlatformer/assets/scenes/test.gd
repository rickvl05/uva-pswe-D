extends "res://assets/scripts/Playermovement.gd"

@onready var rayleft = $Rayleft
@onready var rayright = $Rayright

#func _process(delta):
 	## pickup function, check the area2d in the raycast for a pickup 
	#if Input.is_action_just_pressed("pickup"):
		#var pickup = null
	## if the look_direction of player is 1, then the player is facing right
		#if player.get("look_direction") == 1:
			#pickup = rayright.get_collider()
		#else:
			#pickup = rayleft.get_collider()	
			#
		#if pickup:
			#pickup.queue_free()
			#print("Picked up item")
			#
		#if not pickup:
			#print("No item to pick up")

