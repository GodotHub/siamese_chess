extends Control

var engine:PastorEngine = PastorEngine.new()
var state:State = null

func _ready() -> void:
	state = Chess.create_initial_state()
	engine.set_max_depth(8)
	engine.set_think_time(INF)
	engine.connect("search_finished", print_tt)
	engine.start_search(state, 0, [], Callable())

func print_tt() -> void:
	var tt:TranspositionTable = engine.get_transposition_table()
	tt.print_status()
