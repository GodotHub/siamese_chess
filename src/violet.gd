class_name Violet extends Node3D

var ai: AI = null
var nnue: NNUE = null

@export var group: int = 0

func _ready() -> void:
	init_ai()

func init_ai() -> void:
	ai = VioletAI.new()
	ai.set_max_depth(5)
	nnue = ai.get_nnue()
	
