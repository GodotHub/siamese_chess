extends Control

# 由于谜题数量大，测试量也比较大，故通过爬虫形式获取谜题，交给自己的引擎来解答
var engine:PastorEngine = PastorEngine.new()

func _ready() -> void:
	$http_request.connect("request_completed", on_request_completed)
	$http_request.request("https://lichess.org/api/puzzle/batch/mixed?difficulty=normal&nb=5")

func on_request_completed(_result:int, _response_code:int, _headers:PackedStringArray, _body:PackedByteArray) -> void:
	var json:Dictionary = JSON.parse_string(_body.get_string_from_utf8())
	var puzzles:Array = json["puzzles"]
	for puzzle:Dictionary in puzzles:
		var state:State = Chess.create_initial_state()
		var pgn:String = puzzle["game"]["pgn"]
		var pgn_splited:PackedStringArray = pgn.split(" ", false)
		for iter:String in pgn_splited:
			var move:int = Chess.name_to_move(state, iter)
			Chess.apply_move(state, move)
			$chessboard_flat.set_state(state)
			assert(move != -1)	# 以防某种记谱形式无法识别
		print(puzzle)	# 调试方便起见输出数据包
		print(state.print_board())
		await solve_puzzle(state)

func solve_puzzle(state:State) -> void:
	engine.set_max_depth(10)
	engine.set_think_time(20)
	engine.start_search(state, state.get_turn(), [], Callable())
	await engine.search_finished
	var text:String = Chess.get_move_name(state, engine.get_search_result())
	print("My solution: ", text)
