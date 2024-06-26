extends Area2D

@onready var leveldisplay = $Leveldisplay
@onready var playeramounttext = $Playeramount
@onready var players = $"../../Players"

# the level the door is support to teleport the players to
@export var level: float

# amount of players inside the door
var playeramount = 0
var playersinside = []

func _ready():
	leveldisplay.text = "Level " + str(level)

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

func _process(_delta):
	# if the player pressed interact
	if playeramount == 2:
		if Input.is_action_just_pressed("interact"):
			# if the playeramount is 2, teleport the players to the next scene
			for player in playersinside:
				player.global_position = Vector2(0, 0)
