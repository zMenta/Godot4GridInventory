extends Control

@export var slot_amount : int = 64

@onready var slot_scene : PackedScene = preload("res://inventory_ui/slot/slot.tscn")
@onready var grid_container : GridContainer = $ColorRect/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var col_count : int = grid_container.columns

var slot_array : Array[TextureRect] = []
var item_held : Item = null
var current_slot : Slot = null
var can_place := false
var icon_anchor : Vector2i = Vector2i()

func _ready() -> void:
	for i in range(slot_amount):
		var slot : Slot = slot_scene.instantiate()
		slot.id = i
		slot_array.append(slot)
		grid_container.add_child(slot)
		slot.slot_entered.connect(_on_slot_mouse_entered)
		slot.slot_exited.connect(_on_slot_mouse_exited)

func _process(_delta: float) -> void:
	if item_held:
		if Input.is_action_just_pressed("rotate"):
			rotate_held_item()

		if Input.is_action_just_pressed("m1") and current_slot:
			place_item()
	else:
		if Input.is_action_just_pressed("m1") and current_slot:
			pickup_item()


func _on_slot_mouse_entered(slot: Slot) -> void:
	icon_anchor = Vector2i(1000, 1000)
	current_slot = slot
	if item_held:
		check_slot_availability(current_slot)
		set_slots.call_deferred(current_slot)


func _on_slot_mouse_exited(slot: Slot) -> void:
	current_slot = null
	clear_slots()


# Item spawn button
func _on_button_pressed() -> void:
	var item : Item = load("res://item/item.tscn").instantiate()
	item.is_selected = true
	add_child(item)
	item_held = item


func check_slot_availability(slot: Slot) -> void:
	for grid in item_held.item_grid:
		# Calculates the position of the slot that needs to be checked because of item_grid "hitbox";
		var slot_to_check : int = slot.id + grid.x + (grid.y * col_count)
		var column_wrap_check : int = slot.id % col_count + grid.x
		# If column_wrap_check is less than 0 it means the item_grid hitbox wraps around on the left side,
		# if is bigger than col_count it means that the hitbox wraps on the right side.
		if column_wrap_check < 0 or column_wrap_check >= col_count:
			can_place = false
			return
		if slot_to_check < 0 or slot_to_check >= slot_array.size():
			can_place = false
			return
		if slot_array[slot_to_check].state == Slot.States.OCCUPIED:
			can_place = false
			return
		if slot_array[slot_to_check].stored_item != null:
			can_place = false
			return
	can_place = true


func set_slots(slot: Slot) -> void:
	for grid in item_held.item_grid:
		# Calculates the position of the slot that needs to be checked because of item_grid "hitbox";
		var slot_to_check : int = slot.id + grid.x + (grid.y * col_count)
		var column_wrap_check : int = slot.id % col_count + grid.x
		# If column_wrap_check is less than 0 it means the item_grid hitbox wraps around on the left side,
		# if is bigger than col_count it means that the hitbox wraps on the right side.
		if column_wrap_check < 0 or column_wrap_check >= col_count:
			continue
		if slot_to_check < 0 or slot_to_check >= slot_array.size():
			continue

		if can_place:
			slot_array[slot_to_check].state = Slot.States.FREE
			if grid.x < icon_anchor.x: icon_anchor.x = grid.x
			if grid.y < icon_anchor.y: icon_anchor.y = grid.y
		else:
			slot_array[slot_to_check].state = Slot.States.OCCUPIED


func clear_slots() -> void:
	for slot in slot_array:
		slot.state = Slot.States.DEFAULT


func rotate_held_item() -> void:
	item_held.rotate_item()
	clear_slots()
	if current_slot:
		_on_slot_mouse_entered(current_slot)


func place_item() -> void:
	if not can_place or not current_slot:
		return

	var slot_anchor : int = current_slot.id + icon_anchor.x + (icon_anchor.y * col_count)
	item_held.snap_to(slot_array[slot_anchor].global_position)
	
	for grid in item_held.item_grid:
		var slot_to_check : int = current_slot.id + grid.x + (grid.y * col_count)
		slot_array[slot_to_check].state = Slot.States.OCCUPIED
		slot_array[slot_to_check].stored_item = item_held

	item_held.slot_anchor = current_slot
	item_held.is_selected = false
	item_held.reparent(grid_container)
	item_held.global_position = get_global_mouse_position()
	item_held = null
	clear_slots()
	

func pickup_item() -> void:
	if current_slot.stored_item == null:
		return

	item_held = current_slot.stored_item
	item_held.is_selected = true

	item_held.reparent(self)
	item_held.global_position = get_global_mouse_position()

	for grid in item_held.item_grid:
		var slot_id : int = item_held.slot_anchor.id + grid.x + (grid.y * col_count)
		slot_array[slot_id].state = Slot.States.DEFAULT
		slot_array[slot_id].stored_item = null

	check_slot_availability(current_slot)
	set_slots.call_deferred(current_slot)

