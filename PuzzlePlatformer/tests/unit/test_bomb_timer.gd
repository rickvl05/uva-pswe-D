extends GutTest

var Bomb = load('res://scripts/items/BombTimer.gd')
var bomb = null

func before_each():
	bomb = Bomb.new()
	
func test_initial_state():
	assert_eq(bomb.min_wait_time, 3)
	assert_eq(bomb.total_time, 0)
	assert_eq(bomb.elapsed_time, 0)
	assert_eq(bomb.orange_time, 2)
	assert_eq(bomb.red_time, 2)
	
func test_bomb_explosion():
	bomb._on_timebomb_explosiontime(2)
	
	assert_eq(bomb.wait_time, 2)
