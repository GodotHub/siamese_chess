@abstract
extends Node3D
class_name MarkerEvent

@onready var level:Level = get_parent()

@abstract func event() -> void
