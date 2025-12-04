extends Control

# 由于谜题数量大，测试量也比较大，故通过爬虫形式获取谜题，交给自己的引擎来解答
var state:State = RuleStandard.create_initial_state()
var engine:PastorEngine = PastorEngine.new()

func _ready() -> void:
	$http_request.connect("request_completed", on_request_completed)
	$http_request.request("https://lichess.org/api/puzzle/daily")

func on_request_completed(result:int, response_code:int, headers:PackedStringArray, body:PackedByteArray) -> void:
	var json:Dictionary = JSON.parse_string(body.get_string_from_utf8())
	var state:State = RuleStandard.create_initial_state()
	var pgn:String = json["game"]["pgn"]
	var pgn_splited:PackedStringArray = pgn.split(" ", false)
	for iter:String in pgn_splited:
		var move:int = RuleStandard.name_to_move(state, iter)
		RuleStandard.apply_move(state, move)
		$chessboard_flat.set_state(state)
		assert(move != -1)	# 以防某种记谱形式无法识别
	print(json)	# 调试方便起见输出数据包
	engine.set_max_depth(20)
	engine.set_think_time(20)
	var solution:PackedStringArray = json["puzzle"]["solution"]
	engine.start_search(state, state.get_turn(), [], Callable())
	await engine.search_finished
	var text:String = RuleStandard.get_move_name(state, engine.get_search_result())
	$label.text = text
