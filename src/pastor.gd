# 使用Node3D节点，除了AI逻辑判断以外还包含了角色动作控制
# 除了搜索着法以外还充当裁判，管理对方的规则内着法，以及胜负判定

extends Node3D
class_name Pastor

signal send_initial_state(state:Chess.ChessState)
signal decided_move(move:Chess.Move)
signal send_opponent_move(move_list:Array[Chess.Move])

var chess_branch:Chess.ChessMoveBranch = null
var thread:Thread = null

func _ready() -> void:
	var tween:Tween = create_tween()
	tween.tween_interval(1)
	tween.tween_callback(create_state)

func create_state() -> void:
	chess_branch = Chess.ChessMoveBranch.new()
	if DisplayServer.clipboard_has():
		chess_branch.set_state(Chess.create_state_from_fen(DisplayServer.clipboard_get()))
	if !is_instance_valid(chess_branch.get_state()):
		chess_branch.set_state(Chess.create_state_from_fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"))
	send_initial_state.emit(chess_branch.get_state().duplicate())
	thread = Thread.new()
	thread.start(decision)

func receive_move(move:Chess.Move) -> void:
	chess_branch.execute_move(move)
	if chess_branch.current_node.group == 0:
		thread.wait_to_finish()
		thread.start(decision)

func decision() -> void:
	chess_branch.search()
	if chess_branch.current_node.group == 1:
		send_opponent_valid_move()
		return
	var move:Chess.Move = chess_branch.get_best_move()
	if !is_instance_valid(move):
		# 判定棋局结束
		# var decision_instance:Decision = Decision.create_decision_instance(["Retry", "Quit"])
		# decision_instance.connect("decided", set_action)
		# add_child(decision_instance)
		# await decision_instance.decided
		return
	decided_move.emit.call_deferred(move)

func send_opponent_valid_move() -> void:	# 仅限轮到对方时使用
	var output:Array[Chess.Move] = []
	for iter:String in chess_branch.current_node.children:
		if chess_branch.current_node.children[iter].dead:
			continue
		output.push_back(Chess.parse_move(iter))
	if output.size() == 0:
		# 也是棋局结束
		return
	send_opponent_move.emit.call_deferred(output)
