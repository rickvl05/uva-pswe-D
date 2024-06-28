extends GutTest

var item = null

func before_each():
	item = Item.new()
	
func test_initial_state():
	assert_eq(item.held_by, null)
	assert_eq(item.spawn_position, Vector2(0,0))
	assert_eq(item.respawning, false)

func test_respawn():
	item.respawn()
	
	assert_eq(item.respawning, true)
