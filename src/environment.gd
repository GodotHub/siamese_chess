extends Node3D

func _ready() -> void:
	$player.connect("tap_position", $chessboard.tap_position)
	$player.connect("finger_on_position", $chessboard.finger_on_position)
	$player.connect("finger_up", $chessboard.finger_up)
	$chessboard.connect("move_played", $history.push_move)
