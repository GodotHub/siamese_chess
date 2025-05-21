extends Node3D

func _ready() -> void:
	$cheshire.connect("tap_position", $chessboard.tap_position)
	$cheshire.connect("finger_on_position", $chessboard.finger_on_position)
	$cheshire.connect("finger_up", $chessboard.finger_up)
	$cheshire.set_initial_camera($cheshire/camera_on_seat)
	$chessboard.connect("move_played", $history.push_move)
	$chessboard.connect("move_played", $pastor.receive_move)
	$pastor.connect("send_initial_state", $chessboard.set_state)
	$pastor.connect("decided_move", $chessboard.execute_move)
	$pastor.connect("send_opponent_move", $chessboard.set_valid_move)
	$pastor.connect("win", pastor_win)
	$pastor.connect("lose", pastor_lose)
	dialog_start()

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

func pastor_win() -> void:
	var dialog_1:Dialog = Dialog.create_dialog_instance([
		"……",
		"看来是我拿下了胜利。",
		"我仍相信您的决策经过了深思熟虑，但是致命的错误仍摆在这里。",
		"我暂时没有其他安排，需要重新进行一场对局吗？",
	])
	add_child(dialog_1)
	$cheshire.force_set_camera($cheshire/camera_on_seat)
	await dialog_1.on_next
	$cheshire.force_set_camera($cheshire/camera_pastor_closeup)
	await dialog_1.on_next
	$cheshire.force_set_camera($cheshire/camera_chessboard_side)
	await dialog_1.on_next
	$cheshire.force_set_camera($cheshire/camera_on_seat)
	await dialog_1.on_next
	start()

func pastor_draw(type:int) -> void:	# 0:长将和 1:白方逼和 2:黑方逼和 3:50步和 4:子力不足
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
	var dialog_1:Dialog = Dialog.create_dialog_instance([
		"……",
		"您在标准国际象棋规则中，拿下了胜利。",
		"您的计算能力足够强大，或许真能解决您目前所发生的事态。",
		"我暂时没有其他安排，需要重新进行一场对局吗？"
	])
	add_child(dialog_1)
	$cheshire.force_set_camera($cheshire/camera_on_seat)
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
		var decision_instance:Decision = Decision.create_decision_instance(["从头开始", "从剪贴板导入棋局（FEN格式）"], false)
		add_child(decision_instance)
		await decision_instance.decided
		if decision_instance.selected_index == 0:
			$pastor.create_state_from_start()
			var dialog_2:Dialog = Dialog.create_dialog_instance([
				"现在棋盘已经准备好了。",
				"您是黑方，作为后手，我则先手",
				"开始对局，祝你好运……"
			])
			add_child(dialog_2)
			$cheshire.force_set_camera($cheshire/area_chessboard/camera_3d)
			await dialog_2.on_next
			await dialog_2.on_next
			await dialog_2.on_next
			$pastor.start_decision()
			break
		elif decision_instance.selected_index == 1:
			if $pastor.create_state_from_fen():
				var dialog_2:Dialog = Dialog.create_dialog_instance([
					"现在棋盘已经准备好了。",
					"根据棋局信息，" + ("目前是白方先手。" if $pastor.chess_state.extra[0] == "w" else "目前是黑方先手。"),
					"开始对局，祝你好运……"
				])
				add_child(dialog_2)
				$cheshire.force_set_camera($cheshire/area_chessboard/camera_3d)
				await dialog_2.on_next
				await dialog_2.on_next
				await dialog_2.on_next
				$pastor.start_decision()
				break
		$cheshire.force_set_camera($cheshire/camera_pastor_closeup)
		var dialog_illegal:Dialog = Dialog.create_dialog_instance(["您的剪贴板似乎没有记下局面，或者格式不对，", "注意是FEN格式，请您复制好再重新尝试！"])
		add_child(dialog_illegal)
		await dialog_illegal.on_next
		await dialog_illegal.on_next
