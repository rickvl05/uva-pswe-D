extends State

@export var idle_state: State
@export var held_state: State
@export var finish_animation: String

# Inherit state properties
func enter() -> void:
	super()

func process_physics(delta: float) -> State:
	if parent.held_by != null:
		parent.animations.play(finish_animation + str(parent.color))
	
	parent.velocity.x = move_toward(parent.velocity.x, 0, parent.deceleration * delta)
	parent.move_and_slide()
	
	if parent.is_on_floor():
		parent.animations.play(finish_animation + str(parent.color))

	return null
	

func _on_animated_sprite_2d_animation_finished():
	if parent.held_by != null:
		parent.state_machine.change_state(held_state)
	elif parent.is_on_floor():
		return parent.state_machine.change_state(idle_state)
