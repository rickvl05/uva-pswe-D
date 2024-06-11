extends RigidBody2D

@export var held_by: CharacterBody2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if !multiplayer.is_server():
		freeze = true

func _process(delta):
	if multiplayer.is_server():
		if held_by != null:
			# Necessary to keep triggering integrate forces
			apply_central_force(Vector2(1,1))

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if multiplayer.is_server():
		if held_by != null:
			# Position has to be updated in this function otherwise it will interfere
			# with the physics simulation
			position = held_by.global_position + Vector2(0, -held_by.item_height)
