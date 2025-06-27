extends Evaluation
class_name EvaluationStandard	# 接口

const WIN:int = 50000
const THRESHOLD:int = 20000

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
	"K": {"instance": "res://scene/piece_king.tscn", "group": 0},
	"Q": {"instance": "res://scene/piece_queen.tscn", "group": 0},
	"R": {"instance": "res://scene/piece_rook.tscn", "group": 0},
	"N": {"instance": "res://scene/piece_knight.tscn", "group": 0},
	"B": {"instance": "res://scene/piece_bishop.tscn", "group": 0},
	"P": {"instance": "res://scene/piece_pawn.tscn", "group": 0},
	"k": {"instance": "res://scene/piece_king.tscn", "group": 1},
	"q": {"instance": "res://scene/piece_queen.tscn", "group": 1},
	"r": {"instance": "res://scene/piece_rook.tscn", "group": 1},
	"n": {"instance": "res://scene/piece_knight.tscn", "group": 1},
	"b": {"instance": "res://scene/piece_bishop.tscn", "group": 1},
	"p": {"instance": "res://scene/piece_pawn.tscn", "group": 1},
}

static func parse(fen:String) -> ChessState:
	var state:ChessState = ChessState.new()
	state.evaluation = EvaluationStandard
	state.pieces.resize(128)
	state.pieces.fill(0)
	var pointer:Vector2i = Vector2i(0, 0)
	var fen_splited:PackedStringArray = fen.split(" ")
	if fen_splited.size() < 6:
		return null
	for i:int in range(fen_splited[0].length()):
		if fen_splited[0][i] == "/":
			pointer.x = 0
			pointer.y += 1
		elif fen_splited[0][i].is_valid_int():
			pointer.x += fen_splited[0][i].to_int()
		elif fen_splited[0][i]:
			state.add_piece(pointer.x + pointer.y * 16, fen_splited[0].unicode_at(i))
			pointer.x += 1
	if pointer.x != 8 || pointer.y != 7:
		return null
	if !(fen_splited[1] in ["w", "b"]):
		return null
	if !fen_splited[4].is_valid_int():
		return null
	if !fen_splited[5].is_valid_int():
		return null
	state.reserve_extra(6)
	state.set_extra(0, 0 if fen_splited[1] == "w" else 1)
	state.set_extra(1, (int(fen_splited[2].contains("K")) << 3) + (int(fen_splited[2].contains("Q")) << 2) + (int(fen_splited[2].contains("k")) << 1) + int(fen_splited[2].contains("q")))
	state.set_extra(2, Chess.to_int(fen_splited[3]))
	state.set_extra(3, fen_splited[4].to_int())
	state.set_extra(4, fen_splited[5].to_int())
	return state

static func stringify(_state:ChessState) -> String:
	var null_counter:int = 0
	var chessboard:PackedStringArray = []
	for i:int in range(8):
		var line:String = ""
		for j:int in range(8):
			if _state.pieces[i * 16 + j]:
				if null_counter:
					line += "%d" % null_counter
					null_counter = 0
				line += char(_state.pieces[i * 16 + j])
			else:
				null_counter += 1
		if null_counter:
			line += "%d" % null_counter
			null_counter = 0
		chessboard.append(line)
	var output:PackedStringArray = ["/".join(chessboard)]
	output.push_back("w" if _state.get_extra(0) == 0 else "b")
	output.push_back(("K" if _state.get_extra(1) & 8 else "") + ("Q" if _state.get_extra(1) & 4 else "") + ("k" if _state.get_extra(1) & 2 else "") + ("q" if _state.get_extra(1) & 1 else "") if _state.get_extra(1) else "-")
	output.push_back(Chess.to_position_name(_state.get_extra(2)) if _state.get_extra(2) else "-")
	output.push_back("%d" % _state.get_extra(3))
	output.push_back("%d" % _state.get_extra(4))
	# king_passant是为了判定是否违规走子，临时记录的，这里不做转换
	return " ".join(output)

static func get_end_type(_state:ChessState) -> String:
	var group:int = _state.extra[0]
	var move_list:PackedInt32Array = get_valid_move(_state, group)
	if !move_list.size():
		var null_move_check:int = alphabeta(_state, -WIN, WIN, 1, 1 - group)
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
	if _state.history.get(_state.zobrist, 0) == 3:
		return "threefold_repetition"	# 三次重复局面
	if _state.get_extra(3) == 50:
		return "50_moves"
	return ""

static func is_same_camp(piece_1:int, piece_2:int) -> bool:
	return (piece_1 >= 65 && piece_1 <= 90) == (piece_2 >= 65 && piece_2 <= 90)

static func get_piece_instance(by:int, piece:int) -> PieceInstance:
	var packed_scene:PackedScene = load(piece_mapping[char(piece)]["instance"])
	var instance:PieceInstance = packed_scene.instantiate()
	instance.position_name = Chess.to_position_name(by)
	instance.group = piece_mapping[char(piece)]["group"]
	return instance

static func generate_premove(_state:ChessState, _group:int) -> PackedInt32Array:
	var output:PackedInt32Array = []
	for _from_1:int in range(8):
		for _from_2:int in range(8):
			var _from:int = (_from_1 << 4) + _from_2
			if !_state.has_piece(_from):
				continue
			var from_piece:int = _state.get_piece(_from)
			if (_group == 0) != (from_piece >= 65 && from_piece <= 90):
				continue
			var directions:PackedInt32Array
			if from_piece & 95 == 80:
				var front:int = -16 if from_piece == 80 else 16
				var on_start:bool = _from / 16 == (6 if from_piece == 80 else 1)
				var on_end:bool = _from / 16 == (1 if from_piece == 80 else 16)
				if on_end:
					output.push_back(Move.create(_from, _from + front, 81 if from_piece == 80 else 113))
					output.push_back(Move.create(_from, _from + front, 82 if from_piece == 80 else 114))
					output.push_back(Move.create(_from, _from + front, 78 if from_piece == 80 else 110))
					output.push_back(Move.create(_from, _from + front, 66 if from_piece == 80 else 98))
					if !((_from + front + 1) & 0x88):
						output.push_back(Move.create(_from, _from + front + 1, 81 if from_piece == 80 else 113))
						output.push_back(Move.create(_from, _from + front + 1, 82 if from_piece == 80 else 114))
						output.push_back(Move.create(_from, _from + front + 1, 78 if from_piece == 80 else 110))
						output.push_back(Move.create(_from, _from + front + 1, 66 if from_piece == 80 else 98))

					if !((_from + front - 1) & 0x88):
						output.push_back(Move.create(_from, _from + front - 1, 81 if from_piece == 80 else 113))
						output.push_back(Move.create(_from, _from + front - 1, 82 if from_piece == 80 else 114))
						output.push_back(Move.create(_from, _from + front - 1, 78 if from_piece == 80 else 110))
						output.push_back(Move.create(_from, _from + front - 1, 66 if from_piece == 80 else 98))
				else:
					output.push_back(Move.create(_from, _from + front, 0))
					if !((_from + front + 1) & 0x88):
						output.push_back(Move.create(_from, _from + front + 1, 0))
					if !((_from + front - 1) & 0x88):
						output.push_back(Move.create(_from, _from + front - 1, 0))
					if on_start:
						output.push_back(Move.create(_from, _from + front + front, 0))
				continue
			elif from_piece & 95 == 75 || from_piece & 95 == 81:
				directions = directions_eight_way
			elif from_piece & 95 == 82:
				directions = directions_straight
			elif from_piece & 95 == 78:
				directions = directions_horse
			elif from_piece & 95 == 66:
				directions = directions_diagonal

			for iter:int in directions:
				var to:int = _from + iter
				while !(to & 0x88):
					output.push_back(Move.create(_from, to, 0))
					if from_piece & 95 == 75 || from_piece & 95 == 78:
						break
					to += iter
	if _group == 0 && _state.get_extra(1) & 8 && !_state.has_piece(Chess.g1) && !_state.has_piece(Chess.f1):
		output.push_back(Move.create(Chess.e1, Chess.g1, 75))
	if _group == 0 && _state.get_extra(1) & 4 && !_state.has_piece(Chess.c1) && !_state.has_piece(Chess.d1):
		output.push_back(Move.create(Chess.e1, Chess.c1, 81))
	if _group == 1 && _state.get_extra(1) & 2 && !_state.has_piece(Chess.g8) && !_state.has_piece(Chess.f8):
		output.push_back(Move.create(Chess.e8, Chess.g8, 75))
	if _group == 1 && _state.get_extra(1) & 1 && !_state.has_piece(Chess.c8) && !_state.has_piece(Chess.d8):
		output.push_back(Move.create(Chess.e8, Chess.c8, 81))
	return output

static func generate_move(_state:ChessState, _group:int) -> PackedInt32Array:
	var output:PackedInt32Array = []
	for _from_1:int in range(8):
		for _from_2:int in range(8):
			var _from:int = (_from_1 << 4) + _from_2
			if !_state.has_piece(_from):
				continue
			var from_piece:int = _state.get_piece(_from)
			if (_group == 0) != (from_piece >= 65 && from_piece <= 90):
				continue
			var directions:PackedInt32Array
			if from_piece & 95 == 80:
				var front:int = -16 if _group == 0 else 16
				var on_start:bool = _from / 16 == (6 if _group == 0 else 1)
				var on_end:bool = _from / 16 == (1 if _group == 0 else 6)
				if !_state.has_piece(_from + front):
					if on_end:
						output.push_back(Move.create(_from, _from + front, 81 if _group == 0 else 113))
						output.push_back(Move.create(_from, _from + front, 82 if _group == 0 else 114))
						output.push_back(Move.create(_from, _from + front, 78 if _group == 0 else 110))
						output.push_back(Move.create(_from, _from + front, 66 if _group == 0 else 98))
					else:
						output.push_back(Move.create(_from, _from + front, 0))
						if !_state.has_piece(_from + front + front) && on_start:
							output.push_back(Move.create(_from, _from + front + front, 0))
				if _state.has_piece(_from + front + 1) && !is_same_camp(from_piece, _state.get_piece(_from + front + 1)) || (_from / 16 == 2 || _from / 16 == 5) && _state.get_extra(2) == _from + front + 1:
					if on_end:
						output.push_back(Move.create(_from, _from + front + 1, 81 if _group == 0 else 113))
						output.push_back(Move.create(_from, _from + front + 1, 82 if _group == 0 else 114))
						output.push_back(Move.create(_from, _from + front + 1, 78 if _group == 0 else 110))
						output.push_back(Move.create(_from, _from + front + 1, 66 if _group == 0 else 98))
					else:
						output.push_back(Move.create(_from, _from + front + 1, 0))
				if _state.has_piece(_from + front - 1) && !is_same_camp(from_piece, _state.get_piece(_from + front - 1)) || (_from / 16 == 2 || _from / 16 == 5) && _state.get_extra(2) == _from + front - 1:
					if on_end:
						output.push_back(Move.create(_from, _from + front - 1, 81 if _group == 0 else 113))
						output.push_back(Move.create(_from, _from + front - 1, 82 if _group == 0 else 114))
						output.push_back(Move.create(_from, _from + front - 1, 78 if _group == 0 else 110))
						output.push_back(Move.create(_from, _from + front - 1, 66 if _group == 0 else 98))
					else:
						output.push_back(Move.create(_from, _from + front - 1, 0))
				continue
			elif from_piece & 95 == 75 || from_piece & 95 == 81:
				directions = directions_eight_way
			elif from_piece & 95 == 82:
				directions = directions_straight
			elif from_piece & 95 == 78:
				directions = directions_horse
			elif from_piece & 95 == 66:
				directions = directions_diagonal

			for iter:int in directions:
				var to:int = _from + iter
				var to_piece:int = _state.get_piece(to)
				while !(to & 0x88) && (!to_piece || !is_same_camp(from_piece, to_piece)):
					output.push_back(Move.create(_from, to, 0))
					if !(to & 0x88) && to_piece && !is_same_camp(from_piece, to_piece):
						break
					if from_piece & 95 == 75 || from_piece & 95 == 78:
						break
					to += iter
					to_piece = _state.get_piece(to)
					if !(from_piece == 82 && to_piece == 75 || from_piece == 114 && to_piece == 107):
						continue
					if _from % 16 >= 4 && (from_piece == 82 && _state.get_extra(1) & 8 || from_piece == 114 && _state.get_extra(1) & 2):
						output.push_back(Move.create(to, Chess.g1 if from_piece == 82 else Chess.g8, 75))
					elif _from % 16 <= 3 && (from_piece == 82 && _state.get_extra(1) & 4 || from_piece == 114 && _state.get_extra(1) & 2):
						output.push_back(Move.create(to, Chess.c1 if from_piece == 82 else Chess.c8, 81))
	return output

static func apply_move(_state:ChessState, _move:int) -> void:
	_state.history.set(_state.zobrist, _state.history.get(_state.zobrist, 0) + 1)	# 上一步的局面
	if _state.extra[0] == 1:
		_state.set_extra(4, _state.get_extra(4) + 1)
		_state.set_extra(0, 0)
	elif _state.extra[0] == 0:
		_state.set_extra(0, 1)
	_state.set_extra(3, _state.get_extra(3) + 1)
	var from_piece:int = _state.get_piece(Move.from(_move))
	var from_group:int = 0 if from_piece >= 65 && from_piece <= 90 else 1	# 大写A到大写Z
	var to_piece:int = _state.get_piece(Move.to(_move))
	var dont_move:bool = false
	var has_en_passant:bool = false
	var has_king_passant:bool = false
	if to_piece:
		_state.capture_piece(Move.to(_move))
		_state.set_extra(3, 0)	# 吃子时重置50步和棋
	if abs(_state.get_extra(5) - Move.to(_move)) <= 1:
		if from_group == 0:
			if _state.get_piece(Chess.c8) == 107:
				_state.capture_piece(Chess.c8)
			if _state.get_piece(Chess.g8) == 107:
				_state.capture_piece(Chess.g8)
		else:
			if _state.get_piece(Chess.c1) == 75:
				_state.capture_piece(Chess.c1)
			if _state.get_piece(Chess.g1) == 75:
				_state.capture_piece(Chess.g1)

	if from_piece & 95 == 82:	#哪边的车动过，就不能往那个方向易位
		if Move.from(_move) % 16 >= 4:
			if from_group == 0:
				_state.set_extra(1, _state.get_extra(1) & 7)
			else:
				_state.set_extra(1, _state.get_extra(1) & 13)
		elif Move.from(_move) % 16 <= 3:
			if from_group == 0:
				_state.set_extra(1, _state.get_extra(1) & 11)
			else:
				_state.set_extra(1, _state.get_extra(1) & 14)

	if from_piece & 95 == 75:
		if from_group == 0:
			_state.set_extra(1, _state.get_extra(1) & 3)
		else:
			_state.set_extra(1, _state.get_extra(1) & 12)
		if Move.extra(_move):
			if Move.to(_move) == Chess.g1:
				_state.move_piece(Chess.h1, Chess.f1)
				_state.set_extra(5, Chess.f1)
			if Move.to(_move) == Chess.c1:
				_state.move_piece(Chess.a1, Chess.d1)
				_state.set_extra(5, Chess.d1)
			if Move.to(_move) == Chess.g8:
				_state.move_piece(Chess.h8, Chess.f8)
				_state.set_extra(5, Chess.f8)
			if Move.to(_move) == Chess.c8:
				_state.move_piece(Chess.a8, Chess.d8)
				_state.set_extra(5, Chess.d8)
			has_king_passant = true

	if from_piece & 95 == 80:
		var front:int = -16 if from_piece == 80 else 16
		_state.set_extra(3, 0)	# 移动兵时重置50步和棋
		if Move.to(_move) - Move.from(_move) == front * 2:
			has_en_passant = true
			_state.set_extra(2, Move.from(_move) + front)
		if (Move.from(_move) / 16 == 2 || Move.from(_move) / 16 == 5) && Move.to(_move) == _state.get_extra(2):
			var captured:int = Move.to(_move) - front
			_state.capture_piece(captured)
		if Move.extra(_move):
			dont_move = true
			_state.capture_piece(Move.from(_move))
			_state.add_piece(Move.to(_move), Move.extra(_move))

	if !dont_move:
		_state.move_piece(Move.from(_move), Move.to(_move))

	if !has_en_passant:
		_state.set_extra(2, -1)
	if !has_king_passant:
		_state.set_extra(5, -1)

static func get_piece_score(by:int, piece:int) -> int:
	var piece_position:Vector2i = Vector2(by % 16, by / 16)
	if piece_value.has(char(piece)):
		return position_value[char(piece)][piece_position.x + piece_position.y * 8] + piece_value[char(piece)]
	else:
		return 0

static func evaluate_add(_state:ChessState, by:int, piece:int) -> int:
	return get_piece_score(by, piece)

static func evaluate_move(state:ChessState, from:int, to:int) -> int:
	return get_piece_score(to, state.get_piece(from)) - get_piece_score(from, state.get_piece(from))

static func evaluate_capture(state:ChessState, by:int) -> int:
	return -get_piece_score(by, state.get_piece(by))

static func evaluate(state:ChessState, move:int) -> int:
	var from:int = Move.from(move)
	var from_piece:int = state.get_piece(from)
	var to:int = Move.to(move)
	var to_piece:int = state.get_piece(to)
	var extra:int = Move.extra(move)
	var group:int = 0 if (from >= 65 && from <= 90) else 1
	var score:int = get_piece_score(to, from_piece) - get_piece_score(from, from_piece)
	if to_piece && !is_same_camp(from_piece, to_piece):
		score -= get_piece_score(to_piece, to)
	if abs(state.get_extra(5) - Move.to(move)) <= 1:
		score -= piece_value["k" if group == 0 else "K"]
	if from_piece == "K".unicode_at(0) && extra != 0:
		score += get_piece_score("R".unicode_at(0), (from + to) / 2)
		score -= get_piece_score("R".unicode_at(0), Chess.a1 if to < from else Chess.h1)
	if from_piece == "k".unicode_at(0) && extra != 0:
		score += get_piece_score("r".unicode_at(0), (from + to) / 2)
		score -= get_piece_score("r".unicode_at(0), Chess.a8 if to < from else Chess.h8)
	if from_piece & 95 == "P".unicode_at(0):
		var front:int = -16 if group == 0 else 16
		if from / 16 == 0:
			score += get_piece_score(extra, to)
			score -= get_piece_score(from_piece, from)
		if to == state.get_extra(2):
			score -= get_piece_score("p".unicode_at(0), to - front)
	return score

static func is_check(_state:ChessState) -> bool:
	var score:float = alphabeta(_state, -THRESHOLD, THRESHOLD, 1, 1 - _state.get_extra(0))
	return abs(score) >= WIN

static func compare_move(a:int, b:int, _group:int, move_to_score:Dictionary, history_table:Dictionary) -> bool:
	if history_table.get(a, 0) != history_table.get(b, 0):
		return history_table.get(a, 0) > history_table.get(b, 0)
	return move_to_score[a] > move_to_score[b]

static func alphabeta(_state:ChessState, alpha:int, beta:int, depth:int = 5, group:int = 0, history_table:Dictionary[int, int] = {}, main_variation:PackedInt32Array = [], transposition_table:TranspositionTable = null, is_timeup:Callable = Callable()) -> int:
	if is_instance_valid(transposition_table):
		var score:int = transposition_table.probe_hash(_state.zobrist, depth, alpha, beta)
		if score != 65535:
			return score
	if depth <= 0:
		if is_instance_valid(transposition_table):
			transposition_table.record_hash(_state.zobrist, depth, _state.get_relative_score(group), TranspositionTable.Flag.EXACT)
		return _state.get_relative_score(group)

	if _state.history.has(_state.zobrist):
		return 0	# 视作平局，如果局面不太好，也不会选择负分的下法

	if is_timeup.is_valid() && is_timeup.call():
		return _state.get_relative_score(group)

	var line:PackedInt32Array = []
	var move_list:Array = []
	var flag:TranspositionTable.Flag = TranspositionTable.Flag.ALPHA
	var value:int = -WIN
	move_list = _state.get_all_move(group)
	move_list.sort_custom(func(a:int, b:int) -> bool: return history_table.get(a, 0) > history_table.get(b, 0))
	for iter:int in move_list:
		var test_state:ChessState = _state.duplicate()
		test_state.apply_move(iter)
		value = -alphabeta(test_state, -beta, -alpha, depth - 1, 1 - group, history_table, line, transposition_table, is_timeup)
		if beta <= value:
			if is_instance_valid(transposition_table):
				transposition_table.record_hash(_state.zobrist, depth, _state.get_relative_score(group), TranspositionTable.Flag.BETA)
			return beta
		if alpha < value:
			alpha = value
			flag = TranspositionTable.Flag.EXACT
			history_table[iter] = history_table.get(iter, 0) + (1 << depth)
			main_variation.clear()
			main_variation.push_back(iter)
			main_variation.append_array(line)
	if is_instance_valid(transposition_table):
		transposition_table.record_hash(_state.zobrist, depth, alpha, flag)
	return alpha

static func mtdf(state:ChessState, group:int, depth:int, history_table:Dictionary[int, int], main_variation:PackedInt32Array = [], transposition_table:TranspositionTable = null) -> int:
	var l:int = -WIN
	var r:int = WIN
	var m:int = 0
	var value:int = 0
	while l + 1 < r:
		m = (l + r) / 2
		if m <= 0 && l / 2 < m:
			m = l / 2
		elif m >= 0 && r / 2 > m:
			m = r / 2
		value = alphabeta(state, m, m + 1, depth, group, history_table, main_variation, transposition_table)
		if value <= m:
			r = m
		else:
			l = m
	return value

static func get_valid_move(state:ChessState, group:int) -> PackedInt32Array:
	var move_list:PackedInt32Array = state.get_all_move(group)
	var output:PackedInt32Array = []
	for iter:int in move_list:
		var test_state:ChessState = state.duplicate()
		test_state.apply_move(iter)
		var valid_check:int = alphabeta(test_state, -WIN, WIN, 1, 1 if group == 0 else 0)	# 下一步被吃就说明这一步不合法
		if abs(valid_check) < THRESHOLD:	# 合法阈值
			output.push_back(iter)
	return output

static func search(state:ChessState, group:int, main_variation:PackedInt32Array = [], transposition_table:TranspositionTable = null, is_timeup:Callable = Callable(), max_depth:int = 1000) -> void:
	# 迭代加深，并准备提前中断
	var history_table:Dictionary[int, int] = {}
	for i:int in range(1, max_depth, 1):
		#mtdf(state, group, i, history_table, main_variation, transposition_table)
		alphabeta(state, -WIN, WIN, i, group, history_table, main_variation, transposition_table, is_timeup)
