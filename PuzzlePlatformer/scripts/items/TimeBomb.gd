extends "res://script_templates/item.gd"

@onready var p1 = $YellowIgnitionParticles
@onready var p2 = $OrangeIgnitionParticles
@onready var p3 = $RedIgnitionParticles
@onready var explosion = $BombExplosion

@export var explosion_time: int = 15
@export var ignited: bool = false

var orange_time: float = 0
var red_time: float = 0
var exploded: bool = false
var countdown_begin: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()
	orange_time = explosion_time - explosion_time * 0.33
	red_time = explosion_time - explosion_time * 0.67


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	explosion.rotation = -rotation
	if ignited and not countdown_begin:
		ignite_bomb()
	if not exploded and ignited and countdown_begin:
		if $BombTimer.time_left <= orange_time:
			p2.emitting = true
		if $BombTimer.time_left <= red_time:
			p3.emitting = true

func _on_bomb_timer_timeout() -> void:
	exploded = true
	var children = get_children()
	for child in children:
		if child != explosion:
			child.queue_free()
	held_by = null
	explosion.emitting = true


func ignite_bomb() -> void:
	explosion.rotation_degrees = 0
	$BombTimer.start(explosion_time)
	countdown_begin = true
	p1.emitting = true

func _on_area_2d_body_entered(body) -> void:
	if body is Player:
		ignite.rpc()

@rpc("any_peer", "reliable", "call_local")
func ignite() -> void:
	ignited = true

# Called when item has been picked up by a player.
func been_picked_up() -> void:
	ignite.rpc()

func _on_bomb_explosion_finished() -> void:
	queue_free()