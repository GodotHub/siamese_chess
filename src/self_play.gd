extends Node3D

var cur_player: int = 0
var cur_epoch: int = 0

@export var epoch: int = 0
@onready var chessboard: Chessboard = $"../chessboard"
@onready var a: VioletAI = $a
@onready var b: VioletAI = $b

func train():
	go(a)
	go(b)
	pass
	
func go(ai_node: VioletAI):
	ai_node.ai.search(chessboard.state, ai_node.group, Callable(), Callable())
	var move = ai_node.ai.best_move()
	chessboard.execute_move(move)
	
func on_button_start_pressed() -> void:
	train()
	pass # Replace with function body.
