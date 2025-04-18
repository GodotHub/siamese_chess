extends Node3D
class_name Chessboard

var position_name_from:String = ""
var position_name_to:String = ""
var chessboard_name:String = "test"

func _ready() -> void:
	Chess.set_current_chessboard(self)	# 调试用：直接运行棋盘场景时设置当前位置
	$player.connect("start_drawing_navi", start_drawing_navi)
	$player.connect("drawing_navi", drawing_navi)
	$player.connect("end_drawing_navi", end_drawing_navi)
	$player.connect("cancel_drawing_navi", cancel_drawing_navi)
	$player.connect("confirm", confirm)
	var pieces:Dictionary = Chess.get_pieces_in_chessboard(chessboard_name)
	for key:String in pieces:
		var piece:PieceInstance = Chess.get_piece_instance(chessboard_name, key)
		$pieces.add_child(piece)

func get_position_name(_position:Vector3) -> String:
	var chess_pos:Vector2i = Vector2i(int(_position.x + 4) / 1, int(_position.z + 4) / 1)
	return "%c%d" % [chess_pos.x + 97, chess_pos.y + 1]

func convert_name_to_position(_name:String) -> Vector3:
	return get_node(_name).position

func start_drawing_navi(position_name:String) -> void:
	$canvas.clear_lines()
	if !Chess.has_piece(chessboard_name, position_name):
		return
	position_name_from = position_name
	$canvas.start_drawing($canvas.convert_name_to_position(position_name))
	for i:int in range(8):
		for j:int in range(8):
			var _position_name_to = "%c%d" % [i + 97, j + 1]
			if Chess.is_navi_valid(chessboard_name, position_name, _position_name_to):
				$canvas.draw_point($canvas.convert_name_to_position(_position_name_to))

func drawing_navi(position_name:String) -> void:
	if !position_name_from:
		return
	if !Chess.is_navi_valid(chessboard_name, position_name_from, position_name):
		return
	$canvas.drawing_straight($canvas.convert_name_to_position(position_name))
	position_name_to = position_name

func end_drawing_navi() -> void:
	$canvas.end_drawing()
	$canvas.clear_points()

func cancel_drawing_navi() -> void:
	$canvas.cancel_drawing()

func check_piece() -> void:
	pass

func confirm() -> void:
	if !position_name_from || !position_name_to:
		return
	Chess.execute_navi(chessboard_name, position_name_from, position_name_to)
	position_name_from = ""
	position_name_to = ""
	$canvas.clear_lines()
