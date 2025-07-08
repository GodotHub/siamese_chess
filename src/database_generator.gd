extends Control

var progress_bar:Array[ProgressBar] = []
var progress_bar_data:PackedFloat32Array = []
var zobrist:PackedInt64Array = []
var main_variation:PackedInt32Array = []
var rule_standard:RuleStandard = null
var chess_state:State = null
var transposition_table:TranspositionTable = TranspositionTable.new()

func _ready() -> void:
	if FileAccess.file_exists("user://standard_opening.fa"):
		transposition_table.load_file("user://standard_opening.fa")
	else:
		transposition_table.reserve(1 << 20)
	rule_standard = RuleStandard.new()
	chess_state = rule_standard.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
	var thread:Thread = Thread.new()
	thread.start(make_database)

func performance_test() -> float:
	var time_start:float = Time.get_ticks_usec()
	rule_standard.search(chess_state, 0, transposition_table, Callable(), 6, debug_output)
	var time_end:float = Time.get_ticks_usec()
	return time_end - time_start

func perft_test() -> void:
	var node_count:PackedInt32Array = [1, 20, 400, 8902, 197281, 4865609, 119060324, 3195901860, 84998978956, 2439530234167, 69352859712417]
	for i:int in range(node_count.size()):
		var result:int = rule_standard.perft(chess_state, i, 0)
		print("perft_test depth:%d count:%d" % [i, result])
		assert(result == node_count[i])

func _physics_process(_delta:float):
	while progress_bar_data.size() > progress_bar.size():
		add_progress_bar()
	for i:int in range(progress_bar_data.size()):
		progress_bar[i].value = progress_bar_data[i]
		$panel/margin_container/label.text = "%x" % transposition_table.best_move(chess_state.get_zobrist())

func make_database() -> void:
	perft_test()
	print("before: %dms" % performance_test())
	rule_standard.search(chess_state, 0, transposition_table, Callable(), 10, debug_output)
	print(main_variation)
	#$pastor.transposition_table = transposition_table
	transposition_table.save_file("user://standard_opening.fa")
	print("after: %dms" % performance_test())

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
