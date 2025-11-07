extends Node3D
class_name Level

signal move_camera(camera:Camera3D)

var engine:ChessEngine = null	# 有可能会出现多线作战，共用同一个引擎显然不好
var chessboard:Chessboard = null
var in_battle:bool = false
var teleport:Dictionary = {}
var history_state:PackedInt32Array = []
var level_state:String = ""
var mutex:Mutex = Mutex.new()

func _ready() -> void:
	engine = PastorEngine.new()
	var state = State.new()
	chessboard = $chessboard
	for node:Node in get_children():
		if node is Actor:
			var by:int = Chess.to_position_int(chessboard.get_position_name(node.global_position))
			state.add_piece(by, node.piece_type)
	chessboard.set_state(state)
	for node:Node in get_children():
		if node is Actor:
			var by:int = Chess.to_position_int(chessboard.get_position_name(node.global_position))
			node.get_parent().remove_child(node)
			chessboard.add_piece_instance(node, by)
	if has_node("camera"):
		chessboard.connect("clicked", move_camera.emit.call_deferred.bind($camera))
	change_state("explore_idle")

func change_state(next_state:String, arg:Dictionary = {}) -> void:
	mutex.lock()
	if has_method("state_exit_" + level_state):
		call_deferred("state_exit_" + level_state)
	level_state = next_state
	call_deferred("state_ready_" + level_state, arg)
	mutex.unlock()

func state_ready_explore_idle(_arg:Dictionary) -> void:
	chessboard.connect("ready_to_move", change_state.bind("explore_ready_to_move"))
	chessboard.set_valid_move(RuleStandard.generate_explore_move(chessboard.state, 1))	# TODO: 由于移花接木机制，这个情况下Cheshire不会进行寻路。

func state_exit_explore_idle() -> void:
	chessboard.disconnect("ready_to_move", change_state.bind("explore_move"))

func state_ready_explore_ready_to_move(_arg:Dictionary) -> void:
	HoldCard.show_card()
	chessboard.connect("clicked_move", change_state.bind("explore_check_move"))
	chessboard.connect("canceled", change_state.bind("explore_idle"))
	HoldCard.connect("selected", change_state.bind("explore_use_card"))

func state_exit_explore_ready_to_move() -> void:
	HoldCard.hide_card()
	chessboard.disconnect("clicked_move", change_state.bind("explore_check_move"))
	chessboard.disconnect("canceled", change_state.bind("explore_idle"))
	HoldCard.disconnect("selected", change_state.bind("explore_use_card"))

func state_ready_explore_check_move(_arg:Dictionary) -> void:
	var from:int = Chess.from(chessboard.confirm_move)
	var to:int = Chess.to(chessboard.confirm_move)
	var valid_move:Dictionary = chessboard.valid_move
	if from & 0x88 || to & 0x88 || !valid_move.has(from):
		change_state("explore_idle", {})
		return
	var move_list:PackedInt32Array = valid_move[from].filter(func (move:int) -> bool: return to == Chess.to(move))
	if move_list.size() == 0:
		change_state("explore_idle", {})
		return
	elif move_list.size() > 1:
		change_state("explore_extra_move", {"move_list": move_list})

	else:
		change_state("explore_move", {"move": move_list[0]})

func state_ready_explore_extra_move(_arg:Dictionary) -> void:
	var decision_list:PackedStringArray = []
	for iter:int in _arg["move_list"]:
		decision_list.push_back("%c" % Chess.extra(iter))
	decision_list.push_back("cancel")
	Dialog.connect("on_next", func () -> void:
		if Dialog.selected == decision_list.size():
			change_state.bind("explore_idle")
		else:
			change_state.bind("explore_move", {"move": _arg["move_list"][Dialog.selected]}), ConnectFlags.CONNECT_ONE_SHOT)
	Dialog.push_selection(decision_list, true, true)

func state_ready_explore_move(_arg:Dictionary) -> void:
	chessboard.connect("animation_finished", change_state.bind("explore_check_attack"), ConnectFlags.CONNECT_ONE_SHOT)
	chessboard.execute_move(_arg["move"])

func state_ready_explore_check_attack(_arg:Dictionary) -> void:
	var white_move_list:PackedInt32Array = RuleStandard.generate_valid_move(chessboard.state, 0)
	for move:int in white_move_list:
		var to:int = Chess.to(move)
		if chessboard.state.has_piece(to):
			continue
		if char(chessboard.state.get_piece(to)) in ["k", "q", "r", "b", "n", "p"]:
			change_state("versus_enemy")
			return
	change_state("explore_idle")

func state_ready_explore_use_card(_arg:Dictionary) -> void:
	HoldCard.show_card()
	if !is_instance_valid(HoldCard.selected_card):
		change_state("explore_ready_to_move")
		return
	chessboard.connect("canceled", change_state.bind("explore_idle"))
	chessboard.connect("clicked_move", change_state.bind("explore_using_card"))
	HoldCard.connect("selected", change_state.bind("explore_use_card"))

func state_exit_explore_use_card() -> void:
	HoldCard.hide_card()
	chessboard.disconnect("canceled", change_state.bind("explore_idle"))
	chessboard.disconnect("clicked_move", change_state.bind("explore_using_card"))
	HoldCard.disconnect("selected", change_state.bind("explore_use_card"))

func state_ready_explore_using_card(_arg:Dictionary) -> void:
	var card:Card = HoldCard.selected_card
	card.use_card(chessboard, Chess.to(chessboard.confirm_move))
	HoldCard.deselect()
	change_state("explore_check_attack")

func state_ready_versus_enemy(_arg:Dictionary) -> void:
	chessboard.set_valid_movd([])
	engine.connect("search_finished", func() -> void:
		change_state("versus_move", {"move": engine.get_search_result()})
		, ConnectFlags.CONNECT_ONE_SHOT)
	engine.set_think_time(3)
	engine.start_search(chessboard.state, 0, history_state, Callable())

func state_ready_versus_waiting() -> void:
	engine.connect("search_finished", change_state.bind("versus_enemy"))

func state_ready_versus_move(_arg:Dictionary) -> void:
	history_state.push_back(chessboard.state.get_zobrist())
	chessboard.connect("animation_finished", func() -> void:
		if chessboard.state.get_turn() == 0:
			if engine.is_searching():
				change_state("versus_waiting")
			else:
				change_state("versus_enemy")
		else:
			change_state("versus_player")
	, ConnectFlags.CONNECT_ONE_SHOT)
	chessboard.execute_move(_arg["move"])

func state_ready_versus_player(_arg:Dictionary) -> void:
	chessboard.connect("clicked_move", change_state.bind("versus_check_move"))
	chessboard.set_valid_move(RuleStandard.generate_valid_move(chessboard.state, 1))
	engine.set_think_time(INF)
	engine.start_search(chessboard.state, 1, history_state, Callable())

func state_ready_versus_check_move(_arg:Dictionary) -> void:
	var from:int = Chess.from(chessboard.confirm_move)
	var to:int = Chess.to(chessboard.confirm_move)
	var valid_move:Dictionary = chessboard.valid_move
	if from & 0x88 || to & 0x88 || !valid_move.has(from):
		change_state("versus_player", {})
		return
	var move_list:PackedInt32Array = valid_move[from].filter(func (move:int) -> bool: return to == Chess.to(move))
	if move_list.size() == 0:
		change_state("versus_player", {})
		return
	elif move_list.size() > 1:
		change_state("versus_extra_move", {"move_list": move_list})

	else:
		change_state("versus_move", {"move": move_list[0]})

func state_ready_versus_extra_move(_arg:Dictionary) -> void:
	var decision_list:PackedStringArray = []
	for iter:int in _arg["move_list"]:
		decision_list.push_back("%c" % Chess.extra(iter))
	decision_list.push_back("cancel")
	Dialog.connect("on_next", func () -> void:
		if Dialog.selected == decision_list.size():
			change_state.bind("versus_player")
		else:
			change_state.bind("versus_move", {"move": _arg["move_list"][Dialog.selected]}), ConnectFlags.CONNECT_ONE_SHOT)
	Dialog.push_selection(decision_list, true, true)
