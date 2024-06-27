extends GutTest

var game = null

func before_each():
	game = load("res://scripts/game.gd").new()
	
func test_initial_state():
	assert_eq(game.paused, false)
	assert_eq(game.number_players_loaded, 0)
	assert_eq(game.current_level_number, 0)
	
func test_should_pause():
	assert_eq(game.should_pause(), false)
