extends TextureRect
class_name Slot

signal slot_entered(slot: Slot)
signal slot_exited(slot: Slot)

@onready var color_filter : ColorRect = $StatusFilter

enum States {DEFAULT, OCCUPIED, FREE} 

var id : int
var is_hovering := false
var state := States.DEFAULT : set = _set_state
var stored_item : Item


func _set_state(new_state: States = States.DEFAULT) -> void:
	state = new_state
	match state:
		States.DEFAULT:
			color_filter.color = Color(Color.WHITE, 0)
		States.OCCUPIED:
			color_filter.color = Color(Color.RED, 0.3)
		States.FREE:
			color_filter.color = Color(Color.GREEN, 0.2)
			

func _on_mouse_entered() -> void:
	slot_entered.emit(self)
	is_hovering = true

func _on_mouse_exited() -> void:
	slot_exited.emit(self)
	is_hovering = false

