extends Evaluation
class_name EvaluationStandard	# 接口

const piece_value:Dictionary[String, int] = {
	"K": 60000,
	"Q": 929,
	"R": 479,
	"B": 320,
	"N": 280,
	"P": 100,
	"k": -60000,
	"q": -929,
	"r": -479,
	"b": -320,
	"n": -280,
	"p": -100,
}

const directions_diagonal:PackedInt32Array = [-17, -15, 15, 17]
const directions_straight:PackedInt32Array = [-16, -1, 1, 16]
const directions_eight_way:PackedInt32Array = [-17, -16, -15, -1, 1, 15, 16, 17]
const directions_horse:PackedInt32Array = [33, 31, 18, 14, -33, -31, -18, -14]

const position_value:Dictionary[String, Array] = {
	"K": [
	  4,  54,  47, -99, -99,  60,  83, -62,
	-32,  10,  55,  56,  56,  55,  10,   3,
	-62,  12, -57,  44, -67,  28,  37, -31,
	-55,  50,  11,  -4, -19,  13,   0, -49,
	-55, -43, -52, -28, -51, -47,  -8, -50,
	-47, -42, -43, -79, -64, -32, -29, -32,
	 -4,   3, -14, -50, -57, -18,  13,   4,
	 17,  30,  -3, -14,   6,  -1,  40,  18
	],
	"Q": [
	  6,   1,  -8,-104,  69,  24,  88,  26,
	 14,  32,  60, -10,  20,  76,  57,  24,
	 -2,  43,  32,  60,  72,  63,  43,   2,
	  1, -16,  22,  17,  25,  20, -13,  -6,
	-14, -15,  -2,  -5,  -1, -10, -20, -22,
	-30,  -6, -13, -11, -16, -11, -16, -27,
	-36, -18,   0, -19, -15, -15, -21, -38,
	-39, -30, -31, -13, -31, -36, -34, -42
	],
	"R": [
	 35,  29,  33,   4,  37,  33,  56,  50,
	 55,  29,  56,  67,  55,  62,  34,  60,
	 19,  35,  28,  33,  45,  27,  25,  15,
	  0,   5,  16,  13,  18,  -4,  -9,  -6,
	-28, -35, -16, -21, -13, -29, -46, -30,
	-42, -28, -42, -25, -25, -35, -26, -46,
	-53, -38, -31, -26, -29, -43, -44, -53,
	-30, -24, -18,   5,  -2, -18, -31, -32
	],
	"B": [
	-59, -78, -82, -76, -23,-107, -37, -50,
	-11,  20,  35, -42, -39,  31,   2, -22,
	 -9,  39, -32,  41,  52, -10,  28, -14,
	 25,  17,  20,  34,  26,  25,  15,  10,
	 13,  10,  17,  23,  17,  16,   0,   7,
	 14,  25,  24,  15,   8,  25,  20,  15,
	 19,  20,  11,   6,   7,   6,  20,  16,
	 -7,   2, -15, -12, -14, -15, -10, -10
	],
	"N": [
	-66, -53, -75, -75, -10, -55, -58, -70,
	 -3,  -6, 100, -36,   4,  62,  -4, -14,
	 10,  67,   1,  74,  73,  27,  62,  -2,
	 24,  24,  45,  37,  33,  41,  25,  17,
	 -1,   5,  31,  21,  22,  35,   2,   0,
	-18,  10,  13,  22,  18,  15,  11, -14,
	-23, -15,   2,   0,   2,   0, -23, -20,
	-74, -23, -26, -24, -19, -35, -22, -69
	],
	"P": [
	  0,   0,   0,   0,   0,   0,   0,   0,
	 78,  83,  86,  73, 102,  82,  85,  90,
	  7,  29,  21,  44,  40,  31,  44,   7,
	-17,  16,  -2,  15,  14,   0,  15, -13,
	-26,   3,  10,   9,   6,   1,   0, -23,
	-22,   9,   5, -11, -10,  -2,   3, -19,
	-31,   8,  -7, -37, -36, -14,   3, -31,
	  0,   0,   0,   0,   0,   0,   0,   0
	],
	"k": [
	 17, -30,   3,  14,  -6,   1, -40, -18,
	  4,  -3,  14,  50,  57,  18, -13,  -4,
	 47,  42,  43,  79,  64,  32,  29,  32,
	 55,  43,  52,  28,  51,  47,   8,  50,
	 55, -50, -11,   4,  19, -13,   0,  49,
	 62, -12,  57, -44,  67, -28, -37,  31,
	 32, -10, -55, -56, -56, -55, -10,  -3,
	 -4, -54, -47,  99,  99, -60, -83,  62,
	],
	"q": [
	 39,  30,  31,  13,  31,  36,  34,  42,
	 36,  18,   0,  19,  15,  15,  21,  38,
	 30,   6,  13,  11,  16,  11,  16,  27,
	 14,  15,   2,   5,   1,  10,  20,  22,
	 -1,  16, -22, -17, -25, -20,  13,   6,
	  2, -43, -32, -60, -72, -63, -43,  -2,
	-14, -32, -60,  10, -20, -76, -57, -24,
	 -6,  -1,   8, 104, -69, -24, -88, -26
	],
	"r": [
	 30,  24,  18,  -5,   2,  18,  31,  32,
	 53,  38,  31,  26,  29,  43,  44,  53,
	 42,  28,  42,  25,  25,  35,  26,  46,
	 28,  35,  16,  21,  13,  29,  46,  30,
	  0,  -5, -16, -13, -18,   4,   9,   6,
	-19, -35, -28, -33, -45, -27, -25, -15,
	-55, -29, -56, -67, -55, -62, -34, -60,
	-35, -29, -33,  -4, -37, -33, -56, -50,
	],
	"b": [
	  7,  -2,  15,  12,  14,  15,  10,  10,
	-19, -20, -11,  -6,  -7,  -6, -20, -16,
	-14, -25, -24, -15,  -8, -25, -20, -15,
	-13, -10, -17, -23, -17, -16,   0,  -7,
	-25, -17, -20, -34, -26, -25, -15, -10,
	  9, -39,  32, -41, -52,  10, -28,  14,
	 11, -20, -35,  42,  39, -31,  -2,  22,
	 59,  78,  82,  76,  23, 107,  37,  50,
	],
	"n": [
	 74,  23,  26,  24,  19,  35,  22,  69,
	 23,  15,  -2,   0,  -2,   0,  23,  20,
	 18, -10, -13, -22, -18, -15, -11,  14,
	  1,  -5, -31, -21, -22, -35,  -2,   0,
	-24, -24, -45, -37, -33, -41, -25, -17,
	-10, -67,  -1, -74, -73, -27, -62,   2,
	  3,   6,-100,  36,  -4, -62,   4,  14,
	 66,  53,  75,  75,  10,  55,  58,  70,
	],
	"p": [
	  0,   0,   0,   0,   0,   0,   0,   0,
	 31,  -8,   7,  37,  36,  14,  -3,  31,
	 22,  -9,  -5,  11,  10,   2,  -3,  19,
	 26,  -3, -10,  -9,  -6,  -1,   0,  23,
	 17, -16,   2, -15, -14,   0, -15,  13,
	 -7, -29, -21, -44, -40, -31, -44,  -7,
	-78, -83, -86, -73,-102, -82, -85, -90,
	  0,   0,   0,   0,   0,   0,   0,   0,
	]
}

const piece_mapping:Dictionary = {
	"K": {"instance": "res://scene/piece_intstance_king.tscn", "group": 0},
	"Q": {"instance": "res://scene/piece_intstance_queen.tscn", "group": 0},
	"R": {"instance": "res://scene/piece_intstance_rook.tscn", "group": 0},
	"N": {"instance": "res://scene/piece_intstance_knight.tscn", "group": 0},
	"B": {"instance": "res://scene/piece_intstance_bishop.tscn", "group": 0},
	"P": {"instance": "res://scene/piece_intstance_pawn.tscn", "group": 0},
	"k": {"instance": "res://scene/piece_intstance_king.tscn", "group": 1},
	"q": {"instance": "res://scene/piece_intstance_queen.tscn", "group": 1},
	"r": {"instance": "res://scene/piece_intstance_rook.tscn", "group": 1},
	"n": {"instance": "res://scene/piece_intstance_knight.tscn", "group": 1},
	"b": {"instance": "res://scene/piece_intstance_bishop.tscn", "group": 1},
	"p": {"instance": "res://scene/piece_intstance_pawn.tscn", "group": 1},
}

static func get_end_type(_state:ChessState) -> String:
	var group:int = 0 if _state.extra[0] == "w" else 1
	var move_list:Dictionary = search(_state, 1, group)
	if move_list.size() == 0:
		var null_move_check:int = alphabeta(_state, 0, -10000, 10000, 1, 1 - group)
		if abs(null_move_check) >= 500:
			if group == 0:
				return "checkmate_black"
			else:
				return "checkmate_white"
		else:
			if group == 0:
				return "stalemate_black"
			else:
				return "stalemate_white"
	return ""

static func is_same_camp(piece_1:int, piece_2:int) -> bool:
	return (piece_1 >= "A".unicode_at(0) && piece_1 <= "Z".unicode_at(0)) == (piece_2 >= "A".unicode_at(0) && piece_2 <= "Z".unicode_at(0))

static func get_piece_instance(by:int, piece:int) -> PieceInstance:
	var packed_scene:PackedScene = load(piece_mapping[char(piece)]["instance"])
	var instance:PieceInstance = packed_scene.instantiate()
	instance.position_name = Chess.to_position_name(by)
	instance.group = piece_mapping[char(piece)]["group"]
	return instance

static func generate_move(_state:ChessState, _group:int) -> PackedInt32Array:
	var output:PackedInt32Array = []
	for _from:int in range(128):
		if !_state.get_piece(_from):
			continue
		var from_piece:int = _state.get_piece(_from)
		var directions:PackedInt32Array
		if char(from_piece) in "KQkq":
			directions = directions_eight_way
		elif char(from_piece) in "Rr":
			directions = directions_straight
		elif char(from_piece) in "Nn":
			directions = directions_horse
		elif char(from_piece) in "Bb":
			directions = directions_diagonal

		for iter:int in directions:
			var to:int = _from + iter
			var to_has_piece:bool = _state.has_piece(to)
			var to_piece:int = _state.get_piece(to)
			while !(to & 0x88) && (!to_has_piece || !is_same_camp(from_piece, to_piece)):
				output.push_back(Move.create(_from, to, 0))
				if !(to & 0x88) && to_has_piece && !is_same_camp(from_piece, to_piece):
					break
				if char(from_piece) in "KkNn":
					break
				to += iter
				to_has_piece = _state.has_piece(to)
				to_piece = _state.get_piece(to)
	return output

static func get_piece_score(by:int, piece:int) -> int:
	var piece_position:Vector2i = Vector2(by % 16, by / 16)
	if piece_value.has(char(piece)):
		return position_value[char(piece)][piece_position.x + piece_position.y * 8] + piece_value[char(piece)]
	else:
		return 0

static func evaluate_events(state:ChessState, events:Array[ChessEvent]) -> int:
	var score:int = 0
	for iter:ChessEvent in events:
		if iter is ChessEvent.AddPiece:
			score += get_piece_score(iter.by, iter.piece)
		if iter is ChessEvent.MovePiece:
			score += get_piece_score(iter.to, state.get_piece(iter.from)) - get_piece_score(iter.from, state.get_piece(iter.from))
		if iter is ChessEvent.CapturePiece:
			score -= get_piece_score(iter.by, iter.piece)
	return score

static func alphabeta(_state:ChessState, score:int, alpha:int, beta:int, depth:int = 5, group:int = 0, _memorize:bool = true) -> int:
	#var flag:TranspositionTable.Flag = TranspositionTable.Flag.UNKNOWN
	#if memorize:
	#	var stored_score:int = TranspositionTable.probe_hash(_state.zobrist, depth, alpha, beta)
	#	if stored_score != 65535:
	#		return stored_score
	if depth <= 0:	# 底端
	#	TranspositionTable.record_hash(_state.zobrist, depth, score, TranspositionTable.Flag.EXACT)
		return score
	var move_list:Array = []
	var move_value:Dictionary[int, int] = {}
	var move_event:Dictionary[int, Array] = {}
	if group == 0:
		# 空着裁剪
		#flag = TranspositionTable.Flag.ALPHA
		var null_move_value:int = alphabeta(_state, score, beta - 1, beta, depth - 4, 1)
		if null_move_value >= beta:
			#TranspositionTable.record_hash(_state.zobrist, depth, beta, TranspositionTable.Flag.BETA)
			return beta

		move_list = _state.get_all_move(group)
		for iter:int in move_list:
			move_event[iter] = _state.create_event(iter)
			move_value[iter] = evaluate_events(_state, move_event[iter])
		var value:int = -10000
		move_list.sort_custom(func(a:int, b:int) -> bool: return move_value[a] > move_value[b])
		for iter:int in move_list:
			_state.apply_event(move_event[iter])
			value = max(value, alphabeta(_state, score + move_value[iter], alpha, beta, depth - 1, 1))
			_state.rollback_event(move_event[iter])
			if beta <= value:
				#TranspositionTable.record_hash(_state.zobrist, depth, beta, TranspositionTable.Flag.BETA)
				return beta
			if alpha < value:
				#flag = TranspositionTable.Flag.EXACT
				alpha = value
		#TranspositionTable.record_hash(_state.zobrist, depth, value, flag)
		return value
	else:
		#flag = TranspositionTable.Flag.BETA
		# 空着裁剪
		var null_move_value:int = alphabeta(_state, score, alpha, alpha + 1, depth - 4, 0)
		if null_move_value <= alpha:
			#TranspositionTable.record_hash(_state.zobrist, depth, alpha, TranspositionTable.Flag.ALPHA)
			return alpha

		move_list = _state.get_all_move(group)
		for iter:int in move_list:
			move_event[iter] = _state.create_event(iter)
			move_value[iter] = evaluate_events(_state, move_event[iter])
		var value:int = 10000
		move_list.sort_custom(func(a:int, b:int) -> bool: return move_value[a] < move_value[b])
		for iter:int in move_list:
			_state.apply_event(move_event[iter])
			value = min(value, alphabeta(_state, score + move_value[iter], alpha, beta, depth - 1, 0))
			_state.rollback_event(move_event[iter])
			if alpha >= value:
				#TranspositionTable.record_hash(_state.zobrist, depth, alpha, TranspositionTable.Flag.ALPHA)
				return alpha
			if beta > value:
				#flag = TranspositionTable.Flag.EXACT
				beta = value
		#TranspositionTable.record_hash(_state.zobrist, depth, value, flag)
		return value

static func mtdf(state:ChessState, score:int, depth:int, group:int) -> int:
	var l:int = -2000
	var r:int = 2000
	var m:int = 0
	var value:int = 0
	while l + 1 < r:
		m = (l + r) / 2
		if m <= 0 && l / 2 < m:
			m = l / 2
		elif m >= 0 && r / 2 > m:
			m = r / 2
		value = alphabeta(state, score, m, m + 1, depth, group)
		if value <= m:
			r = m
		else:
			l = m
	return value

static func search(state:ChessState, depth:int = 10, group:int = 0) -> Dictionary:
	var move_list:PackedInt32Array = state.get_all_move(group)
	var output:Dictionary[int, int] = {}
	var test_state:ChessState = state.duplicate()	# 复制状态防止修改时出现异常
	for iter:int in move_list:
		var events:Array[ChessEvent] = test_state.create_event(iter)
		var score:int = EvaluationStandard.evaluate_events(test_state, events)
		test_state.apply_event(events)
		var valid_check:int = alphabeta(test_state, score, -200000, 200000, 1, 1 if group == 0 else 0, false)	# 下一步被吃就说明这一步不合法
		if abs(valid_check) < 50000:
			output[iter] = 0
		test_state.rollback_event(events)
	for key:int in output:
		var events:Array[ChessEvent] = test_state.create_event(key)
		var score:int = EvaluationStandard.evaluate_events(test_state, events)
		test_state.apply_event(events)
		#output[key] = mtdf(test_state, score, depth, 1 if group == 0 else 0)
		output[key] = alphabeta(test_state, score, -200000, 200000, depth - 1, 1 if group == 0 else 0)
		test_state.rollback_event(events)
	return output
