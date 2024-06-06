extends State

@export var fall_state: State
@export var jump_state: State
@export var walk_state: State

# Inherit state properties
func enter() -> void:
	super()

func process_input(event: InputEvent) -> State:
	if Input.is_action_pressed('jump') and parent.is_on_floor():
		return jump_state
	if Input.is_action_pressed('move_left') or Input.is_action_pressed('move_right'):
		return walk_state
	return null

func process_physics(delta: float) -> State:
	# Apply gravity and decelerate player.
	parent.velocity.y += gravity * delta
	parent.velocity.x = move_toward(parent.velocity.x, 0, parent.deceleration * delta)
	parent.move_and_slide()
	
	if !parent.is_on_floor():
		return fall_state

	return null
