extends State

@export var death_state: State
@export var spawn_state: State

var is_dying: bool = false

# Inherit state properties
func enter() -> void:
	parent.coyote_timer = 0
	parent.animations.play("Death" + str(parent.color))
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
