extends RigidBody2D

@onready var p1 = $YellowIgnitionParticles
@onready var p2 = $OrangeIgnitionParticles
@onready var p3 = $RedIgnitionParticles
@onready var explosion = $BombExplosion

@export var explosion_time = 15

signal moving

var held_by: CharacterBody2D = null
var orange_time: float = 0
var red_time: float = 0
var exploded: bool = false
var ignited: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	orange_time = explosion_time - explosion_time * 0.33
	red_time = explosion_time - explosion_time * 0.67
	
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	if !multiplayer.is_server():
		freeze = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	explosion.rotation = -rotation
	if not exploded and ignited:
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
	held_by = null
	explosion.emitting = true

func _on_bomb_explosion_finished():
	queue_free()

func ignite_bomb():
	if not ignited:
		explosion.rotation_degrees = 0
		$BombTimer.start(explosion_time)
		ignited = true
		p1.emitting = true

func _on_area_2d_body_entered(body):
	if body is Player:
		ignite_bomb()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if multiplayer.is_server():
		if held_by != null:
			# Position has to be updated in this function otherwise it will interfere
			# with the physics simulation
			position = held_by.global_position + Vector2(0, -held_by.item_height)
			rotation = 0
			ignite_bomb()
