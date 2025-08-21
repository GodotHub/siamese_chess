extends Node3D

var state:State = null
var history:Array[State] = []
var score:int = 0
var think_time:int = 10
var start_thinking:float = 0
var opening_book:OpeningBook = OpeningBook.new()
var ai: PastorAI = PastorAI.new()
@onready var history_chart:Document = load("res://scene/history.tscn").instantiate()

var pastor_state:String = "idle"

var telephone_2025_first_time:bool = false

func _ready() -> void:
	$history.set_document(history_chart)
	$cheshire.set_initial_interact($interact/area_passthrough)
	$clock.connect("timeout", timeout)
	$telephone.connect("call_number", dialog_telephone)
	$interact/area_pastor.connect("clicked", select_dialog)

func select_dialog() -> void:
	if has_method("dialog_" + pastor_state):
		call("dialog_" + pastor_state)

func dialog_telephone(number:String) -> void:
	if has_method("dialog_telephone_" + number):
		call("dialog_telephone_" + number)

func dialog_telephone_2025() -> void:
	if !telephone_2025_first_time:
		telephone_2025_first_time = true
		$dialog.push_dialog("您好！", true, true)
		await $dialog.on_next
		$dialog.push_dialog("刚刚您试着打通了电话。", true, true)
		await $dialog.on_next
		$dialog.push_dialog("如果您在下棋时遇到困难，您可以通过电话询问一些建议。", true, true)
		await $dialog.on_next
		$dialog.push_dialog("只需要告诉我局面，我会提示您我认为最佳的着法。", true, true)
		await $dialog.on_next
	else:
		$dialog.push_dialog("您好！", true, true)
		await $dialog.on_next
		if state:
			var test_state:State = state.duplicate()
			$dialog.push_dialog("您是在和谁下棋吗？可以告诉我现在什么情况？", true, true)
			await $dialog.on_next
			$dialog.push_dialog("……", true, true)
			await $dialog.on_next
			if state.get_turn() == 0:
				$dialog.push_dialog("现在是对手在下棋，您可以先看一下他的应对方式。", true, true)
				await $dialog.on_next
				return
			$dialog.push_dialog("这样啊……", true, true)
			await $dialog.on_next
			$dialog.push_dialog("容我稍作思考。", true, true, true)
			var telephone_ai:PastorAI = PastorAI.new()
			telephone_ai.set_max_depth(6)
			telephone_ai.start_search(test_state, 1, INF, Callable())
			if telephone_ai.is_searching():
				await telephone_ai.search_finished
			var best_move:int = telephone_ai.get_search_result()
			$dialog.next()
			$dialog.push_dialog("我认为您应当下" + RuleStandard.get_move_name(test_state, best_move), true, true)
			await $dialog.on_next
		else:
			$dialog.push_dialog("现在您还没在下棋，我暂时帮不上。", true, true)
			await $dialog.on_next

func dialog_idle() -> void:
	$cheshire.force_set_camera($camera/camera_pastor_closeup)
	$dialog.push_selection(["下棋？", "询问规则", "返回"])
	await $dialog.on_next
	if $dialog.selected == 0:
		dialog_start_game()
	elif $dialog.selected == 1:
		dialog_description_chess()

func dialog_description_chess() -> void:
	$dialog.push_dialog("这只是标准的国际象棋。", true, true)
	$cheshire.force_set_camera($camera/camera_pastor_closeup)
	await $dialog.on_next
	$dialog.push_dialog("在这里，您至少需要了解国际象棋的基本规则。", true, true)
	$cheshire.force_set_camera($camera/camera_pastor_closeup)
	await $dialog.on_next
	$dialog.push_dialog("不过，如果您对这种游戏仍然一头雾水，您也可以试着上手，", true, true)
	$cheshire.force_set_camera($camera/camera_pastor_closeup)
	await $dialog.on_next
	$dialog.push_dialog("您可以边对照规则边上手实践，我也会提示一些可走的着法，", true, true)
	$cheshire.force_set_camera($camera/camera_pastor_closeup)
	await $dialog.on_next
	$dialog.push_dialog("不过……我不会放水，请做好输棋的心理准备吧。", true, true)
	$cheshire.force_set_camera($camera/camera_pastor_closeup)
	await $dialog.on_next

func dialog_in_game() -> void:
	$dialog.push_selection(["提出悔棋", "结束棋局", "取消"])
	$cheshire.force_set_camera($camera/camera_pastor_closeup)
	await $dialog.on_next
	$cheshire.add_stack($interact/area_chessboard)
	if $dialog.selected == 0:
		if history.size() <= 2:	# 白方第一步棋无法撤回
			return
		if history.back().get_turn() == 1:
			history.pop_back()
		if history.back().get_turn() == 0:
			history.pop_back()
			ai.stop_search()
		state = history.back().duplicate()
	elif $dialog.selected == 1:
		ai.stop_search()
		$clock.stop()
		$chessboard.set_valid_move([])
		$chessboard.set_valid_premove([])
		pastor_state = "idle"
	elif $dialog.selected == 2:
		return

func dialog_start_game() -> void:
	while true:
		$dialog.push_selection(["标准棋局（30+0）", "快棋（10+5）", "超快棋（5+3）", "子弹棋（小规模布局，1/2+0）", "导入棋局"])
		await $dialog.on_next
		if $dialog.selected in [0, 1, 2]:
			state = RuleStandard.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
			$chessboard.set_state(state)
			history_chart.set_state(state)
			if $dialog.selected == 0:
				$clock.set_time(1800, 1, 0)
				think_time = 5
			elif $dialog.selected == 1:
				$clock.set_time(600, 1, 5)
				think_time = 3
			elif $dialog.selected == 2:
				$clock.set_time(300, 1, 3)
				think_time = 2
			$dialog.push_dialog("现在棋盘已经准备好了。", true, true)
			$cheshire.force_set_camera($camera/camera_chessboard)
			await $dialog.on_next
			$dialog.push_dialog("您是黑方后手开局，时间有限，请注意合理分配。", true, true)
			$cheshire.force_set_camera($camera/camera_pastor_closeup)
			await $dialog.on_next
			$clock.start()
			$cheshire.add_stack($interact/area_chessboard)
			pastor_state = "in_game"
			call_deferred("in_game")
			break
		elif $dialog.selected == 3:
			state = RuleStandard.parse("8/8/2rbqk2/2pppn2/2NPPP2/2KQBR2/8/8 w - - 0 1")
			$chessboard.set_state(state)
			history_chart.set_state(state)
			$clock.set_time(30, 1, 0)
			think_time = 1
			$dialog.push_dialog("现在棋盘已经准备好了。", true, true)
			$cheshire.force_set_camera($camera/camera_chessboard)
			await $dialog.on_next
			$dialog.push_dialog("该对局为特殊布局，时间上较为紧张，注意速战速决。", true, true)
			$cheshire.force_set_camera($camera/camera_pastor_closeup)
			await $dialog.on_next
			$clock.start()
			$cheshire.add_stack($interact/area_chessboard)
			pastor_state = "in_game"
			call_deferred("in_game")
			break
		elif $dialog.selected == 4:
			var text_input_instance:TextInput = TextInput.create_text_input_instance("输入FEN格式的布局：", "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
			add_child(text_input_instance)
			await text_input_instance.confirmed
			state = RuleStandard.parse(text_input_instance.text)
			if is_instance_valid(state):
				think_time = 5
				$chessboard.set_state(state)
				history_chart.set_state(state)
				$dialog.push_dialog("现在棋盘已经准备好了。", true, true)
				$cheshire.force_set_camera($camera/camera_chessboard)
				await $dialog.on_next
				$dialog.push_dialog("根据棋局信息，" + ("目前是白方先手。" if state.get_turn() == 0 else "目前是黑方先手。"), true, true)
				$cheshire.force_set_camera($camera/camera_pastor_closeup)
				await $dialog.on_next
				pastor_state = "in_game"
				$cheshire.add_stack($interact/area_chessboard)
				call_deferred("in_game")
				break
		$dialog.push_dialog("您输入的格式有误，请重新检查。", true, true)
		$cheshire.force_set_camera($camera/camera_chessboard)
		await $dialog.on_next

func in_game() -> void:
	while RuleStandard.get_end_type(state) == "":
		$chessboard.set_valid_move([])
		$chessboard.set_valid_premove(RuleStandard.generate_premove(state, 1))
		ai.start_search(state, 0, $clock.time_1, Callable())
		if ai.is_searching():
			await ai.search_finished
		var move:int = ai.get_search_result()
		RuleStandard.apply_move(state, move)
		$chessboard.execute_move(move)
		history_chart.push_move(move)
		if RuleStandard.get_end_type(state) != "":
			break
		$chessboard.set_valid_move(RuleStandard.generate_valid_move(state, 1))
		$chessboard.set_valid_premove([])
		$clock.next()
		ai.start_search(state, 1, INF, Callable())
		await $chessboard.move_played
		RuleStandard.apply_move(state, $chessboard.confirm_move)
		history_chart.push_move($chessboard.confirm_move)
		$clock.next()
		ai.stop_search()
		if ai.is_searching():
			await ai.search_finished

func timeout(group:int) -> void:
	if group == 0:	# 棋钟的阵营1才是Pastor的
		$dialog.push_dialog("棋局结束，黑方超时", true, true)
		await $dialog.on_next
	else:
		$dialog.push_dialog("棋局结束，白方超时", true, true)
		await $dialog.on_next
	pastor_state = "idle"


func game_end(end_type:String) -> void:	# 0:长将和 1:白方逼和 2:黑方逼和 3:50步和 4:子力不足
	$clock.stop()
	match end_type:
		"treefold_repetition":
			$dialog.push_dialog("长将和棋", true, true)
			await $dialog.on_next
		"stalemate_black":
			$dialog.push_dialog("黑方逼和", true, true)
			await $dialog.on_next
		"stalemate_white":
			$dialog.push_dialog("白方逼和", true, true)
			await $dialog.on_next
		"50_moves":
			$dialog.push_dialog("50步和棋", true, true)
			await $dialog.on_next
		"not_enough_pawn":
			$dialog.push_dialog("子力不足和棋", true, true)
			await $dialog.on_next
		"checkmate_white":
			$dialog.push_dialog("棋局结束，白方将杀胜利", true, true)
			await $dialog.on_next
		"checkmate_black":
			$dialog.push_dialog("棋局结束，黑方将杀胜利", true, true)
			await $dialog.on_next
	pastor_state = "idle"
