extends Control

@export var slot_amount : int = 64

@onready var slot_scene : PackedScene = preload("res://inventory_ui/slot/slot.tscn")
@onready var grid_container : GridContainer = $ColorRect/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var col_count : int = grid_container.columns

var slot_array : Array[TextureRect] = []
var item_held : Item = null
var current_slot : Slot = null
var can_place := false
var icon_anchor : Vector2i

func _ready() -> void:
	for i in range(slot_amount):
		var slot : Slot = slot_scene.instantiate()
		slot.id = i
		slot_array.append(slot)
		grid_container.add_child(slot)
		slot.slot_entered.connect(_on_slot_mouse_entered)
		slot.slot_exited.connect(_on_slot_mouse_exited)


func _on_slot_mouse_entered(slot: Slot) -> void:
	icon_anchor = Vector2i(10000, 10000)
	current_slot = slot
	if item_held:
		check_slot_availability(current_slot)
		set_slots.call_deferred(current_slot)


func _on_slot_mouse_exited(slot: Slot) -> void:
	# slot.state = slot.States.DEFAULT
	pass

# Item spawn button
func _on_button_pressed() -> void:
	var item : Item = preload("res://item/item.tscn").instantiate()
	item.is_selected = true
	add_child(item)
	item_held = item


func check_slot_availability(slot: Slot) -> void:
	for grid in item_held.item_grid:
		# Calculates the position of the slot that needs to be checked because of item_grid "hitbox";
		var slot_to_check : int = slot.id + grid[0] + (grid[1] * col_count)
		var column_wrap_check : int = slot.id % col_count + grid[0]
		# If column_wrap_check is less than 0 it means the item_grid hitbox wraps around on the left side,
		# if is bigger than col_count it means that the hitbox wraps on the right side.
		if column_wrap_check < 0 or column_wrap_check >= col_count:
			can_place = false
			return
		if slot_to_check < 0 or slot_to_check >= slot_array.size():
			can_place = false
			return
		if slot_array[slot_to_check].state == slot_array[slot_to_check].States.OCCUPIED:
			can_place = false
			return
	can_place = true


func set_slots(slot: Slot) -> void:
	for grid in item_held.item_grid:
		# Calculates the position of the slot that needs to be checked because of item_grid "hitbox";
		var slot_to_check : int = slot.id + grid[0] + (grid[1] * col_count)
		var column_wrap_check : int = slot.id % col_count + grid[0]
		# If column_wrap_check is less than 0 it means the item_grid hitbox wraps around on the left side,
		# if is bigger than col_count it means that the hitbox wraps on the right side.
		if column_wrap_check < 0 or column_wrap_check >= col_count:
			continue
		if slot_to_check < 0 or slot_to_check >= slot_array.size():
			continue

		if can_place:
			print("slot set")
			slot_array[slot_to_check].state = Slot.States.FREE
			if grid[0] < icon_anchor.y: icon_anchor.y = grid[0]
			if grid[1] < icon_anchor.x: icon_anchor.x = grid[1]
		else:
			slot_array[slot_to_check].state = Slot.States.OCCUPIED

