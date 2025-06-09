extends Evaluation
class_name EvaluationMaze

static func evaluate_events(_state:ChessState, _events:Array[ChessEvent]) -> int:
	# 白方起点h8，黑方起点a8
	var sum:int = 0
	for iter:ChessEvent in _events:
		if iter is ChessEvent:
			var piece_position_from:Vector2i = Chess.to_piece_position(iter.position_name_from)
			var piece_position_to:Vector2i = Chess.to_piece_position(iter.position_name_to)
			if _state.get_piece(iter.position_name_from).group == 0:
				sum += piece_position_to.x - piece_position_from.x
				sum += piece_position_from.y - piece_position_to.y
			else:
				sum += piece_position_from.x - piece_position_to.x
				sum += piece_position_to.y - piece_position_from.y
	return sum

static func search(_state:ChessState, _depth:int = 10, _group:int = 0) -> Dictionary:
	return {}
