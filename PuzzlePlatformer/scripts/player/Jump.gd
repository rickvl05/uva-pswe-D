extends State
"""
This file contains the jump state of the player. Players are in this state
when they just pressed the jump button. From this state, the player can
grab or throw items/players and interact with doors.

State Flow:
	Jump -> Idle - When the player is not moving and is on the ground.
	Jump -> Walk - When the player is moving left or right and is on the ground.
	Jump -> Fall - When the player is falling in the air.
	Jump -> Held - When the player is grabbed.
"""


@export var idle_state: State
@export var walk_state: State
@export var fall_state: State
@export var held_state: State


func enter() -> void:
	# Disable coyote time and add jump velocity
	parent.coyote_timer = 0
	parent.velocity.y = -parent.jump_velocity
	GlobalAudioPlayer.initialize_SFX.rpc("jump", parent.position, false)
	super()


func process_input(_event: InputEvent) -> State:
	parent.door_action()

	# Disable input if the player is in a door
	if parent.is_in_door:
		return null

	parent.grab_or_throw()
	return null


func process_physics(delta: float) -> State:
	if parent.held_by != null:
		return held_state
	if parent.velocity.y > 0:
		return fall_state

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	parent.horizontal_movement(direction, delta)

	# Move player and check for collisions
	parent.move_and_slide()

	if parent.is_on_floor():
		if direction != 0:
			return walk_state
		return idle_state

	return null
