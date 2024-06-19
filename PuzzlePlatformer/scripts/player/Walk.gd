extends State

@export var idle_state: State
@export var jump_state: State
@export var fall_state: State
@export var held_state: State

const jump_sfx = preload("res://assets/sounds/jump.wav")

func enter() -> void:
	super()
	parent.coyote_timer = parent.coyote_time

func process_input(event: InputEvent) -> State:
	if event.is_action_pressed('jump') and parent.coyote_timer > 0:
		GlobalAudioPlayer.play_SFX.rpc(jump_sfx, parent.position)
		return jump_state
	return null

func process_physics(delta: float) -> State:
	if parent.held_by != null:
		return held_state
	
	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	parent.horizontal_movement(direction, delta)
	
	parent.move_and_slide()
	
	if parent.is_on_floor():
		if direction == 0:
			return idle_state
	else:
		return fall_state
	
	return null
