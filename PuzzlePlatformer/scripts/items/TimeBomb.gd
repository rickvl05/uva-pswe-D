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
	disable_emission()
	$CollisionShape2D.disabled = true
	$Sprite2D.visible = false
	held_by = null
	GlobalAudioPlayer.initialize_SFX.rpc("explosion", position, false, 2000, 5)
	explosion.emitting = true


func ignite_bomb() -> void:
	explosion.rotation_degrees = 0
	$BombTimer.start(explosion_time)
	countdown_begin = true
	p1.emitting = true


@rpc("any_peer", "reliable", "call_local")
func ignite() -> void:
	ignited = true

@rpc("any_peer", "reliable", "call_local")
func unignite() -> void:
	ignited = false

func _on_area_2d_body_entered(body) -> void:
	if body is Player:
		ignite.rpc()

# Called when item has been picked up by a player.
func been_picked_up() -> void:
	ignite.rpc()

func disable_emission() -> void:
	p1.emitting = false
	p2.emitting = false
	p3.emitting = false
	
func enable_bomb(enable: bool) -> void:
	$CollisionShape2D.disabled = not enable
	$Sprite2D.visible = enable

func respawn() -> void:
	super()
	$BombTimer.stop()
	disable_emission()
	unignite.rpc()
	countdown_begin = false
	exploded = false
	enable_bomb(true)

func _on_bomb_explosion_finished() -> void:
	unignite.rpc()
	countdown_begin = false
	exploded = false
	enable_bomb(false)
	respawn()
