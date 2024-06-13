extends AnimatableBody2D

# standonplatform is an area2d
@onready var standonplatform = $Standonplatform
@onready var playeramounttext = $Playeramount
@onready var animation_player = $AnimationPlayer

var playeramount = 0

func _on_standonplatform_body_entered(body):
	playeramount += 1
	playeramounttext.text = str(playeramount) + " / 2 Players"
#
	if playeramount >= 2:
		# set custom speed to positive
		animation_player.play("going up", -1, 1.0, false)


func _on_standonplatform_body_exited(body):
	playeramount -= 1
	playeramounttext.text = str(playeramount) + " / 2 Players"
	if playeramount < 2:
		# set custom speed to negative
		animation_player.play("going up", -1, -1.0, false)
	

