extends Node3D

class Level:
	var state:State = null
	var chessboard:Chessboard = null
	var ready:Callable = Callable()
	var process:Callable = Callable()


var level_1:Level = Level.new()
var level_2:Level = Level.new()
var level_3:Level = Level.new()

var ai:AI = null
var history_state:PackedInt32Array = []

func _ready() -> void:
	level_1.state = RuleStandard.parse("1Y2k1Y1/1X4X1/1X4X1/1Y4Y1/1X4X1/1X4X1/1Y4Y1/1X4X1 w - - 0 1")
	level_1.chessboard = create_chessboard(level_1.state, Vector3(0, 0, 0))
	level_1.process = func() -> void:
		var exit_1 = Chess.to_x88(59)
		var entry_1 = Chess.to_x88(3)
		var exit_2 = Chess.to_x88(60)
		var entry_2 = Chess.to_x88(4)
		if level_1.state.has_piece(exit_1):
			level_2.state.add_piece(entry_1, level_1.state.get_piece(exit_1))
			level_1.state.capture_piece(exit_1)
			level_1.chessboard.set_state(level_1.state)
			var instance:Actor = level_1.chessboard.pop_piece_instance(exit_1)
			level_2.chessboard.set_state(level_2.state)
			level_2.chessboard.add_piece_instance(instance, entry_1)
			level_2.chessboard.set_valid_move(RuleStandard.generate_valid_move(level_2.state, 1))
		if level_1.state.has_piece(exit_2):
			level_2.state.add_piece(entry_2, level_1.state.get_piece(exit_2))
			level_1.state.capture_piece(exit_2)
			level_1.chessboard.set_state(level_1.state)
			var instance:Actor = level_1.chessboard.pop_piece_instance(exit_2)
			level_2.chessboard.set_state(level_2.state)
			level_2.chessboard.add_piece_instance(instance, entry_2)
			level_2.chessboard.set_valid_move(RuleStandard.generate_valid_move(level_2.state, 1))
	level_2.state = RuleStandard.parse("1Y4Y1/1X4X1/1X4X1/1Y4Y1/1X4X1/1X4X1/1Y4Y1/1X4X1 w - - 0 1")
	level_2.chessboard = create_chessboard(level_2.state, Vector3(0, 0, 18))
	level_2.process = func() -> void:
		var exit_1 = Chess.to_x88(3)
		var entry_1 = Chess.to_x88(59)
		var exit_2 = Chess.to_x88(4)
		var entry_2 = Chess.to_x88(60)
		var exit_3 = Chess.to_x88(59)
		var entry_3 = Chess.to_x88(3)
		var exit_4 = Chess.to_x88(60)
		var entry_4 = Chess.to_x88(4)
		if level_2.state.has_piece(exit_1):
			level_1.state.add_piece(entry_1, level_2.get_piece(exit_1))
		if level_2.state.has_piece(exit_2):
			level_1.state.add_piece(entry_2, level_2.get_piece(exit_2))
		if level_2.state.has_piece(exit_3):
			level_3.state.add_piece(entry_3, level_2.get_piece(exit_3))
		if level_2.state.has_piece(exit_4):
			level_3.state.add_piece(entry_4, level_2.get_piece(exit_4))
	level_3.state = RuleStandard.parse("1Y4Y1/1X4X1/1X4X1/1Y4Y1/1X4X1/1X4X1/1Y4Y1/1X4X1 w - - 0 1")
	level_3.chessboard = create_chessboard(level_3.state, Vector3(0, 0, 36))
	level_3.process = func() -> void:
		var exit_1 = Chess.to_x88(3)
		var entry_1 = Chess.to_x88(59)
		var exit_2 = Chess.to_x88(4)
		var entry_2 = Chess.to_x88(60)
		if level_3.state.has_piece(exit_1):
			level_2.state.add_piece(entry_1, level_3.get_piece(exit_1))
		if level_3.state.has_piece(exit_2):
			level_2.state.add_piece(entry_2, level_3.get_piece(exit_2))

	ai = PastorAI.new()
	ai.set_max_depth(100)
	ai.set_think_time(3)
	$player.set_initial_interact($interact)
	explore(level_1)
	explore(level_2)
	explore(level_3)

func create_chessboard(_state:State, pos:Vector3) -> Chessboard:
	var new_chessboard:Chessboard = load("res://scene/chessboard_large.tscn").instantiate()
	add_child(new_chessboard)
	$interact.inspectable_item.push_back(new_chessboard)
	new_chessboard.global_position = pos
	new_chessboard.set_state(_state)
	for i:int in 128:
		match String.chr(_state.get_piece(i)):
			"k":
				new_chessboard.add_piece_instance(load("res://scene/cheshire.tscn").instantiate(), i)
			"X":
				new_chessboard.add_piece_instance(load("res://scene/shrub.tscn").instantiate(), i)
			"Y":
				new_chessboard.add_piece_instance(load("res://scene/tree.tscn").instantiate(), i)
	return new_chessboard

func explore(level:Level) -> void:
	while level.state.get_bit("a".unicode_at(0)):	# 有棋子再说
		level.chessboard.set_valid_move(RuleStandard.generate_valid_move(level.state, 1))
		level.chessboard.set_valid_premove([])
		await level.chessboard.move_played
		RuleStandard.apply_move(level.state, level.chessboard.confirm_move)
		await level.chessboard.animation_finished
		level.process.call()

func versus(level:Level) -> void:
	while RuleStandard.get_end_type(level.state) == "":
		level.chessboard.set_valid_move([])
		level.chessboard.set_valid_premove(RuleStandard.generate_premove(level.state, 1))
		ai.set_think_time(3)
		ai.start_search(level.state, 0, history_state, Callable())
		if ai.is_searching():
			await ai.search_finished
		var move:int = ai.get_search_result()
		
		var test_state:State = level.state.duplicate()
		var variation:PackedInt32Array = ai.get_principal_variation()
		var text:String = ""
		for iter:int in variation:
			var move_name:String = RuleStandard.get_move_name(test_state, iter)
			text += move_name + " "
			RuleStandard.apply_move(test_state, iter)
		print(text)
		
		history_state.push_back(level.state.get_zobrist())
		RuleStandard.apply_move(level.state, move)
		level.chessboard.execute_move(move)
		if RuleStandard.get_end_type(level.state) != "":
			break
		level.chessboard.set_valid_move(RuleStandard.generate_valid_move(level.state, 1))
		level.chessboard.set_valid_premove([])
		ai.set_think_time(INF)
		ai.start_search(level.state, 1, history_state, Callable())
		await level.chessboard.move_played
		history_state.push_back(level.state.get_zobrist())
		RuleStandard.apply_move(level.state, level.chessboard.confirm_move)
		ai.stop_search()
		if ai.is_searching():
			await ai.search_finished
	match RuleStandard.get_end_type(level.state):
		"checkmate_black":
			for by:int in 128:
				if level.state.has_piece(by) && Chess.group(level.state.get_piece(by)) == 0:
					level.state.capture_piece(by)
					level.chessboard.chessboard_piece[by].captured()
		"checkmate_white":
			for by:int in 128:
				if level.state.has_piece(by) && Chess.group(level.state.get_piece(by)) == 1:
					level.state.capture_piece(by)
					level.chessboard.chessboard_piece[by].captured()
