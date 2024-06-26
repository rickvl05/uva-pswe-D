extends Node2D

var can_place: bool = true
var is_panning: bool = false
var is_dragging: bool = false
var item_held: bool = false
var toggle_dragging: bool = false
var toggle_square: bool = false
var currently_dragging: bool = false
var line_mode: bool = false
var preview = []
var draw_mode: bool = false

@onready var level: Node = get_node("/root/main/World")
@onready var editor: Node2D = get_node("/root/main/cam_container")
@onready var editor_cam: Camera2D = editor.get_node("Camera2D")

@onready var tile_map: TileMap = get_node("/root/main/World/TileMap")
@onready var tab_container: TabContainer = get_node("/root/main/item_select/menu_tab")

@export var cam_spd: int = 100
@export var max_zoom: float = 2.0
@export var min_zoom: float = 0.5
@export var current_item: PackedScene = null
@export var current_rect: TextureRect = null
@export var current_tile_id: Vector2i
@export var IsTile: bool
@export var toggle_eraser: bool = false

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
	if !GlobalLevelEditor.playing:
		handle_editor(global_position)
	else:
		if Input.is_action_just_pressed("mb_right"):
			is_panning = true
		if Input.is_action_just_released("mb_right"):
			is_panning = false

		if Input.is_action_just_pressed("mb_left") and IsTile and toggle_dragging:
			drag_start_position = global_position
			currently_dragging = true
			#preview = []
		elif Input.is_action_just_released("mb_left") and IsTile and toggle_dragging:
			drag_end_position = global_position
			if drag_start_position.distance_to(drag_end_position) > DRAG_THRESHOLD:
				complete_drag()
			clear_preview(preview)
			currently_dragging = false
		# handle square drawing
		if Input.is_action_just_pressed("mb_left") and IsTile and toggle_square:
			drag_start_position = global_position
			currently_dragging = true
			#preview = []
		elif Input.is_action_just_released("mb_left") and IsTile and toggle_square:
			drag_end_position = global_position
			if drag_start_position.distance_to(drag_end_position) > DRAG_THRESHOLD:
					complete_square()

			clear_preview(preview)
			currently_dragging = false
		if Input.is_action_just_pressed("mb_left"):
			if current_item:
				var instance = current_item.instantiate()
				draw_mode = true
				print("drawing", draw_mode)
				if toggle_eraser:
					erase_tile()
				elif instance.IsTile:
					pass
					#draw_tile()
				instance.queue_free()
		elif Input.is_action_just_released("mb_left"):
			if draw_mode:
				draw_mode = false

		if currently_dragging:
			clear_preview(preview)
			#preview = []
			var start_pos = tile_map.local_to_map(drag_start_position)
			var end_pos = tile_map.local_to_map(global_position)
			if toggle_dragging:
				draw_line_tiles(start_pos, end_pos, 2)
			if toggle_square:
				draw_square(start_pos, end_pos, 2)
			if toggle_eraser and !toggle_dragging and !toggle_square:
				erase_tile()
			elif !toggle_eraser and !toggle_dragging and !toggle_square:
				draw_tile()

func handle_editor(global_position):
	if (IsTile == false and can_place and Input.is_action_just_pressed("mb_left")):
		print("select itemed item: ", current_item)
		item_held = true
		select_item(current_item)
	elif (IsTile == true and can_place and Input.is_action_just_pressed("mb_left")):
		item_held = false
		print("selected tile: ", current_rect)
		select_tile(current_rect)
	pass

func select_item(item):
	if item and can_place:
		if item.has_method("get"):
			var scene = item.get("this_scene")
			if scene:
				current_item = scene
				if GlobalLevelEditor.playing:
					var new_item: Node2D = scene.instantiate() as Node2D
					level.add_child(new_item)
					new_item.global_position = Vector2(0, 0)

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
		
		editor_cam.zoom.x = clamp(editor_cam.zoom.x, min_zoom, max_zoom)
		editor_cam.zoom.y = clamp(editor_cam.zoom.y, min_zoom, max_zoom)
			
func drag_draw():
	global_position = get_global_mouse_position()

func complete_drag():
	var new_item = current_item.instantiate()
	var start_pos = tile_map.local_to_map(drag_start_position)
	var end_pos = tile_map.local_to_map(drag_end_position)
	draw_line_tiles(start_pos, end_pos, new_item.layer)
	print("Completed line from ", start_pos, " to ", end_pos)
	new_item.queue_free()

func complete_square():
	var new_item = current_item.instantiate()
	var start_pos = tile_map.local_to_map(drag_start_position)
	var end_pos = tile_map.local_to_map(drag_end_position)
	print(new_item.layer)
	draw_square(start_pos, end_pos, new_item.layer)
	print("Completed square from ", start_pos, " to ", end_pos)
	new_item.queue_free()

func clear_preview(preview: Array):
	tile_map.clear_layer(2)

func draw_line_tiles(start_pos: Vector2i, end_pos: Vector2i, layer: int):
	# Bresenham's line algorithm
	var new_item = current_item.instantiate()
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
		# BUG!!!!! sometimes it gets in here when holding item, should not be possible
		var reserved_cells = tile_map.reserved_cells
		if !reserved_cells.has(Vector2(x0,y0)) or layer == 0 or layer == 2:
			tile_map.set_cell(layer, Vector2i(x0, y0), new_item.source, current_tile_id, 0)
		if x0 == x1 and y0 == y1:
			break
		var e2 = 2 * err
		if e2 > -dy:
			err -= dy
			x0 += sx
		if e2 < dx:
			err += dx
			y0 += sy
	new_item.queue_free()


func draw_square(start_pos: Vector2i, end_pos: Vector2i, layer: int):
	var new_item = current_item.instantiate()
	var x0 = start_pos.x
	var y0 = start_pos.y
	var x1 = end_pos.x
	var y1 = end_pos.y
	var dx = abs(x1 - x0)
	var dy = abs(y1 - y0)
	for x in range(dx+1):
		for y in range(dy+1):
			var reserved_cells = tile_map.reserved_cells
			var x_mod = x
			var y_mod = y
			if x1 - x0 < 0:
				x_mod = -x
			if y1 - y0 < 0:
				y_mod = -y
			if !reserved_cells.has(Vector2(x0 + x_mod, y0 + y_mod)) or layer == 0 or layer == 2:
				tile_map.set_cell(layer, Vector2i(x0 + x_mod, y0 + y_mod), new_item.source, current_tile_id, 0)
	new_item.queue_free()

func draw_tile():
	print("test")
	var grid_position = tile_map.local_to_map(global_position)
	if !tile_map.reserved_cells.has(grid_position):
		tile_map.set_cell(1, grid_position, 0, current_tile_id, 0)

func erase_tile():
	var grid_position = tile_map.local_to_map(global_position)
	if tile_map.reserved_cells.has(grid_position):
		var reserved_item = tile_map.reserved_cells[grid_position]
		var item_position = reserved_item.global_position / tile_map.cell_size
		tile_map.remove_child(reserved_item)
		reserved_item.queue_free()
		tile_map.reserved_cells.erase(grid_position)
		if tile_map.placed_items.has(item_position):
			tile_map.placed_items.erase(item_position)
	else:
		tile_map.erase_cell(0, grid_position)

func _on_line_but_toggled(toggled_on):
	toggle_dragging = !toggle_dragging

func _on_del_but_toggled(toggled_on):
	toggle_eraser = !toggle_eraser

func _on_square_but_toggled(toggled_on):
	toggle_square = !toggle_square

