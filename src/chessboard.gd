extends Node3D
class_name Chessboard

var chessboard_name:String = "test"

func _ready() -> void:
	Chess.set_current_chessboard(self)	# 调试用：直接运行棋盘场景时设置当前位置
	$player.connect("tap_position", tap_position)
	$player.connect("confirm_navi", confirm_navi)
	$player.connect("finger_on_position", finger_on_position)
	$player.connect("finger_up", finger_up)
	var pieces:Dictionary = Chess.get_chess_state().current
	for key:String in pieces:
		var piece:PieceInstance = Chess.get_chess_state().get_piece_instance(key)
		$pieces.add_child(piece)

func get_position_name(_position:Vector3) -> String:
	var chess_pos:Vector2i = Vector2i(int(_position.x + 4) / 1, int(_position.z + 4) / 1)
	return "%c%d" % [chess_pos.x + 97, chess_pos.y + 1]

func convert_name_to_position(_name:String) -> Vector3:
	return get_node(_name).position

func tap_position(position_name:String) -> void:
	$canvas.clear_points()
	if !Chess.get_chess_state().has_piece(position_name):
		return
	for i:int in range(8):
		for j:int in range(8):
			var _position_name_to = "%c%d" % [i + 97, j + 1]
			if Chess.get_chess_state().is_navi_valid(position_name, _position_name_to):
				$canvas.draw_point($canvas.convert_name_to_position(_position_name_to))

func finger_on_position(position_name:String) -> void:
	pass

func finger_up() -> void:
	pass

func confirm_navi(position_name_from:String, position_name_to:String) -> void:
	if !position_name_from || !position_name_to || !Chess.get_chess_state().is_navi_valid(position_name_from, position_name_to):
		return
	Chess.get_chess_state().execute_navi(position_name_from, position_name_to)
	$canvas.clear_points()
