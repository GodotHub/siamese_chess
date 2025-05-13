extends Node3D
class_name Pastor

signal decided_move(move:Chess.Move)

var chess_branch:Chess.ChessMoveBranch = null
var thread:Thread = null

func _ready() -> void:
	chess_branch = Chess.ChessMoveBranch.new()
	chess_branch.current_node.state = Chess.ChessState.new()
	thread = Thread.new()
	if chess_branch.current_node.group == 0:
		thread.start(decision)

func receive_move(move:Chess.Move) -> void:
	chess_branch.execute_move(move)
	if chess_branch.current_node.group == 0:
		thread.wait_to_finish()
		thread.start(decision)

func decision() -> void:
	chess_branch.search()
	var move:Chess.Move = chess_branch.get_best_move()
	decided_move.emit.call_deferred(move)
