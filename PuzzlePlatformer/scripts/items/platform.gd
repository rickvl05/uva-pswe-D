extends AnimatableBody2D
"""
This file contains the code for the platform that requires a certain amount of
players to be on it to move. Moving is done on the host player's machine, the
clients then match the host's position.
"""


## Players needed to activate the platform.
@export var players_needed: int
## Current amount of players on the platform, should be zero at the start.
@export var playercount = 0

@onready var standonplatform = $Standonplatform
@onready var playeramounttext = $Playeramount
@onready var platform_animator = $PlatformAnimator



func _ready():
	# Set starting text
	playeramounttext.text = str(playercount) + " / " + str(players_needed) + " Players"


func _on_standonplatform_body_entered(_body):
	"""
	Moves the platform upwards if the correct amount of players are on it. Also
	updates the platform text.
	"""
	var count = count_players()

	# if the correct amount of players are on the platform, activate it
	if multiplayer.is_server() and playercount < players_needed and count >= players_needed:
		platform_animator.play("going up", -1, 1.0, false)

	playercount = count
	playeramounttext.text = str(playercount) + " / " + str(players_needed) + " Players"


func _on_standonplatform_body_exited(_body):
	"""
	Moves the platform downwards if the correct amount of players are not on it.
	Also updates the platform text.
	"""
	var count = count_players()

	# if its not the correct amount anymore, activate the animation with the reverse speed
	if multiplayer.is_server() and playercount >= players_needed and count < players_needed:
		platform_animator.play("going up", -1, -1.0, true)

	playercount = count
	playeramounttext.text = str(playercount) + " / " + str(players_needed) + " Players"



func count_players() -> int:
	"""
	Returns the amount of players on the platform, takes held players into account.
	"""
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
