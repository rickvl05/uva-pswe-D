extends GutTest

var Platform = load('res://scripts/items/platform.gd')
var platform = null

func before_each():
	platform = Platform.new()
	platform.players_needed = 2
	
func test_initial_state():
	assert_eq(platform.playercount, 0)
	assert_eq(platform.players_needed, 2)
