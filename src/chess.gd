extends Node

var pieces:Dictionary[String, Dictionary] = {
	"test": {
		"e8": {
			"class": "king"
		}
	}
}
var current_chessboard:Chessboard = null

func change_chessboard(next:String) -> void:
	if is_instance_valid(current_chessboard):
		current_chessboard.queue_free()
	var packed_scene:PackedScene = load("res://scene/chessboard_%s.tscn" % next)
	current_chessboard = packed_scene.instantiate()
	get_tree().root.add_child(current_chessboard)

func get_current_chessboard() -> Chessboard:
	return current_chessboard
  
func set_current_chessboard(_chessboard:Chessboard) -> void:
	current_chessboard = _chessboard

func get_piece_instance(chessboard_name:String, position_name:String) -> PieceInstance:
	var piece:PieceInstance = null
	if pieces[chessboard_name][position_name].has("instance"):
		return pieces[chessboard_name][position_name]["instance"]
	var packed_scene:PackedScene = load("res://scene/piece_%s.tscn" % pieces[chessboard_name][position_name]["class"])
	piece = packed_scene.instantiate()
	piece.chessboard_name = chessboard_name
	piece.position_name = position_name
	pieces[chessboard_name][position_name]["instance"] = piece
	return piece

func get_piece(chessboard_name:String, position_name:String) -> Dictionary:	# 不允许直接获得对象本身
	return pieces[chessboard_name][position_name]

func get_pieces_in_chessboard(chessboard_name:String) -> Dictionary:
	return pieces[chessboard_name]

func move_piece(chessboard_name:String, from:String, to:String) -> void:
	var piece_data:Dictionary = pieces[chessboard_name][from]
	pieces[chessboard_name].erase(from)
	pieces[chessboard_name][to] = piece_data
	if pieces[chessboard_name][to].has("instance"):
		var instance:PieceInstance = pieces[chessboard_name][to]["instance"]
		instance.move(to)

func has_piece(chessboard_name:String, position_name:String) -> bool:
	return pieces.has(chessboard_name) && pieces[chessboard_name].has(position_name)

func is_navi_valid(chessboard_name:String, position_name_from:String, position_name_to:String) -> bool:
	if has_piece(chessboard_name, position_name_from):
		return call("is_navi_valid_" + pieces[chessboard_name][position_name_from]["class"], position_name_from, position_name_to)
	return false 

func execute_navi(chessboard_name:String, position_name_from:String, position_name_to:String) -> void:
	if is_navi_valid(chessboard_name, position_name_from, position_name_to):
		call("execute_navi_" + pieces[chessboard_name][position_name_from]["class"], chessboard_name, position_name_from, position_name_to)

func is_navi_valid_king(position_name_from:String, position_name_to:String) -> bool:
	var position_name_from_buffer:PackedByteArray = position_name_from.to_ascii_buffer()
	var position_name_to_buffer:PackedByteArray = position_name_to.to_ascii_buffer()
	var position_from:Vector2i = Vector2i(position_name_from_buffer[0] - 97, position_name_from_buffer[1] - 49)
	var position_to:Vector2i = Vector2i(position_name_to_buffer[0] - 97, position_name_to_buffer[1] - 49)
	var distance:float = position_from.distance_squared_to(position_to)
	return distance == 1 || distance == 2

func execute_navi_king(chessboard_name:String, position_name_from:String, position_name_to:String) -> void:
	Chess.move_piece(chessboard_name, position_name_from, position_name_to)
