extends Node3D

var state:State = null

func _ready() -> void:
	var fallback_piece:Actor = load("res://scene/piece_shrub.tscn").instantiate().set_show_on_backup(false).set_larger_scale()
	state = RuleStandard.parse("1Y2k1Y1/1X4X1/1X4X1/1Yz3Y1/1X4X1/1X4X1/1Y4Y1/1X4X1 w - - 0 1")
	for i:int in 10:
		$chessboard_blank.add_piece_instance(load("res://scene/shrub.tscn").instantiate())
	for i:int in 10:
		$chessboard_blank.add_piece_instance(load("res://scene/tree.tscn").instantiate())
	$chessboard_blank.add_piece_instance(load("res://scene/carnation.tscn").instantiate().set_direction(PI / 2))
	var cheshire:Actor = load("res://scene/cheshire.tscn").instantiate()
	$chessboard_blank.add_piece_instance(cheshire)
	$chessboard_blank.set_state(state.duplicate())
	$player.set_initial_interact($interact)
	play()

func generate_king_move(_state:State) -> PackedInt32Array:
	var output:PackedInt32Array = []
	var from_bit:int = _state.get_bit("k".unicode_at(0))
	var from:int = 0
	while from_bit != 1:
		from_bit >>= 1
		from += 1
	from = from % 8 + from / 8 * 16
	for i:int in 64:
		var to:int = i % 8 + i / 8 * 16
		if from == to:
			continue
		output.push_back(Chess.create(from, to, 0))
	return output

func play() -> void:
	while true:
		$chessboard_blank.set_valid_move(generate_king_move(state))
		$chessboard_blank.set_valid_premove([])
		await $chessboard_blank.move_played
		RuleStandard.apply_move(state, $chessboard_blank.confirm_move)
		if state.get_bit("k".unicode_at(0)) & (Chess.mask(59) | Chess.mask(60)):
			get_tree().change_scene_to_file.call_deferred("res://scene/outside.tscn")
			break
