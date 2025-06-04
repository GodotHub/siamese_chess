extends Node3D

var fen:PackedStringArray = [
	"貓##2##猫/2#1#3/1##1#1##/4#3/1#1#1##1/1#6/1#1#1##1/3#1#2 w - - 0 1"
]
func _ready() -> void:
	$cheshire.add_stack($area_3d_0/camera_3d, $chessboard_blank_0)
	$cheshire.move_camera($area_3d_0/camera_3d)
	$chessboard_blank_0.connect("move_played", $pastor.receive_move)
	$pastor.connect("send_initial_state", $chessboard_blank_0.set_state)
	$pastor.connect("decided_move", $chessboard_blank_0.execute_move)
	$pastor.connect("send_opponent_move", $chessboard_blank_0.set_valid_move)
	$pastor.create_state(fen[0])
	$pastor.depth = 20
	$pastor.evaluation = EvaluationMaze
	$pastor.start_decision()
