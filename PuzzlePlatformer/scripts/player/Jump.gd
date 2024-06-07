extends State

@export var idle_state: State
@export var walk_state: State
@export var fall_state: State

func enter() -> void:
	super()
	# Disable coyote time and add jump velocity
	parent.coyote_timer = 0
	parent.velocity.y = -parent.jump_velocity

func process_physics(delta: float) -> State:

	if parent.velocity.y > 0:
		return fall_state

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	parent.horizontal_movement(direction, delta)
	
	if parent.is_on_floor():
		if direction != 0:
			return walk_state
		return idle_state
	
	return null
