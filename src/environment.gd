extends Node3D

var state:State = null
var history:Array[State] = []
var score:int = 0
var think_time:int = 10
var start_thinking:float = 0
var opening_book:OpeningBook = OpeningBook.new()
var ai: PastorAI = PastorAI.new();
var interrupted:bool = false

var pastor_state:String = "idle"

func _ready() -> void:
	$cheshire.set_initial_interact($interact/area_passthrough)
	$chess_timer.connect("timeout", timeout)
	$interact/area_pastor.connect("clicked", select_dialog)

	if FileAccess.file_exists("user://standard_opening_document.fa"):
		opening_book.load_file("user://standard_opening_document.fa")

func select_dialog() -> void:
	if has_method("dialog_" + pastor_state):
		call("dialog_" + pastor_state)

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
			interrupted = true
		state = history.back().duplicate()
	elif $dialog.selected == 1:
		interrupted = true
		$chess_timer.stop()
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
			if $dialog.selected == 0:
				$chess_timer.set_time(1800, 1, 0)
				think_time = 5
			elif $dialog.selected == 1:
				$chess_timer.set_time(600, 1, 5)
				think_time = 3
			elif $dialog.selected == 2:
				$chess_timer.set_time(300, 1, 3)
				think_time = 2
			$dialog.push_dialog("现在棋盘已经准备好了。", true, true)
			$cheshire.force_set_camera($camera/camera_chessboard)
			await $dialog.on_next
			$dialog.push_dialog("您是黑方后手开局，时间有限，请注意合理分配。", true, true)
			$cheshire.force_set_camera($camera/camera_pastor_closeup)
			await $dialog.on_next
			$chess_timer.start()
			$cheshire.add_stack($interact/area_chessboard)
			pastor_state = "in_game"
			call_deferred("in_game")
			break
		elif $dialog.selected == 3:
			state = RuleStandard.parse("8/8/2rbqk2/2pppn2/2NPPP2/2KQBR2/8/8 w - - 0 1")
			$chessboard.set_state(state)
			$chess_timer.set_time(30, 1, 0)
			think_time = 1
			$dialog.push_dialog("现在棋盘已经准备好了。", true, true)
			$cheshire.force_set_camera($camera/camera_chessboard)
			await $dialog.on_next
			$dialog.push_dialog("该对局为特殊布局，时间上较为紧张，注意速战速决。", true, true)
			$cheshire.force_set_camera($camera/camera_pastor_closeup)
			await $dialog.on_next
			$chess_timer.start()
			$cheshire.add_stack($interact/area_chessboard)
			pastor_state = "in_game"
			call_deferred("in_game")
			break
		elif $dialog.selected == 4:
			var text_input_instance:TextInput = TextInput.create_text_input_instance("输入FEN格式的布局：")
			add_child(text_input_instance)
			await text_input_instance.confirmed
			state = RuleStandard.parse(text_input_instance.text)
			if is_instance_valid(state):
				think_time = 5
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
		timer_start()
		$chessboard.set_valid_move([])
		$chessboard.set_valid_premove(RuleStandard.generate_premove(state, 1))
		ai.start_search(state, 0, is_timeup.bind(think_time), Callable())
		await ai.search_finished
		var move:int = ai.get_search_result()
		RuleStandard.apply_move(state, move)
		$chessboard.execute_move(move)
		if RuleStandard.get_end_type(state) != "":
			break
		$chessboard.set_valid_move(RuleStandard.generate_move(state, 1))
		$chessboard.set_valid_premove([])
		$chess_timer.next()
		await $chessboard.move_played
		RuleStandard.apply_move(state, $chessboard.confirm_move)
		$chess_timer.next()

func search() -> void:
	ai.search(state, 0, is_timeup.bind(think_time), Callable())
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
	$chess_timer.stop()
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

func timer_start() -> void:
	start_thinking = Time.get_unix_time_from_system()

func is_timeup(duration:float) -> bool:
	return Time.get_unix_time_from_system() - start_thinking >= duration || interrupted
