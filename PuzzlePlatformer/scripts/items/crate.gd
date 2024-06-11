extends RigidBody2D

@export var bounce_strength = 500


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_bouncepad_body_entered(body):
	if body is Player:
		body.velocity.y = -bounce_strength
