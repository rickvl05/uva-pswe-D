extends GutTest

var player: Player = null
var sender = null

func before_each():
	get_tree().root.add_child(load("res://scenes/menus/main_menu.tscn").instantiate())
	MultiplayerManager.host_game()
	player = get_tree().get_nodes_in_group("Player")[0]
	sender = InputSender.new(player)
	
func after_each():
	sender.release_all()
	sender.clear()
	
func test_initial_state():
	assert_eq(player.coyote_timer, 0.0)
	assert_eq(player.is_in_door, false)
	assert_eq(player.gravity, int(ProjectSettings.get_setting("physics/2d/default_gravity")))
	assert_eq(player.held_by, null)
	assert_eq(player.held_item, null)
	assert_eq(player.color, 1)
	assert_eq(player.copied_colliders, [])
	
func test_set_checkpoint():
	var spawn_point = Vector2(5, 5)
	player.set_checkpoint(spawn_point)
	
	assert_eq(player.spawn_point, spawn_point)

func test_respawn():
	var spawn_point = Vector2(41, 100)
	player.set_checkpoint(spawn_point)
	player.respawn()
	
	assert_eq(player.global_position, spawn_point)

func test_move_right():
	var old_pos = player.position.x
	sender.action_down("move_right").hold_for('5f')
	await(sender.idle)
	
	assert_gt(player.position.x, old_pos)
	
func test_move_left():
	var old_pos = player.position.x
	sender.action_down("move_left").hold_for('5f')
	await(sender.idle)
	
	assert_lt(player.position.x, old_pos)
