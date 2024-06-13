extends State

@export var idle_state: State
@export var walk_state: State
@export var jump_state: State
@export var held_state: State

var jump_buffer_timer: float = 0

func enter() -> void:
	super()
	jump_buffer_timer = 0

func process_input(event: InputEvent) -> State:
	if Input.is_action_just_pressed('jump'):
		if parent.coyote_timer > 0:
			return jump_state
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
	
	parent.move_and_slide()
	
	if parent.is_on_floor():
		if jump_buffer_timer > 0:
			return jump_state
		if direction != 0:
			return walk_state
		return idle_state
	
	return null
