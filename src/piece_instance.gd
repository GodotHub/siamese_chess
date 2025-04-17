extends Node3D
class_name PieceInstance

var chessboard:Chessboard = null
var chessboard_name:String = ""
var position_name:String = ""

func _ready() -> void:
	chessboard = Chess.get_current_chessboard()
	if !chessboard:
		return
	if position_name:
		position = chessboard.convert_name_to_position(position_name)
	else:
		position_name = chessboard.get_position_name(position)
		position = chessboard.convert_name_to_position(position_name)

func move(_position_name:String) -> void:
	position_name = _position_name
	position = chessboard.convert_name_to_position(position_name)
