extends Node3D

func _ready() -> void:
	$cheshire.set_initial_camera($cheshire/camera_on_seat)
	$chessboard.connect("move_played", $history.push_move)
	$chessboard.connect("move_played", $pastor.receive_move)
	$chessboard.connect("press_timer", $chess_timer.next)
	$chess_timer.connect("timeout", timeout)
	$pastor.connect("send_initial_state", $chessboard.set_state)
	$pastor.connect("decided_move", $chessboard.execute_move)
	$pastor.connect("send_opponent_move", $chessboard.set_valid_move)
	$pastor.connect("win", pastor_win)
	$pastor.connect("lose", pastor_lose)
	$pastor.evaluation = EvaluationStandard
	for iter:Area3D in get_tree().get_nodes_in_group("move_camera"):
		iter.add_user_signal("input")
		iter.connect("input", move_camera)
	dialog_start()

func move_camera(_from:Node3D, _to:Area3D, _event:InputEvent, _event_position:Vector3, _normal:Vector3) -> void:
	if _event is InputEventMouseButton && _event.pressed && _event.button_index == MOUSE_BUTTON_LEFT:
		$cheshire.add_stack(_to.get_node(_to.get_meta("camera")), _to.get_node(_to.get_meta("inspectable_item")))
		$cheshire.move_camera(_to.get_node(_to.get_meta("camera")))

func dialog_start() -> void:
	var dialog_1:Dialog = Dialog.create_dialog_instance([	# Pastor的自我介绍，对于棋局的介绍，以及二选一
		"……",
		"……您好",
		"很抱歉不太擅长自我介绍，不过您可以称呼我玉兰。",
		"先进入正题吧。",
		"现在您看到的是国际象棋的棋盘。",
		"既然来到这里，默认您已了解国际象棋基本规则。",
		"现在为您提供两种选项以开始对局，",
	])
	add_child(dialog_1)
	await dialog_1.on_next
	await dialog_1.on_next
	$cheshire.force_set_camera($cheshire/camera_pastor_closeup)
	await dialog_1.on_next
	await dialog_1.on_next
	$cheshire.force_set_camera($cheshire/area_chessboard/camera_3d)
	await dialog_1.on_next
	await dialog_1.on_next
	$cheshire.force_set_camera($cheshire/camera_on_seat)
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
	$cheshire.force_set_camera($cheshire/area_chessboard/camera_3d)
	await dialog_1.on_next
	$cheshire.force_set_camera($cheshire/camera_pastor_closeup)
	await dialog_1.on_next
	$cheshire.force_set_camera($cheshire/camera_chessboard_side)
	await dialog_1.on_next
	$cheshire.force_set_camera($cheshire/camera_on_seat)
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
			$cheshire.force_set_camera($cheshire/camera_pastor_closeup)
			await dialog_1.on_next
			$cheshire.force_set_camera($cheshire/camera_chessboard_side)
			await dialog_1.on_next
			$cheshire.force_set_camera($cheshire/camera_on_seat)
			await dialog_1.on_next
		1:
			var dialog_1:Dialog = Dialog.create_dialog_instance([
				"逼和结束。",
				"残局处理时，即使是您的优势，也需要谨慎落子，这跟靠蛮力打架可不一样。",
				"我暂时没有其他安排，需要重新进行一场对局吗？"
			])
			add_child(dialog_1)
			$cheshire.force_set_camera($cheshire/camera_pastor_closeup)
			await dialog_1.on_next
			$cheshire.force_set_camera($cheshire/camera_chessboard_side)
			await dialog_1.on_next
			$cheshire.force_set_camera($cheshire/camera_on_seat)
			await dialog_1.on_next
		2:
			var dialog_1:Dialog = Dialog.create_dialog_instance([
				"逼和，但这对您而言是好事。",
				"在我的巨大优势中找到强制和棋的着法，这是我的疏忽，也是您实力的体现。",
				"我暂时没有其他安排，需要重新进行一场对局吗？"
			])
			add_child(dialog_1)
			$cheshire.force_set_camera($cheshire/camera_pastor_closeup)
			await dialog_1.on_next
			$cheshire.force_set_camera($cheshire/camera_chessboard_side)
			await dialog_1.on_next
			$cheshire.force_set_camera($cheshire/camera_on_seat)
			await dialog_1.on_next
		3:
			var dialog_1:Dialog = Dialog.create_dialog_instance([
				"和棋，超出50个半步未吃子。",
				"看来这场残局的推进还是蛮有难度的。",
				"我暂时没有其他安排，需要重新进行一场对局吗？"
			])
			add_child(dialog_1)
			$cheshire.force_set_camera($cheshire/camera_pastor_closeup)
			await dialog_1.on_next
			$cheshire.force_set_camera($cheshire/camera_chessboard_side)
			await dialog_1.on_next
			$cheshire.force_set_camera($cheshire/camera_on_seat)
			await dialog_1.on_next
		4:
			var dialog_1:Dialog = Dialog.create_dialog_instance([
				"……",
				"和棋，这些棋子没有办法对双方的国王造成任何威胁。",
				"能出现这种情况也非常罕见，只要有一个兵就有决定胜负的机会。",
				"我暂时没有其他安排，需要重新进行一场对局吗？"
			])
			add_child(dialog_1)
			$cheshire.force_set_camera($cheshire/camera_pastor_closeup)
			await dialog_1.on_next
			$cheshire.force_set_camera($cheshire/camera_chessboard_side)
			await dialog_1.on_next
			$cheshire.force_set_camera($cheshire/camera_on_seat)
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
	$cheshire.force_set_camera($cheshire/area_chessboard/camera_3d)
	await dialog_1.on_next
	$cheshire.force_set_camera($cheshire/camera_pastor_closeup)
	await dialog_1.on_next
	$cheshire.force_set_camera($cheshire/camera_chessboard_side)
	await dialog_1.on_next
	$cheshire.force_set_camera($cheshire/camera_on_seat)
	await dialog_1.on_next
	start()

func start() -> void:
	while true:
		var decision_instance:Decision = Decision.create_decision_instance(["从头开始", "导入棋局"], false)
		add_child(decision_instance)
		await decision_instance.decided
		if decision_instance.selected_index == 0:
			$pastor.create_state("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", EvaluationStandard)
			var dialog_2:Dialog = Dialog.create_dialog_instance([
				"现在棋盘已经准备好了。",
				"您是黑方，以后手开局，我则先手"
			])
			add_child(dialog_2)
			$cheshire.force_set_camera($cheshire/area_chessboard/camera_3d)
			await dialog_2.on_next
			await dialog_2.on_next
			select_time_limit()
			break
		elif decision_instance.selected_index == 1:
			var text_input_instance:TextInput = TextInput.create_text_input_instance("输入FEN格式的布局：")
			add_child(text_input_instance)
			await text_input_instance.confirmed
			if $pastor.create_state(text_input_instance.text, EvaluationStandard):
				var dialog_2:Dialog = Dialog.create_dialog_instance([
					"现在棋盘已经准备好了。",
					"根据棋局信息，" + ("目前是白方先手。" if $pastor.chess_state.get_extra(0) == "w" else "目前是黑方先手。")
				])
				add_child(dialog_2)
				$cheshire.force_set_camera($cheshire/area_chessboard/camera_3d)
				await dialog_2.on_next
				await dialog_2.on_next
				select_time_limit()
				break
		$cheshire.force_set_camera($cheshire/area_chessboard/camera_3d)
		var dialog_illegal:Dialog = Dialog.create_dialog_instance(["您输入的格式有误，务必重新检查一下再尝试。"])
		add_child(dialog_illegal)
		await dialog_illegal.on_next

func select_time_limit() -> void:
	var dialog_1:Dialog = Dialog.create_dialog_instance([
		"对了，最近我准备了个棋钟。",
		"如果您选择开启棋钟，那么这局中某一方的倒计时结束时，这人将会被判负。",
		"虽然您是在和软件算法进行对决，不过可以锻炼一下思考深度和决策效率。",
		"那么您是否需要开启计时？"
	])
	add_child(dialog_1)
	$cheshire.force_set_camera($cheshire/area_timer/camera_3d)
	await dialog_1.on_next
	await dialog_1.on_next
	$cheshire.force_set_camera($cheshire/camera_pastor_closeup)
	await dialog_1.on_next
	await dialog_1.on_next
	
	var decision_instance:Decision = Decision.create_decision_instance(["不开启计时", "慢棋（30+0）", "快棋（10+5）", "超快棋（5+3）"], false)
	add_child(decision_instance)
	await decision_instance.decided
	match decision_instance.selected_index:
		0:
			var dialog_2:Dialog = Dialog.create_dialog_instance([
				"好吧，那先不管计时，你可以按照你喜欢的思考节奏来进行对局。",
			])
			add_child(dialog_2)
			await dialog_2.on_next
		1:
			$chess_timer.set_time(1800, 1, 0)
			var dialog_2:Dialog = Dialog.create_dialog_instance([
				"这次，你我双方分别有30分钟的时间，都有充足的思考时间。",
				"对于外行而言，这个时间其实偏多了，请您充分利用好其中每一分每一秒。",
				"虽然不代表您可以无限地拖延下去，不过中途上个厕所再回到对局应该没太大问题。",
				"稍后正式开始对局，您现在就可以思考用什么样的开局来打败我。"
			])
			add_child(dialog_2)
			$cheshire.force_set_camera($cheshire/area_timer/camera_3d)
			await dialog_2.on_next
			$cheshire.force_set_camera($cheshire/camera_pastor_closeup)
			await dialog_2.on_next
			await dialog_2.on_next
			await dialog_2.on_next
			$chess_timer.start()
		2:
			$chess_timer.set_time(600, 1, 5)
			var dialog_2:Dialog = Dialog.create_dialog_instance([
				"双方初始10分钟时间，与您在与其他人休闲对弈时的时长类似。",
				"您有足够的时间去挑选有争议的着法，但过久的犹豫会导致全盘皆输。",
				"另外，您的每次落子都有5秒钟的加时，请不必紧张。",
				"请充分平衡好你的时间，在保证不漏着的前提下果断出击。"
			])
			add_child(dialog_2)
			$cheshire.force_set_camera($cheshire/area_timer/camera_3d)
			await dialog_2.on_next
			$cheshire.force_set_camera($cheshire/camera_pastor_closeup)
			await dialog_2.on_next
			await dialog_2.on_next
			await dialog_2.on_next
			$chess_timer.start()
		3:
			$chess_timer.set_time(300, 1, 3)
			var dialog_2:Dialog = Dialog.create_dialog_instance([
				"双方初始5分钟，是非常考验直觉的对局，只适合高阶棋手游玩。",
				"在超快棋下，请做好开局准备，一旦出现开局漏着，中盘对局会变得非常痛苦。",
				"尽量让局面变得让自己下起来足够舒适，不需要所谓绝对正确的着法。",
				"此外，每次落子有3秒钟加时。"
			])
			add_child(dialog_2)
			$cheshire.force_set_camera($cheshire/area_timer/camera_3d)
			await dialog_2.on_next
			await dialog_2.on_next
			$cheshire.force_set_camera($cheshire/camera_pastor_closeup)
			await dialog_2.on_next
			await dialog_2.on_next
			$chess_timer.start()
	$cheshire.add_stack($cheshire/area_chessboard/camera_3d, $chessboard)
	$cheshire.move_camera($cheshire/area_chessboard/camera_3d)
	$pastor.start_decision()
