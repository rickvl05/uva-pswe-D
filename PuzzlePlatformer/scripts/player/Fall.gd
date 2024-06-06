extends State

@export var idle_state: State
@export var walk_state: State
@export var jump_state: State

func enter() -> void:
	super()

func process_input(event: InputEvent) -> State:
	if Input.is_action_pressed('jump') and parent.coyote_timer > 0:
		return jump_state
	return null

func process_physics(delta: float) -> State:	
	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Apply forces
	parent.horizontal_movement(direction, delta)
	parent.velocity.y += gravity * delta
	parent.move_and_slide()
	
	# Update coyote time
	parent.coyote_timer -= delta
	
	if parent.is_on_floor():
		if direction != 0:
			return walk_state
		return idle_state
	
	return null
