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

func is_collision_valid(crate_pos: Vector2, player_pos: Vector2) -> bool:
	# Calculate the top side normal
	var top_side_normal = Vector2(0, 1).rotated(deg_to_rad(rotation_degrees))

	# Calculate the collision direction
	var collision_direction = (player_pos - crate_pos).normalized()

	# Check if the collision direction aligns with the top side normal
	var dot_product = -top_side_normal.dot(collision_direction)

	# Assuming a tolerance of 40 degrees for a valid collision
	return dot_product > cos(deg_to_rad(40))

func _on_bouncepad_body_entered(body):
	var valid_jump = is_collision_valid(position, body.position)
	if (body is Player or (body is RigidBody2D and not body == self)) and valid_jump:
		var bounce_vec = Vector2(0, -bounce_strength).rotated(deg_to_rad(rotation_degrees))
		if body is Player:
			body.velocity = bounce_vec
		else:
			body.apply_central_impulse(bounce_vec)
