extends State

@export var idle_state: State
@export var walk_state: State

func enter() -> void:
	super()

func process_physics(delta: float) -> State:	
	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Apply forces
	parent.horizontal_movement(direction, delta)
	parent.velocity.y += gravity * delta
	parent.move_and_slide()
	
	if parent.is_on_floor():
		if direction != 0:
			return walk_state
		return idle_state
	
	return null
