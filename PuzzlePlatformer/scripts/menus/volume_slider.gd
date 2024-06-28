extends HScrollBar

@export
var bus_name = "Master"
var bus_index: int

func _ready():
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
