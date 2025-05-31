# 使用Node3D节点，除了AI逻辑判断以外还包含了角色动作控制
# 除了搜索着法以外还充当裁判，管理对方的规则内着法，以及胜负判定

extends Node3D
class_name Pastor

signal send_initial_state(state:ChessState)
signal decided_move(move:Move)
signal send_opponent_move(move_list:Array[Move])
signal lose()
signal win()
signal draw()

var chess_state:ChessState = null
var thread:Thread = null
var history:Array[String] = []
var score:float = 0

func _ready() -> void:
	pass

func create_state(fen:String) -> bool:
	chess_state = ChessState.create_from_fen(fen)
	if !is_instance_valid(chess_state):
		return false
	history = [fen]
	send_initial_state.emit(chess_state.duplicate())
	return true

func start_decision() -> void:
	thread = Thread.new()
	thread.start(decision, Thread.PRIORITY_HIGH)

func receive_move(move:Move) -> void:
	var events:Array[ChessEvent] = chess_state.create_event(move)
	score += Evaluation.evaluate_events(chess_state, events)
	chess_state.apply_event(events)
	
	history.push_back(chess_state.stringify())
	if chess_state.get_extra(0) == "w":
		thread.wait_to_finish()
		thread.start(decision, Thread.PRIORITY_HIGH)
	else:
		send_opponent_valid_move()

func decision() -> void:
	if chess_state.get_extra(0) == "b":
		send_opponent_valid_move()
		return
	var move_list:Dictionary = ChessBranch.search(chess_state, 4, 0)
	if !move_list.size():
		# 判定棋局结束
		var null_move_check:float = ChessBranch.alphabeta(chess_state, score, -10000, 10000, 1, 1)
		if null_move_check <= -500:
			lose.emit.call_deferred()
		else:
			draw.emit.call_deferred(1)	# 我方无着法的逼和
		return
	print(move_list)
	var best_str:String = ""
	for iter:String in move_list:
		if !best_str || move_list[iter] > move_list[best_str]:
			best_str = iter
	var best:Move = Move.parse(best_str)
	decided_move.emit.call_deferred(best)

func send_opponent_valid_move() -> void:	# 仅限轮到对方时使用
	var move_list:Dictionary = ChessBranch.search(chess_state, 1, 1)
	var output:Array[Move] = []
	if move_list.size() == 0:
		var null_move_check:float = ChessBranch.alphabeta(chess_state, score, -10000, 10000, 1, 0)
		if null_move_check >= 500:
			win.emit()
		else:
			draw.emit(2)	# 黑方无着法的逼和
		return
	for iter:String in move_list:
		output.push_back(Move.parse(iter))
	send_opponent_move.emit.call_deferred(output)
