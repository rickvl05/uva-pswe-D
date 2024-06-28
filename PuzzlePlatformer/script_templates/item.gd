"""
This file containts the Item class, which is the base class for all items in
the game. It is a RigidBody2D node that can be picked up by a CharacterBody2D
node. The item is frozen on all clients except the host, which is responsible
for calculating the item physics. The other clients will only update the item's
position and rotation. When the item is held, it will follow the position of
the player that is holding it.
"""

class_name Item
extends RigidBody2D

var held_by: CharacterBody2D = null
var spawn_position = Vector2(0, 0)
var respawning = false
var particles = preload("res://scenes/items and objects/spawn_particles.tscn").instantiate()

"""
Freezes the item on all clients except the host. Also sets the spawn position
to the item's position when the item is created.
"""
func setup() -> void:
	add_child(particles)
	spawn_position = position
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	if !multiplayer.is_server():
		freeze = true

"""
Updates the item's position and rotation when it is held by a player. This has
to be done in the _integrate_forces function, because the item is a RigidBody2D
node and the position and rotation are calculated by the physics engine. This
means that updating the position and rotation outside of the _integrate_forces
function will interfere with the physics engine. Also sets the item's position
to the spawn position when the item is respawning.
"""
func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	if multiplayer.is_server():
		if held_by != null:
			position = held_by.global_position + Vector2(0, -held_by.item_height)
			rotation = 0

	if respawning:
		position = spawn_position
		particles.emitting = true
		linear_velocity = Vector2(0, 0)
		respawning = false

"""
Respawns an item.
"""
func respawn() -> void:
	respawning = true
