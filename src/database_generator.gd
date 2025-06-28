extends Control

var progress_bar:Array[ProgressBar] = []
var progress_bar_data:PackedFloat32Array = []
var zobrist:PackedInt64Array = []
var main_variation:PackedInt32Array = []

func _ready() -> void:
	var thread:Thread = Thread.new()
	thread.start(make_database)

func _physics_process(_delta:float):
	while progress_bar_data.size() > progress_bar.size():
		add_progress_bar()
	for i:int in range(progress_bar_data.size()):
		progress_bar[i].value = progress_bar_data[i]
		$panel/margin_container/label.text = ""
	for iter:int in main_variation:
		$panel/margin_container/label.text += "%x->%x" % [Move.from(iter), Move.to(iter)]
		if Move.extra(iter):
			$panel/margin_container/label.text += ":%d" % [Move.extra(iter)]
		$panel/margin_container/label.text += " "

func make_database() -> void:
	var transposition_table:TranspositionTable = TranspositionTable.new()
	transposition_table.reserve(1 << 20)
	var chess_state:ChessState = EvaluationStandard.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
	EvaluationStandard.search(chess_state, 0, main_variation, transposition_table, Callable(), 10, debug_output)
	#$pastor.transposition_table = transposition_table
	transposition_table.save_file("user://standard_opening.fa")

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
