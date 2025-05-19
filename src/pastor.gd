# 使用Node3D节点，除了AI逻辑判断以外还包含了角色动作控制
# 除了搜索着法以外还充当裁判，管理对方的规则内着法，以及胜负判定

extends Node3D
class_name Pastor

signal send_initial_state(state:ChessState)
signal decided_move(move:Move)
signal send_opponent_move(move_list:Array[Move])

var chess_state:ChessState = null
var chess_branch:ChessBranch = null
var thread:Thread = null
var history:Array[String] = []


func _ready() -> void:
	var tween:Tween = create_tween()
	tween.tween_interval(1)
	tween.tween_callback(create_state)

func create_state() -> void:
	chess_branch = ChessBranch.new()
	if DisplayServer.clipboard_has():
		history = [DisplayServer.clipboard_get()]
		chess_state = ChessState.create_from_fen(history[0])
	if !is_instance_valid(chess_state):
		history = ["rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"]
		chess_state = ChessState.create_from_fen(history[0])
	send_initial_state.emit(chess_state.duplicate())
	thread = Thread.new()
	thread.start(decision)

func receive_move(move:Move) -> void:
	chess_state.execute_move(move)
	history.push_back(chess_state.stringify())
	if chess_state.extra[0] == "w":
		thread.wait_to_finish()
		thread.start(decision)
	else:
		send_opponent_valid_move()

func decision() -> void:
	var move_list:Dictionary = chess_branch.search(chess_state, 4)
	print(move_list)
	if chess_state.extra[0] == "b":
		send_opponent_valid_move()
		return
	var best_str:String = ""
	for iter:String in move_list:
		if abs(move_list[iter]) >= 500:
			continue
		if !best_str || move_list[iter] > move_list[best_str]:
			best_str = iter
	var best:Move = Move.parse(best_str)
	if !is_instance_valid(best):
		# 判定棋局结束
		# var decision_instance:Decision = Decision.create_decision_instance(["Retry", "Quit"])
		# decision_instance.connect("decided", set_action)
		# add_child(decision_instance)
		# await decision_instance.decided
		return
	decided_move.emit.call_deferred(best)

func send_opponent_valid_move() -> void:	# 仅限轮到对方时使用
	var move_list:Dictionary = chess_branch.search(chess_state, 2)
	var output:Array[Move] = []
	for iter:String in move_list:
		if abs(move_list[iter]) >= 500:
			continue
		output.push_back(Move.parse(iter))
	if output.size() == 0:
		# 也是棋局结束
		return
	send_opponent_move.emit.call_deferred(output)
