extends Node3D

var state:State = null
var ai:AI = null
var history_state:PackedInt32Array = []

func _ready() -> void:
	ai = PastorAI.new()
	ai.set_max_depth(6)
	var fallback_piece:Actor = load("res://scene/piece_shrub.tscn").instantiate().set_show_on_backup(false)
	fallback_piece.scale *= 16
	state = RuleStandard.create_random_state(10)
	$chessboard_blank.fallback_piece = fallback_piece
	for i:int in 10:
		$chessboard_blank.add_piece_instance(load("res://scene/flower.tscn").instantiate())
	for i:int in 10:
		$chessboard_blank.add_piece_instance(load("res://scene/shrub.tscn").instantiate())
	for i:int in 10:
		$chessboard_blank.add_piece_instance(load("res://scene/tree.tscn").instantiate())
	$chessboard_blank.add_piece_instance(load("res://scene/cheshire.tscn").instantiate())
	$chessboard_blank.add_piece_instance(load("res://scene/enemy_cheshire.tscn").instantiate())
	$chessboard_blank.set_state(state.duplicate())
	$player.set_initial_interact($interact)
	play()

func play() -> void:
	while RuleStandard.get_end_type(state) == "":
		$chessboard_blank.set_valid_move([])
		$chessboard_blank.set_valid_premove(RuleStandard.generate_premove(state, 1))
		ai.start_search(state, 0, INF, history_state, Callable())
		if ai.is_searching():
			await ai.search_finished
		var move:int = ai.get_search_result()
		history_state.push_back(state.get_zobrist())
		RuleStandard.apply_move(state, move)
		$chessboard_blank.execute_move(move)
		if RuleStandard.get_end_type(state) != "":
			break
		$chessboard_blank.set_valid_move(RuleStandard.generate_valid_move(state, 1))
		$chessboard_blank.set_valid_premove([])
		ai.start_search(state, 1, INF, history_state, Callable())
		await $chessboard_blank.move_played
		history_state.push_back(state.get_zobrist())
		RuleStandard.apply_move(state, $chessboard_blank.confirm_move)
		ai.stop_search()
		if ai.is_searching():
			await ai.search_finished
