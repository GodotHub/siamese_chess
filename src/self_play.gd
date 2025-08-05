extends Node3D

var cur_player: int = 0
var cur_epoch: int = 0

@export var epoch: int = 0
@onready var chessboard: Chessboard = $"../chessboard"
@onready var white: Violet = $a
@onready var black: Violet = $b

func play():
	go(white)
	await get_tree().create_timer(0.5).timeout
	go(black)
	
func search(ai_node: Violet) -> int:
	ai_node.ai.search(chessboard.state, ai_node.group, Callable(), Callable())
	return ai_node.ai.get_search_result()
	
func go(ai_node: Violet):
	var move = search(ai_node)
	chessboard.execute_move(move)
	
func on_button_start_pressed() -> void:
	play()
	pass # Replace with function body.
