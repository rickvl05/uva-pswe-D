extends AnimatableBody2D

# players needed to activate the platform
@export var players_needed: int

# current amount of players on the platform
@export var playercount = 0

@onready var standonplatform = $Standonplatform
@onready var playeramounttext = $Playeramount
@onready var platform_animator = $PlatformAnimator



func _ready():
	playeramounttext.text = str(playercount) + " / " + str(players_needed) + " Players"

func _on_standonplatform_body_entered(body):
	var count = count_players()
	
	# if the correct amount of players are on the platform, activate it
	if multiplayer.is_server() and playercount < players_needed and count >= players_needed:
		platform_animator.play("going up", -1, 1.0, false)
	
	playercount = count	
	playeramounttext.text = str(playercount) + " / " + str(players_needed) + " Players"
	

func _on_standonplatform_body_exited(body):
	var count = count_players()
	
	# if its not the correct amount anymore, activate the animation with the reverse speed
	if multiplayer.is_server() and playercount >= players_needed and count < players_needed:
		platform_animator.play("going up", -1, -1.0, true)
			
	playercount = count
	playeramounttext.text = str(playercount) + " / " + str(players_needed) + " Players"


# Returns the amount of players on the platform
func count_players() -> int:
	var bodies = standonplatform.get_overlapping_bodies()
	
	var count = 0
	for body in bodies:
		count += 1
		
		# Count how many players the host player is holding
		if body.is_multiplayer_authority():
			var current_body = body.held_item
			while (current_body):
				count += 1
				if current_body is Player:
					current_body = current_body.held_item
				else:
					current_body = null
	
	return count
