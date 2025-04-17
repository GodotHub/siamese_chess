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

func get_piece(chessboard:String, position_name:String) -> Dictionary:	# 不允许直接获得对象本身
	return pieces[chessboard][position_name]

func get_pieces_in_chessboard(chessboard:String) -> Dictionary:
	return pieces[chessboard]

func move_piece(chessboard:String, from:String, to:String) -> void:
	var piece_data:Dictionary = pieces[chessboard][from]
	pieces[chessboard].erase(from)
	pieces[chessboard][to] = piece_data
