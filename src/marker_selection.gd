@abstract
extends Node3D
class_name MarkerSelection

@onready var level:Level = get_parent()
@export var selection:String = ""

@abstract func event() -> void
