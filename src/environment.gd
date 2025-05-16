extends Node3D

func _ready() -> void:
	$cheshire.connect("tap_position", $chessboard.tap_position)
	$cheshire.connect("finger_on_position", $chessboard.finger_on_position)
	$cheshire.connect("finger_up", $chessboard.finger_up)
	$chessboard.connect("move_played", $history.push_move)
	$chessboard.connect("move_played", $pastor.receive_move)
	$pastor.connect("send_initial_state", $chessboard.set_state)
	$pastor.connect("decided_move", $chessboard.execute_move)
	$pastor.connect("send_opponent_move", $chessboard.set_valid_move)
