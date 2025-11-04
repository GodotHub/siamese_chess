extends Node3D
class_name Level

signal move_camera(camera:Camera3D)

var engine:ChessEngine = null	# 有可能会出现多线作战，共用同一个引擎显然不好
var chessboard:Chessboard = null
var in_battle:bool = false
var teleport:Dictionary = {}
var history_state:PackedInt32Array = []

func _ready() -> void:
	engine = PastorEngine.new()
	var state = State.new()
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

func check_teleport(move:int) -> void:
	for from:int in teleport:
		var to:int = teleport[from]["to"]
		var next_level:Level = teleport[from]["level"]
		if next_level.in_battle:
			continue
		if Chess.to(move) == from && !next_level.chessboard.state.has_piece(to):
			next_level.chessboard.state.add_piece(to, chessboard.state.get_piece(from))
			chessboard.state.capture_piece(from)
			chessboard.move_piece_instance_to_other(from, to, next_level.chessboard)
			next_level.chessboard.set_valid_move(RuleStandard.generate_explore_move(next_level.chessboard.state, 1))
		elif Chess.from(move) == from && next_level.chessboard.state.has_piece(to) && !(char(next_level.chessboard.state.get_piece(to)) in ["W", "w", "X", "x", "Y", "y", "Z", "z"]):
			chessboard.state.add_piece(from, next_level.chessboard.state.get_piece(to))
			next_level.chessboard.state.capture_piece(to)
			next_level.chessboard.move_piece_instance_to_other(to, from, chessboard)
			chessboard.set_valid_move(RuleStandard.generate_valid_move(chessboard.state, 1))

func check_attack() -> bool:
	# TODO: 这是不准确的攻击范围判定，拓展RuleStandard功能以改写成标准的攻击范围
	var white_move_list:PackedInt32Array = RuleStandard.generate_valid_move(chessboard.state, 0)
	for move:int in white_move_list:
		var to:int = Chess.to(move)
		if chessboard.state.has_piece(to):
			continue
		if char(chessboard.state.get_piece(to)) in ["k", "q", "r", "b", "n", "p"]:
			return true
	return false

func explore() -> void:
	while true:	# 有棋子再说
		if chessboard.state.get_bit("a".unicode_at(0)):
			chessboard.set_valid_move(RuleStandard.generate_explore_move(chessboard.state, 1))	# TODO: 由于移花接木机制，这个情况下Cheshire不会进行寻路。
			await chessboard.clicked_move
			if await check_move(Chess.from(chessboard.confirm_move), Chess.to(chessboard.confirm_move), chessboard.valid_move):
				await chessboard.animation_finished
				check_teleport(chessboard.confirm_move)
				if check_attack():
					versus.call_deferred()
					return
		else:
			await chessboard.clicked

func check_move(from:int, to:int, valid_move:Dictionary[int, Array]) -> bool:
	if from & 0x88 || to & 0x88 || !valid_move.has(from):
		return false
	var move_list:PackedInt32Array = valid_move[from].filter(func (move:int) -> bool: return to == Chess.to(move))
	if move_list.size() == 0:
		return false
	elif move_list.size() > 1:
		var decision_list:PackedStringArray = []
		for iter:int in move_list:
			decision_list.push_back("%c" % Chess.extra(iter))
		var decision_instance:Decision = Decision.create_decision_instance(decision_list, true)
		add_child(decision_instance)
		await decision_instance.decided
		if decision_instance.selected_index == -1:
			return false
		chessboard.execute_move(move_list[decision_instance.selected_index])
	else:
		chessboard.execute_move(move_list[0])
	return true

func versus() -> void:
	in_battle = true
	while RuleStandard.get_end_type(chessboard.state) == "":
		chessboard.set_valid_move([])
		engine.set_think_time(3)
		engine.start_search(chessboard.state, 0, history_state, Callable())
		if engine.is_searching():
			await engine.search_finished
		var move:int = engine.get_search_result()
		
		var test_state:State = chessboard.state.duplicate()
		var variation:PackedInt32Array = engine.get_principal_variation()
		var text:String = ""
		for iter:int in variation:
			var move_name:String = RuleStandard.get_move_name(test_state, iter)
			text += move_name + " "
			RuleStandard.apply_move(test_state, iter)
		print(text)
		
		history_state.push_back(chessboard.state.get_zobrist())
		chessboard.execute_move(move)
		if RuleStandard.get_end_type(chessboard.state) != "":
			break
		chessboard.set_valid_move(RuleStandard.generate_valid_move(chessboard.state, 1))
		engine.set_think_time(INF)
		engine.start_search(chessboard.state, 1, history_state, Callable())
		await chessboard.clicked_move
		while true:
			if await check_move(Chess.from(chessboard.comfirm_move), Chess.to(chessboard.confirm_move), chessboard.valid_move):
				history_state.push_back(chessboard.state.get_zobrist())
				engine.stop_search()
				if engine.is_searching():
					await engine.search_finished
				break
			await chessboard.clicked_move
	match RuleStandard.get_end_type(chessboard.state):
		"checkmate_black":
			for by:int in 128:
				if chessboard.state.has_piece(by) && Chess.group(chessboard.state.get_piece(by)) == 0:
					chessboard.state.capture_piece(by)
					chessboard.chessboard_piece[by].captured()
			explore.call_deferred()
		"checkmate_white":
			for by:int in 128:
				if chessboard.state.has_piece(by) && Chess.group(chessboard.state.get_piece(by)) == 1:
					chessboard.state.capture_piece(by)
					chessboard.chessboard_piece[by].captured()
			# 死了
	in_battle = false
