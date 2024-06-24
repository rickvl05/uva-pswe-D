"""
This file is the 'back-end' of the item_template.gd file.
"""

class_name Item
extends RigidBody2D

var held_by: CharacterBody2D = null
var spawn_position = Vector2(0, 0)
var respawning = false
var particles = preload("res://scenes/items and objects/spawn_particles.tscn").instantiate()

# Called at the beginning of the item template. Used for throwing and respawn.
func setup() -> void:
	add_child(particles)
	spawn_position = position
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	if !multiplayer.is_server():
		freeze = true

func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	if multiplayer.is_server():
		if held_by != null:
			# Position has to be updated in this function otherwise it will interfere
			# with the physics simulation
			position = held_by.global_position + Vector2(0, -held_by.item_height)
			rotation = 0
	
	if respawning:
		position = spawn_position
		particles.emitting = true
		linear_velocity = Vector2(0, 0)
		respawning = false

func respawn() -> void:
	respawning = true
