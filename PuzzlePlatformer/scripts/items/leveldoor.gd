extends Area2D

@onready var playeramounttext = $Playeramount
@onready var players = $"../../Players"

@export var level: float

var playeramount = 0
var playersinside = []

# when a player enters this body, increase the playeramount by 1
func _on_body_entered(body):
	playersinside.append(body)
	playeramount += 1
	playeramounttext.text = str(playeramount) + " / 2 Players"

# when a player exits this body, decrease the playeramount by 1
func _on_body_exited(body):
	playersinside.erase(playersinside.find(body))
	playeramount -= 1
	playeramounttext.text = str(playeramount) + " / 2 Players"

func _process(delta):
	# if the player pressed interact
	if playeramount == 2:
		if Input.is_action_just_pressed("interact"):
			# if the playeramount is 2, teleport the players to the next scene
			for player in playersinside:
				player.global_position = Vector2(0, 0)
			
			# HIER SWTICH HIJ NAAR EEN NIEUW LEVEEEEEL