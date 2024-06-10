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
## Determines the amount of force used when pushing items
@export var push_force: float
## Determines the amount of upward force when pushing objects. Useful for
## ensuring that items do not het stuck when pushing.
@export var upward_push: float
## Determines the threshold that decides whether upward push will be applied.
@export var upward_push_threshold: float
## Determines the amount of time you have left to jump after leaving the floor
@export var coyote_time: float
## Determines the amount of time the jump buffer is active
@export var jump_buffer: float

@onready var animations = $AnimatedSprite2D
@onready var state_machine = $StateMachine

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
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
		# Apply gravity
		velocity.y += gravity * delta

		# Apply state specific physics and state transitions
		state_machine.process_physics(delta)
		move_and_slide()

		# Apply push force to rigid body's
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			if c.get_collider() is RigidBody2D:
				var normal = c.get_normal() * push_force

				# Apply upward force when the vertical force is lower than the
				# threshold. Ensures that rigid body's don't get stuck on terrain
				# and don't get stuck in a collision box.
				if abs(normal.y) < upward_push_threshold * push_force:
					normal.y = upward_push

				c.get_collider().apply_central_impulse(-normal)

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

func kill():
	# Method for handling when a player goes out of bounds
	# or dies.
	print("I am dead!")
