class_name Player
extends CharacterBody2D

## Determines the top speed of the player
@export var speed: float
## Determines the acceleration of the player when a movement key is pressed
@export var acceleration: float
## Determines the deceleration of the player when no movement key is pressed
@export var deceleration: float
## Determines the velocity added when jumping
@export var jump_velocity: float
## Determines the amount of time you have left to jump after leaving the floor
@export var coyote_time: float

@onready var animations = $AnimatedSprite2D
@onready var state_machine = $StateMachine

var coyote_timer: float = 0

func _ready() -> void:
	# Initialize the state machine, passing a reference of the player to the states,
	# that way they can move and react accordingly
	state_machine.init(self)
	set_multiplayer_authority(name.to_int())
	
	if multiplayer.get_unique_id() == name.to_int():
		$Camera2D.make_current()
	else:
		$Camera2D.enabled = false

func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		state_machine.process_physics(delta)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)

"""
Applies horizontal velocity to the player based on the direction and the time
delta. Also flips the sprite direction.
"""
func horizontal_movement(direction: float, delta: float) -> void:
	if direction:
		velocity.x = move_toward(velocity.x, speed * direction, acceleration * delta)
		if direction > 0:
			animations.flip_h = false
		elif direction < 0:
			animations.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
