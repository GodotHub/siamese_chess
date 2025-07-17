extends Node3D

var known_dialog:PackedInt32Array = []

func _ready() -> void:
	$cheshire.set_initial_interact($interact/area_passthrough)
	$chessboard.connect("move_played", $history.push_move)
	$chessboard.connect("move_played", $pastor.receive_move)
	$chessboard.connect("press_timer", $chess_timer.next)
	$chess_timer.connect("timeout", timeout)
	$pastor.connect("send_initial_state", $chessboard.set_state)
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
	$interact/area_pastor.connect("clicked", dialog_start_game)

func select_dialog() -> void:
	pass

func dialog_start_game() -> void:
	var dialog_1:Dialog = Dialog.create_dialog_instance([
		"现在你有若干选项开始游戏",
	])
	add_child(dialog_1)
	$cheshire.force_set_camera($camera/camera_pastor_closeup)
	await dialog_1.on_next
	start()

func timeout(group:int) -> void:
	if group == 0:	# 棋钟的阵营1才是Pastor的
		var dialog_1:Dialog = Dialog.create_dialog_instance([
			"时间到。",
			"这不是什么稀罕事，巨大压力之下普通人多少会不知所措。",
			"能做的就是继续磨练自身的技术了",
			"还需要再来一局吗？"
		])
		add_child(dialog_1)
		await dialog_1.on_next
		await dialog_1.on_next
		await dialog_1.on_next
		await dialog_1.on_next
	else:
		var dialog_1:Dialog = Dialog.create_dialog_instance([
			"……很意外",
			"作为引擎竟然还能出现超时。",
			"您不仅要在时间上领先于我，还需要在防止出错的情况下拖到最后一刻。",
			"可谓技艺精湛，值得肯定。",
			"是否需要重新开始？"
		])
		add_child(dialog_1)
		await dialog_1.on_next
		await dialog_1.on_next
		await dialog_1.on_next
		await dialog_1.on_next
		await dialog_1.on_next
	start()

func pastor_win() -> void:
	$chess_timer.stop()
	var dialog_1:Dialog = Dialog.create_dialog_instance([
		"……",
		"看来是我拿下了胜利。",
		"我仍相信您的决策经过了深思熟虑，但是致命的错误仍摆在这里。",
		"我暂时没有其他安排，需要重新进行一场对局吗？",
	])
	add_child(dialog_1)
	$cheshire.force_set_camera($camera/camera_chessboard)
	await dialog_1.on_next
	$cheshire.force_set_camera($camera/camera_pastor_closeup)
	await dialog_1.on_next
	$cheshire.force_set_camera($camera/camera_chessboard_side)
	await dialog_1.on_next
	$cheshire.force_set_camera($camera/camera_on_seat)
	await dialog_1.on_next
	start()

func pastor_draw(type:int) -> void:	# 0:长将和 1:白方逼和 2:黑方逼和 3:50步和 4:子力不足
	$chess_timer.stop()
	match type:
		0:
			var dialog_1:Dialog = Dialog.create_dialog_instance([
				"长将和棋。",
				"看来你我都不认为这盘棋能继续下去，该说是错失良机，还是重获新生？",
				"我暂时没有其他安排，需要重新进行一场对局吗？"
			])
			add_child(dialog_1)
			$cheshire.force_set_camera($camera/camera_pastor_closeup)
			await dialog_1.on_next
			$cheshire.force_set_camera($camera/camera_chessboard_side)
			await dialog_1.on_next
			$cheshire.force_set_camera($camera/camera_on_seat)
			await dialog_1.on_next
		1:
			var dialog_1:Dialog = Dialog.create_dialog_instance([
				"逼和结束。",
				"残局处理时，即使是您的优势，也需要谨慎落子，这跟靠蛮力打架可不一样。",
				"我暂时没有其他安排，需要重新进行一场对局吗？"
			])
			add_child(dialog_1)
			$cheshire.force_set_camera($camera/camera_pastor_closeup)
			await dialog_1.on_next
			$cheshire.force_set_camera($camera/camera_chessboard_side)
			await dialog_1.on_next
			$cheshire.force_set_camera($camera/camera_on_seat)
			await dialog_1.on_next
		2:
			var dialog_1:Dialog = Dialog.create_dialog_instance([
				"逼和，但这对您而言是好事。",
				"在我的巨大优势中找到强制和棋的着法，这是我的疏忽，也是您实力的体现。",
				"我暂时没有其他安排，需要重新进行一场对局吗？"
			])
			add_child(dialog_1)
			$cheshire.force_set_camera($camera/camera_pastor_closeup)
			await dialog_1.on_next
			$cheshire.force_set_camera($camera/camera_chessboard_side)
			await dialog_1.on_next
			$cheshire.force_set_camera($camera/camera_on_seat)
			await dialog_1.on_next
		3:
			var dialog_1:Dialog = Dialog.create_dialog_instance([
				"和棋，超出50个半步未吃子。",
				"看来这场残局的推进还是蛮有难度的。",
				"我暂时没有其他安排，需要重新进行一场对局吗？"
			])
			add_child(dialog_1)
			$cheshire.force_set_camera($camera/camera_pastor_closeup)
			await dialog_1.on_next
			$cheshire.force_set_camera($camera/camera_chessboard_side)
			await dialog_1.on_next
			$cheshire.force_set_camera($camera/camera_on_seat)
			await dialog_1.on_next
		4:
			var dialog_1:Dialog = Dialog.create_dialog_instance([
				"……",
				"和棋，这些棋子没有办法对双方的国王造成任何威胁。",
				"能出现这种情况也非常罕见，只要有一个兵就有决定胜负的机会。",
				"我暂时没有其他安排，需要重新进行一场对局吗？"
			])
			add_child(dialog_1)
			$cheshire.force_set_camera($camera/camera_pastor_closeup)
			await dialog_1.on_next
			$cheshire.force_set_camera($camera/camera_chessboard_side)
			await dialog_1.on_next
			$cheshire.force_set_camera($camera/camera_on_seat)
			await dialog_1.on_next
	start()

func pastor_lose() -> void:
	$chess_timer.stop()
	var dialog_1:Dialog = Dialog.create_dialog_instance([
		"……",
		"您在标准国际象棋规则中，拿下了胜利。",
		"您的计算能力足够强大，或许真能解决您目前所发生的事态。",
		"我暂时没有其他安排，需要重新进行一场对局吗？"
	])
	add_child(dialog_1)
	$cheshire.force_set_camera($camera/camera_chessboard)
	await dialog_1.on_next
	$cheshire.force_set_camera($camera/camera_pastor_closeup)
	await dialog_1.on_next
	$cheshire.force_set_camera($camera/camera_chessboard_side)
	await dialog_1.on_next
	$cheshire.force_set_camera($camera/camera_on_seat)
	await dialog_1.on_next
	start()

func start() -> void:
	while true:
		var decision_instance:Decision = Decision.create_decision_instance(["标准棋局（30+0）", "快棋（10+5）", "超快棋（5+3）", "子弹棋（小规模布局，1/2+0）", "导入棋局"], false)
		add_child(decision_instance)
		await decision_instance.decided
		if decision_instance.selected_index in [0, 1, 2]:
			$pastor.create_state("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", RuleStandard.new())
			var dialog_2:Dialog = Dialog.create_dialog_instance([
				"现在棋盘已经准备好了。",
				"您是黑方后手开局，时间有限，请注意合理分配。"
			])
			if decision_instance.selected_index == 0:
				$chess_timer.set_time(1800, 1, 0)
				$pastor.think_time = 5
			elif decision_instance.selected_index == 1:
				$chess_timer.set_time(600, 1, 5)
				$pastor.think_time = 3
			elif decision_instance.selected_index == 2:
				$chess_timer.set_time(300, 1, 3)
				$pastor.think_time = 2
			add_child(dialog_2)
			$cheshire.force_set_camera($camera/camera_chessboard)
			await dialog_2.on_next
			$cheshire.force_set_camera($camera/camera_pastor_closeup)
			await dialog_2.on_next
			$chess_timer.start()
			$cheshire.add_stack($interact/area_chessboard)
			$pastor.start_decision()
			break
		elif decision_instance.selected_index == 3:
			$pastor.create_state("8/8/2rbqk2/2pppn2/2NPPP2/2KQBR2/8/8 w - - 0 1", RuleStandard.new())
			var dialog_2:Dialog = Dialog.create_dialog_instance([
				"现在棋盘已经准备好了。",
				"该对局为特殊布局，时间上较为紧张，注意速战速决。"
			])
			$chess_timer.set_time(30, 1, 0)
			$pastor.think_time = 1
			add_child(dialog_2)
			$cheshire.force_set_camera($camera/camera_chessboard)
			await dialog_2.on_next
			$cheshire.force_set_camera($camera/camera_pastor_closeup)
			await dialog_2.on_next
			$chess_timer.start()
			$cheshire.add_stack($interact/area_chessboard)
			$pastor.start_decision()
			break
		elif decision_instance.selected_index == 4:
			var text_input_instance:TextInput = TextInput.create_text_input_instance("输入FEN格式的布局：")
			add_child(text_input_instance)
			await text_input_instance.confirmed
			if $pastor.create_state(text_input_instance.text, RuleStandard.new()):
				var dialog_2:Dialog = Dialog.create_dialog_instance([
					"现在棋盘已经准备好了。",
					"根据棋局信息，" + ("目前是白方先手。" if $pastor.state.get_extra(0) == 0 else "目前是黑方先手。")
				])
				$pastor.think_time = 10
				add_child(dialog_2)
				$cheshire.force_set_camera($camera/camera_chessboard)
				await dialog_2.on_next
				await dialog_2.on_next
				$cheshire.add_stack($interact/area_chessboard)
				$pastor.start_decision()
				break
		$cheshire.force_set_camera($camera/camera_chessboard)
		var dialog_illegal:Dialog = Dialog.create_dialog_instance(["您输入的格式有误，务必重新检查一下再尝试。"])
		add_child(dialog_illegal)
		await dialog_illegal.on_next
