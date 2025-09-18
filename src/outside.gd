extends Node3D

var state:State = null

func _ready() -> void:
	var fallback_piece:Actor = load("res://scene/piece_shrub.tscn").instantiate()
	fallback_piece.scale *= 16
	state = RuleStandard.create_initial_state()
	$chessboard_blank.fallback_piece = fallback_piece
	$chessboard_blank.add_piece_instance(load("res://scene/cheshire.tscn").instantiate(), Vector3(0, 0, 0), true)
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
