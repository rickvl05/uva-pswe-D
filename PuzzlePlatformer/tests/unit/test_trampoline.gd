extends GutTest

var Trampoline = load('res://scenes/items and objects/trampoline.tscn')
var trampoline = null

func before_each():
	trampoline = Trampoline.instantiate()
	
func after_each():
	trampoline.queue_free()
	
func test_initial_state():
	assert_eq(trampoline.bounce_strength, 500)
	assert_eq(trampoline.picked_up, false)
	
func test_been_picked_up():
	trampoline.been_picked_up()
	
	assert_eq(trampoline.picked_up, true)
	
func test_invalid_jump():
	assert_eq(trampoline.determine_valid_jump(true, null), false)
