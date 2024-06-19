extends State

@export var jump_state: State
@export var walk_state: State
@export var fall_state: State
@export var held_state: State

const jump_sfx = preload("res://assets/sounds/jump.wav")

# Inherit state properties
func enter() -> void:
	super()
	parent.coyote_timer = parent.coyote_time

func process_input(event: InputEvent) -> State:
	if event.is_action_pressed('jump'):
		GlobalAudioPlayer.play_SFX.rpc(jump_sfx, parent.position)
		return jump_state
	if event.is_action_pressed('move_left') or event.is_action_pressed('move_right'):
		return walk_state
	return null

func process_physics(delta: float) -> State:
	if parent.held_by != null:
		return held_state
	
	parent.velocity.x = move_toward(parent.velocity.x, 0, parent.deceleration * delta)
	
	parent.move_and_slide()
	
	if !parent.is_on_floor():
		return fall_state

	return null
