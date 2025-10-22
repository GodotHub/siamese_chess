extends Node3D
class_name Level

signal move_camera(camera:Camera3D)

var engine:ChessEngine = null	# 有可能会出现多线作战，共用同一个引擎显然不好
var state:State = null
var chessboard:Chessboard = null
var in_battle:bool = false
var teleport:Dictionary = {}
var history_state:PackedInt32Array = []

func _ready() -> void:
	engine = PastorEngine.new()
	state = State.new()
	chessboard = $chessboard
	for node:Node in get_children():
		if node is Actor:
			var by:int = Chess.to_position_int(chessboard.get_position_name(node.global_position))
			state.add_piece(by, node.piece_type)
	chessboard.set_state(state)
	for node:Node in get_children():
		if node is Actor:
			var by:int = Chess.to_position_int(chessboard.get_position_name(node.global_position))
			node.get_parent().remove_child(node)
			chessboard.add_piece_instance(node, by)
	if has_node("camera"):
		chessboard.connect("clicked", move_camera.emit.call_deferred.bind($camera))
	explore()

func step(move:int) -> void:
	for from:int in teleport:
		var to:int = teleport[from]["to"]
		var next_level:Level = teleport[from]["level"]
		if Chess.to(move) == from && !next_level.state.has_piece(to):
			next_level.state.add_piece(to, state.get_piece(from))
			state.capture_piece(from)
			chessboard.move_piece_instance_to_other(from, to, next_level.chessboard)
			next_level.chessboard.set_valid_move(RuleStandard.generate_valid_move(next_level.state, 1))
		elif Chess.from(move) == from && next_level.state.has_piece(to) && !(char(next_level.state.get_piece(to)) in ["X", "x", "Y", "y", "Z", "z"]):
			state.add_piece(from, next_level.state.get_piece(to))
			next_level.state.capture_piece(to)
			next_level.chessboard.move_piece_instance_to_other(to, from, chessboard)
			chessboard.set_valid_move(RuleStandard.generate_valid_move(state, 1))

func explore() -> void:
	while true:	# 有棋子再说
		if state.get_bit("a".unicode_at(0)):
			chessboard.set_valid_move(RuleStandard.generate_valid_move(state, 1))
			chessboard.set_valid_premove([])
			await chessboard.move_played
			RuleStandard.apply_move(state, chessboard.confirm_move)
			step(chessboard.confirm_move)
			
			# TODO: 这是不准确的攻击范围判定，拓展RuleStandard功能以改写成标准的攻击范围
			var white_move_list:PackedInt32Array = RuleStandard.generate_valid_move(state, 0)
			var attack:int = 0
			for move:int in white_move_list:
				attack |= Chess.mask(Chess.to_64(Chess.to(move)))
			if state.get_bit("a".unicode_at(0)) & attack:
				versus.call_deferred()
				break
		else:
			await chessboard.clicked

func versus() -> void:
	while RuleStandard.get_end_type(state) == "":
		chessboard.set_valid_move([])
		chessboard.set_valid_premove(RuleStandard.generate_premove(state, 1))
		engine.set_think_time(3)
		engine.start_search(state, 0, history_state, Callable())
		if engine.is_searching():
			await engine.search_finished
		var move:int = engine.get_search_result()
		
		var test_state:State = state.duplicate()
		var variation:PackedInt32Array = engine.get_principal_variation()
		var text:String = ""
		for iter:int in variation:
			var move_name:String = RuleStandard.get_move_name(test_state, iter)
			text += move_name + " "
			RuleStandard.apply_move(test_state, iter)
		print(text)
		
		history_state.push_back(state.get_zobrist())
		RuleStandard.apply_move(state, move)
		chessboard.execute_move(move)
		if RuleStandard.get_end_type(state) != "":
			break
		chessboard.set_valid_move(RuleStandard.generate_valid_move(state, 1))
		chessboard.set_valid_premove([])
		engine.set_think_time(INF)
		engine.start_search(state, 1, history_state, Callable())
		await chessboard.move_played
		history_state.push_back(state.get_zobrist())
		RuleStandard.apply_move(state, chessboard.confirm_move)
		engine.stop_search()
		if engine.is_searching():
			await engine.search_finished
	match RuleStandard.get_end_type(state):
		"checkmate_black":
			for by:int in 128:
				if state.has_piece(by) && Chess.group(state.get_piece(by)) == 0:
					state.capture_piece(by)
					chessboard.chessboard_piece[by].captured()
			explore()
		"checkmate_white":
			for by:int in 128:
				if state.has_piece(by) && Chess.group(state.get_piece(by)) == 1:
					state.capture_piece(by)
					chessboard.chessboard_piece[by].captured()
