extends Area2D

@onready var doorstatustext = $Doorstatus

var locked = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# when a key enters this body, change the status to unlocked
func _on_body_entered(body):
	if body.name == 'Key':
		# Change status
		doorstatustext.text = "unlocked"
		locked = false
		
		# Remove the key
		body.queue_free()
		
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
