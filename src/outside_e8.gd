extends Node3D

var state:State = null

func _ready() -> void:
	var fallback_piece:Actor = load("res://scene/piece_shrub.tscn").instantiate().set_show_on_backup(false).set_larger_scale()
	state = RuleStandard.parse("1Y2k1Y1/1X4X1/1X4X1/1Yq3Y1/1X4X1/1X4X1/1Y4Y1/1X4X1 w - - 0 1")
	for i:int in 10:
		$chessboard_blank.add_piece_instance(load("res://scene/shrub.tscn").instantiate())
	for i:int in 10:
		$chessboard_blank.add_piece_instance(load("res://scene/tree.tscn").instantiate())
	$chessboard_blank.add_piece_instance(load("res://scene/piece_queen_black.tscn").instantiate().set_show_on_backup(false).set_larger_scale())
	var cheshire:Actor = load("res://scene/cheshire.tscn").instantiate()
	$chessboard_blank.add_piece_instance(cheshire)
	$chessboard_blank.set_state(state.duplicate())
	$chessboard_blank.connect("ready_to_move", change_actor)
	$player.set_initial_interact($interact)
	$player.set_actor(cheshire)
	play()

func play() -> void:
	while true:
		$chessboard_blank.set_valid_move(RuleStandard.generate_valid_move(state, 1))
		$chessboard_blank.set_valid_premove([])
		await $chessboard_blank.move_played
		RuleStandard.apply_move(state, $chessboard_blank.confirm_move)

func change_actor(by:int) -> void:
	$player.set_actor($chessboard_blank.chessboard_piece[by])
