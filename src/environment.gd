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
	await dialog_1.on_exit
	while true:
		var decision_instance:Decision = Decision.create_decision_instance(["从头开始", "从剪贴板导入棋局（FEN格式）"], false)
		add_child(decision_instance)
		await decision_instance.decided
		if decision_instance.selected_index == 0:
			$pastor.create_state_from_start()
			break
		elif decision_instance.selected_index == 1:
			if $pastor.create_state_from_fen():
				break
		var dialog_illegal:Dialog = Dialog.create_dialog_instance(["您的剪贴板似乎没有记下你的局面，或者格式不对，", "注意是FEN格式，请您复制好再重新尝试！"])
		add_child(dialog_illegal)
		await dialog_illegal.on_next
		await dialog_illegal.on_next
	var dialog_2:Dialog = Dialog.create_dialog_instance([	# Pastor的自我介绍，对于棋局的介绍，以及二选一
		"现在棋盘已经准备好了。",
		"您是黑方，作为后手，我则先手",
		"现在开始对局，那么先走一步……"
	])
	add_child(dialog_2)
	await dialog_2.on_next
	$cheshire.force_set_camera($cheshire/area_chessboard/camera_3d)
	await dialog_2.on_next
	await dialog_2.on_exit
	$pastor.start_decision()
