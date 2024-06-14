extends Node2D

var can_place: bool = true
var is_panning: bool = false

@onready var level: Node = get_node("/root/main/World")
@onready var editor: Node2D = get_node("/root/main/cam_container")
@onready var editor_cam: Camera2D = editor.get_node("Camera2D")

@onready var tile_map: TileMap = get_node("/root/main/World/TileMap")
@onready var tab_container: TabContainer = get_node("/root/main/item_select/menu_tab") # Adjust this path to your TabContainer node

@export var cam_spd: int = 100
@export var max_zoom: float = 2.0
@export var min_zoom: float = 0.5
@export var current_item: PackedScene = null
@export var current_rect: TextureRect = null
@export var current_tile_id: Vector2i
@export var IsTile: bool

signal move_editor_finished

enum NavigationMode { NAVIGATE_TABS, NAVIGATE_ITEMS }
var navigation_mode = NavigationMode.NAVIGATE_TABS
var current_item_index = 0
var previous_item = null

func _ready() -> void:
	print("level=", level)
	editor_cam.make_current()
	pass

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	
	if !Global.playing:
		handle_editor(global_position)
	else:
		if Input.is_action_just_pressed("mb_right"):
			is_panning = true
		elif Input.is_action_just_released("mb_right"):
			is_panning = false

func handle_editor(global_position):
	if ( IsTile == false and can_place and Input.is_action_just_pressed("mb_left")):
		select_item(current_item)
	elif (IsTile == true and can_place and Input.is_action_just_pressed("mb_left")):
		select_tile(current_rect)
	pass

#func move_tab():
	#pass
	#if navigation_mode == NavigationMode.NAVIGATE_TABS:
		#navigate_tabs()
	#else:
		#navigate_items()

func select_item(item):
	if item and can_place:
		if item.has_method("get"):
			var scene = item.get("this_scene")
			if scene:
				current_item = scene  # Update the current_item here
				if Global.playing:
					var new_item: Node2D = scene.instantiate() as Node2D
					level.add_child(new_item)
					new_item.global_position = Vector2(0, 0) # Set a default position

func select_tile(tile):
	if tile and can_place:
		if tile.has_method("get"):
			var tile_id = tile.get("tile_id")
			current_tile_id = tile_id
			current_item = tile.get("this_scene")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			editor_cam.zoom -= Vector2(0.1, 0.1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			editor_cam.zoom += Vector2(0.1, 0.1)
		
		# Clamp the zoom level to be within min_zoom and max_zoom
		editor_cam.zoom.x = clamp(editor_cam.zoom.x, min_zoom, max_zoom)
		editor_cam.zoom.y = clamp(editor_cam.zoom.y, min_zoom, max_zoom)
	if event is InputEventMouseMotion:
		if is_panning:
			editor.global_position -= event.relative * editor_cam.zoom
