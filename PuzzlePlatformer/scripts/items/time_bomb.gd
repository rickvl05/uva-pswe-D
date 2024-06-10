extends RigidBody2D

@onready var p1 = $YellowIgnitionParticles
@onready var p2 = $OrangeIgnitionParticles
@onready var p3 = $RedIgnitionParticles
@onready var explosion = $BombExplosion

@export var explosion_time = 15

var orange_time = 0
var red_time = 0
var exploded = false

# Called when the node enters the scene tree for the first time.
func _ready():
	explosion.rotation_degrees = 0
	$BombTimer.start(explosion_time)
	p1.emitting = true
	orange_time = explosion_time - explosion_time * 0.33
	red_time = explosion_time - explosion_time * 0.67


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	explosion.rotation = -rotation
	if not exploded:
		if $BombTimer.time_left <= orange_time:
			p2.emitting = true
		if $BombTimer.time_left <= red_time:
			p3.emitting = true


func _on_bomb_timer_timeout():
	exploded = true
	var children = get_children()
	for child in children:
		if child != explosion:
			child.queue_free()
	explosion.emitting = true

func _on_bomb_explosion_finished():
	queue_free()
