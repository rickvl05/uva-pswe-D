"""
This file contains the idle state of the player. Players are in this state
when they are not moving and not in the air. From this state, the player can
grab or throw items/players and interact with doors.

State Flow:
	Idle -> Jump - When the player presses the jump button.
	Idle -> Walk - When the player presses the left or right arrow keys.
	Idle -> Fall - When the player is no longer on the floor.
	Idle -> Held - When the player is grabbed.
"""

extends State

@export var jump_state: State
@export var walk_state: State
@export var fall_state: State
@export var held_state: State

func enter() -> void:
	# Reset the coyote timer
	parent.coyote_timer = parent.coyote_time
	super()

func process_input(event: InputEvent) -> State:
	parent.door_action()

	# Disable input if the player is in a door
	if parent.is_in_door:
		return null

	parent.grab_or_throw()

	if event.is_action_pressed('jump'):
		return jump_state
	if Input.get_axis("move_left", "move_right"):
		return walk_state
	return null

func process_physics(delta: float) -> State:
	if parent.held_by != null:
		return held_state

	# Decelerate player
	parent.velocity.x = move_toward(parent.velocity.x, 0, parent.deceleration * delta)

	# Move player and check for collisions
	parent.move_and_slide()

	if !parent.is_on_floor():
		return fall_state

	return null
