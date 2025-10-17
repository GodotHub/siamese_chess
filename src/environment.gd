extends Node3D

var pastor_game_state:State = null
var pastor_history_state:PackedInt32Array = []
var friend_game_state:State = null
var pastor_history:Array[State] = []
var opening_book:OpeningBook = OpeningBook.new()
var engine: PastorEngine = PastorEngine.new()
@onready var pastor_history_chart:Document = load("res://scene/history.tscn").instantiate()

var pastor_state:String = "idle"
var friend_state:String = "idle"

var telephone_2025_first_time:bool = false

func _ready() -> void:
	$history.set_document(pastor_history_chart)
	$player.set_initial_interact($interact/area_passthrough)
	$clock_pastor.connect("timeout", pastor_game_timeout)
	$telephone.connect("call_number", dialog_telephone)
	$cheshire.visible = true
	$cheshire.play_animation("thinking")
	$interact/area_pastor.connect("clicked", pastor_select_dialog)
	$interact/area_outside.connect("clicked", go_outside)
	$interact/area_menu.connect("clicked", check_menu)
	$interact/area_friend_chessboard.connect("clicked", dialog_friend_start_game)
	
func pastor_select_dialog() -> void:
	if has_method("dialog_pastor_" + pastor_state):
		call("dialog_pastor_" + pastor_state)

func dialog_telephone(number:String) -> void:
	if has_method("dialog_telephone_" + number):
		call("dialog_telephone_" + number)

func dialog_telephone_2025() -> void:
	if !FileAccess.file_exists("user://archive/inspectable.telephone.json"):
		var path:String = "user://archive/inspectable.telephone.json"
		var file:FileAccess = FileAccess.open(path, FileAccess.WRITE)
		file.store_string("{\"path\": \"res://scene/telephone.tscn\"}")
		file.close()
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
		if pastor_game_state:
			var test_state:State = pastor_game_state.duplicate()
			$dialog.push_dialog("您是在和谁下棋吗？可以告诉我现在什么情况？", true, true)
			await $dialog.on_next
			$dialog.push_dialog("……", true, true)
			await $dialog.on_next
			if pastor_game_state.get_turn() == 0:
				$dialog.push_dialog("现在是对手在下棋，您可以先看一下他的应对方式。", true, true)
				await $dialog.on_next
				return
			$dialog.push_dialog("这样啊……", true, true)
			await $dialog.on_next
			$dialog.push_dialog("容我稍作思考。", true, true, true)
			var telephone_engine:PastorEngine = PastorEngine.new()
			telephone_engine.set_max_depth(6)
			telephone_engine.start_search(test_state, 1, pastor_history_state, Callable())
			if telephone_engine.is_searching():
				await telephone_engine.search_finished
			var best_move:int = telephone_engine.get_search_result()
			$dialog.next()
			$dialog.push_dialog("我认为您应当下" + RuleStandard.get_move_name(test_state, best_move), true, true)
			await $dialog.on_next
		else:
			$dialog.push_dialog("现在您还没在下棋，我暂时帮不上。", true, true)
			await $dialog.on_next

func dialog_pastor_idle() -> void:
	$player.force_set_camera($camera/camera_pastor_closeup)
	$dialog.push_selection(["下棋？", "询问规则", "返回"])
	await $dialog.on_next
	if $dialog.selected == 0:
		dialog_pastor_game_start()
	elif $dialog.selected == 1:
		dialog_description_chess()

func dialog_description_chess() -> void:
	$dialog.push_dialog("这只是标准的国际象棋。", true, true)
	$player.force_set_camera($camera/camera_pastor_closeup)
	await $dialog.on_next
	$dialog.push_dialog("在这里，您至少需要了解国际象棋的基本规则。", true, true)
	$player.force_set_camera($camera/camera_pastor_closeup)
	await $dialog.on_next
	$dialog.push_dialog("不过，如果您对这种游戏仍然一头雾水，您也可以试着上手，", true, true)
	$player.force_set_camera($camera/camera_pastor_closeup)
	await $dialog.on_next
	$dialog.push_dialog("您可以边对照规则边上手实践，我也会提示一些可走的着法，", true, true)
	$player.force_set_camera($camera/camera_pastor_closeup)
	await $dialog.on_next
	$dialog.push_dialog("不过……我不会放水，请做好输棋的心理准备吧。", true, true)
	$player.force_set_camera($camera/camera_pastor_closeup)
	await $dialog.on_next

func dialog_pastor_in_game() -> void:
	$dialog.push_selection(["提出悔棋", "结束棋局", "取消"])
	$player.force_set_camera($camera/camera_pastor_closeup)
	await $dialog.on_next
	$player.add_stack($interact/area_pastor_chessboard)
	if $dialog.selected == 0:
		if pastor_history.size() <= 2:	# 白方第一步棋无法撤回
			return
		if pastor_history.back().get_turn() == 1:
			pastor_history.pop_back()
			pastor_history_state.resize(pastor_history_state.size() - 1)
		if pastor_history.back().get_turn() == 0:
			pastor_history.pop_back()
			pastor_history_state.resize(pastor_history_state.size() - 1)
			engine.stop_search()
		pastor_game_state = pastor_history.back().duplicate()
		$chessboard_pastor.set_state(pastor_game_state)
		$chessboard_pastor.set_valid_move(RuleStandard.generate_valid_move(pastor_game_state, 1))
		$chessboard_pastor.set_valid_premove([])
	elif $dialog.selected == 1:
		engine.stop_search()
		$clock_pastor.stop()
		$chessboard_pastor.set_valid_move([])
		$chessboard_pastor.set_valid_premove([])
		pastor_state = "idle"
		pastor_history_chart.save_file()
	elif $dialog.selected == 2:
		return

func dialog_pastor_game_start() -> void:
	while true:
		$dialog.push_selection(["标准棋局（30+0）", "快棋（10+5）", "超快棋（5+3）", "子弹棋（随机布局，3+0）", "导入棋局", "取消"])
		await $dialog.on_next
		if $dialog.selected in [0, 1, 2]:
			pastor_game_state = RuleStandard.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
			$chessboard_pastor.set_state(pastor_game_state)
			$chessboard_pastor.add_default_piece_set()
			pastor_history_chart.set_state(pastor_game_state)
			pastor_history_chart.set_filename("history." + String.num_int64(Time.get_unix_time_from_system()) + ".json")
			if $dialog.selected == 0:
				$clock_pastor.set_time(1800, 1, 0)
				engine.set_think_time(5)
			elif $dialog.selected == 1:
				$clock_pastor.set_time(600, 1, 5)
				engine.set_think_time(3)
			elif $dialog.selected == 2:
				$clock_pastor.set_time(300, 1, 3)
				engine.set_think_time(2)
			$dialog.push_dialog("现在棋盘已经准备好了。", true, true)
			$player.force_set_camera($camera/camera_pastor_chessboard)
			await $dialog.on_next
			$dialog.push_dialog("您是黑方后手开局，时间有限，请注意合理分配。", true, true)
			$player.force_set_camera($camera/camera_pastor_closeup)
			await $dialog.on_next
			$clock_pastor.start()
			$player.add_stack($interact/area_pastor_chessboard)
			pastor_state = "in_game"
			call_deferred("game_with_pastor")
			break
		elif $dialog.selected == 3:
			engine.set_think_time(1)
			pastor_game_state = RuleStandard.create_random_state(15)
			$chessboard_pastor.set_state(pastor_game_state)
			$chessboard_pastor.add_default_piece_set()
			pastor_history_chart.set_state(pastor_game_state)
			pastor_history_chart.set_filename("history." + String.num_int64(Time.get_unix_time_from_system()) + ".json")
			$clock_pastor.set_time(180, 1, 0)
			$dialog.push_dialog("现在棋盘已经准备好了。", true, true)
			$player.force_set_camera($camera/camera_pastor_chessboard)
			await $dialog.on_next
			$dialog.push_dialog("该对局为特殊布局，请仔细观察棋盘后开始。", true, true)
			await $dialog.on_next
			$clock_pastor.start()
			$player.add_stack($interact/area_pastor_chessboard)
			pastor_state = "in_game"
			call_deferred("game_with_pastor")
			break
		elif $dialog.selected == 4:
			var text_input_instance:TextInput = TextInput.create_text_input_instance("输入FEN格式的布局：", "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
			add_child(text_input_instance)
			await text_input_instance.confirmed
			pastor_game_state = RuleStandard.parse(text_input_instance.text)
			if is_instance_valid(pastor_game_state):
				$clock_pastor.set_time(1800, 1, 0)
				$chessboard_pastor.set_state(pastor_game_state)
				$chessboard_pastor.add_default_piece_set()
				pastor_history_chart.set_state(pastor_game_state)
				pastor_history_chart.set_filename("history." + String.num_int64(Time.get_unix_time_from_system()) + ".json")
				$dialog.push_dialog("现在棋盘已经准备好了。", true, true)
				$player.force_set_camera($camera/camera_pastor_chessboard)
				await $dialog.on_next
				$dialog.push_dialog("根据棋局信息，" + ("目前是白方先手。" if pastor_game_state.get_turn() == 0 else "目前是黑方先手。"), true, true)
				$player.force_set_camera($camera/camera_pastor_closeup)
				await $dialog.on_next
				pastor_state = "in_game"
				$clock_pastor.start()
				$player.add_stack($interact/area_pastor_chessboard)
				call_deferred("game_with_pastor")
				break
		elif $dialog.selected == 5:
			return
		$dialog.push_dialog("您输入的格式有误，请重新检查。", true, true)
		$player.force_set_camera($camera/camera_pastor_chessboard)
		await $dialog.on_next

func game_with_pastor() -> void:
	while RuleStandard.get_end_type(pastor_game_state) == "":
		$chessboard_pastor.set_valid_move([])
		$chessboard_pastor.set_valid_premove(RuleStandard.generate_premove(pastor_game_state, 1))
		engine.start_search(pastor_game_state, 0, pastor_history_state, Callable())
		if engine.is_searching():
			await engine.search_finished
		var move:int = engine.get_search_result()
		pastor_history_state.push_back(pastor_game_state.get_zobrist())
		RuleStandard.apply_move(pastor_game_state, move)
		$chessboard_pastor.execute_move(move)
		pastor_history_chart.push_move(move)
		pastor_history.push_back(pastor_game_state.duplicate())
		if RuleStandard.get_end_type(pastor_game_state) != "":
			break
		$chessboard_pastor.set_valid_move(RuleStandard.generate_valid_move(pastor_game_state, 1))
		$chessboard_pastor.set_valid_premove([])
		$clock_pastor.next()
		engine.start_search(pastor_game_state, 1, pastor_history_state, Callable())
		await $chessboard_pastor.move_played
		pastor_history_state.push_back(pastor_game_state.get_zobrist())
		RuleStandard.apply_move(pastor_game_state, $chessboard_pastor.confirm_move)
		pastor_history_chart.push_move($chessboard_pastor.confirm_move)
		pastor_history.push_back(pastor_game_state.duplicate())
		$clock_pastor.next()
		engine.stop_search()
		if engine.is_searching():
			await engine.search_finished
	pastor_game_end(RuleStandard.get_end_type(pastor_game_state))

func pastor_game_timeout(group:int) -> void:
	if group == 0:	# 棋钟的阵营1才是Pastor的
		$dialog.push_dialog("棋局结束，黑方超时", true, true)
		await $dialog.on_next
	else:
		$dialog.push_dialog("棋局结束，白方超时", true, true)
		await $dialog.on_next
	pastor_history_chart.save_file()
	pastor_state = "idle"

func pastor_game_end(end_type:String) -> void:	# 0:长将和 1:白方逼和 2:黑方逼和 3:50步和 4:子力不足
	$clock_pastor.stop()
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
	pastor_history_chart.save_file()
	pastor_state = "idle"

func check_menu() -> void:	# 玩家初次遇到时归档
	if !FileAccess.file_exists("user://archive/menu.cafe.json"):
		var path:String = "user://archive/menu.cafe.json"
		var file:FileAccess = FileAccess.open(path, FileAccess.WRITE)
		file.store_string("{\"lines\": []}")
		file.close()

func dialog_friend_start_game() -> void:
	if friend_state == "in_game":
		if friend_game_state.get_turn() == 0:
			$player.move_camera.call_deferred($camera/camera_friend_chessboard_white)
		else:
			$player.move_camera.call_deferred($camera/camera_friend_chessboard_black)
		return
	while true:
		$dialog.push_selection(["标准棋局（30+0）", "快棋（10+5）", "超快棋（5+3）", "导入棋局", "取消"])
		await $dialog.on_next
		if $dialog.selected in [0, 1, 2]:
			friend_game_state = RuleStandard.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
			$chessboard_friend.set_state(friend_game_state)
			$chessboard_friend.add_default_piece_set()
			if $dialog.selected == 0:
				$clock_friend.set_time(1800, 1, 0)
			elif $dialog.selected == 1:
				$clock_friend.set_time(600, 1, 5)
			elif $dialog.selected == 2:
				$clock_friend.set_time(300, 1, 3)
			$clock_friend.start()
			friend_state = "in_game"
			call_deferred("game_with_friend")
			break
		elif $dialog.selected == 3:
			var text_input_instance:TextInput = TextInput.create_text_input_instance("输入FEN格式的布局：", "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
			add_child(text_input_instance)
			await text_input_instance.confirmed
			friend_game_state = RuleStandard.parse(text_input_instance.text)
			if is_instance_valid(friend_game_state):
				$chessboard_friend.set_state(friend_game_state)
				$chessboard_friend.add_default_piece_set()
				call_deferred("game_with_friend")
				friend_state = "in_game"
				break
		elif $dialog.selected == 4:
			return
		$dialog.push_dialog("输入的格式有误。", true, true)
		await $dialog.on_next

func game_with_friend() -> void:
	while RuleStandard.get_end_type(friend_game_state) == "":
		$chessboard_friend.set_valid_move(RuleStandard.generate_valid_move(friend_game_state, 0))
		$chessboard_friend.set_valid_premove([])
		$player.move_camera($camera/camera_friend_chessboard_white)
		await $chessboard_friend.move_played
		RuleStandard.apply_move(friend_game_state, $chessboard_friend.confirm_move)
		$clock_friend.next()
		if RuleStandard.get_end_type(friend_game_state) != "":
			break
		$chessboard_friend.set_valid_move(RuleStandard.generate_valid_move(friend_game_state, 1))
		$chessboard_friend.set_valid_premove([])
		$player.move_camera($camera/camera_friend_chessboard_black)
		await $chessboard_friend.move_played
		RuleStandard.apply_move(friend_game_state, $chessboard_friend.confirm_move)
		$clock_friend.next()

func go_outside() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scene/outside.tscn")
