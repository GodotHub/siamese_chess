extends Control

var chess_state:State = null
var engine: PastorEngine = PastorEngine.new()

func _ready() -> void:
	chess_state = RuleStandard.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
	engine.set_think_time(INF)
	engine.set_max_depth(8)
	var thread:Thread = Thread.new()
	thread.start(score_test)

func score_test() -> void:
	engine.set_think_time(INF)
	engine.set_max_depth(6)
	chess_state = RuleStandard.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
	print(chess_state.print_board())
	engine.get_transposition_table().clear()
	engine.start_search(chess_state, 0, [], Callable())
	await engine.search_finished
	var original_score:int = engine.get_score()
	var mirrored_state:State = RuleStandard.mirror_state(chess_state)
	print(mirrored_state.print_board())
	engine.get_transposition_table().clear()
	engine.start_search(mirrored_state, 0, [], Callable())
	await engine.search_finished
	var mirrored_score:int = engine.get_score()
	var rotated_state:State = RuleStandard.rotate_state(chess_state)
	rotated_state = RuleStandard.swap_group(rotated_state)
	print(rotated_state.print_board())
	engine.get_transposition_table().clear()
	engine.start_search(rotated_state, 0, [], Callable())
	await engine.search_finished
	var rotated_score:int = engine.get_score()
	print("%d %d %d" % [original_score, mirrored_score, rotated_score])
