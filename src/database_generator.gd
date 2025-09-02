extends Control

var progress_bar:Array[ProgressBar] = []
var progress_bar_data:PackedFloat32Array = []
var zobrist:PackedInt64Array = []
var main_variation:PackedInt32Array = []
var chess_state:State = null
var ai: PastorAI = PastorAI.new()

func _ready() -> void:
	chess_state = RuleStandard.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
	ai.set_max_depth(8)
	var thread:Thread = Thread.new()
	thread.start(make_database)

func performance_test() -> float:
	chess_state = RuleStandard.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
	var time_start:float = Time.get_ticks_usec()
	# RuleStandard.search(chess_state, 0, transposition_table, Callable(), 6, debug_output)
	ai.start_search(chess_state, 0, INF, debug_output)
	await ai.search_finished
	var time_end:float = Time.get_ticks_usec()
	return time_end - time_start

func perft_test() -> void:
	var node_count:PackedInt32Array
	chess_state = RuleStandard.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
	node_count = [1, 20, 400, 8902, 197281, 4865609, 119060324]
	for i:int in range(node_count.size()):
		var result:int = RuleStandard.perft(chess_state, i, 0)
		print("perft_test_1 depth:%d expect:%d actual:%d" % [i, node_count[i], result])
	chess_state = RuleStandard.parse("r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1")
	node_count = [1, 48, 2039, 97862, 4085603, 193690690]
	for i:int in range(node_count.size()):
		var result:int = RuleStandard.perft(chess_state, i, 0)
		print("perft_test_2 depth:%d expect:%d actual:%d" % [i, node_count[i], result])
	chess_state = RuleStandard.parse("8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1")
	node_count = [1, 14, 191, 2812, 43238, 674624, 11030083]
	for i:int in range(node_count.size()):
		var result:int = RuleStandard.perft(chess_state, i, 0)
		print("perft_test_3 depth:%d expect:%d actual:%d" % [i, node_count[i], result])
	chess_state = RuleStandard.parse("r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1")
	node_count = [1, 6, 264, 9467, 422333, 15833292]
	for i:int in range(node_count.size()):
		var result:int = RuleStandard.perft(chess_state, i, 0)
		print("perft_test_4 depth:%d expect:%d actual:%d" % [i, node_count[i], result])
	chess_state = RuleStandard.parse("r2q1rk1/pP1p2pp/Q4n2/bbp1p3/Np6/1B3NBn/pPPP1PPP/R3K2R b KQ - 0 1")
	node_count = [1, 6, 264, 9467, 422333, 15833292]
	for i:int in range(node_count.size()):
		var result:int = RuleStandard.perft(chess_state, i, 1)
		print("perft_test_5 depth:%d expect:%d actual:%d" % [i, node_count[i], result])
	chess_state = RuleStandard.parse("rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8")
	node_count = [1, 44, 1486, 62379, 2103487, 89941194]
	for i:int in range(node_count.size()):
		var result:int = RuleStandard.perft(chess_state, i, 0)
		print("perft_test_6 depth:%d expect:%d actual:%d" % [i, node_count[i], result])
	chess_state = RuleStandard.parse("r4rk1/1pp1qppp/p1np1n2/2b1p1B1/2B1P1b1/P1NP1N2/1PP1QPPP/R4RK1 w - - 0 10")
	node_count = [1, 46, 2079, 89890, 3894594, 89941194]
	for i:int in range(node_count.size()):
		var result:int = RuleStandard.perft(chess_state, i, 0)
		print("perft_test_7 depth:%d expect:%d actual:%d" % [i, node_count[i], result])
	
func _physics_process(_delta:float):
	while progress_bar_data.size() > progress_bar.size():
		add_progress_bar()
	for i:int in range(progress_bar_data.size()):
		progress_bar[i].value = progress_bar_data[i]
		$panel/margin_container/label.text = "%x" % ai.get_transposition_table().best_move(chess_state.get_zobrist())

func make_database() -> void:
	#perft_test()
	print("before: %dms" % await performance_test())
	chess_state = RuleStandard.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
	# RuleStandard.search(chess_state, 0, transposition_table, Callable(), 10, debug_output)
	ai.set_max_depth(20)
	ai.start_search(chess_state, 0, INF, debug_output)
	await ai.search_finished
	print(main_variation)
	#$pastor.transposition_table = transposition_table
	ai.get_transposition_table().save_file("user://standard_opening.fa")
	print("after: %dms" % await performance_test())

func debug_output(_zobrist:int, depth:int, cur:int, total:int) -> void:
	while depth >= progress_bar_data.size():
		zobrist.push_back(0)
		progress_bar_data.push_back(0)
	zobrist[depth] = _zobrist
	progress_bar_data[depth] = float(cur) / float(total) * 100.0

func get_value(depth:int, move:int, _value:int) -> void:
	if main_variation.size() <= depth:
		main_variation.resize(depth + 1)
	main_variation[depth] = move

func add_progress_bar() -> void:
	var new_progress_bar:ProgressBar = ProgressBar.new()
	new_progress_bar.fill_mode = ProgressBar.FILL_BOTTOM_TO_TOP
	new_progress_bar.custom_minimum_size = Vector2(50, 300)
	progress_bar.push_back(new_progress_bar)
	$panel_2/margin_container/h_box_container.add_child(new_progress_bar)
