extends Object
class_name ChessBranch

var history:Array[String] = []

func alphabeta(_state:ChessState, alpha:float, beta:float, depth:int = 5) -> float:
	if !depth:
		return _state.score
	var group:int = 0 if _state.extra[0] == "w" else 1
	if group == 0:
		var move_list:Array[Move] = _state.get_all_move(group)
		var value:float = -10000
		for iter:Move in move_list:
			var test_state:ChessState = _state.duplicate()
			test_state.execute_move(iter)
			value = max(value, alphabeta(test_state, alpha, beta, depth - 1))
			alpha = max(alpha, value)
			if beta <= alpha:
				break
		return value
	else:
		var move_list:Array[Move] = _state.get_all_move(group)
		var value:float = 10000
		for iter:Move in move_list:
			var test_state:ChessState = _state.duplicate()
			test_state.execute_move(iter)
			value = min(value, alphabeta(test_state, alpha, beta, depth - 1))
			beta = min(beta, value)
			if beta <= alpha:
				break
		return value

func search(state:ChessState, depth:int = 10) -> Dictionary:
	var group:int = 0 if state.extra[0] == "w" else 1
	var move_list:Array[Move] = state.get_all_move(group)
	var output:Dictionary[String, float] = {}
	for iter:Move in move_list:
		var test_state:ChessState = state.duplicate()
		test_state.execute_move(iter)
		output[iter.stringify()] = alphabeta(test_state, -10000, 10000, depth - 1)
	return output
