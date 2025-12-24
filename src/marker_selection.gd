@abstract
extends Node3D
class_name MarkerSelection

@onready var level:Level = get_parent()
@onready var selection:String = ""

@abstract func event() -> void
