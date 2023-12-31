@tool
extends Node2D
class_name Item

@export var item_grid : Array[Vector2i] = [Vector2i()] : set = _set_item_grid
@export var hide_item_grid := false : set = _set_hide_item_grid

@onready var item_texture : TextureRect = $ItemTexture

var is_selected := false : set = _set_is_selected
var slot_anchor : Slot

func _set_hide_item_grid(new_value: bool) -> void:
	hide_item_grid = new_value
	queue_redraw()

func _set_item_grid(new_value: Array[Vector2i]) -> void:
	item_grid = new_value
	queue_redraw()

func _set_is_selected(new_value: bool) -> void:
	is_selected = new_value
	if is_selected:
		top_level = true
	else:
		top_level = false

func _ready() -> void:
	# Moving the hitbox x axis 1 slot to the left;
	# So it's more aligned with the texture.
	if not Engine.is_editor_hint():
		item_texture.anchors_preset = item_texture.PRESET_CENTER
		for i in item_grid.size():		
			item_grid[i] -= Vector2i(1,0)


func _process(delta: float) -> void:
	if is_selected:
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

func snap_to(destination: Vector2) -> void:
	var tween := get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	var rect_size = item_texture.get_rect().size

	if int(rotation_degrees) % 180 == 0:
		destination += rect_size/2 
	else:
		destination += Vector2(rect_size.y, rect_size.x)/2

	tween.tween_property(self, "global_position", destination, 0.15)

