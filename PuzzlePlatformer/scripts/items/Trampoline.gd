extends RigidBody2D

@export var held_by: CharacterBody2D = null

@export var bounce_strength: int = 500
@export var bounce_disabled: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	if !multiplayer.is_server():
		freeze = true

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if multiplayer.is_server():
		if held_by != null:
			# Position has to be updated in this function otherwise it will interfere
			# with the physics simulation
			position = held_by.global_position + Vector2(0, -held_by.item_height)
			rotation = 0

func _on_bouncepad_body_entered(body):
	print(bounce_disabled)
	if body is Player and !bounce_disabled:
		body.velocity.y = -bounce_strength

func been_picked_up():
	bounce_disabled = true

func thrown_away():
	bounce_disabled = false
