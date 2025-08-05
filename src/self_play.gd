extends Node3D

var cur_player: int = 0
var cur_epoch: int = 0

@export var epoch: int = 0
@onready var chessboard: Chessboard = $"../chessboard"
@onready var white: VioletAI = $a
@onready var black: VioletAI = $b

func play():
	go(white)
	go(black)
	
func search(ai_node: VioletAI) -> int:
	ai_node.ai.search(chessboard.state, ai_node.group, Callable(), Callable())
	return ai_node.ai.best_move()
	
func go(ai_node: VioletAI):
	var move = search(ai_node)
	chessboard.execute_move(move)
	
func on_button_start_pressed() -> void:
	play()
	pass # Replace with function body.
