# 使用Node3D节点，除了AI逻辑判断以外还包含了角色动作控制
# 除了搜索着法以外还充当裁判，管理对方的规则内着法，以及胜负判定

extends Node3D
class_name Pastor

signal send_initial_state(state:ChessState)
signal decided_move(move:int)
signal send_opponent_move(move_list:PackedInt32Array)
signal send_opponent_premove(move_list:PackedInt32Array)
signal lose()
signal win()
signal draw(type:int)

var chess_state:ChessState = null
var thread:Thread = null
var score:int = 0
var think_time:int = 10
var min_depth:int = 4
var evaluation:Object = null
var timer:Timer = null
var start_thinking:float = 0

func _ready() -> void:
	pass

func create_state(fen:String, _evaluation:Object) -> bool:
	chess_state = _evaluation.parse(fen)
	if !is_instance_valid(chess_state):
		return false
	evaluation = _evaluation
	send_initial_state.emit(chess_state.duplicate())
	return true

func start_decision() -> void:
	thread = Thread.new()
	thread.start(decision, Thread.PRIORITY_HIGH)

func receive_move(move:int) -> void:
	chess_state.apply_move(move)

	var end_type:String = evaluation.get_end_type(chess_state)
	if end_type:
		match end_type:
			"checkmate_black":
				lose.emit()
			"checkmate_white":
				win.emit()
			"stalemate_black":
				draw.emit(1)
			"stalemate_white":
				draw.emit(2)
			"threefold_repetition":
				draw.emit(0)
		return

	if chess_state.get_extra(0) == 0:
		thread.wait_to_finish()
		thread.start(decision, Thread.PRIORITY_HIGH)
	else:
		send_opponent_valid_move()

func decision() -> void:
	if chess_state.get_extra(0) == 1:
		send_opponent_valid_move()
		return
	send_opponent_valid_premove()
	timer_start()
	var move_list:Dictionary[int, int] = {}
	evaluation.search(move_list, chess_state, is_timeup.bind(think_time), min_depth, 1000, 0)
	if !move_list.size():
		return
	var best:int = -1
	for iter:int in move_list:
		if best == -1 || move_list[iter] > move_list[best]:
			best = iter
	decided_move.emit.call_deferred(best)

func timer_start() -> void:
	start_thinking = Time.get_unix_time_from_system()

func is_timeup(duration:float) -> bool:
	return Time.get_unix_time_from_system() - start_thinking >= duration

func send_opponent_valid_move() -> void:	# 仅限轮到对方时使用
	var move_list:PackedInt32Array = evaluation.get_valid_move(chess_state, 1)
	if move_list.size() == 0:
		return
	send_opponent_move.emit.call_deferred(move_list)

func send_opponent_valid_premove() -> void:
	var move_list:PackedInt32Array = evaluation.generate_premove(chess_state, 1)
	if move_list.size() == 0:
		return
	send_opponent_premove.emit.call_deferred(move_list)
