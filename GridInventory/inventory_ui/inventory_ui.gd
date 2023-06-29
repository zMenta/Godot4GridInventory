extends Control

@export var slot_amount : int = 64

@onready var slot_scene : PackedScene = preload("res://inventory_ui/slot/slot.tscn")
@onready var grid_container : GridContainer = $ColorRect/MarginContainer/VBoxContainer/ScrollContainer/GridContainer

var slot_array : Array[TextureRect] = []

func _ready() -> void:
	for i in range(slot_amount):
		var slot : Slot = slot_scene.instantiate()
		slot.id = i
		slot_array.append(slot)
		grid_container.add_child(slot)
		slot.slot_entered.connect(_on_slot_mouse_entered)
		slot.slot_exited.connect(_on_slot_mouse_exited)


func _on_slot_mouse_entered(slot: Slot) -> void:
	slot.state = slot.States.OCCUPIED

func _on_slot_mouse_exited(slot: Slot) -> void:
	slot.state = slot.States.DEFAULT

# Item spawn button
func _on_button_pressed() -> void:
	var item : Item = preload("res://item/item.tscn").instantiate()
	item.is_selected = true
	add_child(item)


