extends Node3D
class_name Chessboard

var navi:Array[String] = []	# 线条是有排序的，总结下来只有四个字符：起点和终点
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
		var piece:Piece = Chess.get_piece_instance(chessboard_name, key)
		$pieces.add_child(piece)

func get_position_name(_position:Vector3) -> String:
	var chess_pos:Vector2i = Vector2i(int(_position.x + 4) / 1, int(_position.z + 4) / 1)
	return "%c%d" % [chess_pos.x + 97, chess_pos.y + 1]

func convert_name_to_position(_name:String) -> Vector3:
	return get_node(_name).position

func start_drawing_navi(position_name:String) -> void:
	$canvas.start_drawing($canvas.convert_name_to_position(position_name))
	navi.push_back(position_name)

func drawing_navi(position_name:String) -> void:
	$canvas.drawing_straight($canvas.convert_name_to_position(position_name))
	navi[-1] = navi[-1].substr(0, 2) + position_name

func end_drawing_navi() -> void:
	$canvas.end_drawing()

func cancel_drawing_navi() -> void:
	$canvas.cancel_drawing()
	navi.pop_back()

func check_piece() -> void:
	pass

func confirm() -> void:
	if !navi.size():
		return
	var position_name_1:String = navi[0].substr(0, 2)
	var position_name_2:String = navi[0].substr(2)
	if Chess.has_piece(chessboard_name, position_name_1):
		Chess.get_piece_instance(chessboard_name, position_name_1).receive_navi(position_name_2)
	navi.pop_front()
