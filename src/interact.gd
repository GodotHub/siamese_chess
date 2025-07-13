extends Area3D
class_name Interact

@export var next_interact:Array[Interact] = []	# 能够按哪些
@export var camera:Camera3D = null
@export var inspectable_item:Array[InspectableItem] = []

func _ready() -> void:
	add_user_signal("input")
	connect("input", move_camera)
	set_enabled(false)
	for iter:InspectableItem in inspectable_item:
		iter.set_enabled(false)

func enter() -> void:
	set_enabled(false)
	for iter:InspectableItem in inspectable_item:
		iter.set_enabled(true)
	for iter:Interact in next_interact:
		iter.set_enabled(true)

func leave() -> void:
	for iter:InspectableItem in inspectable_item:
		iter.set_enabled(false)
	for iter:Interact in next_interact:
		iter.set_enabled(false)

func get_camera() -> Camera3D:
	return camera

func set_enabled(enabled:bool) -> void:
	if enabled:
		collision_layer |= 1
	else:
		collision_layer &= ~1

func move_camera(_from:Node3D, _to:Area3D, _event:InputEvent, _event_position:Vector3, _normal:Vector3) -> void:
	if _event is InputEventMouseButton && _event.pressed && _event.button_index == MOUSE_BUTTON_LEFT:
		_from.add_stack(_to)
		_from.move_camera(_to.get_camera())
