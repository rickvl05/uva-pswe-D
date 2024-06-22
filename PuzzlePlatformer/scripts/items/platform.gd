extends AnimatableBody2D

@export var players_needed: int

@onready var standonplatform = $Standonplatform
@onready var playeramounttext = $Playeramount
@onready var platform_animator = $PlatformAnimator

var playercount = 0

func _ready():
	playeramounttext.text = str(playercount) + " / " + str(players_needed) + " Players"

func _on_standonplatform_body_entered(_body):
	playercount += 1
	playeramounttext.text = str(playercount) + " / " + str(players_needed) + " Players"
#
	if playercount == players_needed and multiplayer.is_server():
		# set custom speed to positive
		platform_animator.play("going up", -1, 1.0, false)


func _on_standonplatform_body_exited(_body):
	playercount -= 1
	playeramounttext.text = str(playercount) + " / " + str(players_needed) + " Players"
	if playercount == players_needed - 1 and multiplayer.is_server():
		# set custom speed to negative
		platform_animator.play("going up", -1, -1.0, true)
