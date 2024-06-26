extends GutTest

var manager = null

func before_each():
	get_tree().root.add_child(load("res://scenes/menus/main_menu.tscn").instantiate())
	manager = MultiplayerManager
	
func test_initial_state():
	assert_eq(manager.available_colors, [1,2,3,4])
	assert_eq(manager.player_count, 0)
	assert_eq(manager.GameScene, null)
	
func test_host_game():
	manager.host_game()
	
	assert_eq(manager.player_count, 1)
	
func test_join_game_error():
	assert_eq(manager.join_game(), 0)
