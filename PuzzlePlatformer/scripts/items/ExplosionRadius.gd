extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_bomb_timer_timeout():
	for body in get_overlapping_bodies():
		if body.has_method("kill"):
			body.kill()
	queue_free()
