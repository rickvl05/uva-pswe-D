extends State
"""
This file contains the fall state of the player. Players are in this state when
they are falling through the air. From this state, the player can grab or throw
items/players and interact with doors. Players can also move in this state.

State Flow:
	Fall -> Idle - When the player lands on the ground without moving horizontally.
	Fall -> Walk - When the player lands on the ground and moves horizontally.
	Fall -> Jump - When the player presses the jump button and has coyote time left.
	Fall -> Held - When the player is grabbed.
"""


@export var idle_state: State
@export var walk_state: State
@export var jump_state: State
@export var held_state: State


var jump_buffer_timer: float = 0


func enter() -> void:
	super()
	jump_buffer_timer = 0


func exit() -> void:
	# Reset the deceleration to the standard value, important after being thrown.
	parent.deceleration = parent.standard_deceleration


func process_input(event: InputEvent) -> State:
	parent.door_action()

	# Disable input if the player is in a door
	if parent.is_in_door:
		return null

	parent.grab_or_throw()

	if event.is_action('jump'):
		# Jump from air when there is coyote time left
		if parent.coyote_timer > 0:
			return jump_state

		# Start the jump buffer timer
		jump_buffer_timer = parent.jump_buffer
	return null


func process_physics(delta: float) -> State:
	if parent.held_by != null:
		return held_state

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	parent.horizontal_movement(direction, delta)

	# Update timers
	jump_buffer_timer -= delta
	parent.coyote_timer -= delta

	# Move player and check for collisions
	parent.move_and_slide()

	if parent.is_on_floor():
		# Jump if there is time left on the jump buffer
		if jump_buffer_timer > 0:
			return jump_state
		if direction != 0:
			return walk_state
		return idle_state

	return null
