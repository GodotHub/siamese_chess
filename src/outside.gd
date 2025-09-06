extends Node3D

var state:State = null

func _ready() -> void:
	var cheshire_instance:Actor = load("res://scene/cheshire.tscn").instantiate()
	cheshire_instance.scale = Vector3(0.15, 0.15, 0.15)
	state = RuleStandard.create_initial_state()
	$chessboard_blank.piece_mapping["k"] = cheshire_instance
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
