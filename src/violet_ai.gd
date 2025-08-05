class_name VioletAI extends Node3D

var ai: PastorAI = PastorAI.new()

@export var group: int = 0

func _ready() -> void:
	init_ai()

func init_ai() -> void:
	ai.set_max_depth(5)
	
