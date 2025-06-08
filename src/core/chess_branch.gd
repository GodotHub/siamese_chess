extends Object
class_name ChessBranch

static func alphabeta(_state:ChessState, score:float, alpha:float, beta:float, depth:int = 5, group:int = 0) -> float:
	if depth <= 0:	# 底端
		return score
	var move_list:PackedInt32Array = []
	var move_value:Dictionary[Move, float] = {}
	var move_event:Dictionary[Move, Array] = {}
	if group == 0:
		# 空着裁剪
		var null_move_value:float = alphabeta(_state, score, beta - 1, beta, depth - 4, 1)
		if null_move_value >= beta:
			return beta

		move_list = _state.get_all_move(group)
		for iter:Move in move_list:
			move_event[iter] = _state.create_event(iter, true)
			move_value[iter] = Evaluation.evaluate_events(_state, move_event[iter])
		var value:float = -10000
		move_list.sort_custom(func(a:Move, b:Move) -> bool: return move_value[a] > move_value[b])
		for iter:Move in move_list:
			_state.apply_event(move_event[iter])
			value = max(value, alphabeta(_state, score + move_value[iter], alpha, beta, depth - 1, 1))
			_state.rollback_event(move_event[iter])
			alpha = max(alpha, value)
			if beta <= alpha:
				break
		return value
	else:
		# 空着裁剪
		var null_move_value:float = alphabeta(_state, score, alpha, alpha + 1, depth - 4, 0)
		if null_move_value <= alpha:
			return alpha

		move_list = _state.get_all_move(group)
		for iter:Move in move_list:
			move_event[iter] = _state.create_event(iter, true)
			move_value[iter] = EvaluationStandard.evaluate_events(_state, move_event[iter])
		var value:float = 10000
		move_list.sort_custom(func(a:Move, b:Move) -> bool: return move_value[a] < move_value[b])
		for iter:Move in move_list:
			_state.apply_event(move_event[iter])
			value = min(value, alphabeta(_state, score + move_value[iter], alpha, beta, depth - 1, 0))
			_state.rollback_event(move_event[iter])
			beta = min(beta, value)
			if beta <= alpha:
				break
		return value

static func search(state:ChessState, depth:int = 10, group:int = 0) -> Dictionary:
	var move_list:PackedInt32Array = state.get_all_move(group)
	var output:Dictionary[String, float] = {}
	var test_state:ChessState = state.duplicate()	# 复制状态防止修改时出现异常
	for iter:Move in move_list:
		var events:Array[ChessEvent] = test_state.create_event(iter, true)
		var score:float = EvaluationStandard.evaluate_events(test_state, events)
		test_state.apply_event(events)
		var valid_check:float = alphabeta(test_state, score, -10000, 10000, 1, 1 if group == 0 else 0)	# 下一步被吃就说明这一步不合法
		if abs(valid_check) >= 500:
			test_state.rollback_event(events)
			continue
		output[iter.stringify()] = alphabeta(test_state, score, -10000, 10000, depth - 1, 1 if group == 0 else 0)
		test_state.rollback_event(events)
	return output
