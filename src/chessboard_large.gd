extends Chessboard
class_name ChessboardLarge
# 这个large指的是多个棋盘拼凑在一块的意思

var next_chessboard:Array[ChessboardLarge] = []

func create_next_chessboard() -> ChessboardLarge:
	var new_chessboard:ChessboardLarge = load("res://scene/chessboard_large.tscn").instantiate()
	next_chessboard.push_back(new_chessboard)
	new_chessboard.state = State.new()
	new_chessboard.next_chessboard.push_back(self)
	return new_chessboard

func tap_position(position_name:String) -> void:
	super.tap_position(position_name)
	for iter:ChessboardLarge in next_chessboard:
		iter.other_tap_position(self, position_name)

func other_tap_position(chessboard:ChessboardLarge, position_name:String) -> void:
	var to:int = Chess.to_position_int(position_name)
	if selected != -1 && !chessboard.state.has_piece(to):
		move_piece_instance_to_other_chessboard(selected, to, chessboard)

func move_piece_instance_to_other_chessboard(from:int, to:int, other:ChessboardLarge) -> void:
	var instance_from:Actor = chessboard_piece[from]
	instance_from.get_parent().remove_child(instance_from)
	chessboard_piece.erase(from)
	other.add_piece_instance(instance_from)
	other.state.add_piece(to, state.get_piece(from))
	state.capture_piece(from)
