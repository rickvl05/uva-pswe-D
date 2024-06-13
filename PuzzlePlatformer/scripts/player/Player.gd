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

var held_item = null
var held_by = null
var copied_colliders = []

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
	# Disables input when paused
	if get_tree().root.get_node("Game").paused:
		return

	if is_multiplayer_authority():
		# Grab or throw
		if Input.is_action_just_pressed('grab') and raycast.is_colliding() and held_item == null:
			var body = raycast.get_collider()
			if body.held_by == null:
				request_grab.rpc_id(1, body.name, name, body.get_class())
		elif Input.is_action_just_pressed('throw') and held_item != null:
			throw()

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
	# Disable movement when paused
	if get_tree().root.get_node("Game").paused:
		return

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
	if direction == 0:
		return
	
	# Flip raycast direction if necessary
	if ((direction < 0 and raycast.target_position.y > 0) or
		(direction > 0 and raycast.target_position.y < 0)):
			raycast.target_position = -raycast.target_position

	# Flip sprite direction
	if direction > 0:
		animations.flip_h = false
	else:
		animations.flip_h = true

@rpc("reliable", "any_peer", "call_local")
func request_grab(target_name, source_name, type) -> void:
	var target
	if type == "CharacterBody2D":
		target = get_tree().root.get_node("Game").get_node("Players").get_node(str(target_name))
	else:
		target = get_tree().root.get_node("Game").get_node(str(target_name))
	var source = get_tree().root.get_node("Game").get_node("Players").get_node(str(source_name))
	
	if target.held_by == null:
		target.held_by = source
		grab.rpc_id(source_name.to_int(), target_name, type)
		

@rpc("reliable", "any_peer", "call_local")
func grab(target_name, type) -> void:
	var target
	if type == "CharacterBody2D":
		target = get_tree().root.get_node("Game").get_node("Players").get_node(str(target_name))
		update_hold_status_characterbody.rpc(target.name, name)
	else: 
		target = get_tree().root.get_node("Game").get_node(str(target_name))
		update_hold_status_rigidbody.rpc(target.name, name)
	
	if held_item.has_method("been_picked_up"):
		held_item.been_picked_up()
	
	copy_colliders(target)
	
	# Update colliders for all players under the player
	var current_body = held_by
	while (current_body != null):
		copy_colliders_remote.rpc_id(held_by.name.to_int(), held_by.name, name)
		current_body = current_body.held_by

func throw() -> void:
	var item_name = held_item.name
	
	if held_item.has_method("been_thrown_away"):
		held_item.been_thrown_away()
	
	free_copied_colliders(held_item)

	# Update colliders for all holders under the player
	var current_body = held_by
	while (current_body != null):
		free_copied_colliders_remote.rpc_id(held_by.name.to_int(), held_by.name, name)
		current_body = current_body.held_by

	# Update hold statuses on all clients and apply throw force
	var direction = raycast.target_position.normalized()
	if held_item is CharacterBody2D:
		update_hold_status_characterbody.rpc(item_name, name)
		apply_velocity.rpc_id(item_name.to_int(), item_name, Vector2(-direction.y * horizontal_throw, vertical_throw))
	else:
		update_hold_status_rigidbody.rpc(item_name, name)
		apply_impulse.rpc_id(1, item_name, Vector2(-direction.y * horizontal_throw, vertical_throw))

@rpc("reliable", "any_peer", "call_local")
func apply_impulse(target_name, normal):
	var target: RigidBody2D = get_tree().root.get_node("Game").get_node(str(target_name))
	target.apply_central_impulse(-normal)

@rpc("reliable", "any_peer", "call_local")
func apply_velocity(target_name, normal):
	var target: CharacterBody2D = get_tree().root.get_node("Game").get_node("Players").get_node(str(target_name))
	target.velocity = -normal
	
@rpc("reliable", "any_peer", "call_local")
func update_hold_status_rigidbody(body_name, player_name):
	var body = get_tree().root.get_node("Game").get_node(str(body_name))
	var player = get_tree().root.get_node("Game").get_node("Players").get_node(str(player_name))

	if player.held_item == null:
		player.held_item = body
		body.held_by = player
		body.freeze = true
	else:
		player.held_item = null
		body.held_by = null
		if multiplayer.is_server():
			body.freeze = false

@rpc("reliable", "any_peer", "call_local")
func update_hold_status_characterbody(body_name, player_name):
	var body = get_tree().root.get_node("Game").get_node("Players").get_node(str(body_name))
	var player = get_tree().root.get_node("Game").get_node("Players").get_node(str(player_name))

	if player.held_item == null:
		player.held_item = body
		body.held_by = player
	else:
		player.held_item = null
		body.held_by = null

@rpc("reliable", "any_peer", "call_local")
func copy_colliders_remote(target_name, source_name):
	var target = get_tree().root.get_node("Game").get_node("Players").get_node(str(target_name))
	var source = get_tree().root.get_node("Game").get_node("Players").get_node(str(source_name))
	
	target.copy_colliders(source.held_item)

@rpc("reliable", "any_peer", "call_local")
func free_copied_colliders_remote(target_name, source_name):
	var target = get_tree().root.get_node("Game").get_node("Players").get_node(str(target_name))
	var source = get_tree().root.get_node("Game").get_node("Players").get_node(str(source_name))

	target.free_copied_colliders(source.held_item)

func copy_colliders(start_body) -> void:
	# Calculate at which offset the copied colliders should start
	var offset = 0
	var current_body = self

	while (current_body != start_body):
		offset += 1
		current_body = current_body.held_item
	
	# Loop through held items of held item
	current_body = start_body
	while (current_body != null):
		for child in current_body.get_children():
			if child is CollisionShape2D:
				# Copy collider of grabbed body
				var collider = child.duplicate()
				add_child(collider)
				collider.position = Vector2(0, -item_height * offset)
				collider.rotation = 0

				# Disable collider of body
				child.disabled = true

				# Store references to body and collider
				copied_colliders.append(collider)

		offset += 1
		
		if current_body is CharacterBody2D:
			current_body = current_body.held_item
		else:
			current_body = null

func free_copied_colliders(thrown_item):
	var current_body = thrown_item
	while (current_body != null):
		for child in current_body.get_children():
			if child is CollisionShape2D:
				child.disabled = false
				
		var collider = copied_colliders.pop_back()
		collider.queue_free()

		if current_body is CharacterBody2D:
			current_body = current_body.held_item
		else:
			current_body = null

func kill():
	# Method for handling when a player goes out of bounds
	# or dies.
	if held_item:
		throw()
	print("I am dead!")
