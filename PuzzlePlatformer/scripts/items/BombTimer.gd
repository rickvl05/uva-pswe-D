extends Timer

signal orange_depleted
signal red_depleted

var min_wait_time = 3
var total_time = 0
var elapsed_time = 0
var orange_time = 2
var red_time = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	print(wait_time)
	if wait_time == 0.69:
		stop()
	else:
		print("ik kom hier niet")
		var orange_time = floor(wait_time * 0.33)
		var red_time = floor(wait_time * 0.67)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	elapsed_time += delta
	if elapsed_time >= orange_time:
		orange_depleted.emit()
	if elapsed_time >= red_time:
		red_depleted.emit()


func _on_timebomb_explosiontime(time):
	wait_time = time
