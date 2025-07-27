# 使用Node3D节点，除了AI逻辑判断以外还包含了角色动作控制
# 除了搜索着法以外还充当裁判，管理对方的规则内着法，以及胜负判定

extends Node3D
class_name Pastor

signal send_initial_state(state:State)
signal decided_move(move:int)
signal send_opponent_move(move_list:PackedInt32Array)
signal send_opponent_premove(move_list:PackedInt32Array)
signal lose()
signal win()
signal draw(type:int)

var state:State = null
var thread:Thread = null
var score:int = 0
var think_time:int = 10
var start_thinking:float = 0
var interrupted:bool = false
var transposition_table:TranspositionTable = null

func create_state(fen:String) -> bool:
	state = RuleStandard.parse(fen)
	if !is_instance_valid(state):
		return false
	send_initial_state.emit(state.duplicate())
	return true

func start_decision() -> void:
	interrupted = false
	thread = Thread.new()
	thread.start(decision, Thread.PRIORITY_HIGH)

func receive_move(move:int) -> void:
	RuleStandard.apply_move(state, move, state.add_piece, state.capture_piece, state.move_piece, state.set_extra, state.push_history, state.change_score)

	var end_type:String = RuleStandard.get_end_type(state)
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
			"50_moves":
				draw.emit(3)
		return

	if state.get_extra(0) == 0:
		thread.wait_to_finish()
		thread.start(decision, Thread.PRIORITY_HIGH)
	else:
		send_opponent_valid_move()

func decision() -> void:
	if state.get_extra(0) == 1:
		send_opponent_valid_move()
		return
	send_opponent_valid_premove()
	timer_start()
	RuleStandard.search(state, 0, transposition_table, is_timeup.bind(think_time), 100, Callable())
	if !interrupted:
		decided_move.emit.call_deferred(transposition_table.best_move(state.get_zobrist()))	# 取置换表记录内容

func timer_start() -> void:
	start_thinking = Time.get_unix_time_from_system()

func is_timeup(duration:float) -> bool:
	return Time.get_unix_time_from_system() - start_thinking >= duration || interrupted

func send_opponent_valid_move() -> void:	# 仅限轮到对方时使用
	var move_list:PackedInt32Array = RuleStandard.generate_valid_move(state, 1)
	if move_list.size() == 0:
		return
	send_opponent_move.emit.call_deferred(move_list)
	send_opponent_premove.emit.call_deferred([])

func send_opponent_valid_premove() -> void:
	var move_list:PackedInt32Array = RuleStandard.generate_premove(state, 1)
	if move_list.size() == 0:
		return
	send_opponent_move.emit.call_deferred([])
	send_opponent_premove.emit.call_deferred(move_list)
