extends State

@export var fall_state: State

# Inherit state properties
func enter() -> void:
	parent.coyote_timer = 0
	super()
	
func process_input(event: InputEvent) -> State:	
	parent.grab_or_throw()
	return null
	
func process_physics(_delta: float) -> State:
	if parent.held_by == null:
		parent.deceleration = parent.thrown_deceleration
		return fall_state
	
	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	parent.change_direction(direction)
	
	parent.move_and_slide()
	
	if parent.held_by != null:
		parent.position = parent.held_by.position + Vector2(0, -parent.held_by.item_height)

	return null
