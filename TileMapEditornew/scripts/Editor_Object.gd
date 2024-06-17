extends Node2D

var can_place: bool = true
var is_panning: bool = false
var is_dragging: bool = false
var item_held: bool = false

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
var drag_start_position: Vector2
var drag_end_position: Vector2

const DRAG_THRESHOLD = 10

func _ready() -> void:
	print("level=", level)
	editor_cam.make_current()
	pass

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	if !Global.playing:
		handle_editor(global_position)
	else:
		if Input.is_action_just_pressed("mb_left") and IsTile:
			print("hi at ", global_position)
			drag_start_position = global_position
		elif Input.is_action_just_released("mb_left") and IsTile:
			print("bye at ", global_position)
			drag_end_position = global_position
			if drag_start_position.distance_to(drag_end_position) > DRAG_THRESHOLD:
					is_dragging = false
					complete_drag()
			else:
				is_dragging = false
			#if item_held:  # Only place a single tile if no item is held
				#place_single_tile(global_position)
		elif Input.is_action_just_pressed("mb_right"):
			is_panning = true
		elif Input.is_action_just_released("mb_right"):
			is_panning = false

func handle_editor(global_position):
	if ( IsTile == false and can_place and Input.is_action_just_pressed("mb_left")):
		item_held == true
		select_item(current_item)
	elif (IsTile == true and can_place and Input.is_action_just_pressed("mb_left")):
		item_held == false
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
		if is_dragging:
			print("is dragging")
			drag_draw()
			
func drag_draw():
	global_position = get_global_mouse_position()
	print("start draw at: ", global_position)

func complete_drag():
	var start_pos = tile_map.local_to_map(drag_start_position)
	var end_pos = tile_map.local_to_map(drag_end_position)
	draw_line_tiles(start_pos, end_pos)

	print("Completed drag from ", start_pos, " to ", end_pos)

func draw_line_tiles(start_pos: Vector2i, end_pos: Vector2i):
	# Bresenham's line algorithm
	var x0 = start_pos.x
	var y0 = start_pos.y
	var x1 = end_pos.x
	var y1 = end_pos.y
	var dx = abs(x1 - x0)
	var dy = abs(y1 - y0)
	var sx
	var sy
	if x0 < x1:
		sx = 1
	else: sx = -1
	if y0 < y1:
		sy = 1
	else: sy = -1
	var err = dx - dy

	while true:
		tile_map.set_cell(0, Vector2i(x0, y0), 0, current_tile_id, 0)
		if x0 == x1 and y0 == y1:
			break
		var e2 = 2 * err
		if e2 > -dy:
			err -= dy
			x0 += sx
		if e2 < dx:
			err += dx
			y0 += sy
