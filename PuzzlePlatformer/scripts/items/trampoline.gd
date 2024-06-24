extends "res://script_templates/item.gd"

@export var bounce_strength: int = 500
@export var picked_up: bool = false

@onready var animation = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	setup()

# Called when item has been picked up by a player.
func been_picked_up():
	picked_up = true

# Called when item has been thrown away by a player.
func been_thrown_away():
	picked_up = false

func is_collision_valid(crate_pos: Vector2, player_pos: Vector2) -> bool:
	var crate_norm = crate_pos.normalized()
	
	var player_norm = player_pos.normalized()
	
	var degrees = -rad_to_deg(crate_norm.angle_to(player_norm))
	
	return degrees < 60

func determine_valid_jump(held, body):
	if held:
		return (position - body.position).y < 0
	else:
		return is_collision_valid(position, body.position)

func _on_bouncepad_body_entered(body):
	var valid_jump = determine_valid_jump(picked_up, body)
	if (body is Player or (body is RigidBody2D and not body == self)) and valid_jump:
		var bounce_vec = Vector2(0, -bounce_strength).rotated(deg_to_rad(rotation_degrees))
		animation.play("default")
		GlobalAudioPlayer.initialize_SFX.rpc("bounce", position, false)
		if body is Player:
			body.velocity = bounce_vec
		else:
			body.apply_central_impulse(bounce_vec)
