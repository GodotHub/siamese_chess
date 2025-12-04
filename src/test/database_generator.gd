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
	thread.start(make_database)

func _physics_process(_delta:float) -> void:
	while progress_bar_data.size() > progress_bar.size():
		add_progress_bar()
	for i:int in range(progress_bar_data.size()):
		progress_bar[i].value = progress_bar_data[i]

func make_database() -> void:
	chess_state = Chess.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
	engine.set_max_depth(20)
	engine.start_search(chess_state, 0, [], debug_output)
	await engine.search_finished
	main_variation = engine.get_principal_variation()
	print(main_variation)
	engine.get_transposition_table().save_file("user://standard_opening.fa")

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
