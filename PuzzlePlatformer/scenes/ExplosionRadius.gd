extends Area2D

signal death_signal

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_bomb_timer_timeout():
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is Player:
			body.kill()
	queue_free()

func _on_death_signal():
	print("I am dead")
