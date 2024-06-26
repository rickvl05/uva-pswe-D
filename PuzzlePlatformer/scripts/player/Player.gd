"""
This file contains the player class. The player class is responsible for
handling the player's movement, jumping, grabbing and throwing. Player movement
and states are only calculated on the client controlling the player, the
position and animations are then synced to the other clients.

-------------------------------------------------------------------------------
Grab / Throw information:
-------------------------------------------------------------------------------
When a player grabs an item, the player will copy the colliders of the grabbed
item and attach them to the player. This is done to ensure that the player
collides with the environment as if the player is holding the item. These
colliders are only copied on client side and are not synced to the other
clients. When the player throws the item, the colliders are removed and the
item is thrown with a certain force. The force is only applied on the host for
items and on the authorative client if it is a player. This is done to prevent
syncing issues.

Issues when throwing or grabbing while being held by another player are
resolved by updating colliders of all players under the player. This is done by
sending a message to all players in the chain to update their colliders.

Grabbing an object is done by sending a request to the host to grab the object.
The host will then check if the object is not held by another player, if the
object is not held by another player, the host will send a message to the
requesting client to grab the object. This is done to prevent race conditions
when multiple players try to grab the same object.

The tracking of held items is done in the scripts of the held items. For
rigidbody's this is only done on the host and for players this is only done on
their authorative client. This is done to prevent syncing issues.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
Helmet information:
-------------------------------------------------------------------------------
The helmet is a staticbody on top of the player that only get detected by other
players and rigidbody's. This is done to allow horizontal movement when a
player or rigidbody is on top of the player. Without the helmet players are
stuck when another player or rigidbody is on top of the player.
-------------------------------------------------------------------------------
"""

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
@onready var state_machine = $StateMachine
@onready var animations = $AnimatedSprite2D
@onready var hand1 = $Hand1
@onready var hand2 = $Hand2
@onready var raycast = $GrabRay
@onready var checkray = $CheckRay
@onready var interact_area = $InteractArea
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


"""
Initializes the player. Sets the deceleration to the standard deceleration and
sets the multiplayer authority. If the player is the multiplayer authority, the
camera is set to the current camera and the helmet is set to the correct
collision layer. If the player is not the multiplayer authority, the camera is
disabled and the helmet is set to the correct collision layer.
"""
func _ready() -> void:
	state_machine.init(self)
	deceleration = standard_deceleration

	set_multiplayer_authority(name.to_int())
	if multiplayer.get_unique_id() == name.to_int():
		$Camera2D.make_current()
		helmet.set_collision_layer_value(6, true)
	else:
		$Camera2D.enabled = false
		helmet.set_collision_layer_value(7, true)

"""
Handles the player's input. The input is only handled when the player is not
paused. The input is then passed to the state machine to handle the input
according to the current state.
"""
func _unhandled_input(event: InputEvent) -> void:
	# Disables input when paused
	if get_tree().root.get_node("Game").should_pause():
		return

	if is_multiplayer_authority():
		# State specific inputs
		state_machine.process_input(event)

"""
Handles the player's physics. The physics are only handled when the player is
the multiplayer authority of the player. First the gravity is applied to the
player's velocity, then the maximum velocity is set. Then the state specific
physics are applied. Finally the push force is applied to rigidbody's that have
collided with the player.
"""
func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		velocity.y += gravity * delta

		# Set maximum velocity
		velocity.y = clamp(velocity.y, -max_velocity, max_velocity)
		velocity.x = clamp(velocity.x, -max_velocity, max_velocity)

		# State specific physics
		state_machine.process_physics(delta)

		apply_push_force()

"""
Handles the player's frame processes. Has no general functionality but is used
to call the state specific frame processes.
"""
func _process(delta: float) -> void:
	# State specific processes
	state_machine.process_frame(delta)

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
Applies force to a rigidbody. The force is applied in the opposite direction of
the normal vector. This should only be called on the host to prevent syncing
issues.
"""
@rpc("reliable", "any_peer", "call_local")
func apply_impulse(target_name, normal):
	var target: RigidBody2D
	target = get_tree().root.get_node("Game/Level/" + str(target_name))
	if target:
		target.apply_central_impulse(-normal)

"""
Applies force to a characterboidy. The force is applied in the opposite
direction of the normal vector. This should only be called on the authorative
client to prevent syncing issues.
"""
@rpc("reliable", "any_peer", "call_local")
func apply_velocity(target_name, normal):
	var target: CharacterBody2D
	target = get_tree().root.get_node("Game/Players/" + str(target_name))
	if target:
		target.velocity = -normal


"""
Allows the player to enter or exit a door when the player is in the door's
interact area. The player can enter the door when the player is not in the door
and the player can exit the door when the player is in the door.
"""
func door_action() -> void:
	if Input.is_action_just_pressed("move_up") and not is_in_door and interact_area.has_overlapping_areas():
		var door = interact_area.get_overlapping_areas()[0]
		door.enter_door(self)
	elif Input.is_action_just_pressed("move_down") and is_in_door and interact_area.has_overlapping_areas():
		var door = interact_area.get_overlapping_areas()[0]
		door.exit_door(self)

"""
Allows the player to grab or throw an item. The player can grab an item when the
player is not holding an item and the player can throw an item when the player
is holding an item. The player can only grab an item when there is enough space
to hold the item.
"""
func grab_or_throw() -> void:
	if Input.is_action_just_pressed('grab') and raycast.is_colliding() and held_item == null:
		var body = raycast.get_collider(0)

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
			GlobalAudioPlayer.initialize_SFX("deny", position, true)
	elif Input.is_action_just_pressed('throw') and held_item != null:
		throw(false)


"""
Sends a request to the host to grab an item. The host will then check if the
item is not held by another player. Also checks whenever a player is being
grabbed that the grabbing player is not being held by the grabbed player. Sends
a message to the grabbing player to grab the item if all checks pass.
"""
@rpc("reliable", "any_peer", "call_local")
func request_grab(target_name, source_name, type) -> void:
	var source = get_tree().root.get_node("Game/Players/" + str(source_name))
	var target
	if type == "CharacterBody2D":
		target = get_tree().root.get_node("Game/Players/" + str(target_name))

		# Check if the player that is being grabbed holds the grabbing player
		if source.held_by == target:
			return
	else:
		target = get_tree().root.get_node("Game/Level/" + str(target_name))


	if target.held_by == null:
		target.held_by = source
		grab.rpc_id(source_name.to_int(), target_name, type)

"""
Grabs an item. The colliders of the grabbed item are copied and attached to the
player and the original colliders are disabled, this is only done on the client.
This is done to ensure that the player collides with the environment as if the
player is holding the item. If the grabbing player is being held by another
player the colliders of all players in the chain are updated. The hand
visibility is also updated.
"""
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
	while (current_body):
		copy_colliders_remote.rpc_id(current_body.name.to_int(), current_body.name, name)
		current_body = current_body.held_by

	# Enable hands
	hand1.visible = true
	hand2.visible = true


"""
Throws an item. The copied colliders are removed and the original colliders are
enabled. If the throwing player is being held by another player the colliders
of all players in the chain are updated. The item is then thrown in the
direction of the raycast. Forces are only applied on the host if it is a
rigidbody or the authorative client if it is a player. The hand visibility is
also updated.

If the dropped flag is set to true, the item is dropped instead of thrown.
Otherwise the item is thrown.
"""
func throw(drop_flag: bool) -> void:
	assert(held_item != null, "No held item available")

	var item_name = held_item.name

	# Apply item specific throw logic
	if held_item.has_method("been_thrown_away"):
		held_item.been_thrown_away()

	free_copied_colliders(held_item)

	# Update colliders for all holders under the player
	var current_body = held_by
	while (current_body):
		free_copied_colliders_remote.rpc_id(current_body.name.to_int(), current_body.name, name)
		current_body = current_body.held_by

	# Determine throw direction
	var direction = raycast.target_position.normalized()
	var vector = Vector2(-direction.y * horizontal_throw, vertical_throw)
	if Input.is_action_pressed('move_down') or drop_flag:
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

"""
Copies all colliders start from start_body and above and attaches them to the
player. This is done to ensure that the player collides with the environment as
if the player is holding the item. If the grabbed item is a player the
colliders of all players and/or items that that player is holding are copied as
well. Also disables the original colliders of the grabbed item. This is only
done on the client. The copied colliders are stored in the copied_colliders
list to be removed when the item is thrown.
"""
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
				var collider: CollisionShape2D = child.duplicate()
				var shape = child.shape.duplicate()
				add_child(collider)

				# Match character hitbox width
				collider.shape = shape
				if collider.shape is RectangleShape2D:
					shape.extents.x = collisionsquare.shape.extents.x
				elif collider.shape is CircleShape2D:
					shape.radius = collisionsquare.shape.extents.x

				collider.position = Vector2(0, collider.position.y + -item_height * offset)
				collider.rotation = 0

				# Store references to body and collider
				copied_colliders.append(collider)

				# Disable collider of body
				child.disabled = true

		offset += 1

		if current_body is CharacterBody2D:
			current_body = current_body.held_item
		else:
			current_body = null

"""
Frees all copied colliders starting from thrown item and above. Also enables
their original colliders. This is only done on the client.
"""
func free_copied_colliders(thrown_item):
	var current_body = thrown_item
	while (current_body != null):
		var collider = copied_colliders.pop_back()
		collider.disabled = true
		collider.queue_free()

		for child in current_body.get_children():
			# Enable helmet
			if child is StaticBody2D:
				child.get_node("CollisionShape2D").disabled = false
			# Enable player collider
			if child is CollisionShape2D:
				child.disabled = false

		if current_body is CharacterBody2D:
			current_body = current_body.held_item
		else:
			current_body = null

"""
Remote version of the copy colliders function. This function is called to copy
colliders on the players that are holding the player.
"""
@rpc("reliable", "any_peer", "call_local")
func copy_colliders_remote(target_name, source_name):
	var target = get_tree().root.get_node("Game/Players/" + str(target_name))
	var source = get_tree().root.get_node("Game/Players/" + str(source_name))

	target.copy_colliders(source.held_item)

"""
Remote version of the free copied colliders function. This function is called
to free colliders on the players that are holding the player.
"""
@rpc("reliable", "any_peer", "call_local")
func free_copied_colliders_remote(target_name, source_name):
	var target = get_tree().root.get_node("Game/Players/" + str(target_name))
	var source = get_tree().root.get_node("Game/Players/" + str(source_name))

	target.free_copied_colliders(source.held_item)

"""
Updates the hold status of a rigidbody, this should be called on the host and
all clients. If the player is not holding an item, the player will hold the
rigidbody and the rigidbody will be held by the player. The rigidbody will also
be frozen to prevent physics issues. If the player is holding an item, the
player and the rigidbody held statuses will be set to null. The rigidbody will
also be unfrozen on the host.

(Rigidbody's are frozen on all clients so they don't calculate physics. This
ensures that the host is the only one calculating physics for the rigidbody.
This is done to prevent syncing issues.)
"""
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

"""
Updates the hold status of a characterbody, this should be called on the host
and all clients. If the player is not holding an item, the player will hold the
characterbody and the characterbody will be held by the player. If the player
is holding an item, the player and the characterbody held statuses will be set
to null.
"""
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

"""
Sets the player spawn point to a new spawn point.
"""
func set_checkpoint(new_spawnpoint: Vector2):
	spawn_point = new_spawnpoint

"""
Sets the player's position to the spawn point.
"""
func respawn() -> void:
	global_position = spawn_point

"""
Kills the player by changing the state to the death state. Also drops the held
item if the player is holding an item.
"""
func kill():
	# Method for handling when a player goes out of bounds or dies.
	if is_multiplayer_authority():
		if held_item:
			throw(true)
		state_machine.change_state(death_state)

func get_settable_attributes() -> Dictionary:
	return {
		"color": color,
		"held_item": held_item,
		"held_by": held_by
	}
