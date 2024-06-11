extends State

@export var idle_state: State

# Inherit state properties
func enter() -> void:
	super()

func process_physics(delta: float) -> State:
	parent.velocity.x = move_toward(parent.velocity.x, 0, parent.deceleration * delta)
	parent.move_and_slide()
	
	if parent.is_on_floor():
		return idle_state

	return null
