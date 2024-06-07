extends State

@export var jump_state: State
@export var walk_state: State
@export var fall_state: State

# Inherit state properties
func enter() -> void:
	super()
	parent.coyote_timer = parent.coyote_time

func process_input(event: InputEvent) -> State:
	if Input.is_action_just_pressed('jump') and parent.coyote_timer > 0:
		return jump_state
	if Input.is_action_pressed('move_left') or Input.is_action_pressed('move_right'):
		return walk_state
	return null

func process_physics(delta: float) -> State:
	parent.velocity.x = move_toward(parent.velocity.x, 0, parent.deceleration * delta)
	
	if !parent.is_on_floor():
		return fall_state

	return null
