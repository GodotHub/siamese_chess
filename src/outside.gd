extends Node3D


var state_1:State = null
var state_2:State = null
var state_3:State = null

var state:State = null
var ai:AI = null
var history_state:PackedInt32Array = []

func _ready() -> void:
	state_1 = RuleStandard.parse("1Y2k1Y1/1X4X1/1X4X1/1Y4Y1/1X4X1/1X4X1/1Y4Y1/1X4X1 w - - 0 1")
	state_2 = RuleStandard.parse("1Y4Y1/1X4X1/1X4X1/1Y4Y1/1X4X1/1X4X1/1Y4Y1/1X4X1 w - - 0 1")
	state_3 = RuleStandard.parse("1Y4Y1/1X4X1/1X4X1/1Y4Y1/1X4X1/1X4X1/1Y4Y1/1X4X1 w - - 0 1")
	ai = PastorAI.new()
	ai.set_max_depth(100)
	ai.set_think_time(3)
	var fallback_piece:Actor = load("res://scene/piece_shrub.tscn").instantiate().set_show_on_backup(false).set_larger_scale()
	state = RuleStandard.create_random_state(10)
	$chessboard_blank.set_state(state)
	$chessboard_blank.fallback_piece = fallback_piece
	for i:int in 128:
		match String.chr(state.get_piece(i)):
			"K":
				$chessboard_blank.add_piece_instance(load("res://scene/enemy_cheshire.tscn").instantiate(), i)
			"Q":
				$chessboard_blank.add_piece_instance(load("res://scene/piece_queen_white.tscn").instantiate().set_show_on_backup(false).set_larger_scale(), i)
			"R":
				$chessboard_blank.add_piece_instance(load("res://scene/piece_rook_white.tscn").instantiate().set_show_on_backup(false).set_larger_scale(), i)
			"B":
				$chessboard_blank.add_piece_instance(load("res://scene/piece_bishop_white.tscn").instantiate().set_show_on_backup(false).set_larger_scale(), i)
			"N":
				$chessboard_blank.add_piece_instance(load("res://scene/piece_knight_white.tscn").instantiate().set_show_on_backup(false).set_larger_scale(), i)
			"P":
				$chessboard_blank.add_piece_instance(load("res://scene/piece_pawn_white.tscn").instantiate().set_show_on_backup(false).set_larger_scale(), i)
			"W":
				$chessboard_blank.add_piece_instance(load("res://scene/flower.tscn").instantiate(), i)
			"X":
				$chessboard_blank.add_piece_instance(load("res://scene/shrub.tscn").instantiate(), i)
			"Y":
				$chessboard_blank.add_piece_instance(load("res://scene/tree.tscn").instantiate(), i)
			"Z":
				$chessboard_blank.add_piece_instance(load("res://scene/piece_checker_1_white.tscn").instantiate().set_show_on_backup(false).set_larger_scale(), i)
			"k":
				$chessboard_blank.add_piece_instance(load("res://scene/cheshire.tscn").instantiate(), i)
			"q":
				$chessboard_blank.add_piece_instance(load("res://scene/piece_queen_black.tscn").instantiate().set_show_on_backup(false).set_larger_scale(), i)
			"r":
				$chessboard_blank.add_piece_instance(load("res://scene/piece_rook_black.tscn").instantiate().set_show_on_backup(false).set_larger_scale(), i)
			"b":
				$chessboard_blank.add_piece_instance(load("res://scene/piece_bishop_black.tscn").instantiate().set_show_on_backup(false).set_larger_scale(), i)
			"n":
				$chessboard_blank.add_piece_instance(load("res://scene/piece_knight_black.tscn").instantiate().set_show_on_backup(false).set_larger_scale(), i)
			"p":
				$chessboard_blank.add_piece_instance(load("res://scene/piece_pawn_black.tscn").instantiate().set_show_on_backup(false).set_larger_scale(), i)
			"w":
				$chessboard_blank.add_piece_instance(load("res://scene/flower.tscn").instantiate(), i)
			"x":
				$chessboard_blank.add_piece_instance(load("res://scene/shrub.tscn").instantiate(), i)
			"y":
				$chessboard_blank.add_piece_instance(load("res://scene/tree.tscn").instantiate(), i)
			"z":
				$chessboard_blank.add_piece_instance(load("res://scene/piece_checker_1_black.tscn").instantiate().set_show_on_backup(false).set_larger_scale(), i)
	$player.set_initial_interact($interact)
	versus()

func create_chessboard(_state:State, pos:Vector3) -> void:
	var new_chessboard:Chessboard = load("res://scene/chessboard_large.tscn").instantiate()
	add_child(new_chessboard)
	new_chessboard.global_position = pos
	new_chessboard.set_state(_state)
	for i:int in 128:
		match String.chr(state.get_piece(i)):
			"k":
				new_chessboard.add_piece_instance(load("res://scene/cheshire.tscn").instantiate(), i)
			"X":
				new_chessboard.add_piece_instance(load("res://scene/shrub.tscn").instantiate(), i)
			"Y":
				new_chessboard.add_piece_instance(load("res://scene/tree.tscn").instantiate(), i)

func explore(_chessboard:Chessboard, _state:State) -> void:
	while true:
		_chessboard.set_valid_move(RuleStandard.generate_valid_move(_state, 1))
		_chessboard.set_valid_premove([])
		await _chessboard.move_played
		RuleStandard.apply_move(_state, _chessboard.confirm_move)

func versus() -> void:
	while RuleStandard.get_end_type(state) == "":
		$chessboard_blank.set_valid_move([])
		$chessboard_blank.set_valid_premove(RuleStandard.generate_premove(state, 1))
		ai.set_think_time(3)
		ai.start_search(state, 0, history_state, Callable())
		if ai.is_searching():
			await ai.search_finished
		var move:int = ai.get_search_result()
		
		var test_state:State = state.duplicate()
		var variation:PackedInt32Array = ai.get_principal_variation()
		var text:String = ""
		for iter:int in variation:
			var move_name:String = RuleStandard.get_move_name(test_state, iter)
			text += move_name + " "
			RuleStandard.apply_move(test_state, iter)
		print(text)
		
		history_state.push_back(state.get_zobrist())
		RuleStandard.apply_move(state, move)
		$chessboard_blank.execute_move(move)
		if RuleStandard.get_end_type(state) != "":
			break
		$chessboard_blank.set_valid_move(RuleStandard.generate_valid_move(state, 1))
		$chessboard_blank.set_valid_premove([])
		ai.set_think_time(INF)
		ai.start_search(state, 1, history_state, Callable())
		await $chessboard_blank.move_played
		history_state.push_back(state.get_zobrist())
		RuleStandard.apply_move(state, $chessboard_blank.confirm_move)
		ai.stop_search()
		if ai.is_searching():
			await ai.search_finished
	match RuleStandard.get_end_type(state):
		"checkmate_black":
			for by:int in 128:
				if state.has_piece(by) && Chess.group(state.get_piece(by)) == 0:
					state.capture_piece(by)
					$chessboard_blank.chessboard_piece[by].captured()
			steady.call_deferred()
		"checkmate_white":
			for by:int in 128:
				if state.has_piece(by) && Chess.group(state.get_piece(by)) == 1:
					state.capture_piece(by)
					$chessboard_blank.chessboard_piece[by].captured()
			lose.call_deferred()

func steady() -> void:
	print("YOU WIN")

func lose() -> void:
	print("YOU LOSE")
