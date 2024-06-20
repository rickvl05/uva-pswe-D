class_name Player
extends CharacterBody2D

## Determines the top speed of the player
@export var speed: float
## Determines the acceleration of the player when a movement key is pressed
@export var acceleration: float
## Determines the deceleration of the player when no movement key is pressed
@export var standard_deceleration: float
## Deceleration when a player has been thrown
@export var thrown_deceleration: float
## Determines the maximum player velocity
@export var max_velocity: float
## Determines the velocity added when jumping
@export var jump_velocity: float
## Determines the amount of time you have left to jump after leaving the floor
@export var coyote_time: float
## Determines the amount of time the jump buffer is active
@export var jump_buffer: float
## Determines the amount of force used for pushing rigidbody's upwards when
## they are on top of the player
@export var push_force: float
## Determines the amount of upward force when pushing objects. Useful for
## ensuring that items do not het stuck when pushing.
@export var upward_push: float
## Determines the threshold that decides whether upward push will be applied.
@export var upward_push_threshold: float
## Determines how high an item is held above the player
@export var item_height: float
## Determines horizontal throw strength
@export var horizontal_throw: float
## Determines vertical throw strength
@export var vertical_throw: float
## The initial spawn location of the player, should be set by new level
@export var spawn_point: Vector2 = Vector2(0, 0)
## Determines the death state
@export var death_state: State

# Child nodes
@onready var animations = $AnimatedSprite2D
@onready var hand1 = $Hand1
@onready var hand2 = $Hand2
@onready var state_machine = $StateMachine
@onready var raycast = $GrabRay
@onready var checkray = $CheckRay
@onready var helmet = $Helmet
@onready var collisionsquare = $CollisionSquare

# Local variables
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var deceleration: float
var coyote_timer: float = 0
var is_in_door: bool = false

# Multiplayer variables
var color = 1:
	set(new_color):
		color = new_color
var held_item = null:
	set(new_held_item):
		held_item = new_held_item
var held_by = null:
	set(new_held_by):
		held_by = new_held_by
var copied_colliders = []

func _ready() -> void:
	# Initialize the state machine, passing a reference of the player to the states,
	# that way they can move and react accordingly
	state_machine.init(self)
	deceleration = standard_deceleration

	set_multiplayer_authority(name.to_int())
	if multiplayer.get_unique_id() == name.to_int():
		$Camera2D.make_current()
		helmet.set_collision_layer_value(6, true)
	else:
		$Camera2D.enabled = false
		helmet.set_collision_layer_value(7, true)

func _unhandled_input(event: InputEvent) -> void:
	# Disables input when paused
	if get_tree().root.get_node("Game").should_pause():
		return

	if is_multiplayer_authority():
		if Input.is_action_just_pressed("move_down") and is_in_door:
			is_in_door = false
			request_door_action.rpc_id(1, name, false)
			
		# Disable other keys when in door
		if is_in_door:
			return
		
		if Input.is_action_just_pressed("move_up") and not is_in_door:
			enter_door_action()
					
		grab_or_throw()

		# State specific inputs
		state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		velocity.y += gravity * delta
		
		# Set maximum velocity
		velocity.y = clamp(velocity.y, -max_velocity, max_velocity)
		velocity.x = clamp(velocity.x, -max_velocity, max_velocity)

		# State specific physics
		state_machine.process_physics(delta)

		apply_push_force()

func _process(delta: float) -> void:
	# State specific processes
	state_machine.process_frame(delta)


"""
Applies a push force to rigidbody's that have collided with the player. This
force consists of a horizontal part and a slight vertical part to circumvent
the friction with the ground. The force is only applied on the host to prevent
syncing issues.
"""
func apply_push_force() -> void:
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

"""
Applies horizontal velocity to the player based on the direction and the time
delta. Also flips the sprite and raycast direction. Used within player states
to enable movement.
"""
func horizontal_movement(direction: float, delta: float) -> void:
	# Disable movement when paused
	if get_tree().root.get_node("Game").should_pause():
		return

	if direction:
		change_direction(direction)
		velocity.x = move_toward(velocity.x, speed * direction, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)

"""
Flips the sprite and raycast direction. Input direction has to be either -1, 0
or 1. Does nothing is the input direction is 0 but accepts this value as it is
easier to work with this way.
"""
func change_direction(direction: float) -> void:
	assert(direction == -1 or direction == 0 or direction == 1)
	
	if direction == 0:
		return

	# Flip raycast direction if necessary
	if ((direction < 0 and raycast.target_position.y > 0) or
		(direction > 0 and raycast.target_position.y < 0)):
			raycast.target_position = -raycast.target_position

	# Flip sprite direction
	if direction > 0:
		animations.flip_h = false
		hand1.flip_h = false
		hand1.position.x = -abs(hand1.position.x)
		hand2.flip_h = false
	else:
		animations.flip_h = true
		hand1.flip_h = true
		hand1.position.x = abs(hand1.position.x)
		hand2.flip_h = true

"""
Action for entering and leaving a level door
"""
func enter_door_action():
	var door = get_tree().root.get_node("Game/Level/Leveldoor")
	var entered_bodies = door.get_overlapping_bodies()
	
	# Enter or leave door
	for body in entered_bodies:
		if body.is_in_group('Player') and body.name == str(multiplayer.get_unique_id()):
			body.is_in_door = true
			request_door_action.rpc_id(1, body.name, true)

@rpc("reliable", "authority", "call_local")
func request_door_action(source_name, enter_action = true):
	var door = get_tree().root.get_node("Game/Level/Leveldoor")
	door.entered_count = door.entered_count + (1 if enter_action else -1)
	
	update_player_door_state.rpc(source_name, enter_action)

@rpc("reliable", "any_peer", "call_local")
func update_player_door_state(source_name, enter_action = true):
	var player = get_tree().root.get_node("Game/Players/" + str(source_name))
	
	if enter_action:
		player.is_in_door = true
		player.visible = false
		player.collision_layer = 128
	else:
		player.is_in_door = false
		player.visible = true
		player.collision_layer = 18
		
func grab_or_throw() -> void:
	if Input.is_action_just_pressed('grab') and raycast.is_colliding() and held_item == null:
		var body = raycast.get_collider()
		
		# Determine height of item that gets picked up
		var height = 0
		var current_body = body
		while (current_body):
			height += 16 # Maximum item height
			# Rigidbody's don't have held items
			if current_body is RigidBody2D:
				break
			current_body = current_body.held_item
		
		# Update check raycast to item height
		checkray.target_position.x = height
		checkray.force_raycast_update()
		
		# Pickup item if not held and if there is space
		if body.held_by == null and not checkray.is_colliding():
			request_grab.rpc_id(1, body.name, name, body.get_class())
		else:
			GlobalAudioPlayer.initialize_SFX.rpc("deny", position, true)
	elif Input.is_action_just_pressed('throw') and held_item != null:
		throw()

@rpc("reliable", "any_peer", "call_local")
func request_grab(target_name, source_name, type) -> void:
	var source = get_tree().root.get_node("Game/Players/" + str(source_name))
	var target
	if type == "CharacterBody2D":
		target = get_tree().root.get_node("Game/Players/" + str(target_name))
		if source.held_by == target:
			return
	else:
		target = get_tree().root.get_node("Game/Level/" + str(target_name))


	if target.held_by == null:
		target.held_by = source
		grab.rpc_id(source_name.to_int(), target_name, type)


@rpc("reliable", "any_peer", "call_local")
func grab(target_name, type) -> void:
	GlobalAudioPlayer.initialize_SFX.rpc("grab", position, false)
	var target
	if type == "CharacterBody2D":
		target = get_tree().root.get_node("Game/Players/" + str(target_name))
		update_hold_status_characterbody.rpc(target.name, name)
	else:
		target = get_tree().root.get_node("Game/Level/" + str(target_name))
		update_hold_status_rigidbody.rpc(target.name, name)

	if held_item.has_method("been_picked_up"):
		held_item.been_picked_up()

	copy_colliders(target)

	# Update colliders for all players under the player
	var current_body = held_by
	while (current_body != null):
		copy_colliders_remote.rpc_id(held_by.name.to_int(), held_by.name, name)
		current_body = current_body.held_by
	
	# Enable hands
	hand1.visible = true
	hand2.visible = true

func throw() -> void:
	assert(held_item != null, "No held item available")

	var item_name = held_item.name

	if held_item.has_method("been_thrown_away"):
		held_item.been_thrown_away()
		

	free_copied_colliders(held_item)

	# Update colliders for all holders under the player
	var current_body = held_by
	while (current_body != null):
		free_copied_colliders_remote.rpc_id(held_by.name.to_int(), held_by.name, name)
		current_body = current_body.held_by

	# Determine throw direction
	var direction = raycast.target_position.normalized()
	var vector = Vector2(-direction.y * horizontal_throw, vertical_throw)
	if Input.is_action_pressed('move_down'):
		vector = Vector2(0, 0)
	elif Input.is_action_pressed('move_up'):
		vector = Vector2(0, horizontal_throw)
	
	# Update hold statuses on all clients and apply throw force
	if held_item is CharacterBody2D:
		update_hold_status_characterbody.rpc(item_name, name)
		apply_velocity.rpc_id(item_name.to_int(), item_name, vector)
	else:
		update_hold_status_rigidbody.rpc(item_name, name)
		apply_impulse.rpc_id(1, item_name, vector)

	# Disable hands
	hand1.visible = false
	hand2.visible = false
	GlobalAudioPlayer.initialize_SFX.rpc("throw", position, false)

@rpc("reliable", "any_peer", "call_local")
func apply_impulse(target_name, normal):
	var target: RigidBody2D
	target = get_tree().root.get_node("Game/Level/" + str(target_name))
	if target:
		target.apply_central_impulse(-normal)

@rpc("reliable", "any_peer", "call_local")
func apply_velocity(target_name, normal):
	var target: CharacterBody2D
	target = get_tree().root.get_node("Game/Players/" + str(target_name))
	if target:
		target.velocity = -normal

@rpc("reliable", "any_peer", "call_local")
func update_hold_status_rigidbody(body_name, player_name):
	var body = get_tree().root.get_node("Game/Level/" + str(body_name))
	var player = get_tree().root.get_node("Game/Players/" + str(player_name))

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
	var body = get_tree().root.get_node("Game/Players/" + str(body_name))
	var player = get_tree().root.get_node("Game/Players/" + str(player_name))

	if player.held_item == null:
		player.held_item = body
		body.held_by = player
	else:
		player.held_item = null
		body.held_by = null

@rpc("reliable", "any_peer", "call_local")
func copy_colliders_remote(target_name, source_name):
	var target = get_tree().root.get_node("Game/Players/" + str(target_name))
	var source = get_tree().root.get_node("Game/Players/" + str(source_name))

	target.copy_colliders(source.held_item)

@rpc("reliable", "any_peer", "call_local")
func free_copied_colliders_remote(target_name, source_name):
	var target = get_tree().root.get_node("Game/Players/" + str(target_name))
	var source = get_tree().root.get_node("Game/Players/" + str(source_name))

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
			# Disable helmet
			if child is StaticBody2D:
				child.get_node("CollisionShape2D").disabled = true
			# Disable player collider
			if child is CollisionShape2D:
				# Copy collider of grabbed body
				var collider = child.duplicate()
				var shape = child.shape.duplicate()
				collider.shape = shape
				add_child(collider)

				# Match character hitbox width
				if collider.shape is RectangleShape2D:
					shape.extents.x = collisionsquare.shape.extents.x
				elif collider.shape is CircleShape2D:
					shape.radius = collisionsquare.shape.extents.x

				collider.position = Vector2(0, collider.position.y + -item_height * offset)
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
			# Enable helmet
			if child is StaticBody2D:
				child.get_node("CollisionShape2D").disabled = false
			# Enable player collider
			if child is CollisionShape2D:
				child.disabled = false

		var collider = copied_colliders.pop_back()
		if collider:
			collider.queue_free()

		if current_body is CharacterBody2D:
			current_body = current_body.held_item
		else:
			current_body = null


func set_checkpoint(new_spawnpoint: Vector2):
	spawn_point = new_spawnpoint

func respawn() -> void:
	position = spawn_point

func kill():
	# Method for handling when a player goes out of bounds
	# or dies.
	if held_item != null:
		throw()
	state_machine.change_state(death_state)

func get_settable_attributes() -> Dictionary:
	return {
		"color": color,
		"held_item": held_item,
		"held_by": held_by
	}
