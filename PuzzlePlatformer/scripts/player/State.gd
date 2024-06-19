class_name State
extends Node

@export var animation_name: String
var parent: Player

func enter() -> void:
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
