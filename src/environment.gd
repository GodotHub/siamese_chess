extends Node3D

var pastor_state:String = "idle"

func _ready() -> void:
	$cheshire.set_initial_interact($interact/area_passthrough)
	$chessboard.connect("move_played", $history.push_move)
	$chessboard.connect("move_played", $pastor.receive_move)
	$chessboard.connect("press_timer", $chess_timer.next)
	$chess_timer.connect("timeout", timeout)
	$pastor.connect("send_initial_state", $chessboard.set_state)
	$pastor.connect("send_initial_state", $history.set_state)
	$pastor.connect("decided_move", $chessboard.execute_move)
	$pastor.connect("send_opponent_move", $chessboard.set_valid_move)
	$pastor.connect("send_opponent_premove", $chessboard.set_valid_premove)
	$pastor.connect("win", pastor_win)
	$pastor.connect("lose", pastor_lose)
	$pastor.connect("draw", pastor_draw)
	var transposition_table:TranspositionTable = TranspositionTable.new()
	if FileAccess.file_exists("user://standard_opening.fa"):
		transposition_table.load_file("user://standard_opening.fa")
	else:
		transposition_table.reserve(1 << 20)
	$pastor.transposition_table = transposition_table
	$pastor.ai.init({ "transposition_table": transposition_table, "max_depth": 100});
	$interact/area_pastor.connect("clicked", select_dialog)

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
	$dialog.push_selection(["结束棋局", "取消"])
	$cheshire.force_set_camera($camera/camera_pastor_closeup)
	await $dialog.on_next
	if $dialog.selected == 0:
		$pastor.interrupted = true
		$chess_timer.stop()
		$chessboard.set_valid_move([])
		$chessboard.set_valid_premove([])
		pastor_state = "idle"
	elif $dialog.selected == 1:
		return

func dialog_start_game() -> void:
	while true:
		$dialog.push_selection(["标准棋局（30+0）", "快棋（10+5）", "超快棋（5+3）", "子弹棋（小规模布局，1/2+0）", "导入棋局"])
		await $dialog.on_next
		if $dialog.selected in [0, 1, 2]:
			$pastor.create_state("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
			if $dialog.selected == 0:
				$chess_timer.set_time(1800, 1, 0)
				$pastor.think_time = 5
			elif $dialog.selected == 1:
				$chess_timer.set_time(600, 1, 5)
				$pastor.think_time = 3
			elif $dialog.selected == 2:
				$chess_timer.set_time(300, 1, 3)
				$pastor.think_time = 2
			$dialog.push_dialog("现在棋盘已经准备好了。", true, true)
			$cheshire.force_set_camera($camera/camera_chessboard)
			await $dialog.on_next
			$dialog.push_dialog("您是黑方后手开局，时间有限，请注意合理分配。", true, true)
			$cheshire.force_set_camera($camera/camera_pastor_closeup)
			await $dialog.on_next
			$chess_timer.start()
			$cheshire.add_stack($interact/area_chessboard)
			$pastor.start_decision()
			break
		elif $dialog.selected == 3:
			$pastor.create_state("8/8/2rbqk2/2pppn2/2NPPP2/2KQBR2/8/8 w - - 0 1")
			$chess_timer.set_time(30, 1, 0)
			$pastor.think_time = 1
			$dialog.push_dialog("现在棋盘已经准备好了。", true, true)
			$cheshire.force_set_camera($camera/camera_chessboard)
			await $dialog.on_next
			$dialog.push_dialog("该对局为特殊布局，时间上较为紧张，注意速战速决。", true, true)
			$cheshire.force_set_camera($camera/camera_pastor_closeup)
			await $dialog.on_next
			$chess_timer.start()
			$cheshire.add_stack($interact/area_chessboard)
			$pastor.start_decision()
			break
		elif $dialog.selected == 4:
			var text_input_instance:TextInput = TextInput.create_text_input_instance("输入FEN格式的布局：")
			add_child(text_input_instance)
			await text_input_instance.confirmed
			if $pastor.create_state(text_input_instance.text):
				$pastor.think_time = 5
				$dialog.push_dialog("现在棋盘已经准备好了。", true, true)
				$cheshire.force_set_camera($camera/camera_chessboard)
				await $dialog.on_next
				$dialog.push_dialog("根据棋局信息，" + ("目前是白方先手。" if $pastor.state.get_extra(0) == 0 else "目前是黑方先手。"), true, true)
				$cheshire.force_set_camera($camera/camera_pastor_closeup)
				await $dialog.on_next
				$cheshire.add_stack($interact/area_chessboard)
				$pastor.start_decision()
				break
		$dialog.push_dialog("您输入的格式有误，请重新检查。", true, true)
		$cheshire.force_set_camera($camera/camera_chessboard)
		await $dialog.on_next
	pastor_state = "in_game"

func timeout(group:int) -> void:
	if group == 0:	# 棋钟的阵营1才是Pastor的
		$dialog.push_dialog("棋局结束，黑方超时", true, true)
		await $dialog.on_next
	else:
		$dialog.push_dialog("棋局结束，白方超时", true, true)
		await $dialog.on_next
	pastor_state = "idle"

func pastor_win() -> void:
	$chess_timer.stop()
	$dialog.push_dialog("棋局结束，白方将杀胜利", true, true)
	await $dialog.on_next
	pastor_state = "idle"

func pastor_draw(type:int) -> void:	# 0:长将和 1:白方逼和 2:黑方逼和 3:50步和 4:子力不足
	$chess_timer.stop()
	match type:
		0:
			$dialog.push_dialog("长将和棋", true, true)
			await $dialog.on_next
		1:
			$dialog.push_dialog("黑方逼和", true, true)
			await $dialog.on_next
		2:
			$dialog.push_dialog("白方逼和", true, true)
			await $dialog.on_next
		3:
			$dialog.push_dialog("50步和棋", true, true)
			await $dialog.on_next
		4:
			$dialog.push_dialog("子力不足和棋", true, true)
			await $dialog.on_next
	pastor_state = "idle"

func pastor_lose() -> void:
	$chess_timer.stop()
	$dialog.push_dialog("棋局结束，黑方将杀胜利", true, true)
	await $dialog.on_next
	pastor_state = "idle"
