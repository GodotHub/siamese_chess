extends Object
class_name Evaluation	# 接口

static func get_piece_score(_position_name:String, _piece:Piece) -> float:
	return 0

static func evaluate_events(_state:ChessState, _events:Array[ChessEvent]) -> float:
	return 0