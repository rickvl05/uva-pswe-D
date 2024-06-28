"""
This file contains the death state of the player. Players are in this state
when they are killed.

State Flow:
	Death -> Spawn - When the player dies, they enter the death state. After
					 the death animation is finished, the player respawns and
					 enters the spawn state.
"""

extends State

@export var death_state: State
@export var spawn_state: State

var is_dying: bool = false

func enter() -> void:
	# Disable coyote timer and play animation and audio
	parent.coyote_timer = 0
	parent.animations.play("Death" + str(parent.color))
	GlobalAudioPlayer.initialize_SFX.rpc("death", parent.position, false)
	super()

func process_physics(_delta: float) -> State:
	parent.velocity = Vector2(0, 0)
	is_dying = true

	return null

func _on_animated_sprite_2d_animation_finished():
	if is_dying:
		is_dying = false
		parent.respawn()
		parent.state_machine.change_state(spawn_state)
