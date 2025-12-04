extends Control

var progress_bar:Array[ProgressBar] = []
var progress_bar_data:PackedFloat32Array = []
var zobrist:PackedInt64Array = []
var main_variation:PackedInt32Array = []
var chess_state:State = null
var engine: PastorEngine = PastorEngine.new()

func _ready() -> void:
	chess_state = Chess.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
	engine.set_think_time(INF)
	engine.set_max_depth(8)
	var thread:Thread = Thread.new()
	thread.start(performance_test)

func _physics_process(_delta:float) -> void:
	while progress_bar_data.size() > progress_bar.size():
		add_progress_bar()
	for i:int in range(progress_bar_data.size()):
		progress_bar[i].value = progress_bar_data[i]

func performance_test() -> void:
	chess_state = Chess.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
	var time_start:float = Time.get_ticks_usec()
	# Chess.search(chess_state, 0, transposition_table, Callable(), 6, debug_output)
	engine.start_search(chess_state, 0, [], debug_output)
	await engine.search_finished
	var time_end:float = Time.get_ticks_usec()
	var test_state:State = chess_state.duplicate()
	var variation:PackedInt32Array = engine.get_principal_variation()
	var text:String = ""
	for iter:int in variation:
		var move_name:String = Chess.get_move_name(test_state, iter)
		text += move_name + " "
		Chess.apply_move(test_state, iter)
	print(text)
	print(time_end - time_start)

func debug_output(_zobrist:int, depth:int, cur:int, total:int) -> void:
	while depth >= progress_bar_data.size():
		zobrist.push_back(0)
		progress_bar_data.push_back(0)
	zobrist[depth] = _zobrist
	progress_bar_data[depth] = float(cur) / float(total) * 100.0

func add_progress_bar() -> void:
	var new_progress_bar:ProgressBar = ProgressBar.new()
	new_progress_bar.fill_mode = ProgressBar.FILL_BOTTOM_TO_TOP
	new_progress_bar.custom_minimum_size = Vector2(50, 300)
	progress_bar.push_back(new_progress_bar)
	$panel_2/margin_container/h_box_container.add_child(new_progress_bar)
