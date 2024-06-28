extends GutTest

var Bomb = load('res://scenes/items and objects/time_bomb.tscn')
var bomb = null

func before_each():
	bomb = Bomb.instantiate()
	get_tree().root.add_child(bomb)
	
func after_each():
	bomb.queue_free()
	
func test_initial_state():
	assert_eq(bomb.explosion_time, 5)
	assert_eq(bomb.ignited, false)
	assert_eq(bomb.exploded, false)
	assert_eq(bomb.countdown_begin, false)
	
