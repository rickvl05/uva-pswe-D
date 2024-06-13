"""
This file is the 'back-end' of the item_template.gd file.
"""

extends RigidBody2D

@export var held_by: CharacterBody2D = null

# Called at the beginning of the item template. Used for throwing mechanics.
func setup() -> void:
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	if !multiplayer.is_server():
		freeze = true

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if multiplayer.is_server():
		if held_by != null:
			# Position has to be updated in this function otherwise it will interfere
			# with the physics simulation
			position = held_by.global_position + Vector2(0, -held_by.item_height)
			rotation = 0
