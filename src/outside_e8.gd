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

func play() -> void:
	while true:
		$chessboard_blank.set_valid_move(RuleStandard.generate_valid_move(state, 1))
		$chessboard_blank.set_valid_premove([])
		await $chessboard_blank.move_played
		RuleStandard.apply_move(state, $chessboard_blank.confirm_move)
		if state.get_bit("k".unicode_at(0)) & (Chess.mask(59) | Chess.mask(60)):
			get_tree().change_scene_to_file.call_deferred("res://scene/outside.tscn")
			break
