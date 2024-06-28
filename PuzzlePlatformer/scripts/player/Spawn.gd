extends State
"""
This file contains the spawn state, which is the starting state for the player.
In this state players do not have control over their movement and are falling
from the sky.

The animation assigned to the spawn state is the egg falling animation which is
shared between all players as the color of the players is not yet determined
when a player is instantiated. At the time of the egg breaking animation this
is known and the player specific animation is played.

State Flow:
	Spawn -> Idle - When the egg breaking animation is finished and the player is on the floor.
	Spawn -> Held - When the egg breaking animation is finished and the player is grabbed.
"""


@export var idle_state: State
@export var held_state: State
@export var finish_animation: String

var timer = 0

# Inherit state properties
func enter() -> void:
	super()
	timer = 1

func exit() -> void:
	# Set correct hand color
	parent.hand1.play("Hand" + str(parent.color))
	parent.hand2.play("Hand" + str(parent.color))

func process_physics(delta: float) -> State:
	# Apply gravity
	parent.velocity.x = move_toward(parent.velocity.x, 0, parent.deceleration * delta)
	parent.move_and_slide()

	# Start egg breaking animation when held or on floor
	if parent.held_by and parent.animations.animation != finish_animation + str(parent.color):
		parent.animations.play(finish_animation + str(parent.color))
	elif parent.is_on_floor() and parent.animations.animation != finish_animation + str(parent.color):
		parent.animations.play(finish_animation + str(parent.color))

	# Decrease timer
	timer -= delta
	if timer <= 0:
		return idle_state

	return null


func _on_animated_sprite_2d_animation_finished():
	# Change state to held or idle when the egg breaking animation is finished
	if parent.held_by != null:
		parent.state_machine.change_state(held_state)
	elif parent.is_on_floor() or parent.velocity.y < 0:
		parent.state_machine.change_state(idle_state)
