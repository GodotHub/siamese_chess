extends MarkerBit
class_name MarkerTeleport

@export var to:String = ""
@export var args:Dictionary = {}

func _init() -> void:
	piece = "z".unicode_at(0)

func change_scene() -> void:
	Loading.change_scene(to, args)
