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

func get_piece_instance(chessboard_name:String, position_name:String) -> Piece:
	var piece:Piece = null
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
		var instance:Piece = pieces[chessboard_name][to]["instance"]
		instance.move(to)

func has_piece(chessboard_name:String, position_name:String) -> bool:
	return pieces.has(chessboard_name) && pieces[chessboard_name].has(position_name)
