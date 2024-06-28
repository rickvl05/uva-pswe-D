class_name StateMachine
extends Node
"""
This file contains the StateMachine class. This class is used to manage the
states of the player. The current state is updated whenever the physics, input,
or frame functions pass a new state to the state machine. The state machine
then calls the exit function of the current state and the enter function of the
new state. Then the state machine will call the process functions of the new
state until a new state is returned.

We chose to use a state machine to manage the player states because it is
easily expandable, allows for easy debugging, and is easy to understand. It is
also easy to add state specific behaviour while also allowing for behaviour
shared between states.
"""


@export var starting_state: State

var current_state: State

func init(parent: Player) -> void:
	"""
	Initializes the state machine by setting the parent of all children to the
	Player. This is necessary to call Player functions from the children. Also
	changes to the starting state.
	"""
	for child in get_children():
		child.parent = parent

	change_state(starting_state)

func change_state(new_state: State) -> void:
	"""
	Changes the current state to the new state. Calls the exit function of the
	current state and the enter function of the new state.
	"""
	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()

func process_physics(delta: float) -> void:
	"""
	Processes the physics of the current state. If the state returns a new state,
	changes to that state.
	"""
	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)

func process_input(event: InputEvent) -> void:
	"""
	Processes the inputs of the current state. If the state returns a new state,
	changes to that state.
	"""
	var new_state = current_state.process_input(event)
	if new_state:
		change_state(new_state)

func process_frame(delta: float) -> void:
	"""
	Processes the frame of the current state. If the state returns a new state,
	changes to that state.
	"""
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)

func get_current_state() -> State:
	return current_state
