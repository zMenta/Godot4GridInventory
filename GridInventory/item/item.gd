@tool
extends Node2D
class_name Item

@export var item_grid : Array[Vector2i] = [Vector2i()] : set = _set_item_grid
@export var hide_item_grid := false : set = _set_hide_item_grid

var is_selected := false : set = _set_is_selected
var grid_anchor : Vector2i

func _set_hide_item_grid(new_value: bool) -> void:
	hide_item_grid = new_value
	queue_redraw()

func _set_item_grid(new_value: Array[Vector2i]) -> void:
	item_grid = new_value
	queue_redraw()

func _set_is_selected(new_value: bool) -> void:
	is_selected = new_value
	# if is_selected:
	# 	mouse_filter = MOUSE_FILTER_IGNORE
	# else:
	# 	mouse_filter = MOUSE_FILTER_PASS


func _ready() -> void:
	# Moving the hitbox x axis 1 slot to the left;
	# So it's more aligned with the texture.
	if not Engine.is_editor_hint():
		for i in item_grid.size():		
			item_grid[i] -= Vector2i(1,0)

	print(item_grid)


func _process(delta: float) -> void:
	if is_selected:
		# var offset : Vector2 = texture.get_size() / 2  + Vector2(10, -10)
		# global_position = lerp(global_position, get_global_mouse_position() - offset, 25 * delta) 
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta) 

func _draw() -> void:
	if Engine.is_editor_hint() and not hide_item_grid:
		_draw_item_grid(item_grid)


func _draw_item_grid(grid_array: Array[Vector2i]) -> void:
	var grid_size : int = 32
	for i in grid_array.size():
		draw_rect(Rect2(Vector2(grid_array[i].x * grid_size, grid_array[i].y * grid_size),
			Vector2(grid_size,grid_size)),
			Color(Color.BLUE, 0.4),
			true
		)

func rotate_item() -> void:
	for i in item_grid.size():
		item_grid[i] = Vector2i(-item_grid[i].y, item_grid[i].x)

	rotation_degrees += 90
	if rotation_degrees >= 360:
		rotation_degrees = 0

	print(item_grid)
