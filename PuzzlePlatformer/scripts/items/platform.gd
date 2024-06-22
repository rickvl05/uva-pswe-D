extends AnimatableBody2D

# standonplatform is an area2d
@onready var standonplatform = $Standonplatform
@onready var playeramounttext = $Playeramount
@onready var platform_animator = $PlatformAnimator
@export var maxplayers: float

var playeramount = 0

func _on_standonplatform_body_entered(_body):
	playeramount += 1
	playeramounttext.text = str(playeramount) + " / " + str(maxplayers) + " Players"
#
	if playeramount >= maxplayers:
		# set custom speed to positive
		platform_animator.play("going up", -1, 1.0, false)


func _on_standonplatform_body_exited(_body):
	playeramount -= 1
	playeramounttext.text = str(playeramount) + " / " + str(maxplayers) + " Players"
	if playeramount < maxplayers:
		# set custom speed to negative
		platform_animator.play("going up", -1, -1.0, false)
	

