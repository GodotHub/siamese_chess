extends Node3D

signal game_ended

var history_state:PackedInt64Array = []
var engine:ChessEngine = PastorEngine.new()

func _ready() -> void:
	engine.connect("search_finished", in_game_black)
	$level/table_0/chessboard_standard.connect("clicked_move", in_game_white)

	engine.set_max_depth(6)
	engine.set_think_time(INF)
	$player.force_set_camera($level/camera)
	$level/table_0/chessboard_standard.set_enabled(false)
	$level/chessboard/pieces/pastor.play_animation("thinking")
	$level.interact_list[0x54] = {"下棋": interact_pastor}
	$level.interact_list[0x55] = {"下棋": interact_pastor}
	$level.interact_list[0x25] = {"": change_scene}

func interact_pastor() -> void:
	var from:int = $level/chessboard.state.bit_index("k".unicode_at(0))[0]
	from = Chess.to_x88(from)
	$level/chessboard.execute_move(Chess.create(from, 0x54, 0))
	await $level/chessboard.animation_finished
	$level/chessboard.set_enabled(false)
	$level/table_0/chessboard_standard.set_enabled(true)
	$level/chessboard/pieces/cheshire.set_position($level/chessboard.convert_name_to_position("e2"))
	$level/chessboard/pieces/cheshire.play_animation("thinking")
	$player.force_set_camera($level/camera_chessboard)
	in_game()
	await game_ended

func in_game() -> void:
	$level/table_0/chessboard_standard.state = RuleStandard.create_initial_state()
	$level/table_0/chessboard_standard.add_default_piece_set()
	in_game_white.call_deferred()

func in_game_white() -> void:
	if $level/table_0/chessboard_standard.confirm_move != 0:
		history_state.push_back($level/table_0/chessboard_standard.state.get_zobrist())
		$level/table_0/chessboard_standard.execute_move($level/table_0/chessboard_standard.confirm_move)
	if RuleStandard.get_end_type($level/table_0/chessboard_standard.state) != "":
		game_end.call_deferred()
		return
	$level/table_0/chessboard_standard.set_valid_move([])
	engine.start_search($level/table_0/chessboard_standard.state, 0, history_state, Callable())

func in_game_black() -> void:
	history_state.push_back($level/table_0/chessboard_standard.state.get_zobrist())
	$level/table_0/chessboard_standard.execute_move(engine.get_search_result())
	if RuleStandard.get_end_type($level/table_0/chessboard_standard.state) != "":
		game_end.call_deferred()
		return
	$level/table_0/chessboard_standard.set_valid_move(RuleStandard.generate_valid_move($level/table_0/chessboard_standard.state, 1))

func game_end() -> void:
	$player.force_set_camera($level/camera)
	$level/chessboard/pieces/cheshire.play_animation("battle_idle")
	$level/chessboard/pieces/cheshire.set_position($level/chessboard.convert_name_to_position("e3"))
	$level/chessboard.set_enabled(true)
	$level/table_0/chessboard_standard.set_enabled(false)
	game_ended.emit()

func change_scene() -> void:
	Loading.change_scene("res://scene/outside_0.tscn", {"by": 0x04})
