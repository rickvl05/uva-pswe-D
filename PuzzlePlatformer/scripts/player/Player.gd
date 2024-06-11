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
## Determines how high an item is held above the player
@export var item_height: float
## Determines horizontal throw strength
@export var horizontal_throw: float
## Determines vertical throw strength
@export var vertical_throw: float

@onready var animations = $AnimatedSprite2D
@onready var state_machine = $StateMachine
@onready var raycast = $RayCast2D

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var coyote_timer: float = 0
var color = 1

var held_item: RigidBody2D = null
var copied_collider = null

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
	if is_multiplayer_authority():
		# Grab or throw
		if Input.is_action_just_pressed('grab') and raycast.is_colliding() and held_item == null:
			var body = raycast.get_collider()
			if body.held_by == null:
				grab_rigidbody(body)
		elif Input.is_action_just_pressed('throw') and held_item != null:
			throw_rigidbody()

		state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		velocity.y += gravity * delta

		# Apply state specific physics and state transitions
		state_machine.process_physics(delta)

		# Apply push force to rigid body's
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider() is RigidBody2D:
				var normal = collision.get_normal() * push_force

				# Apply upward force when the vertical force is lower than the
				# threshold. Ensures that rigid body's don't get stuck on terrain
				# and don't get stuck in a collision box.
				if abs(normal.y) < upward_push_threshold * push_force:
					normal.y = upward_push

				# Apply impulse vector on rigidbody on host
				apply_impulse.rpc_id(1, collision.get_collider().name, normal)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)

"""
Applies horizontal velocity to the player based on the direction and the time
delta. Also flips the sprite and raycast direction.
"""
func horizontal_movement(direction: float, delta: float) -> void:
	if direction:
		change_direction(direction)
		velocity.x = move_toward(velocity.x, speed * direction, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)

"""
Flips the sprite and raycast direction. Input direction has to be either -1 or
1.
"""
func change_direction(direction: float) -> void:
	# Flip raycast direction if necessary
	if ((direction < 0 and raycast.target_position.y > 0) or
		(direction > 0 and raycast.target_position.y < 0)):
			raycast.target_position = -raycast.target_position

	# Flip sprite direction
	if direction > 0:
		animations.flip_h = false
	else:
		animations.flip_h = true

func grab_rigidbody(body: RigidBody2D) -> void:
	held_item = body
	update_hold_status.rpc_id(1, held_item.name, name)
	
	for child in body.get_children():
		if child is CollisionShape2D:
			# Copy collider of grabbed body
			var collider = child.duplicate()
			add_child(collider)
			collider.position = Vector2(0, -item_height)
			collider.rotation = 0

			# Disable collider of body and lock rotation
			child.disabled = true
			held_item.lock_rotation = true

			# Store references to body and collider
			copied_collider = collider
			break

func throw_rigidbody() -> void:
	# Free the copied collider
	copied_collider.queue_free()
	copied_collider = null

	# Enable collider of body and unlock rotation
	held_item.lock_rotation = false
	for child in held_item.get_children():
		if child is CollisionShape2D:
			child.disabled = false

	update_hold_status.rpc_id(1, held_item.name, null)
	
	var direction = raycast.target_position.normalized()
	apply_impulse.rpc_id(1, held_item.name,
						 Vector2(-direction.y * horizontal_throw, vertical_throw))
	
	held_item = null

@rpc("reliable", "any_peer", "call_local")
func apply_impulse(target_name, normal):
	var target = get_tree().root.get_node("Game").get_node(str(target_name))
	target.apply_central_impulse(-normal)

@rpc("reliable", "any_peer", "call_local")
func update_hold_status(body_name, player_name):
	var body = get_tree().root.get_node("Game").get_node(str(body_name))
	var player = null

	body.freeze = false
	if player_name != null:
		body.freeze = true
		player = get_tree().root.get_node("Game").get_node("Players").get_node(str(player_name))
		
	body.held_by = player


func kill():
	# Method for handling when a player goes out of bounds
	# or dies.
	print("I am dead!")
