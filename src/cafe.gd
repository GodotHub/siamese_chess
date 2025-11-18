extends Node3D

signal game_ended

var history_state:PackedInt64Array = []
var engine:ChessEngine = PastorEngine.new()

func _ready() -> void:
	var cheshire_by:int = get_meta("by")
	var cheshire_instance:Actor = load("res://scene/cheshire.tscn").instantiate()
	cheshire_instance.position = $level/chessboard.convert_name_to_position(Chess.to_position_name(cheshire_by))
	$level/chessboard.state.add_piece(cheshire_by, "k".unicode_at(0))
	$level/chessboard.add_piece_instance(cheshire_instance, cheshire_by)
	
	engine.connect("search_finished", in_game_black)
	$level/table_0/chessboard_standard.connect("clicked_move", in_game_black_check_move)

	engine.set_max_depth(6)
	engine.set_think_time(INF)
	$player.force_set_camera($level/camera)
	$level/table_0/chessboard_standard.set_enabled(false)
	$level/chessboard/pieces/pastor.play_animation("thinking")
	$level.interact_list[0x54] = {"下棋": interact_pastor}
	$level.title[0x54] = "玉兰"
	$level.interact_list[0x55] = {"下棋": interact_pastor}
	$level.title[0x55] = "玉兰"
	$level.interact_list[0x25] = {"": change_scene}

func interact_pastor() -> void:
	var from:int = $level/chessboard.state.bit_index("k".unicode_at(0))[0]
	from = Chess.to_x88(from)
	if from != 0x54:
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
	Dialog.clear()
	Dialog.disconnect("on_next", on_select_dialog)
	if $level/table_0/chessboard_standard.confirm_move != 0:
		history_state.push_back($level/table_0/chessboard_standard.state.get_zobrist())
		$level/table_0/chessboard_standard.execute_move($level/table_0/chessboard_standard.confirm_move)
	if RuleStandard.get_end_type($level/table_0/chessboard_standard.state) != "":
		game_end.call_deferred()
		return
	$level/table_0/chessboard_standard.set_valid_move([])
	engine.start_search($level/table_0/chessboard_standard.state, 0, history_state, Callable())

func in_game_black() -> void:
	Dialog.push_selection(["悔棋", "离开对局"], false, false)
	Dialog.connect("on_next", on_select_dialog, ConnectFlags.CONNECT_ONE_SHOT)
	history_state.push_back($level/table_0/chessboard_standard.state.get_zobrist())
	$level/table_0/chessboard_standard.execute_move(engine.get_search_result())
	if RuleStandard.get_end_type($level/table_0/chessboard_standard.state) != "":
		game_end.call_deferred()
		return
	$level/table_0/chessboard_standard.set_valid_move(RuleStandard.generate_valid_move($level/table_0/chessboard_standard.state, 1))

func in_game_black_check_move() -> void:
	var chessboard:Chessboard = $level/table_0/chessboard_standard
	var from:int = Chess.from(chessboard.confirm_move)
	var to:int = Chess.to(chessboard.confirm_move)
	var valid_move:Dictionary = chessboard.valid_move
	if from & 0x88 || to & 0x88 || !valid_move.has(from):
		in_game_black.call_deferred()
		return
	var move_list:PackedInt32Array = valid_move[from].filter(func (move:int) -> bool: return to == Chess.to(move))
	if move_list.size() == 0:
		in_game_black.call_deferred()
		return
	elif move_list.size() > 1:
		in_game_black_extra_move.call_deferred(move_list)
	else:
		chessboard.confirm_move = move_list[0]
		in_game_white.call_deferred()

func in_game_black_extra_move(move_list:PackedInt32Array) -> void:
	Dialog.clear()
	Dialog.disconnect("on_next", on_select_dialog)
	var decision_list:PackedStringArray = []
	var decision_to_move:Dictionary = {}
	for iter:int in move_list:
		decision_list.push_back("%c" % Chess.extra(iter))
		decision_to_move[decision_list[-1]] = iter
	decision_list.push_back("cancel")
	Dialog.connect("on_next", func () -> void:
		if Dialog.selected == "cancel":
			in_game_black.call_deferred()
		else:
			in_game_white.call_deferred()
	)
	Dialog.push_selection(decision_list, true, true)

func on_select_dialog() -> void:
	if Dialog.selected == "悔棋":
		pass
	elif Dialog.selected == "离开对局":
		game_end.call_deferred()

func game_end() -> void:
	$player.force_set_camera($level/camera)
	$level/chessboard/pieces/cheshire.play_animation("battle_idle")
	$level/chessboard/pieces/cheshire.set_position($level/chessboard.convert_name_to_position("e3"))
	$level/chessboard.set_enabled(true)
	$level/table_0/chessboard_standard.set_enabled(false)
	game_ended.emit()

func change_scene() -> void:
	HoldCard.reset()
	Loading.change_scene("res://scene/outside_0.tscn", {"by": 0x04})
