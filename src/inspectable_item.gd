extends Node3D
class_name InspectableItem

var button_list:Array[Area3D] = []

func _ready() -> void:
	for iter:Node in get_children():
		if iter is Area3D:
			button_list.push_back(iter)
			iter.add_user_signal("input")
			iter.connect("input", input)
	set_enabled(false)

func set_enabled(enabled:bool) -> void:
	for iter:Area3D in button_list:
		if enabled:
			iter.collision_layer |= 2
		else:  
			iter.collision_layer &= ~2

func input(_from:Node3D, _to:Area3D, _event:InputEvent, _event_position:Vector3, _normal:Vector3) -> void:
	pass
