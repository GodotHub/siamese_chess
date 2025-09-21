extends Node3D

var state:State = null

func _ready() -> void:
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
	$chessboard_blank.connect("move_played", receive_move)
	$player.set_initial_interact($interact)
	update_move()

func receive_move() -> void:
	RuleStandard.apply_move(state, $chessboard_blank.confirm_move)
	update_move()

func update_move() -> void:
	var move_list:PackedInt32Array = RuleStandard.generate_valid_move(state, state.get_turn())
	var premove_list:PackedInt32Array = RuleStandard.generate_premove(state, 1 - state.get_turn())
	$chessboard_blank.set_valid_move(move_list)
	$chessboard_blank.set_valid_premove(premove_list)
