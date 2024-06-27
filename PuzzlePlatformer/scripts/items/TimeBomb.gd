extends Item

# Get child nodes.
@onready var p1 = $YellowIgnitionParticles
@onready var p2 = $OrangeIgnitionParticles
@onready var p3 = $RedIgnitionParticles
@onready var explosion = $BombExplosion

# Exported variables for bomb properties.
@export var explosion_time: int = 15
@export var ignited: bool = false

# Internal state variables.
var orange_time: float = 0
var red_time: float = 0
var exploded: bool = false
var countdown_begin: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()
	orange_time = explosion_time - explosion_time * 0.33
	red_time = explosion_time - explosion_time * 0.67

# Called every frame. Updates the bomb state.
func _process(_delta: float) -> void:
	# Ensure the explosion particles always face upwards.
	explosion.rotation = -rotation

	# Start the bomb ignition process.
	if ignited and not countdown_begin:
		ignite_bomb()

	# Handle the particle emission based on the countdown.
	if not exploded and ignited and countdown_begin:
		if $BombTimer.time_left <= orange_time:
			p2.emitting = true
		if $BombTimer.time_left <= red_time:
			p3.emitting = true

"""
Does the necessary logic when the bomber countdown reaches zero.
"""
func _on_bomb_timer_timeout() -> void:
	exploded = true
	disable_emission()
	$CollisionShape2D.disabled = true
	$Sprite2D.visible = false
	held_by = null
	GlobalAudioPlayer.initialize_SFX.rpc("explosion", position, false, 2000, 5)
	explosion.emitting = true

"""
Start the bomb ignition proces.
"""
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

"""
Called when a body enters the bomb's area. 
Ignites the bomb if the body is a player
"""
func _on_area_2d_body_entered(body) -> void:
	if body is Player:
		ignite.rpc()

"""
Called when the bomb has been picked up by a player.
"""
func been_picked_up() -> void:
	ignite.rpc()

"""
Disables all the particles of the bomb.
"""
func disable_emission() -> void:
	p1.emitting = false
	p2.emitting = false
	p3.emitting = false
	
"""
Used for respawning. Makes the bomb itsself visible or invisible.
"""
func enable_bomb(enable: bool) -> void:
	$CollisionShape2D.disabled = not enable
	$Sprite2D.visible = enable

"""
Respawns the bomb and resets its state back to unignited.
"""
func respawn() -> void:
	super()
	$BombTimer.stop()
	disable_emission()
	unignite.rpc()
	countdown_begin = false
	exploded = false
	enable_bomb(true)

"""
Does the necessary logic when all of the explosion particles are gone.
Initialises the respawn of the bomb.
"""
func _on_bomb_explosion_finished() -> void:
	unignite.rpc()
	countdown_begin = false
	exploded = false
	enable_bomb(false)
	respawn()
