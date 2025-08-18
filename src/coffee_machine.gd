extends InspectableItem

# 咖啡机，自然的用于泡咖啡
# 可能线索就在杯子当中

func _ready() -> void:
	super._ready()

func input(_from:Node3D, _to:Area3D, _event:InputEvent, _event_position:Vector3, _normal:Vector3) -> void:
	pass
