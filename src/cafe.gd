extends Level

signal game_ended

var standard_history_zobrist:PackedInt64Array = []
var standard_history_state:Array[State] = []
var standard_history_event:Array[Dictionary] = []
var standard_engine:ChessEngine = PastorEngine.new()

func _ready() -> void:
	super._ready()
	var cheshire_by:int = get_meta("by")
	var cheshire_instance:Actor = load("res://scene/cheshire.tscn").instantiate()
	cheshire_instance.position = $chessboard.convert_name_to_position(Chess.to_position_name(cheshire_by))
	$chessboard.state.add_piece(cheshire_by, "k".unicode_at(0))
	$chessboard.add_piece_instance(cheshire_instance, cheshire_by)
	
	standard_engine.connect("search_finished", in_game_black)
	$table_0/chessboard_standard.connect("clicked_move", in_game_black_check_move)

	standard_engine.set_max_depth(6)
	standard_engine.set_think_time(INF)
	$player.force_set_camera($camera)
	$table_0/chessboard_standard.set_enabled(false)
	$chessboard/pieces/pastor.play_animation("thinking")
	interact_list[0x54] = {"下棋": interact_pastor}
	title[0x54] = "玉兰"
	interact_list[0x55] = {"下棋": interact_pastor}
	title[0x55] = "玉兰"

func interact_pastor() -> void:
	var from:int = $chessboard.state.bit_index("k".unicode_at(0))[0]
	from = Chess.to_x88(from)
	if from != 0x54:
		$chessboard.execute_move(Chess.create(from, 0x54, 0))
	$chessboard.set_enabled(false)
	$table_0/chessboard_standard.set_enabled(true)
	$chessboard/pieces/cheshire.set_position($chessboard.convert_name_to_position("e2"))
	$chessboard/pieces/cheshire.play_animation("thinking")
	$player.force_set_camera($camera_chessboard)
	in_game()
	await game_ended

func in_game() -> void:
	$table_0/chessboard_standard.state = RuleStandard.create_initial_state()
	$table_0/chessboard_standard.add_default_piece_set()
	in_game_white.call_deferred()

func in_game_white() -> void:
	if $table_0/chessboard_standard.confirm_move != 0:
		standard_history_zobrist.push_back($table_0/chessboard_standard.state.get_zobrist())
		standard_history_state.push_back($table_0/chessboard_standard.state.duplicate())
		var rollback_event:Dictionary = $table_0/chessboard_standard.execute_move($table_0/chessboard_standard.confirm_move)
		standard_history_event.push_back(rollback_event)
	if RuleStandard.get_end_type($table_0/chessboard_standard.state) != "":
		game_end.call_deferred()
		return
	$table_0/chessboard_standard.set_valid_move([])
	standard_engine.start_search($table_0/chessboard_standard.state, 0, standard_history_zobrist, Callable())

func in_game_black() -> void:
	if standard_history_event.size() <= 1:
		Dialog.push_selection(["离开对局"], false, false)
	else:
		Dialog.push_selection(["悔棋", "离开对局"], false, false)
	Dialog.connect("on_next", on_select_dialog, ConnectFlags.CONNECT_ONE_SHOT)
	standard_history_zobrist.push_back($table_0/chessboard_standard.state.get_zobrist())
	standard_history_state.push_back($table_0/chessboard_standard.state.duplicate())
	var rollback_event:Dictionary = $table_0/chessboard_standard.execute_move(standard_engine.get_search_result())
	standard_history_event.push_back(rollback_event)
	if RuleStandard.get_end_type($table_0/chessboard_standard.state) != "":
		game_end.call_deferred()
		return
	$table_0/chessboard_standard.set_valid_move(RuleStandard.generate_valid_move($table_0/chessboard_standard.state, 1))

func in_game_black_check_move() -> void:
	Dialog.clear()
	Dialog.disconnect("on_next", on_select_dialog)
	var standard_chessboard:Chessboard = $table_0/chessboard_standard
	var from:int = Chess.from(standard_chessboard.confirm_move)
	var to:int = Chess.to(standard_chessboard.confirm_move)
	var valid_move:Dictionary = standard_chessboard.valid_move
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
		standard_chessboard.confirm_move = move_list[0]
		in_game_white.call_deferred()

func in_game_black_extra_move(move_list:PackedInt32Array) -> void:
	var decision_list:PackedStringArray = []
	var decision_to_move:Dictionary = {}
	var standard_chessboard:Chessboard = $table_0/chessboard_standard
	for iter:int in move_list:
		decision_list.push_back("%c" % Chess.extra(iter))
		decision_to_move[decision_list[-1]] = iter
	decision_list.push_back("cancel")
	Dialog.connect("on_next", func () -> void:
		if Dialog.selected == "cancel":
			in_game_black.call_deferred()
		else:
			standard_chessboard.confirm_move = decision_to_move[Dialog.selected]
			in_game_white.call_deferred()
	, ConnectFlags.CONNECT_ONE_SHOT)
	Dialog.push_selection(decision_list, false, true)

func on_select_dialog() -> void:
	if Dialog.selected == "悔棋":
		if standard_history_event.size() <= 1:
			Dialog.push_selection(["离开对局"], false, false)
			return
		$table_0/chessboard_standard.state = standard_history_state[-2]
		$table_0/chessboard_standard.set_valid_move(RuleStandard.generate_valid_move(standard_history_state[-2], 1))
		for i:int in 2:
			$table_0/chessboard_standard.receive_rollback_event(standard_history_event[-1])
			standard_history_zobrist.resize(standard_history_zobrist.size() - 1)
			standard_history_state.pop_back()
			standard_history_event.pop_back()
		if standard_history_event.size() <= 1:
			Dialog.push_selection(["离开对局"], false, false)
		else:
			Dialog.push_selection(["悔棋", "离开对局"], false, false)
		Dialog.connect("on_next", on_select_dialog, ConnectFlags.CONNECT_ONE_SHOT)
	elif Dialog.selected == "离开对局":
		game_end.call_deferred()

func game_end() -> void:
	match RuleStandard.get_end_type($table_0/chessboard_standard.state):
		"checkmate_black":
			Dialog.push_dialog("黑方胜", true, true)
			await Dialog.on_next
		"checkmate_white":
			Dialog.push_dialog("白方胜", true, true)
			await Dialog.on_next
		"stalemate_black":
			Dialog.push_dialog("平局", true, true)
			await Dialog.on_next
		"stalemate_white":
			Dialog.push_dialog("平局", true, true)
			await Dialog.on_next
		"50_moves":
			Dialog.push_dialog("平局", true, true)
			await Dialog.on_next
	$player.force_set_camera($camera)
	$chessboard/pieces/cheshire.play_animation("battle_idle")
	$chessboard/pieces/cheshire.set_position($chessboard.convert_name_to_position("e3"))
	$chessboard.set_enabled(true)
	$table_0/chessboard_standard.set_enabled(false)
	game_ended.emit()
