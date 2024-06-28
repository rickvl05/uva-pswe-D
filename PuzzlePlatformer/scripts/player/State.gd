class_name State
extends Node
"""
This file contains the State class, which is a base class for all states in the
game. It contains the basic structure for a state, and the methods that all
states should have.
"""


@export var animation_name: String
var parent: Player

func enter() -> void:
	# Player color specific animation when transitioning to a state
	var animation: String = animation_name
	if animation_name != "Spawn":
		animation = animation_name + str(parent.color)

	parent.animations.play(animation)

func exit() -> void:
	pass

func process_input(_event: InputEvent) -> State:
	return null

func process_frame(_delta: float) -> State:
	return null

func process_physics(_delta: float) -> State:
	return null
