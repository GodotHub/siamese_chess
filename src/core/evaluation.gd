extends Object
class_name Evaluation	# 接口

const piece_value:Dictionary[String, float] = {
	"King": 600.0,
	"Queen": 9.29,
	"Rook": 4.79,
	"Bishop": 3.2,
	"Knight": 2.8,
	"Pawn": 1,
}

const position_value:Dictionary[String, Array] = {
	"King": [
	  4,  54,  47, -99, -99,  60,  83, -62,
	-32,  10,  55,  56,  56,  55,  10,   3,
	-62,  12, -57,  44, -67,  28,  37, -31,
	-55,  50,  11,  -4, -19,  13,   0, -49,
	-55, -43, -52, -28, -51, -47,  -8, -50,
	-47, -42, -43, -79, -64, -32, -29, -32,
	 -4,   3, -14, -50, -57, -18,  13,   4,
	 17,  30,  -3, -14,   6,  -1,  40,  18
	],
	"Queen": [
	  6,   1,  -8,-104,  69,  24,  88,  26,
	 14,  32,  60, -10,  20,  76,  57,  24,
	 -2,  43,  32,  60,  72,  63,  43,   2,
	  1, -16,  22,  17,  25,  20, -13,  -6,
	-14, -15,  -2,  -5,  -1, -10, -20, -22,
	-30,  -6, -13, -11, -16, -11, -16, -27,
	-36, -18,   0, -19, -15, -15, -21, -38,
	-39, -30, -31, -13, -31, -36, -34, -42
	],
	"Rook": [
	 35,  29,  33,   4,  37,  33,  56,  50,
	 55,  29,  56,  67,  55,  62,  34,  60,
	 19,  35,  28,  33,  45,  27,  25,  15,
	  0,   5,  16,  13,  18,  -4,  -9,  -6,
	-28, -35, -16, -21, -13, -29, -46, -30,
	-42, -28, -42, -25, -25, -35, -26, -46,
	-53, -38, -31, -26, -29, -43, -44, -53,
	-30, -24, -18,   5,  -2, -18, -31, -32
	],
	"Bishop": [
	-59, -78, -82, -76, -23,-107, -37, -50,
	-11,  20,  35, -42, -39,  31,   2, -22,
	 -9,  39, -32,  41,  52, -10,  28, -14,
	 25,  17,  20,  34,  26,  25,  15,  10,
	 13,  10,  17,  23,  17,  16,   0,   7,
	 14,  25,  24,  15,   8,  25,  20,  15,
	 19,  20,  11,   6,   7,   6,  20,  16,
	 -7,   2, -15, -12, -14, -15, -10, -10
	],
	"Knight": [
	-66, -53, -75, -75, -10, -55, -58, -70,
	 -3,  -6, 100, -36,   4,  62,  -4, -14,
	 10,  67,   1,  74,  73,  27,  62,  -2,
	 24,  24,  45,  37,  33,  41,  25,  17,
	 -1,   5,  31,  21,  22,  35,   2,   0,
	-18,  10,  13,  22,  18,  15,  11, -14,
	-23, -15,   2,   0,   2,   0, -23, -20,
	-74, -23, -26, -24, -19, -35, -22, -69
	],
	"Pawn": [
	  0,   0,   0,   0,   0,   0,   0,   0,
	 78,  83,  86,  73, 102,  82,  85,  90,
	  7,  29,  21,  44,  40,  31,  44,   7,
	-17,  16,  -2,  15,  14,   0,  15, -13,
	-26,   3,  10,   9,   6,   1,   0, -23,
	-22,   9,   5, -11, -10,  -2,   3, -19,
	-31,   8,  -7, -37, -36, -14,   3, -31,
	  0,   0,   0,   0,   0,   0,   0,   0
	]
}
static func get_piece_score(position_name:String, piece:Piece) -> float:
	var piece_position:Vector2i = Chess.to_piece_position(position_name)
	var group:int = piece.group
	if group == 1:
		piece_position.y = 7 - piece_position.y
	if piece_value.has(piece.class_type.get_name()):
		return (position_value[piece.class_type.get_name()][piece_position.x + (7 - piece_position.y) * 8] / 100.0 + piece_value[piece.class_type.get_name()]) * (1 if group == 0 else -1)
	else:
		return (1 if group == 0 else -1)	# 未知棋子，在某种规则下出现了未知的棋子，我们可以特别处理未知的棋子

static func evaluate_events(state:ChessState, events:Array[ChessEvent]) -> float:
	var score:float = 0
	for iter:ChessEvent in events:
		if iter is ChessEvent.AddPiece:
			score += get_piece_score(iter.position_name, iter.piece)
		if iter is ChessEvent.MovePiece:
			score += get_piece_score(iter.position_name_to, state.get_piece(iter.position_name_from)) - get_piece_score(iter.position_name_from, state.get_piece(iter.position_name_from))
		if iter is ChessEvent.CapturePiece:
			score -= get_piece_score(iter.position_name, iter.piece)
	return score
