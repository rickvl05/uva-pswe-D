extends Node2D

var can_place: bool = true
var is_panning: bool = false

@onready var level: Node = get_node("/root/main/World")
@onready var editor: Node2D = get_node("/root/main/cam_container")
@onready var editor_cam: Camera2D = editor.get_node("Camera2D")

@onready var tile_map: TileMap = get_node("/root/main/worldTileMap")
@onready var tab_container: TabContainer = get_node("/root/main/item_select/menu_tab") # Adjust this path to your TabContainer node

@export var cam_spd: int = 100
@export var max_zoom: float = 2.0
@export var min_zoom: float = 0.5
@export var current_item: PackedScene = null

enum NavigationMode { NAVIGATE_TABS, NAVIGATE_ITEMS }
var navigation_mode = NavigationMode.NAVIGATE_TABS
var current_item_index = 0
var previous_item = null

func _ready() -> void:
	print("level=",level)
	pass

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	
	if !Global.playing:
		move_tab()

func move_tab():
	if navigation_mode == NavigationMode.NAVIGATE_TABS:
		navigate_tabs()
	else:
		navigate_items()

func navigate_tabs():
	var tab_count = tab_container.get_tab_count()
	var current_tab = tab_container.current_tab

	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_left"):
		current_tab -= 1
	elif Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_right"):
		current_tab += 1

	current_tab = clamp(current_tab, 0, tab_count - 1)
	tab_container.current_tab = current_tab

	if Input.is_action_just_pressed("ui_accept"): # Assuming 'Enter' is mapped to 'ui_accept'
		navigation_mode = NavigationMode.NAVIGATE_ITEMS
		current_item_index = 0 # Reset item index when switching to item navigation
		highlight_item()

func navigate_items():
	var current_tab_index = tab_container.current_tab
	var current_vbox = tab_container.get_child(current_tab_index).get_node("ScrollContainer/VBoxContainer")
	var current_hbox = current_vbox.get_child(0) # Assuming there's only one HBoxContainer per tab
	var item_count = current_hbox.get_child_count()

	if Input.is_action_just_pressed("ui_right"):
		current_item_index += 1
		highlight_item()
	elif Input.is_action_just_pressed("ui_left"):
		if current_item_index > 0:
			current_item_index -= 1
		highlight_item()

	current_item_index = clamp(current_item_index, 0, item_count - 1)

	if Input.is_action_just_pressed("ui_accept"): # Assuming 'Enter' is mapped to 'ui_accept'
		var selected_item = current_hbox.get_child(current_item_index)
		select_item(selected_item)

	if Input.is_action_just_pressed("ui_cancel"): # Assuming 'Esc' is mapped to 'ui_cancel' for going back to tab navigation
		navigation_mode = NavigationMode.NAVIGATE_TABS
		remove_highlight()

func highlight_item():
	if previous_item:
		remove_highlight()
	var current_tab_index = tab_container.current_tab
	var current_vbox = tab_container.get_child(current_tab_index).get_node("ScrollContainer/VBoxContainer")
	var current_hbox = current_vbox.get_child(0) # Assuming there's only one HBoxContainer per tab
	var item = current_hbox.get_child(current_item_index)
	item.modulate = Color(1, 1, 0) # Highlight color
	previous_item = item

func remove_highlight():
	if previous_item:
		previous_item.modulate = Color(1, 1, 1) # Original color
		previous_item = null

func select_item(item):
	print("select item")
	if item and can_place:
		print("selected item ", item)
		print("can place: ", can_place)
		print("playing: ", Global.playing)
		if item.has_method("get"):
			var scene = item.get("this_scene")
			print("Scene is:", scene)
			if scene:
				current_item = scene  # Update the current_item here
				print("Updated current_item to: ", current_item)
				if Global.playing:
					var new_item: Node2D = scene.instantiate() as Node2D
					print(new_item)
					print(level)
					level.add_child(new_item)
					new_item.global_position = Vector2(0, 0) # Set a default position or any desired position

func place_tile():
	var mousepos = tile_map.world_to_map(get_global_mouse_position())
	tile_map.set_cell(0, Vector2i(mousepos.x, mousepos.y), Global.current_tile)

func remove_tile():
	var mousepos = tile_map.world_to_map(get_global_mouse_position())
	tile_map.set_cell(0, Vector2i(mousepos.x, mousepos.y), -1)
