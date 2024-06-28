extends GutTest

var finish = null

func before_each():
	finish = load("res://scripts/items/finish.gd").new()
	
func test_initial_state():
	assert_eq(finish.current_level_number, 0)
	assert_eq(finish.next_level_number, 0)
