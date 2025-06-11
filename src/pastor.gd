# 使用Node3D节点，除了AI逻辑判断以外还包含了角色动作控制
# 除了搜索着法以外还充当裁判，管理对方的规则内着法，以及胜负判定

extends Node3D
class_name Pastor

signal send_initial_state(state:ChessState)
signal decided_move(move:int)
signal send_opponent_move(move_list:PackedInt32Array)
signal lose()
signal win()
signal draw()

var chess_state:ChessState = null
var thread:Thread = null
var history:Array[String] = []
var score:int = 0
var depth:int = 6
var evaluation:Object = null

func _ready() -> void:
	pass

func create_state(fen:String) -> bool:
	chess_state = ChessState.create_from_fen(fen)
	if !is_instance_valid(chess_state):
		return false
	chess_state.evaluation = evaluation
	history = [fen]
	send_initial_state.emit(chess_state.duplicate())
	return true

func start_decision() -> void:
	thread = Thread.new()
	thread.start(decision, Thread.PRIORITY_HIGH)

func receive_move(move:int) -> void:
	var events:Array[ChessEvent] = chess_state.create_event(move)
	score += evaluation.evaluate_events(chess_state, events)
	chess_state.apply_event(events)
	history.push_back(chess_state.stringify())

	var end_type:String = evaluation.get_end_type(chess_state)
	if end_type:
		match end_type:
			"checkmate_black":
				lose.emit()
			"checkmate_white":
				win.emit()
			"stalemate_black":
				draw.emit()
			"stalemate_white":
				draw.emit()
		return

	if chess_state.get_extra(0) == "w":
		thread.wait_to_finish()
		thread.start(decision, Thread.PRIORITY_HIGH)
	else:
		send_opponent_valid_move()

func decision() -> void:
	if chess_state.get_extra(0) == "b":
		send_opponent_valid_move()
		return
	var move_list:Dictionary = evaluation.search(chess_state, depth, 0)
	if !move_list.size():
		return
	var best:int = -1
	for iter:int in move_list:
		if best == -1 || move_list[iter] > move_list[best]:
			best = iter
	decided_move.emit.call_deferred(best)

func send_opponent_valid_move() -> void:	# 仅限轮到对方时使用
	var move_list:Dictionary = evaluation.search(chess_state, 1, 1)
	var output:PackedInt32Array = []
	if move_list.size() == 0:
		return
	for iter:int in move_list:
		output.push_back(iter)
	send_opponent_move.emit.call_deferred(output)
