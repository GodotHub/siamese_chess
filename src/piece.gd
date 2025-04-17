extends Node3D
class_name Piece

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
	

func receive_navi(position_name_to:String) -> void:
	Chess.move_piece(chessboard_name, position_name, position_name_to)
	position_name = position_name_to
