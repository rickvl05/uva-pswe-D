extends "res://script_templates/item.gd"

@export var bounce_strength: int = 500
@export var bounce_disabled: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	setup()

# Called when item has been picked up by a player.
func been_picked_up():
	bounce_disabled = true

# Called when item has been thrown away by a player.
func been_thrown_away():
	bounce_disabled = false

func _on_bouncepad_body_entered(body):
	if (body is Player or (body is RigidBody2D and not body == self)) and !bounce_disabled:
		var bounce_vec = Vector2(0, -bounce_strength).rotated(deg_to_rad(rotation_degrees))
		if body is Player:
			body.velocity = bounce_vec
		else:
			body.linear_velocity = bounce_vec
