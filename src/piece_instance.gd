extends Node3D
class_name PieceInstance

var chessboard:Chessboard = null
var chessboard_name:String = ""
var position_name:String = ""
var group:int = 0

func _ready() -> void:
	chessboard = Chess.get_current_chessboard()
	if !chessboard:
		return
	if position_name:
		position = chessboard.convert_name_to_position(position_name)
	else:
		position_name = chessboard.get_position_name(position)
		position = chessboard.convert_name_to_position(position_name)
		
	var material:StandardMaterial3D = StandardMaterial3D.new()
	if group == 1:
		material.albedo_color = Color(0, 0, 0, 1)
	else:
		material.albedo_color = Color(1, 1, 1, 1)
	$piece.set_surface_override_material(0, material)

func move(_position_name:String) -> void:
	position_name = _position_name
	position = chessboard.convert_name_to_position(position_name)
