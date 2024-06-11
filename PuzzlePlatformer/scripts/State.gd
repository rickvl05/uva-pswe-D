class_name State
extends Node

@export var animation_name: String
var parent: Player

func enter() -> void:
	var animation
	if animation_name != "spawn":
		animation = animation_name + str(parent.color)
	
	parent.animations.play(animation)

func exit() -> void:
	pass

func process_input(event: InputEvent) -> State:
	return null

func process_frame(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	return null
