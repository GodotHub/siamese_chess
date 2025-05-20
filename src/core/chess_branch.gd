extends Object
class_name ChessBranch

func alphabeta(_state:ChessState, alpha:float, beta:float, depth:int = 5) -> float:
	if !depth:
		return _state.score
	var group:int = 0 if _state.extra[0] == "w" else 1
	var move_to_state:Dictionary[Move, ChessState] = {}
	var move_list:Array[Move] = []
	if group == 0:
		move_list = _state.get_all_move(group)
		var value:float = -10000
		for iter:Move in move_list:
			var test_state:ChessState = _state.duplicate()
			test_state.execute_move(iter)
			move_to_state[iter] = test_state
		move_list.sort_custom(func(a:Move, b:Move) -> bool: return move_to_state[a].score > move_to_state[b].score)
		for iter:Move in move_list:
			value = max(value, alphabeta(move_to_state[iter], alpha, beta, depth - 1))
			alpha = max(alpha, value)
			if beta <= alpha:
				break
		return value
	else:
		move_list = _state.get_all_move(group)
		var value:float = 10000
		for iter:Move in move_list:
			var test_state:ChessState = _state.duplicate()
			test_state.execute_move(iter)
			move_to_state[iter] = test_state
		move_list.sort_custom(func(a:Move, b:Move) -> bool: return move_to_state[a].score < move_to_state[b].score)
		for iter:Move in move_list:
			value = min(value, alphabeta(move_to_state[iter], alpha, beta, depth - 1))
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
