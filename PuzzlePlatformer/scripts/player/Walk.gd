"""
This file contains the walk state of the player. Players are in this state
when they are moving horizontally on the ground. From this state, the player
can move, grab or throw items/players and interact with doors.

State Flow:
	Walk -> Idle - When the player stops moving.
	Walk -> Jump - When the player presses the jump button.
	Walk -> Fall - When the player falls off the ground.
	Walk -> Held - When the player is grabbed.
"""

extends State

@export var idle_state: State
@export var jump_state: State
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

	if event.is_action_pressed('jump') and parent.coyote_timer > 0:
		return jump_state
	return null

func process_physics(delta: float) -> State:
	if parent.held_by:
		return held_state

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	parent.horizontal_movement(direction, delta)

	# Move player and check for collisions
	parent.move_and_slide()

	if parent.is_on_floor():
		if direction == 0:
			return idle_state
	else:
		return fall_state

	return null
