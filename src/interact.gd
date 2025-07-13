extends Area3D
class_name Interact

@export var next_interact:Array[Interact] = []	# 能够按哪些
@export var camera:Camera3D = null
@export var inspectable_item:Array[InspectableItem] = []

func _ready() -> void:
	pass

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
		collision_mask |= 1
	else:
		collision_mask &= ^1
