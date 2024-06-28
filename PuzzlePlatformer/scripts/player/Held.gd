extends State
"""
This file contains the held state of the player. Players are in this state
when they are held by another player. From this state, the player grab or throw
items/players. The player can not move but they can flip their direction.

State Flow:
	Held -> Fall - When thrown by the player holding them.
"""


@export var fall_state: State


func enter() -> void:
	# Disable coyote time
	parent.coyote_timer = 0
	super()


func process_input(_event: InputEvent) -> State:
	parent.grab_or_throw()
	return null


func process_physics(_delta: float) -> State:
	if parent.held_by == null:
		# Set the player deceleration to the thrown_deceleration
		parent.deceleration = parent.thrown_deceleration
		return fall_state

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	parent.change_direction(direction)

	# Move player and check for collisions
	parent.move_and_slide()

	# Track the position of the player holding this player
	if parent.held_by:
		parent.position = parent.held_by.position + Vector2(0, -parent.held_by.item_height)

	return null
