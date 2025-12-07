extends Control

var chess_state:State = null
var engine: PastorEngine = PastorEngine.new()
var test_case:Array = [
	{
		"fen": "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
		"node_count": [1, 20, 400, 8902, 197281, 4865609, 119060324]
	},
	{
		"fen": "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1",
		"node_count": [1, 48, 2039, 97862, 4085603, 193690690]
	},
	{
		"fen": "8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1",
		"node_count": [1, 14, 191, 2812, 43238, 674624, 11030083]
	},
	{
		"fen": "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1",
		"node_count": [1, 6, 264, 9467, 422333, 15833292]
	},
	{
		"fen": "r2q1rk1/pP1p2pp/Q4n2/bbp1p3/Np6/1B3NBn/pPPP1PPP/R3K2R b KQ - 0 1",
		"node_count": [1, 6, 264, 9467, 422333, 15833292]
	},
	{
		"fen": "rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8",
		"node_count": [1, 44, 1486, 62379, 2103487, 89941194]
	},
	{
		"fen": "r4rk1/1pp1qppp/p1np1n2/2b1p1B1/2B1P1b1/P1NP1N2/1PP1QPPP/R4RK1 w - - 0 10",
		"node_count": [1, 46, 2079, 89890, 3894594, 164075551]
	},
]
func _ready() -> void:
	chess_state = Chess.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
	engine.set_think_time(INF)
	engine.set_max_depth(8)
	var thread:Thread = Thread.new()
	thread.start(perft_test.bind(0))

func perft_test(index:int) -> void:
	chess_state = Chess.parse(test_case[index]["fen"])
	var node_count:PackedInt32Array = test_case[index]["node_count"]
	for i:int in range(node_count.size()):
		var result:int = Chess.perft(chess_state, i, 0)
		if result == node_count[i]:
			print("perft_test_%d depth:%d expect:%d actual:%d" % [index, i, node_count[i], result])
		else:
			printerr("perft_test_%d depth:%d expect:%d actual:%d" % [index, i, node_count[i], result])
