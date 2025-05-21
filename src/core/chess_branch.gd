extends Object
class_name ChessBranch

func alphabeta(_state:ChessState, alpha:float, beta:float, depth:int = 5, group:int = 0) -> float:
	if depth <= 0:	# 底端
		return _state.score

	var move_to_state:Dictionary[Move, ChessState] = {}
	var move_list:Array[Move] = []
	if group == 0:
		# 空着裁剪
		var null_move_value:float = alphabeta(_state, beta - 1, beta, depth - 1 - 3, 1)
		if null_move_value >= beta:
			return beta

		move_list = _state.get_all_move(group)
		var value:float = -10000
		for iter:Move in move_list:
			var test_state:ChessState = _state.duplicate()
			test_state.execute_move(iter)
			move_to_state[iter] = test_state
		move_list.sort_custom(func(a:Move, b:Move) -> bool: return move_to_state[a].score > move_to_state[b].score)
		for iter:Move in move_list:
			value = max(value, alphabeta(move_to_state[iter], alpha, beta, depth - 1, 1))
			alpha = max(alpha, value)
			if beta <= alpha:
				break
		return value
	else:
		# 空着裁剪
		var null_move_value:float = alphabeta(_state, alpha, alpha + 1, depth - 1 - 3, 0)
		if null_move_value <= alpha:
			return alpha

		move_list = _state.get_all_move(group)
		var value:float = 10000
		for iter:Move in move_list:
			var test_state:ChessState = _state.duplicate()
			test_state.execute_move(iter)
			move_to_state[iter] = test_state
		move_list.sort_custom(func(a:Move, b:Move) -> bool: return move_to_state[a].score < move_to_state[b].score)
		for iter:Move in move_list:
			value = min(value, alphabeta(move_to_state[iter], alpha, beta, depth - 1, 0))
			beta = min(beta, value)
			if beta <= alpha:
				break
		return value

func search(state:ChessState, depth:int = 10, group:int = 0) -> Dictionary:
	var move_list:Array[Move] = state.get_all_move(group)
	var output:Dictionary[String, float] = {}
	for iter:Move in move_list:
		var test_state:ChessState = state.duplicate()
		test_state.execute_move(iter)
		var valid_check:float = alphabeta(test_state, -10000, 10000, 1, 1 if group == 0 else 0)	# 下一步被吃就说明这一步不合法
		if abs(valid_check) >= 500:
			continue
		output[iter.stringify()] = alphabeta(test_state, -10000, 10000, depth - 1, 1 if group == 0 else 0)
	return output
