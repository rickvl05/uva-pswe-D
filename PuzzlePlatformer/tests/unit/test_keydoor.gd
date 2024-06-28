extends GutTest

var Door = load('res://scripts/items/keydoor.gd')
var door = null

func before_each():
	door = Door.new()
	
func test_initial_state():
	assert_eq(door.locked, true)
	assert_eq(door.next_level_number, 2)
	assert_eq(door.current_level_number, 0)
	assert_eq(door.entered_count, 0)
