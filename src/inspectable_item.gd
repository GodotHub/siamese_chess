extends Node3D
class_name InspectableItem

func _ready() -> void:
	for iter:Node in get_children():
		if iter is Area3D:
			iter.connect("input_event", input_event.bind(iter.get_name()))

func input_event(_camera:Camera3D, _event:InputEvent, _event_position:Vector3, _normal:Vector3, _shape_idx:int, _area:Area3D) -> void:
	pass
