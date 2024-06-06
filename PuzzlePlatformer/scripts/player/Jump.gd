extends State

@export var fall_state: State
@export var idle_state: State
@export var walk_state: State

func enter() -> void:
	super()
	parent.velocity.y = -parent.jump_velocity

func process_physics(delta: float) -> State:
	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Determine forces
	parent.horizontal_movement(direction, delta)
	parent.velocity.y += gravity * delta
	
	if parent.velocity.y > 0:
		return fall_state

	parent.move_and_slide()
	
	if parent.is_on_floor():
		if direction != 0:
			return walk_state
		return idle_state
	
	return null
