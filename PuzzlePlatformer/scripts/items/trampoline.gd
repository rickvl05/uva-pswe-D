extends Item

@export var bounce_strength: int = 500
@export var picked_up: bool = false

@onready var animation = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	setup()

# Called when item has been picked up by a player.
func been_picked_up():
	disable_bounce()

# Called when item has been thrown away by a player.
func been_thrown_away():
	enable_bounce.rpc()

"""
Disables the trampoine bounce.
"""
func disable_bounce():
	picked_up = true

"""
Enables the trampoline bounce for all players.
"""
@rpc("reliable", "any_peer", "call_local")
func enable_bounce():
	picked_up = false

"""
Determines wether the collision between the trampoline and player is valid.
Normalizes the positions and then calculates the angle.
"""
func is_collision_valid(trampoline_pos: Vector2, player_pos: Vector2) -> bool:
	var trampoline_norm = trampoline_pos.normalized()
	
	var player_norm = player_pos.normalized()
	
	var degrees = -rad_to_deg(trampoline_norm.angle_to(player_norm))
	
	return degrees < 60

"""
Determine if the player should be launched by the trampoline. If the player
is holding the trampoline, it shouldn't be launched, otherwise the
is_collision_valid() function determinses wether the body will be launched.
"""
func determine_valid_jump(held, body):
	if held:
		return false
	else:
		return is_collision_valid(position, body.position)

"""
The main logic for the trampoline. See the wiki page on our github repo.
"""
func _on_bouncepad_body_entered(body):
	var valid_jump = determine_valid_jump(picked_up, body)

	if (body.is_in_group("Player") or (body is RigidBody2D and not body == self)) and valid_jump:
		var bounce_vec = Vector2(0, -bounce_strength).rotated(deg_to_rad(rotation_degrees))
		animation.play("default")
		GlobalAudioPlayer.initialize_SFX.rpc("bounce", position, false)

		if body.is_in_group("Player"):
			body.velocity = bounce_vec
		else:
			body.apply_central_impulse(bounce_vec)
